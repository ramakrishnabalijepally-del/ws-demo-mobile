import 'dart:math' as math;

import '../models/candidate.dart';
import '../models/crs_profile.dart';
import 'clb_conversion.dart';
import 'crs_calculator.dart';

/// Provincial Nominee Program points, from the same candidate profile as the
/// CRS.
///
/// Four provinces rank candidates on a published points grid:
///
/// - **Alberta** — AAIP Worker Expression of Interest, out of 100.
/// - **British Columbia** — BC PNP Skills Immigration Registration System
///   (SIRS), out of 200.
/// - **Saskatchewan** — SINP International Skilled Worker assessment grid, out
///   of 110, with a pass mark of 60.
/// - **Manitoba** — MPNP Skilled Worker Expression of Interest, out of 1,000.
///
/// Grids checked September 2026 against each province's published grid (the
/// AAIP grid as revised 29 January 2025).
///
/// Family, work and study in a province and a job offer are asked on the PNP
/// status screen ([ProvincialFactors]) and scored below.
///
/// **What is still not asked is scored as zero and listed in
/// [PnpScore.notCounted]** — sector endorsements, regional bonuses, a friend
/// in Manitoba. The score is therefore a floor, and every card says so rather
/// than implying it is complete.
// TODO(backend): grids change. The real rules come from the versioned rules
// service, with their effective date, not from constants in the app.

class PnpLine {
  const PnpLine(this.label, this.points, this.maximum);

  final String label;
  final int points;
  final int maximum;
}

class PnpScore {
  const PnpScore({
    required this.code,
    required this.province,
    required this.program,
    required this.lines,
    required this.maximum,
    required this.notCounted,
    this.passMark,
  });

  /// Two-letter province code, for the flag and the streams route.
  final String code;
  final String province;
  final String program;
  final List<PnpLine> lines;
  final int maximum;

  /// The minimum to be eligible, where the province sets one.
  final int? passMark;

  /// Factors worth points that the profile does not collect yet.
  final List<String> notCounted;

  /// Manitoba's risk factor can go negative; a total never shows below zero.
  int get total =>
      math.max(0, lines.fold<int>(0, (sum, line) => sum + line.points));
}

List<PnpScore> calculatePnpScores(Candidate candidate, {DateTime? today}) {
  final birth = candidate.birthDate;
  final age = birth == null ? null : ageOn(birth, today ?? DateTime.now());
  final p = candidate.crs;
  final languages = _Languages.of(p);
  final workYears = (p.canadianWorkYears ?? 0) + (p.foreignWorkYears ?? 0);
  final hasWork = p.canadianWorkYears != null || p.foreignWorkYears != null;
  final ties = _Ties.of(p);

  return [
    _alberta(p, age, languages, workYears, hasWork, ties),
    _britishColumbia(p, languages, workYears, ties),
    _saskatchewan(p, age, languages, workYears, ties),
    _manitoba(p, age, languages, workYears, ties),
  ];
}

/// The provincial answers, with unanswered sets read as empty and study
/// dropped when the profile has no Canadian post-secondary education.
class _Ties {
  const _Ties({
    required this.f,
    required this.family,
    required this.immediate,
    required this.worked,
    required this.studied,
    required this.canadianStudy,
  });

  factory _Ties.of(CrsProfile p) {
    final f = p.provincial;
    final immediate = f.immediateFamily ?? const <ProvinceTie>{};
    return _Ties(
      f: f,
      immediate: immediate,
      family: {...immediate, ...?f.extendedFamily},
      worked: f.workedIn ?? const {},
      studied: p.studiedInCanada ? f.studiedIn ?? const {} : const {},
      canadianStudy: p.studiedInCanada,
    );
  }

  final ProvincialFactors f;

  /// Immediate and extended family together — Saskatchewan and Manitoba.
  final Set<ProvinceTie> family;

  /// Parent, sibling or child only — Alberta.
  final Set<ProvinceTie> immediate;
  final Set<ProvinceTie> worked;
  final Set<ProvinceTie> studied;
  final bool canadianStudy;

  bool offerIn(ProvinceTie province) => f.jobOffer == province;

  /// Anywhere in Canada other than [province].
  static bool _outside(Set<ProvinceTie> set, ProvinceTie province) =>
      set.any((tie) => tie != province && tie != ProvinceTie.none);

