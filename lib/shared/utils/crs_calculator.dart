import 'dart:math' as math;

import '../models/crs_profile.dart';
import '../models/profile_section.dart';
import 'clb_conversion.dart';

/// The Comprehensive Ranking System, calculated from a [CrsProfile].
///
/// Every number here is IRCC's published grid — *Express Entry:
/// Comprehensive Ranking System (CRS) criteria*, canada.ca, checked September
/// 2026 — including the removal of job-offer points on 25 March 2025.
///
/// An unanswered factor scores nothing, so an incomplete profile gives a
/// lower-bound estimate rather than an error. The screens say so.
const int crsMaximum = 1200;

enum CrsGroup {
  core('Core factors'),
  spouse('Spouse or partner factors'),
  transferability('Skill transferability'),
  additional('Additional points');

  const CrsGroup(this.label);

  final String label;
}

class CrsLine {
  const CrsLine(this.group, this.label, this.points);

  final CrsGroup group;
  final String label;
  final int points;
}

class CrsResult {
  const CrsResult(this.lines);

  final List<CrsLine> lines;

  int subtotal(CrsGroup group) => lines
      .where((line) => line.group == group)
      .fold(0, (sum, line) => sum + line.points);

  int get total =>
      math.min(crsMaximum, lines.fold(0, (sum, line) => sum + line.points));
}

/// Completed years of age on [today].
int ageOn(DateTime birth, DateTime today) {
  var age = today.year - birth.year;
  final beforeBirthday = today.month < birth.month ||
      (today.month == birth.month && today.day < birth.day);
  if (beforeBirthday) age--;
  return age;
}

CrsResult calculateCrs(CrsProfile p, {required int? age}) {
  final withSpouse = p.scoresWithSpouse;
  final english = _levels(p.englishTest);
  final french = _levels(p.frenchTest);

  // The first official language is whichever the candidate scores higher in.
  final englishFirst = _firstLanguagePoints(english, withSpouse) >=
      _firstLanguagePoints(french, withSpouse);
  final first = englishFirst ? english : french;
  final second = englishFirst ? french : english;

  final canadianYears = p.canadianWorkYears ?? 0;
  final foreignYears = p.foreignWorkYears ?? 0;

  final lines = <CrsLine>[
    CrsLine(CrsGroup.core, 'Age', _agePoints(age, withSpouse)),
    CrsLine(
      CrsGroup.core,
      'Education',
      _education(p.education, withSpouse ? _educationSpouse : _educationSingle),
    ),
    CrsLine(
      CrsGroup.core,
      'First official language',
      _firstLanguagePoints(first, withSpouse),
    ),
    CrsLine(
      CrsGroup.core,
      'Second official language',
      _secondLanguagePoints(second, withSpouse),
    ),
    CrsLine(
      CrsGroup.core,
      'Canadian work experience',
      (withSpouse
          ? _canadianWorkSpouse
          : _canadianWorkSingle)[math.min(canadianYears, 5)],
    ),
  ];

  if (withSpouse) {
    lines.addAll([
      CrsLine(
        CrsGroup.spouse,
        'Spouse education',
        _education(p.spouseEducation, _spouseEducation),
      ),
      CrsLine(
        CrsGroup.spouse,
        'Spouse language',
        _spouseLanguagePoints(_levels(p.spouseLanguageTest)),
      ),
      CrsLine(
        CrsGroup.spouse,
        'Spouse Canadian work experience',
        _spouseCanadianWork[math.min(p.spouseCanadianWorkYears ?? 0, 5)],
      ),
    ]);
  }

  // Skill transferability. Each factor combines with language and with
  // Canadian work; each factor is capped at 50, and the group at 100.
  final languageStep = first == null
      ? 0
      : first.allAtLeast(9)
          ? 2
          : first.allAtLeast(7)
              ? 1
              : 0;
  final canadianStep = canadianYears >= 2
      ? 2
      : canadianYears == 1
          ? 1
          : 0;

  final educationTier = _educationTier(p.education);
  final educationPoints = math.min(
    50,
    _transfer(educationTier, languageStep) +
        _transfer(educationTier, canadianStep),
  );

  final foreignTier = foreignYears >= 3
      ? 2
      : foreignYears >= 1
          ? 1
          : 0;
  final foreignPoints = math.min(
    50,
    _transfer(foreignTier, languageStep) + _transfer(foreignTier, canadianStep),
  );

  final certificatePoints =
      p.certificateOfQualification == true && first != null
          ? first.allAtLeast(7)
              ? 50
              : first.allAtLeast(5)
                  ? 25
                  : 0
          : 0;

  final transferability = educationPoints + foreignPoints + certificatePoints;
  lines.addAll([
    CrsLine(
      CrsGroup.transferability,
      'Education with language or Canadian work',
      educationPoints,
    ),
    CrsLine(
      CrsGroup.transferability,
      'Foreign work with language or Canadian work',
      foreignPoints,
    ),
    CrsLine(
      CrsGroup.transferability,
      'Certificate of qualification with language',
      certificatePoints,
    ),
    if (transferability > 100)
      CrsLine(
        CrsGroup.transferability,
        'Skill transferability limit (100)',
        100 - transferability,
      ),
  ]);

  // Additional points, capped at 600.
  final frenchPoints = french != null && french.allAtLeast(7)
      ? english != null && english.allAtLeast(5)
          ? 50
          : 25
      : 0;
  final canadianEducationPoints = switch (p.canadianEducation) {
    null || CanadianEducation.none => 0,
    CanadianEducation.oneOrTwoYear => 15,
    CanadianEducation.threeYearOrMore => 30,
  };
  final nominationPoints = p.provincialNomination == true ? 600 : 0;
  final siblingPoints = p.siblingInCanada == true ? 15 : 0;
  final additional =
      nominationPoints + siblingPoints + canadianEducationPoints + frenchPoints;

  lines.addAll([
    CrsLine(CrsGroup.additional, 'Provincial nomination', nominationPoints),
    CrsLine(CrsGroup.additional, 'Sibling in Canada', siblingPoints),
    CrsLine(
      CrsGroup.additional,
      'Canadian post-secondary education',
      canadianEducationPoints,
    ),
    CrsLine(CrsGroup.additional, 'French language skills', frenchPoints),
    if (additional > 600)
      CrsLine(
        CrsGroup.additional,
        'Additional points limit (600)',
        600 - additional,
      ),
  ]);

  return CrsResult(List.unmodifiable(lines));
}

