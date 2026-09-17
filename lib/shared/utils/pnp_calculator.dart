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
/// Grids as published by each province and checked September 2026.
///
/// **What the profile cannot answer is scored as zero and listed in
/// [PnpScore.notCounted]**: a job offer and its wage and location, a relative
/// living in that province, and a provincial licence. The score is therefore a
/// floor, and every card says so rather than implying it is complete.
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
  final province = candidate.province;

  return [
    _alberta(p, age, languages, workYears, hasWork, province),
    _britishColumbia(p, languages, workYears, province),
    _saskatchewan(p, age, languages, workYears),
    _manitoba(p, age, languages, workYears, province),
  ];
}

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
  String province,
) {
  final education = switch (p.education) {
    EducationLevel.doctoral => 12,
    EducationLevel.masters => 10,
    EducationLevel.bachelors ||
    EducationLevel.twoOrMore ||
    EducationLevel.twoYear =>
      7,
    EducationLevel.oneYear => 4,
    _ => p.certificateOfQualification == true ? 7 : 0,
  };
  final inAlberta = province == 'Alberta';
  final canadianStudy = switch (p.canadianEducation) {
    null || CanadianEducation.none => 0,
    _ => inAlberta ? 10 : 6,
  };
  final language = switch (lang.first) {
    null => 0,
    >= 6 => 10,
    5 => 8,
    4 => 5,
    _ => 0,
  };
  final canadianWork =
      (p.canadianWorkYears ?? 0) >= 1 ? (inAlberta ? 10 : 6) : 0;

  return PnpScore(
    code: 'AB',
    province: 'Alberta',
    program: 'AAIP Worker EOI',
    maximum: 100,
    lines: [
      PnpLine('Education', education + canadianStudy, 22),
      PnpLine('Language', language + (lang.bilingualAt4 ? 3 : 0), 13),
      PnpLine(
        'Work experience',
        (!hasWork ? 0 : (workYears >= 1 ? 11 : 3)) + canadianWork,
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
      const PnpLine('Family in Alberta', 0, 8),
      const PnpLine('Alberta job offer', 0, 31),
    ],
    notCounted: const [
      'A family member living in Alberta',
      'An Alberta job offer, its location and any licence it needs',
    ],
  );
}

PnpScore _britishColumbia(
  CrsProfile p,
  _Languages lang,
  int workYears,
  String province,
) {
  final experience = switch (workYears) {
    >= 5 => 20,
    4 => 16,
    3 => 12,
    2 => 8,
    1 => 4,
    _ => 1,
  };
  final education = switch (p.education) {
    EducationLevel.doctoral => 27,
    EducationLevel.masters => 22,
    EducationLevel.twoOrMore || EducationLevel.bachelors => 15,
    EducationLevel.twoYear || EducationLevel.oneYear => 5,
    _ => 0,
  };
  final canadianStudy = switch (p.canadianEducation) {
    null || CanadianEducation.none => 0,
    _ => province == 'British Columbia' ? 8 : 6,
  };
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

  return PnpScore(
    code: 'BC',
    province: 'British Columbia',
    program: 'BC PNP Skills Immigration (SIRS)',
    maximum: 200,
    lines: [
      PnpLine(
        'Work experience',
        experience + ((p.canadianWorkYears ?? 0) >= 1 ? 10 : 0),
        40,
      ),
      PnpLine(
        'Education',
        education +
            canadianStudy +
            (p.certificateOfQualification == true ? 5 : 0),
        40,
      ),
      PnpLine('Language', language + (lang.bilingualAt4 ? 10 : 0), 40),
      const PnpLine('Wage of the job offer', 0, 55),
      const PnpLine('Area of employment', 0, 25),
    ],
    notCounted: const [
      'A BC job offer and its hourly wage',
      'Where in BC the job is',
      'Currently working in BC for that employer',
    ],
  );
}

PnpScore _saskatchewan(
  CrsProfile p,
  int? age,
  _Languages lang,
  int workYears,
) {
  final education = switch (p.education) {
    EducationLevel.doctoral || EducationLevel.masters => 23,
    EducationLevel.bachelors || EducationLevel.twoOrMore => 20,
    EducationLevel.twoYear => 15,
    EducationLevel.oneYear => 12,
    _ => p.certificateOfQualification == true ? 20 : 0,
  };
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
      const PnpLine('Connection to Saskatchewan', 0, 30),
    ],
    notCounted: const [
      'A Saskatchewan job offer',
      'A close relative living in Saskatchewan',
      'Past work or study in Saskatchewan',
    ],
  );
}

PnpScore _manitoba(
  CrsProfile p,
  int? age,
  _Languages lang,
  int workYears,
  String province,
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
  final education = switch (p.education) {
    EducationLevel.doctoral || EducationLevel.masters => 125,
    EducationLevel.twoOrMore => 115,
    EducationLevel.bachelors => 110,
    EducationLevel.twoYear => 100,
    EducationLevel.oneYear => 70,
    _ => p.certificateOfQualification == true ? 70 : 0,
  };
  final inManitoba = province == 'Manitoba';
  // Manitoba's risk factor: Canadian work or study in another province
  // suggests the candidate may not stay.
  final risk = inManitoba
      ? 0
      : ((p.canadianWorkYears ?? 0) >= 1 ? -100 : 0) +
          (switch (p.canadianEducation) {
            null || CanadianEducation.none => 0,
            _ => -100,
          });

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
      const PnpLine('Adaptability', 0, 500),
      if (risk != 0)
        PnpLine('Canadian work or study outside Manitoba', risk, 0),
    ],
    notCounted: const [
      'A close relative or friend in Manitoba',
      'Past work, study or a job offer in Manitoba',
      'A Manitoba licence for your occupation',
    ],
  );
}
