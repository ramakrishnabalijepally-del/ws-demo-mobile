import 'package:flutter_test/flutter_test.dart';
import 'package:worksettle_mobile/shared/data/mock_candidate.dart';
import 'package:worksettle_mobile/shared/models/candidate.dart';
import 'package:worksettle_mobile/shared/models/crs_profile.dart';
import 'package:worksettle_mobile/shared/utils/pnp_calculator.dart';

/// Checked by hand against each province's published grid (September 2026).
void main() {
  final today = DateTime(2026, 9, 16);

  // Adam: 30, bachelor's, IELTS at CLB 9 in all four abilities, three years of
  // skilled work abroad, none in Canada, living outside the four provinces.
  final adam = mockCandidate.copyWith(
    dateOfBirth: '1996-01-01',
    province: 'Ontario',
  );

  PnpScore scoreFor(String code, [Candidate? candidate]) =>
      calculatePnpScores(candidate ?? adam, today: today)
          .firstWhere((s) => s.code == code);

  test('Alberta AAIP: education 7, language 10, work 11, age 5', () {
    final ab = scoreFor('AB');
    expect(ab.total, 33);
    expect(ab.maximum, 100);
  });

  test('BC SIRS: experience 12, education 15, language 30', () {
    final bc = scoreFor('BC');
    expect(bc.total, 57);
    expect(bc.maximum, 200);
  });

  test('Saskatchewan SINP: 58, just under the pass mark of 60', () {
    final sk = scoreFor('SK');
    expect(sk.total, 58);
    expect(sk.passMark, 60);
  });

  test('Manitoba MPNP: language 100, age 75, work 60, education 110', () {
    final mb = scoreFor('MB');
    expect(mb.total, 345);
    expect(mb.maximum, 1000);
  });

  test('a French test at CLB 4 or more adds each bilingual bonus', () {
    final bilingual = adam.copyWith(
      crs: adam.crs.copyWith(
        frenchTest: const LanguageResult(
          test: LanguageTest.tef,
          speaking: 400,
          listening: 400,
          reading: 400,
          writing: 400,
        ),
      ),
    );
    expect(scoreFor('AB', bilingual).total, 33 + 3);
    expect(scoreFor('BC', bilingual).total, 57 + 10);
  });

  Candidate withFactors(ProvincialFactors f, {CrsProfile? crs}) =>
      adam.copyWith(crs: (crs ?? adam.crs).copyWith(provincial: f));

  int line(PnpScore score, String label) =>
      score.lines.firstWhere((l) => l.label == label).points;

  test(
      'work in another province costs 100 in Manitoba, even with Manitoba '
      'work too', () {
    final both = withFactors(
      const ProvincialFactors(
        workedIn: {ProvinceTie.manitoba, ProvinceTie.elsewhere},
      ),
      crs: adam.crs.copyWith(canadianWorkYears: 1),
    );
    final mb = scoreFor('MB', both);
    expect(line(mb, 'Work or study in another province'), -100);
    expect(line(mb, 'Adaptability'), 100);
  });

  test('Canadian work years alone, with no province given, carry no risk', () {
    final unplaced = adam.copyWith(
      crs: adam.crs.copyWith(canadianWorkYears: 1),
    );
    expect(
      scoreFor('MB', unplaced).lines.any((l) => l.points < 0),
      isFalse,
    );
  });

  test('Alberta counts a parent, sibling or child, not a cousin', () {
    final cousin = withFactors(
      const ProvincialFactors(extendedFamily: {ProvinceTie.alberta}),
    );
    final sister = withFactors(
      const ProvincialFactors(immediateFamily: {ProvinceTie.alberta}),
    );
    expect(line(scoreFor('AB', cousin), 'Family in Alberta'), 0);
    expect(line(scoreFor('AB', sister), 'Family in Alberta'), 8);
  });

  test('Saskatchewan and Manitoba count extended family', () {
    final cousins = withFactors(
      const ProvincialFactors(
        extendedFamily: {ProvinceTie.saskatchewan, ProvinceTie.manitoba},
      ),
    );
    expect(line(scoreFor('SK', cousins), 'Connection to Saskatchewan'), 20);
    expect(line(scoreFor('MB', cousins), 'Adaptability'), 200);
  });

  test('Saskatchewan counts past work only at 12 months or more', () {
    CrsProfile sk(bool year) => adam.crs.copyWith(
          provincial: ProvincialFactors(
            workedIn: const {ProvinceTie.saskatchewan},
            saskatchewanWorkYear: year,
          ),
        );
    expect(
      line(
        scoreFor('SK', adam.copyWith(crs: sk(false))),
        'Connection to Saskatchewan',
      ),
      0,
    );
    expect(
      line(
        scoreFor('SK', adam.copyWith(crs: sk(true))),
        'Connection to Saskatchewan',
      ),
      5,
    );
  });

  test('a Saskatchewan job offer fills the 30-point connection alone', () {
    final offer = withFactors(
      const ProvincialFactors(
        jobOffer: ProvinceTie.saskatchewan,
        immediateFamily: {ProvinceTie.saskatchewan},
      ),
    );
    expect(line(scoreFor('SK', offer), 'Connection to Saskatchewan'), 30);
  });

  test('education bonuses follow where you studied, not where you live', () {
    final studied = withFactors(
      const ProvincialFactors(
        studiedIn: {ProvinceTie.alberta, ProvinceTie.britishColumbia},
      ),
      crs: adam.crs.copyWith(
        canadianEducation: CanadianEducation.oneOrTwoYear,
      ),
    );
    expect(line(scoreFor('AB', studied), 'Education'), 7 + 10);
    expect(line(scoreFor('BC', studied), 'Education'), 15 + 8);
    // Manitoba scores study in another province as a risk.
    expect(
      line(scoreFor('MB', studied), 'Work or study in another province'),
      -100,
    );
  });

  test('no Canadian post-secondary study ignores a stale study answer', () {
    final stale = withFactors(
      const ProvincialFactors(studiedIn: {ProvinceTie.alberta}),
    );
    expect(line(scoreFor('AB', stale), 'Education'), 7);
  });

  test('Manitoba study scores 100 at two years, 50 at one', () {
    Candidate study(bool twoYears) => withFactors(
          ProvincialFactors(
            studiedIn: const {ProvinceTie.manitoba},
            manitobaStudyTwoYears: twoYears,
          ),
          crs: adam.crs.copyWith(
            canadianEducation: CanadianEducation.oneOrTwoYear,
          ),
        );
    expect(line(scoreFor('MB', study(true)), 'Adaptability'), 100);
    expect(line(scoreFor('MB', study(false)), 'Adaptability'), 50);
  });

  test('six months with a Manitoba employer offering a job is 500', () {
    final demand = withFactors(
      const ProvincialFactors(
        jobOffer: ProvinceTie.manitoba,
        workingForEmployer: true,
      ),
    );
    expect(line(scoreFor('MB', demand), 'Adaptability'), 500);
  });

  test(
      'Alberta job offer: 10, plus 5 outside the cities, plus 10 if '
      'regulated', () {
    final offer = withFactors(
      const ProvincialFactors(
        jobOffer: ProvinceTie.alberta,
        albertaJobOutsideCities: true,
        albertaJobRegulated: true,
      ),
    );
    expect(scoreFor('AB', offer).total, 33 + 10 + 5 + 10);
  });

  test('BC wage scores a point a dollar from \$16, capped at 55', () {
    int wagePoints(double wage) => line(
          scoreFor(
            'BC',
            withFactors(
              ProvincialFactors(
                jobOffer: ProvinceTie.britishColumbia,
                bcHourlyWage: wage,
                bcArea: BcArea.elsewhere,
                workingForEmployer: false,
              ),
            ),
          ),
          'Wage of the job offer',
        );
    expect(wagePoints(15.99), 0);
    expect(wagePoints(16), 1);
    expect(wagePoints(32.50), 17);
    expect(wagePoints(70), 55);
    expect(wagePoints(95), 55);
  });

  test('BC area and current employment count only with a BC offer', () {
    final offer = withFactors(
      const ProvincialFactors(
        jobOffer: ProvinceTie.britishColumbia,
        bcHourlyWage: 30,
        bcArea: BcArea.elsewhere,
        workingForEmployer: true,
      ),
    );
    final bc = scoreFor('BC', offer);
    expect(line(bc, 'Area of employment'), 15);
    expect(line(bc, 'Work experience'), 12 + 10);
  });

  test('Alberta scores French lower than English', () {
    final frenchOnly = adam.copyWith(
      crs: adam.crs.copyWith(
        englishTest: null,
        frenchTest: const LanguageResult(
          test: LanguageTest.tef,
          speaking: 400,
          listening: 400,
          reading: 400,
          writing: 400,
        ),
      ),
    );
    expect(line(scoreFor('AB', frenchOnly), 'Language'), 8);
  });

  test('a trade certificate beats a one-year diploma where the grid says so',
      () {
    final trades = adam.copyWith(
      crs: adam.crs.copyWith(
        education: EducationLevel.oneYear,
        certificateOfQualification: true,
      ),
    );
    expect(line(scoreFor('AB', trades), 'Education'), 7);
    expect(line(scoreFor('SK', trades), 'Education and training'), 20);
    expect(line(scoreFor('MB', trades), 'Education'), 70);
  });

  test('BC gives no experience points for under a year', () {
    final none = adam.copyWith(
      crs: adam.crs.copyWith(canadianWorkYears: 0, foreignWorkYears: 0),
    );
    expect(line(scoreFor('BC', none), 'Work experience'), 0);
  });

  test('every score lists what the profile could not count', () {
    for (final score in calculatePnpScores(adam, today: today)) {
      expect(score.notCounted, isNotEmpty, reason: score.province);
      expect(score.total, lessThanOrEqualTo(score.maximum));
    }
  });
}