  bool workedOutside(ProvinceTie province) => _outside(worked, province);
  bool studiedOutside(ProvinceTie province) => _outside(studied, province);
}

/// A Canadian certificate of qualification in a trade scores as its own
/// education level on three grids; the better of the two counts.
int _withTrade(CrsProfile p, int level, int trade) =>
    math.max(level, p.certificateOfQualification == true ? trade : 0);

/// The stronger of the two official languages is scored as the first, as
/// every one of these grids does.
class _Languages {
  const _Languages(this.first, this.second);

  /// The lowest CLB across the four abilities, or null with no test.
  final int? first;
  final int? second;

  /// The whole result for the first language, for per-ability grids.
  static ClbLevels? firstLevels(CrsProfile p) {
    final en = p.englishTest == null ? null : clbFor(p.englishTest!);
    final fr = p.frenchTest == null ? null : clbFor(p.frenchTest!);
    if (en == null) return fr;
    if (fr == null) return en;
    return _lowest(en) >= _lowest(fr) ? en : fr;
  }

  static _Languages of(CrsProfile p) {
    final en = p.englishTest == null ? null : _lowest(clbFor(p.englishTest!));
    final fr = p.frenchTest == null ? null : _lowest(clbFor(p.frenchTest!));
    if (en == null) return _Languages(fr, null);
    if (fr == null) return _Languages(en, null);
    return en >= fr ? _Languages(en, fr) : _Languages(fr, en);
  }

  static int _lowest(ClbLevels levels) => levels.all.reduce(math.min);

  bool get bilingualAt4 => (first ?? 0) >= 4 && (second ?? 0) >= 4;
}

PnpScore _alberta(
  CrsProfile p,
  int? age,
  _Languages lang,
  int workYears,
  bool hasWork,
  _Ties t,
) {
  final education = _withTrade(
    p,
    switch (p.education) {
      EducationLevel.doctoral => 12,
      EducationLevel.masters => 10,
      EducationLevel.bachelors ||
      EducationLevel.twoOrMore ||
      EducationLevel.twoYear =>
        7,
      EducationLevel.oneYear => 4,
      _ => 0,
    },
    7,
  );
  final studyPlace =
      t.studied.contains(ProvinceTie.alberta) ? 10 : (t.canadianStudy ? 6 : 0);

  // Alberta scores French lower than English at every level.
  int? lowest(LanguageResult? result) =>
      result == null ? null : clbFor(result).all.reduce(math.min);
  final english = switch (lowest(p.englishTest)) {
    null => 0,
    >= 6 => 10,
    5 => 8,
    4 => 5,
    _ => 0,
  };
  final french = switch (lowest(p.frenchTest)) {
    null => 0,
    >= 6 => 8,
    5 => 5,
    4 => 3,
    _ => 0,
  };

  final workPlace = t.worked.contains(ProvinceTie.alberta)
      ? 10
      : (t.worked.isNotEmpty || (p.canadianWorkYears ?? 0) >= 1 ? 6 : 0);
  final offer = t.offerIn(ProvinceTie.alberta);

  return PnpScore(
    code: 'AB',
    province: 'Alberta',
    program: 'AAIP Worker EOI',
    maximum: 100,
    lines: [
      PnpLine('Education', education + studyPlace, 22),
      PnpLine(
        'Language',
        math.max(english, french) + (lang.bilingualAt4 ? 3 : 0),
        13,
      ),
      PnpLine(
        'Work experience',
        (!hasWork ? 0 : (workYears >= 1 ? 11 : 3)) + workPlace,
        21,
      ),
      PnpLine(
        'Age',
        switch (age) {
          null => 0,
          < 18 => 0,
          <= 20 => 3,
          <= 34 => 5,
          <= 49 => 4,
          _ => 3,
        },
        5,
      ),
      // Since 29 January 2025, a parent, sibling or child only.
      PnpLine(
        'Family in Alberta',
        t.immediate.contains(ProvinceTie.alberta) ? 8 : 0,
        8,
      ),
      PnpLine('Alberta job offer', offer ? 10 : 0, 16),
      PnpLine(
        'Job outside Calgary and Edmonton',
        offer && t.f.albertaJobOutsideCities == true ? 5 : 0,
        5,
      ),
      PnpLine(
        'Regulated occupation or designated trade',
        offer && t.f.albertaJobRegulated == true ? 10 : 0,
        10,
      ),
    ],
    notCounted: const [
      'A Rural Renewal, tourism or law-enforcement endorsement (+6)',
    ],
  );
}