/// A change that would raise the score, and by how much.
class CrsLever {
  const CrsLever({
    required this.title,
    required this.detail,
    required this.gain,
    required this.section,
  });

  final String title;
  final String detail;
  final int gain;

  /// Where in the profile the reader would record it.
  final ProfileSection section;
}

/// The changes that would raise this profile's score, largest first. Each
/// gain is the calculator run again with that one change, so combinations are
/// counted honestly rather than added by hand.
List<CrsLever> crsLevers(CrsProfile p, {required int? age}) {
  final base = calculateCrs(p, age: age).total;
  int gain(CrsProfile changed) => calculateCrs(changed, age: age).total - base;
  final canadianYears = p.canadianWorkYears ?? 0;

  final options = [
    if (p.provincialNomination != true)
      CrsLever(
        title: 'A provincial nomination',
        detail: 'The single largest factor. Nominations come through a '
            'provincial nominee program stream.',
        gain: gain(p.copyWith(provincialNomination: true)),
        section: ProfileSection.additional,
      ),
    CrsLever(
      title: 'CLB 10 in every English ability',
      detail: 'A stronger result also lifts the combinations built on '
          'language.',
      gain: gain(
        p.copyWith(
          englishTest: const LanguageResult(
            test: LanguageTest.celpip,
            speaking: 10,
            listening: 10,
            reading: 10,
            writing: 10,
          ),
        ),
      ),
      section: ProfileSection.language,
    ),
    CrsLever(
      title: 'French at NCLC 7 in every ability',
      detail: 'French counts even when English is your stronger language.',
      gain: gain(
        p.copyWith(
          frenchTest: const LanguageResult(
            test: LanguageTest.tef,
            speaking: 310,
            listening: 249,
            reading: 207,
            writing: 310,
          ),
        ),
      ),
      section: ProfileSection.language,
    ),
    if (canadianYears < 5)
      CrsLever(
        title: 'Another year of skilled work in Canada',
        detail: 'Canadian experience scores on its own and alongside your '
            'education and foreign work.',
        gain: gain(p.copyWith(canadianWorkYears: canadianYears + 1)),
        section: ProfileSection.work,
      ),
  ];

  return [
    for (final lever in options)
      if (lever.gain > 0) lever,
  ]..sort((a, b) => b.gain.compareTo(a.gain));
}

