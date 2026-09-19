import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:worksettle_mobile/shared/controllers/crs_controller.dart';

/// Reads every line of copy in the app and fails on the three mistakes that
/// have actually shipped here.
///
/// This exists because fixing them one screen at a time did not work. A score
/// written into prose was fixed in the assistant's CRS answer and left
/// standing in its job-offer answer; "effectively guarantees an invitation"
/// was fixed in the assistant and left standing in a home article. Each time,
/// the copy that was not in front of whoever was looking survived.
///
/// So this does not look at a screen. It reads `lib/` and applies the rules to
/// everything at once, which is the only way a rule about all copy can hold.
void main() {
  /// Every string literal in `lib/`, with adjacent literals joined the way
  /// Dart joins them, and comments left out — a comment is not copy.
  Map<String, List<String>> copyByFile() {
    final result = <String, List<String>>{};
    final root = Directory('lib');

    for (final entity in root.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      var source = entity.readAsStringSync();

      source = source.replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '');
      source = source.split('\n').map((line) {
        final comment = _commentStart(line);
        return comment == -1 ? line : line.substring(0, comment);
      }).join('\n');

      final literal = RegExp(r"'((?:[^'\\\n]|\\.)*)'");
      final matches = literal.allMatches(source).toList();
      final lines = <String>[];
      var buffer = '';
      var previousEnd = -1;

      for (final match in matches) {
        final between = previousEnd == -1
            ? null
            : source.substring(previousEnd, match.start);
        // Dart joins two literals separated by nothing but whitespace.
        if (between != null && between.trim().isEmpty) {
          buffer += match.group(1)!;
        } else {
          if (buffer.isNotEmpty) lines.add(buffer);
          buffer = match.group(1)!;
        }
        previousEnd = match.end;
      }
      if (buffer.isNotEmpty) lines.add(buffer);
      result[entity.path] = lines;
    }
    return result;
  }

  late Map<String, List<String>> copy;

  setUpAll(() => copy = copyByFile());

  void forbid(
    RegExp pattern,
    String why, {
    Set<String> allowedFiles = const <String>{},
  }) {
    final offences = <String>[];
    copy.forEach((path, lines) {
      if (allowedFiles.contains(path)) return;
      for (final line in lines) {
        if (pattern.hasMatch(line)) offences.add('$path\n    "$line"');
      }
    });
    expect(offences, isEmpty, reason: '$why\n\n${offences.join('\n')}');
  }

  test('no line of copy states an immigration outcome as certain', () {
    // Design system section 20, and the reason it exists: final eligibility
    // rests with IRCC or the province, so nothing here may promise it.
    // "It is not a guarantee they will sponsor you" is the rule being kept,
    // not broken, so only an affirmative promise counts.
    forbid(
      RegExp(
        r'(?<!not a )(?<!no )(?<!not )\b(guarantees?|guaranteed|guaranteeing|'
        r'ensures|will be (approved|invited|accepted)|definitely)\b',
        caseSensitive: false,
      ),
      'Copy may not promise an immigration outcome. Say what it does in '
      'practice and leave the decision where it belongs.',
    );
  });

  test('no line of copy tells the reader what their own score is', () {
    // "at 468 you are already in range" shipped twice. A score is a fact about
    // a person and is calculated; prose that quotes one is a second copy that
    // goes stale the moment the profile changes.
    // "Express Entry draw 302 closed at 468" is a published result and the
    // same for everyone. It is the reader's own standing that may not be
    // written down, so a score only counts when it is aimed at them.
    forbid(
      RegExp(r'\bat [3-6]\d{2}\b[^.]{0,40}\byou\b', caseSensitive: false),
      'A score belongs in an interpolation from crsResultProvider, never '
      'written into a line.',
    );
    forbid(
      RegExp(
        r'\byour (score|crs)\b[^.]{0,30}\b[3-6]\d{2}\b',
        caseSensitive: false,
      ),
      'A score belongs in an interpolation from crsResultProvider, never '
      'written into a line.',
    );
  });

  test('the draw range is never typed out again', () {
    // crsDrawLow and crsDrawHigh are the definition. Typing the numbers makes
    // a second one that nobody remembers to update.
    forbid(
      RegExp('\\b($crsDrawLow|$crsDrawHigh)\\b'),
      'Interpolate crsDrawLow and crsDrawHigh instead of writing the draw '
      'range out.',
      // Only the definition itself.
      allowedFiles: {'lib/shared/controllers/crs_controller.dart'},
    );
  });
}

/// The first `//` on a line that is not inside a string literal.
int _commentStart(String line) {
  var inString = false;
  String? quote;
  for (var i = 0; i < line.length; i++) {
    final char = line[i];
    if (char == r'\') {
      i++;
      continue;
    }
    if (inString) {
      if (char == quote) inString = false;
    } else if (char == "'" || char == '"') {
      inString = true;
      quote = char;
    } else if (char == '/' && i + 1 < line.length && line[i + 1] == '/') {
      return i;
    }
  }
  return -1;
}
