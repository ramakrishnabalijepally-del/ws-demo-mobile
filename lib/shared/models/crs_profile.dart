/// Everything the Comprehensive Ranking System scores, as the candidate enters
/// it across their profile sections.
///
/// Source: IRCC, *Express Entry: Comprehensive Ranking System (CRS) criteria*
/// and *Express Entry: Language test results* (canada.ca, checked September
/// 2026). **Job-offer points were removed from the CRS on 25 March 2025**, so
/// there is deliberately no CRS job-offer field. A provincial job offer is on
/// [ProvincialFactors], because the provincial grids still score one.
///
/// Every field is nullable: null means "not answered yet". That distinction is
/// what drives profile completion — a 0 is an answer, a null is a gap.
library;

import 'provincial_factors.dart';

export 'provincial_factors.dart';

enum MaritalStatus {
  single('Single, never married'),
  married('Married'),
  commonLaw('Common-law'),
  separated('Legally separated'),
  divorced('Divorced'),
  widowed('Widowed');

  const MaritalStatus(this.label);

  final String label;

  bool get hasPartner =>
      this == MaritalStatus.married || this == MaritalStatus.commonLaw;
}

/// Lowest to highest, in IRCC's order — the calculator's point tables are
/// indexed by this order, so it must not be rearranged.
enum EducationLevel {
  lessThanSecondary('Less than secondary school (high school)'),
  secondary('Secondary diploma (high school graduation)'),
  oneYear('One-year program at a university, college or technical school'),
  twoYear('Two-year program at a university, college or technical school'),
  bachelors("Bachelor's degree, or a program of three years or more"),
  twoOrMore(
    'Two or more certificates, diplomas or degrees — one of them for a '
    'program of three years or more',
  ),
  masters(
    "Master's degree, or a professional degree needed to practise a licensed "
    'profession',
  ),
  doctoral('Doctoral level university degree (PhD)');

  const EducationLevel(this.label);

  final String label;
}

enum CanadianEducation {
  none('No Canadian post-secondary education'),
  oneOrTwoYear('A one- or two-year Canadian diploma or certificate'),
  threeYearOrMore(
    "A Canadian program of three years or more, or a master's, professional "
    'or doctoral degree',
  );

  const CanadianEducation(this.label);

  final String label;
}

/// The designated tests IRCC accepts for Express Entry.
enum LanguageTest {
  ielts('IELTS General Training', french: false),
  celpip('CELPIP-General', french: false),
  pteCore('PTE Core', french: false),
  tef('TEF Canada', french: true),
  tcf('TCF Canada', french: true);

  const LanguageTest(this.label, {required this.french});

  final String label;

  /// French tests report NCLC levels; English tests report CLB levels.
  final bool french;
}

enum LanguageAbility {
  speaking('Speaking'),
  listening('Listening'),
  reading('Reading'),
  writing('Writing');

  const LanguageAbility(this.label);

  final String label;
}

/// One set of test results, as printed on the test report.
class LanguageResult {
  const LanguageResult({
    required this.test,
    required this.speaking,
    required this.listening,
    required this.reading,
    required this.writing,
  });

  final LanguageTest test;
  final double speaking;
  final double listening;
  final double reading;
  final double writing;

  double scoreFor(LanguageAbility ability) => switch (ability) {
        LanguageAbility.speaking => speaking,
        LanguageAbility.listening => listening,
        LanguageAbility.reading => reading,
        LanguageAbility.writing => writing,
      };
}

/// Close family living in Canada as citizens or permanent residents, aged 18
/// or over. One answer serves the CRS (a brother or sister adds 15 points) and
/// the immigration profile, so it is never asked twice.
enum FamilyInCanada {
  brother('Brother'),
  sister('Sister'),
  parents('Parents');

  const FamilyInCanada(this.label);

  final String label;

  /// The CRS scores a sibling only.
  bool get isSibling => this != FamilyInCanada.parents;
}

class CrsProfile {
  const CrsProfile({
    this.maritalStatus,
    this.spouseAccompanying,
    this.spouseCanadianOrPr,
    this.education,
    this.canadianEducation,
    this.englishTest,
    this.frenchTest,
    this.canadianWorkYears,
    this.foreignWorkYears,
    this.certificateOfQualification,
    this.provincialNomination,
    this.familyInCanada,
    this.spouseEducation,
    this.spouseLanguageTest,
    this.spouseCanadianWorkYears,
    this.provincial = const ProvincialFactors(),
  });