PnpScore _britishColumbia(
  CrsProfile p,
  _Languages lang,
  int workYears,
  _Ties t,
) {
  // Whole years only, so under a year reads as none: a floor, not a guess.
  final experience = switch (workYears) {
    >= 5 => 20,
    4 => 16,
    3 => 12,
    2 => 8,
    1 => 4,
    _ => 0,
  };
  final offer = t.offerIn(ProvinceTie.britishColumbia);
  final education = switch (p.education) {
    EducationLevel.doctoral => 27,
    EducationLevel.masters => 22,
    EducationLevel.twoOrMore || EducationLevel.bachelors => 15,
    EducationLevel.twoYear || EducationLevel.oneYear => 5,
    _ => 0,
  };
  final studyPlace = t.studied.contains(ProvinceTie.britishColumbia)
      ? 8
      : (t.canadianStudy ? 6 : 0);
  final language = switch (lang.first) {
    null => 0,
    >= 9 => 30,
    8 => 25,
    7 => 20,
    6 => 15,
    5 => 10,
    4 => 5,
    _ => 0,
  };
  // One point per dollar from $16, up to 55 at $70 and above.
  final wage = t.f.bcHourlyWage;
  final wagePoints =
      offer && wage != null ? (wage.floor() - 15).clamp(0, 55) : 0;
  final area = !offer
      ? 0
      : switch (t.f.bcArea) {
          BcArea.area2 => 5,
          BcArea.elsewhere => 15,
          _ => 0,
        };

  return PnpScore(
    code: 'BC',
    province: 'British Columbia',
    program: 'BC PNP Skills Immigration (SIRS)',
    maximum: 200,
    lines: [
      PnpLine(
        'Work experience',
        experience +
            ((p.canadianWorkYears ?? 0) >= 1 ? 10 : 0) +
            (offer && t.f.workingForEmployer == true ? 10 : 0),
        40,
      ),
      PnpLine(
        'Education',
        math.min(
          40,
          education +
              studyPlace +
              (p.certificateOfQualification == true ? 5 : 0),
        ),
        40,
      ),
      PnpLine('Language', language + (lang.bilingualAt4 ? 10 : 0), 40),
      PnpLine('Wage of the job offer', wagePoints, 55),
      PnpLine('Area of employment', area, 25),
    ],
    notCounted: const [
      'Regional experience or alumni status outside Metro Vancouver (+10)',
      'Whether your work experience is directly related to the job offer',
    ],
  );
}

PnpScore _saskatchewan(
  CrsProfile p,
  int? age,
  _Languages lang,
  int workYears,
  _Ties t,
) {
  final education = _withTrade(
    p,
    switch (p.education) {
      EducationLevel.doctoral || EducationLevel.masters => 23,
      EducationLevel.bachelors || EducationLevel.twoOrMore => 20,
      EducationLevel.twoYear => 15,
      EducationLevel.oneYear => 12,
      _ => 0,
    },
    20,
  );
  // The profile records the last 10 years as one number, so the most recent
  // five are filled first and anything beyond counts as six to ten years ago.
  final recent = math.min(workYears, 5);
  final earlier = math.min(math.max(workYears - 5, 0), 5);
  const recentPoints = [0, 2, 4, 6, 8, 10];
  const earlierPoints = [0, 0, 2, 3, 4, 5];

  int languagePoints(int? clb, List<int> table) => switch (clb) {
        null => 0,
        >= 8 => table[0],
        7 => table[1],
        6 => table[2],
        5 => table[3],
        4 => table[4],
        _ => 0,
      };

  return PnpScore(
    code: 'SK',
    province: 'Saskatchewan',
    program: 'SINP International Skilled Worker',
    maximum: 110,
    passMark: 60,
    lines: [
      PnpLine('Education and training', education, 23),
      PnpLine(
        'Skilled work experience',
        recentPoints[recent] + earlierPoints[earlier],
        15,
      ),
      PnpLine(
        'Language',
        languagePoints(lang.first, const [20, 18, 16, 14, 12]) +
            languagePoints(lang.second, const [10, 8, 6, 4, 2]),
        30,
      ),
      PnpLine(
        'Age',
        switch (age) {
          null => 0,
          < 18 => 0,
          <= 21 => 8,
          <= 34 => 12,
          <= 45 => 10,
          <= 50 => 8,
          _ => 0,
        },
        12,
      ),
      // Job offer 30, close relative 20, a year of work 5, a year of study 5
      // — capped at 30 together.
      PnpLine(
        'Connection to Saskatchewan',
        math.min(
          30,
          (t.offerIn(ProvinceTie.saskatchewan) ? 30 : 0) +
              (t.family.contains(ProvinceTie.saskatchewan) ? 20 : 0) +
              (t.worked.contains(ProvinceTie.saskatchewan) &&
                      t.f.saskatchewanWorkYear == true
                  ? 5
                  : 0) +
              (t.studied.contains(ProvinceTie.saskatchewan) ? 5 : 0),
        ),
        30,
      ),
    ],
    notCounted: const [
      'A job offer counts only with a SINP Job Approval Letter',
    ],
  );
}

