import '../models/crs_profile.dart';

/// Converts designated language test results to CLB (English) or NCLC
/// (French) levels.
///
/// Source: IRCC, *Express Entry: Language test results* — the equivalency
/// charts for CELPIP-General, IELTS General Training, PTE Core, TEF Canada and
/// TCF Canada (canada.ca, checked September 2026).
///
/// A level is the highest one whose minimum score the result meets, so a score
/// between two published levels counts at the lower one. Anything under level
/// 4 reports as 3: no CRS factor tells levels below 4 apart.
class ClbLevels {
  const ClbLevels({
    required this.speaking,
    required this.listening,
    required this.reading,
    required this.writing,
  });

  final int speaking;
  final int listening;
  final int reading;
  final int writing;

  List<int> get all => [speaking, listening, reading, writing];

  /// "In all four abilities" — the wording every CRS combination uses.
  bool allAtLeast(int level) => all.every((l) => l >= level);
}

ClbLevels clbFor(LanguageResult result) => ClbLevels(
      speaking: levelFor(
        result.test,
        LanguageAbility.speaking,
        result.speaking,
      ),
      listening: levelFor(
        result.test,
        LanguageAbility.listening,
        result.listening,
      ),
      reading: levelFor(result.test, LanguageAbility.reading, result.reading),
      writing: levelFor(result.test, LanguageAbility.writing, result.writing),
    );

int levelFor(LanguageTest test, LanguageAbility ability, double score) {
  final minimums = _minimums(test, ability);
  for (var i = 0; i < minimums.length; i++) {
    if (score >= minimums[i]) return 10 - i;
  }
  return 3;
}

/// "CLB 9", "NCLC 10+", "CLB below 4".
String levelName(LanguageTest test, int level) {
  final scale = test.french ? 'NCLC' : 'CLB';
  if (level < 4) return '$scale below 4';
  if (level >= 10) return '$scale 10+';
  return '$scale $level';
}

/// The range a score may take on the test report, for validating input.
({double min, double max}) scoreRange(
  LanguageTest test,
  LanguageAbility ability,
) {
  final oral =
      ability == LanguageAbility.speaking || ability == LanguageAbility.writing;
  return switch (test) {
    LanguageTest.ielts => (min: 0, max: 9),
    LanguageTest.celpip => (min: 0, max: 12),
    LanguageTest.pteCore => (min: 10, max: 90),
    LanguageTest.tef => (
        min: 0,
        max: oral
            ? 450
            : ability == LanguageAbility.listening
                ? 360
                : 300,
      ),
    LanguageTest.tcf => (min: 0, max: oral ? 20 : 699),
  };
}

/// Minimum scores for levels 10, 9, 8, 7, 6, 5 and 4, in that order.
List<num> _minimums(LanguageTest test, LanguageAbility ability) {
  final oral =
      ability == LanguageAbility.speaking || ability == LanguageAbility.writing;
  return switch (test) {
    LanguageTest.ielts => switch (ability) {
        LanguageAbility.speaking => _ieltsSpeaking,
        LanguageAbility.listening => _ieltsListening,
        LanguageAbility.reading => _ieltsReading,
        LanguageAbility.writing => _ieltsWriting,
      },
    LanguageTest.celpip => _celpip,
    LanguageTest.pteCore => switch (ability) {
        LanguageAbility.speaking => _pteSpeaking,
        LanguageAbility.listening => _pteListening,
        LanguageAbility.reading => _pteReading,
        LanguageAbility.writing => _pteWriting,
      },
    LanguageTest.tef => oral
        ? _tefSpeakingWriting
        : ability == LanguageAbility.listening
            ? _tefListening
            : _tefReading,
    LanguageTest.tcf => oral
        ? _tcfSpeakingWriting
        : ability == LanguageAbility.listening
            ? _tcfListening
            : _tcfReading,
  };
}

const List<num> _ieltsSpeaking = [7.5, 7.0, 6.5, 6.0, 5.5, 5.0, 4.0];
const List<num> _ieltsListening = [8.5, 8.0, 7.5, 6.0, 5.5, 5.0, 4.5];
const List<num> _ieltsReading = [8.0, 7.0, 6.5, 6.0, 5.0, 4.0, 3.5];
const List<num> _ieltsWriting = [7.5, 7.0, 6.5, 6.0, 5.5, 5.0, 4.0];

const List<num> _celpip = [10, 9, 8, 7, 6, 5, 4];

const List<num> _pteSpeaking = [89, 84, 76, 68, 59, 51, 42];
const List<num> _pteListening = [89, 82, 71, 60, 50, 39, 28];
const List<num> _pteReading = [88, 78, 69, 60, 51, 42, 33];
const List<num> _pteWriting = [90, 88, 79, 69, 60, 51, 41];

const List<num> _tefSpeakingWriting = [393, 371, 349, 310, 271, 226, 181];
const List<num> _tefListening = [316, 298, 280, 249, 217, 181, 145];
const List<num> _tefReading = [263, 248, 233, 207, 181, 151, 121];

const List<num> _tcfSpeakingWriting = [16, 14, 12, 10, 7, 6, 4];
const List<num> _tcfListening = [549, 523, 503, 458, 398, 369, 331];
const List<num> _tcfReading = [549, 524, 499, 453, 406, 375, 342];
