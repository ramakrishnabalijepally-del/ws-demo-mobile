import 'dart:math' as math;

import '../models/candidate.dart';
import '../models/crs_profile.dart';
import 'clb_conversion.dart';
import 'pnp_calculator.dart';

/// Whether a provincial stream lines up with the candidate's profile.
///
/// **This is derived, never stored.** It used to be a `matched: true` flag
/// written beside each stream, which meant the answer was fixed at the moment
/// the fixture was typed: filling in a language test, a degree or a year of
/// work moved the CRS score and the provincial grids, and left every stream
/// verdict exactly where it was.
///
/// The three rungs are the design system's own state ladder, and the middle
/// one is the honest one. Most provincial requirements turn on things the CRS
/// profile deliberately does not collect — a job offer, an occupation code, an
/// address in the province — so a profile alone cannot say yes. It can say
/// "everything I can check is met, and here is what I cannot check", which is
/// [StreamFit.potential].
///
/// **Nothing here reads "ineligible".** A requirement the profile fails is
/// reported as the specific gap, because a nomination, a French result or a
/// year of work can change it.
enum StreamFit {
  /// Every requirement the profile can answer is met, and none are unknown.
  good('Good Match'),

  /// Everything checkable is met, but something cannot be assessed from a
  /// profile.
  potential('Potential Match'),

  /// Something the profile *can* answer is not met yet.
  explore('Explore Further');

  const StreamFit(this.label);

  /// The product's fixed verdict wording. Never invent a fourth.
  final String label;
}

/// A requirement that a candidate profile cannot answer, named so the reader
/// is told what is missing rather than simply refused.
enum StreamUnknown {
  jobOffer('a job offer from an employer in the province'),
  occupationList('an occupation on the province\'s in-demand list'),
  livingInProvince('living in the province already'),
  studiedInProvince('a qualifying credential from the province'),
  targetedDraw('the criteria of whichever draw is running'),
  connectionToProvince('a relative, or past work or study, in the province');

  const StreamUnknown(this.description);

  final String description;
}

/// A stream's published requirements, in the form the app can check them.
///
/// Every field here is read straight off the stream's own requirement list —
/// this is the same rule written so a computer can evaluate it, not a new one.
class StreamCriteria {
  const StreamCriteria({
    this.minClb,
    this.minEducation,
    this.minCrs,
    this.minWorkYears,
    this.minCanadianWorkYears,
    this.needsFrench,
    this.needsCanadianEducation = false,
    this.provincialGridCode,
    this.unknowns = const <StreamUnknown>[],
  });

  /// Lowest CLB across the four abilities, in the stronger official language.
  final int? minClb;

  final EducationLevel? minEducation;

  /// A floor the province publishes for Express Entry draws.
  final int? minCrs;

  /// Skilled work, Canadian and foreign together.
  final int? minWorkYears;

  final int? minCanadianWorkYears;

  /// A minimum in French specifically, for the Quebec streams.
  final int? needsFrench;

  /// A credential from a Canadian institution. The profile collects this, so
  /// it is a gap rather than an unknown.
  final bool needsCanadianEducation;

  /// The province code whose published grid has a pass mark this stream must
  /// clear — 'SK' is the only one of the four that sets one.
  final String? provincialGridCode;

  /// What no profile can answer.
  final List<StreamUnknown> unknowns;
}

/// How a stream sits against this profile, and why.
class StreamAssessment {
  const StreamAssessment({
    required this.fit,
    required this.gaps,
    required this.unknowns,
  });

  final StreamFit fit;

  /// Requirements the profile answers and does not meet, each phrased as the
  /// thing that would close it.
  final List<String> gaps;

  /// Requirements no profile can answer.
  final List<StreamUnknown> unknowns;

  bool get lines => fit != StreamFit.explore;
}

int _lowestClb(LanguageResult? result) =>
    result == null ? 0 : clbFor(result).all.reduce(math.min);

/// The stronger official language, as every provincial grid reads it.
int _bestClb(CrsProfile p) =>
    math.max(_lowestClb(p.englishTest), _lowestClb(p.frenchTest));

/// Assesses one stream against one profile.
StreamAssessment assessStream(
  Candidate candidate,
  StreamCriteria criteria, {
  List<PnpScore>? grids,
  int? crsTotal,
}) {
  final p = candidate.crs;
  final gaps = <String>[];

  final minClb = criteria.minClb;
  if (minClb != null) {
    if (p.englishTest == null && p.frenchTest == null) {
      gaps.add('a language test result — this stream asks for CLB $minClb');
    } else if (_bestClb(p) < minClb) {
      gaps.add('CLB $minClb across all four abilities');
    }
  }

  final needsFrench = criteria.needsFrench;
  if (needsFrench != null && _lowestClb(p.frenchTest) < needsFrench) {
    gaps.add('NCLC $needsFrench in French');
  }

  final minEducation = criteria.minEducation;
  if (minEducation != null) {
    final education = p.education;
    if (education == null) {
      gaps.add('your highest qualification, which this stream sets at '
          '${minEducation.label.toLowerCase()}');
    } else if (education.index < minEducation.index) {
      gaps.add(minEducation.label.toLowerCase());
    }
  }

  final minCrs = criteria.minCrs;
  if (minCrs != null && crsTotal != null && crsTotal < minCrs) {
    gaps.add('a CRS score of $minCrs — yours is $crsTotal');
  }

  final minWorkYears = criteria.minWorkYears;
  if (minWorkYears != null) {
    final years = (p.canadianWorkYears ?? 0) + (p.foreignWorkYears ?? 0);
    if (years < minWorkYears) {
      gaps.add('$minWorkYears year${minWorkYears == 1 ? '' : 's'} of skilled '
          'work experience');
    }
  }

  final minCanadian = criteria.minCanadianWorkYears;
  if (minCanadian != null && (p.canadianWorkYears ?? 0) < minCanadian) {
    gaps.add('$minCanadian year${minCanadian == 1 ? '' : 's'} of skilled work '
        'in Canada');
  }

  if (criteria.needsCanadianEducation &&
      (p.canadianEducation ?? CanadianEducation.none) ==
          CanadianEducation.none) {
    gaps.add('a credential from a Canadian institution');
  }

  final gridCode = criteria.provincialGridCode;
  if (gridCode != null && grids != null) {
    for (final grid in grids) {
      final passMark = grid.passMark;
      if (grid.code != gridCode || passMark == null) continue;
      if (grid.total < passMark) {
        gaps.add('$passMark points on the ${grid.province} grid — you are on '
            '${grid.total}');
      }
    }
  }

  if (gaps.isNotEmpty) {
    return StreamAssessment(
      fit: StreamFit.explore,
      gaps: gaps,
      unknowns: criteria.unknowns,
    );
  }
  return StreamAssessment(
    fit: criteria.unknowns.isEmpty ? StreamFit.good : StreamFit.potential,
    gaps: const <String>[],
    unknowns: criteria.unknowns,
  );
}
