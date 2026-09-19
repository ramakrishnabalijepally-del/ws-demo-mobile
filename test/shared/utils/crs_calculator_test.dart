import 'package:flutter_test/flutter_test.dart';
import 'package:worksettle_mobile/shared/data/mock_candidate.dart';
import 'package:worksettle_mobile/shared/models/crs_profile.dart';
import 'package:worksettle_mobile/shared/models/profile_section.dart';
import 'package:worksettle_mobile/shared/utils/clb_conversion.dart';
import 'package:worksettle_mobile/shared/utils/crs_calculator.dart';

/// Checks the arithmetic against IRCC's published grid. These are the numbers
/// the app tells people about their immigration chances, so they are tested
/// exactly.
void main() {
  group('CLB and NCLC conversion', () {
    test('a score between published levels counts at the lower level', () {
      expect(levelFor(LanguageTest.ielts, LanguageAbility.listening, 6.5), 7);
      expect(levelFor(LanguageTest.ielts, LanguageAbility.listening, 8.0), 9);
      expect(levelFor(LanguageTest.ielts, LanguageAbility.reading, 8.5), 10);
    });

    test('PTE Core, TEF Canada and TCF Canada use their own charts', () {
      expect(levelFor(LanguageTest.pteCore, LanguageAbility.reading, 77), 8);
      expect(levelFor(LanguageTest.tef, LanguageAbility.speaking, 310), 7);
      expect(levelFor(LanguageTest.tcf, LanguageAbility.writing, 13), 8);
      expect(levelFor(LanguageTest.celpip, LanguageAbility.speaking, 12), 10);
    });

    test('anything under level 4 reports as 3', () {
      expect(levelFor(LanguageTest.ielts, LanguageAbility.reading, 3.0), 3);
    });
  });

  group('CRS', () {
    test('the mock candidate scores 424', () {
      // Single, 30, bachelor's degree, IELTS at CLB 9, three years abroad.
      final result = calculateCrs(mockCandidate.crs, age: 30);

      expect(result.subtotal(CrsGroup.core), 349); // 105 + 120 + 124 + 0 + 0
      expect(result.subtotal(CrsGroup.transferability), 75); // 25 + 50
      expect(result.subtotal(CrsGroup.additional), 0);
      expect(result.total, 424);
    });

    test('every factor at its maximum reaches 1,200 through the caps', () {
      const profile = CrsProfile(
        maritalStatus: MaritalStatus.single,
        education: EducationLevel.doctoral,
        canadianEducation: CanadianEducation.threeYearOrMore,
        englishTest: LanguageResult(
          test: LanguageTest.celpip,
          speaking: 10,
          listening: 10,
          reading: 10,
          writing: 10,
        ),
        frenchTest: LanguageResult(
          test: LanguageTest.tef,
          speaking: 400,
          listening: 330,
          reading: 280,
          writing: 400,
        ),
        canadianWorkYears: 5,
        foreignWorkYears: 3,
        certificateOfQualification: true,
        provincialNomination: true,
        familyInCanada: {FamilyInCanada.brother},
      );
      final result = calculateCrs(profile, age: 25);

      expect(result.subtotal(CrsGroup.core), 500);
      expect(result.subtotal(CrsGroup.transferability), 100);
      expect(result.subtotal(CrsGroup.additional), 600);
      expect(result.total, crsMaximum);
    });

    test('an accompanying spouse moves the candidate to the spouse grid', () {
      const profile = CrsProfile(
        maritalStatus: MaritalStatus.married,
        spouseAccompanying: true,
        spouseCanadianOrPr: false,
        education: EducationLevel.bachelors,
        spouseEducation: EducationLevel.masters,
        spouseCanadianWorkYears: 1,
      );
      final result = calculateCrs(profile, age: 25);
      int points(String label) =>
          result.lines.firstWhere((line) => line.label == label).points;

      expect(points('Age'), 100);
      expect(points('Education'), 112);
      expect(result.subtotal(CrsGroup.spouse), 15); // 10 + 0 + 5
    });

    test('a partner who is already a permanent resident scores as single', () {
      const profile = CrsProfile(
        maritalStatus: MaritalStatus.commonLaw,
        spouseAccompanying: true,
        spouseCanadianOrPr: true,
      );
      final result = calculateCrs(profile, age: 25);

      final age = result.lines.firstWhere((line) => line.label == 'Age');
      expect(age.points, 110);
      expect(result.subtotal(CrsGroup.spouse), 0);
    });

    test('an unanswered profile scores nothing rather than failing', () {
      expect(calculateCrs(const CrsProfile(), age: null).total, 0);
    });
  });

  group('profile completion', () {
    test('the mock candidate is 67% complete with family in Canada next', () {
      final completion = completionOf(mockCandidate.crs, hasDateOfBirth: true);

      expect(completion.percent, 67);
      expect(completion.next, ProfileSection.family);
      expect(completion.isComplete, isFalse);
    });

    test('the spouse section appears only when a spouse is scored', () {
      const withSpouse = CrsProfile(
        maritalStatus: MaritalStatus.married,
        spouseAccompanying: true,
        spouseCanadianOrPr: false,
      );
      expect(
        completionOf(withSpouse, hasDateOfBirth: true).sections,
        contains(ProfileSection.spouse),
      );
      expect(
        completionOf(mockCandidate.crs, hasDateOfBirth: true).sections,
        isNot(contains(ProfileSection.spouse)),
      );
    });
  });
}