ClbLevels? _levels(LanguageResult? result) =>
    result == null ? null : clbFor(result);

const Map<int, int> _ageSingle = {
  18: 99, 19: 105, 30: 105, 31: 99, 32: 94, 33: 88, 34: 83, 35: 77, //
  36: 72, 37: 66, 38: 61, 39: 55, 40: 50, 41: 39, 42: 28, 43: 17, 44: 6,
};

const Map<int, int> _ageSpouse = {
  18: 90, 19: 95, 30: 95, 31: 90, 32: 85, 33: 80, 34: 75, 35: 70, //
  36: 65, 37: 60, 38: 55, 39: 50, 40: 45, 41: 35, 42: 25, 43: 15, 44: 5,
};

int _agePoints(int? age, bool withSpouse) {
  if (age == null || age < 18 || age >= 45) return 0;
  if (age >= 20 && age <= 29) return withSpouse ? 100 : 110;
  return (withSpouse ? _ageSpouse : _ageSingle)[age] ?? 0;
}

// Indexed by EducationLevel order.
const List<int> _educationSingle = [0, 30, 90, 98, 120, 128, 135, 150];
const List<int> _educationSpouse = [0, 28, 84, 91, 112, 119, 126, 140];
const List<int> _spouseEducation = [0, 2, 6, 7, 8, 9, 10, 10];

int _education(EducationLevel? level, List<int> table) =>
    level == null ? 0 : table[level.index];

// Indexed by years, 0 to 5 or more.
const List<int> _canadianWorkSingle = [0, 40, 53, 64, 72, 80];
const List<int> _canadianWorkSpouse = [0, 35, 46, 56, 63, 70];
const List<int> _spouseCanadianWork = [0, 5, 7, 8, 9, 10];

int _firstLanguagePoints(ClbLevels? levels, bool withSpouse) {
  if (levels == null) return 0;
  int perAbility(int clb) {
    if (clb >= 10) return withSpouse ? 32 : 34;
    if (clb == 9) return withSpouse ? 29 : 31;
    if (clb == 8) return withSpouse ? 22 : 23;
    if (clb == 7) return withSpouse ? 16 : 17;
    if (clb == 6) return withSpouse ? 8 : 9;
    if (clb >= 4) return 6;
    return 0;
  }

  return levels.all.fold(0, (sum, clb) => sum + perAbility(clb));
}

int _secondLanguagePoints(ClbLevels? levels, bool withSpouse) {
  if (levels == null) return 0;
  int perAbility(int clb) {
    if (clb >= 9) return 6;
    if (clb >= 7) return 3;
    if (clb >= 5) return 1;
    return 0;
  }

  final points = levels.all.fold(0, (sum, clb) => sum + perAbility(clb));
  return math.min(points, withSpouse ? 22 : 24);
}

int _spouseLanguagePoints(ClbLevels? levels) {
  if (levels == null) return 0;
  int perAbility(int clb) {
    if (clb >= 9) return 5;
    if (clb >= 7) return 3;
    if (clb >= 5) return 1;
    return 0;
  }

  return levels.all.fold(0, (sum, clb) => sum + perAbility(clb));
}

/// 0: secondary or less · 1: one-year credential up to a bachelor's ·
/// 2: two or more credentials, or a master's, professional or doctoral degree.
int _educationTier(EducationLevel? level) => switch (level) {
      null || EducationLevel.lessThanSecondary || EducationLevel.secondary => 0,
      EducationLevel.oneYear ||
      EducationLevel.twoYear ||
      EducationLevel.bachelors =>
        1,
      EducationLevel.twoOrMore ||
      EducationLevel.masters ||
      EducationLevel.doctoral =>
        2,
    };

/// The transferability grid: a factor's tier (0–2) against the strength of
/// the thing it combines with (0 none · 1 CLB 7+ or one Canadian year ·
/// 2 CLB 9+ or two Canadian years).
int _transfer(int tier, int step) => const [
      [0, 0, 0],
      [0, 13, 25],
      [0, 25, 50],
    ][tier][step];