  final MaritalStatus? maritalStatus;

  /// Whether a spouse or common-law partner is coming to Canada.
  final bool? spouseAccompanying;

  /// Whether that partner is already a Canadian citizen or permanent resident.
  final bool? spouseCanadianOrPr;

  final EducationLevel? education;
  final CanadianEducation? canadianEducation;

  final LanguageResult? englishTest;
  final LanguageResult? frenchTest;

  /// Skilled (TEER 0–3), paid, full-time or equivalent, in the last 10 years.
  final int? canadianWorkYears;

  /// Skilled work outside Canada in the last 10 years.
  final int? foreignWorkYears;

  /// A certificate of qualification in a skilled trade, issued in Canada.
  final bool? certificateOfQualification;

  final bool? provincialNomination;

  /// Who is in Canada. Null is unanswered; an empty set is "none of them".
  final Set<FamilyInCanada>? familyInCanada;

  /// A brother or sister in Canada, 18 or older, citizen or permanent resident.
  bool? get siblingInCanada =>
      familyInCanada?.any((member) => member.isSibling);

  final EducationLevel? spouseEducation;
  final LanguageResult? spouseLanguageTest;
  final int? spouseCanadianWorkYears;

  /// Answers for the provincial points grids only — none are CRS factors.
  final ProvincialFactors provincial;

  /// Whether the profile records any Canadian post-secondary study, which
  /// decides whether the provincial study question is asked at all.
  bool get studiedInCanada =>
      canadianEducation != null && canadianEducation != CanadianEducation.none;

  /// IRCC scores "with a spouse" only when the partner is coming to Canada and
  /// is not already a citizen or permanent resident. Otherwise the candidate is
  /// scored as a single applicant.
  bool get scoresWithSpouse =>
      (maritalStatus?.hasPartner ?? false) &&
      spouseAccompanying == true &&
      spouseCanadianOrPr != true;

  static const Object _unset = Object();

  /// Pass `null` explicitly to clear an answer; omit a field to keep it.
  CrsProfile copyWith({
    Object? maritalStatus = _unset,
    Object? spouseAccompanying = _unset,
    Object? spouseCanadianOrPr = _unset,
    Object? education = _unset,
    Object? canadianEducation = _unset,
    Object? englishTest = _unset,
    Object? frenchTest = _unset,
    Object? canadianWorkYears = _unset,
    Object? foreignWorkYears = _unset,
    Object? certificateOfQualification = _unset,
    Object? provincialNomination = _unset,
    Object? familyInCanada = _unset,
    Object? spouseEducation = _unset,
    Object? spouseLanguageTest = _unset,
    Object? spouseCanadianWorkYears = _unset,
    ProvincialFactors? provincial,
  }) {
    T? pick<T>(Object? next, T? current) =>
        identical(next, _unset) ? current : next as T?;

    return CrsProfile(
      maritalStatus: pick(maritalStatus, this.maritalStatus),
      spouseAccompanying: pick(spouseAccompanying, this.spouseAccompanying),
      spouseCanadianOrPr: pick(spouseCanadianOrPr, this.spouseCanadianOrPr),
      education: pick(education, this.education),
      canadianEducation: pick(canadianEducation, this.canadianEducation),
      englishTest: pick(englishTest, this.englishTest),
      frenchTest: pick(frenchTest, this.frenchTest),
      canadianWorkYears: pick(canadianWorkYears, this.canadianWorkYears),
      foreignWorkYears: pick(foreignWorkYears, this.foreignWorkYears),
      certificateOfQualification:
          pick(certificateOfQualification, this.certificateOfQualification),
      provincialNomination:
          pick(provincialNomination, this.provincialNomination),
      familyInCanada: pick(familyInCanada, this.familyInCanada),
      spouseEducation: pick(spouseEducation, this.spouseEducation),
      spouseLanguageTest: pick(spouseLanguageTest, this.spouseLanguageTest),
      spouseCanadianWorkYears:
          pick(spouseCanadianWorkYears, this.spouseCanadianWorkYears),
      provincial: provincial ?? this.provincial,
    );
  }
}