PnpScore _manitoba(
  CrsProfile p,
  int? age,
  _Languages lang,
  int workYears,
  _Ties t,
) {
  final levels = _Languages.firstLevels(p);
  final firstLanguage = levels == null
      ? 0
      : levels.all.fold<int>(
          0,
          (sum, clb) =>
              sum +
              switch (clb) {
                >= 8 => 25,
                7 => 22,
                6 => 20,
                5 => 17,
                4 => 12,
                _ => 0,
              },
        );
  final education = _withTrade(
    p,
    switch (p.education) {
      EducationLevel.doctoral || EducationLevel.masters => 125,
      EducationLevel.twoOrMore => 115,
      EducationLevel.bachelors => 110,
      EducationLevel.twoYear => 100,
      EducationLevel.oneYear => 70,
      _ => 0,
    },
    70,
  );
  // Close relative 200, six months' work 100, study 100 (two years or more)
  // or 50, and 500 for six months with a Manitoba employer offering a job.
  final adaptability = math.min(
    500,
    (t.family.contains(ProvinceTie.manitoba) ? 200 : 0) +
        (t.worked.contains(ProvinceTie.manitoba) ? 100 : 0) +
        (t.studied.contains(ProvinceTie.manitoba)
            ? (t.f.manitobaStudyTwoYears == true ? 100 : 50)
            : 0) +
        (t.offerIn(ProvinceTie.manitoba) && t.f.workingForEmployer == true
            ? 500
            : 0),
  );
  // Work or study in another province suggests the candidate may not stay.
  // Each counts on its own, even alongside Manitoba ties.
  final risk = (t.workedOutside(ProvinceTie.manitoba) ? -100 : 0) +
      (t.studiedOutside(ProvinceTie.manitoba) ? -100 : 0);

  return PnpScore(
    code: 'MB',
    province: 'Manitoba',
    program: 'MPNP Skilled Worker EOI',
    maximum: 1000,
    lines: [
      PnpLine(
        'Language',
        math.min(125, firstLanguage + ((lang.second ?? 0) >= 5 ? 25 : 0)),
        125,
      ),
      PnpLine(
        'Age',
        switch (age) {
          null => 0,
          < 18 => 0,
          18 => 20,
          19 => 30,
          20 => 40,
          <= 45 => 75,
          46 => 40,
          47 => 30,
          48 => 20,
          49 => 10,
          _ => 0,
        },
        75,
      ),
      PnpLine(
        'Work experience',
        switch (workYears) {
          >= 4 => 75,
          3 => 60,
          2 => 50,
          1 => 40,
          _ => 0,
        },
        175,
      ),
      PnpLine('Education', education, 125),
      PnpLine('Adaptability', adaptability, 500),
      if (risk != 0) PnpLine('Work or study in another province', risk, 0),
    ],
    notCounted: const [
      'A close friend or distant relative in Manitoba (+50)',
      'Settling outside Winnipeg (+50)',
      'A strategic recruitment invitation (+500)',
      'Work experience recognised by a Manitoba licensing body',
    ],
  );
}
