import 'package:flutter/material.dart';

import '../../../../../app/theme/theme.dart';
import '../../../../../shared/models/crs_profile.dart';
import '../../../../../shared/shared.dart';
import '../../../../../shared/utils/clb_conversion.dart';
import 'form_controls.dart';

/// Picks a designated test and takes the four band scores exactly as printed
/// on the report, converting each to its CLB or NCLC level as it is typed —
/// most candidates know their IELTS scores, not their benchmark.
///
/// It reports a [LanguageResult] only once all four scores are valid; while a
/// score is missing or out of range it reports null.
class LanguageTestEditor extends StatefulWidget {
  const LanguageTestEditor({
    required this.title,
    required this.tests,
    required this.result,
    required this.onChanged,
    this.helper,
    super.key,
  });

  final String title;
  final String? helper;
  final List<LanguageTest> tests;
  final LanguageResult? result;
  final ValueChanged<LanguageResult?> onChanged;

  @override
  State<LanguageTestEditor> createState() => _LanguageTestEditorState();
}

class _LanguageTestEditorState extends State<LanguageTestEditor> {
  late LanguageTest? _test = widget.result?.test;

  /// One controller per ability, in [LanguageAbility] order.
  late final List<TextEditingController> _scores = [
    for (final ability in LanguageAbility.values)
      TextEditingController(text: _initial(ability)),
  ];

  String _initial(LanguageAbility ability) {
    final result = widget.result;
    return result == null ? '' : formatScore(result.scoreFor(ability));
  }

  static String formatScore(double value) => value == value.roundToDouble()
      ? value.toInt().toString()
      : value.toString();

  @override
  void dispose() {
    for (final controller in _scores) {
      controller.dispose();
    }
    super.dispose();
  }

  void _selectTest(LanguageTest? test) {
    setState(() {
      _test = test;
      for (final controller in _scores) {
        controller.clear();
      }
    });
    widget.onChanged(null);
  }

  double? _valid(LanguageTest test, LanguageAbility ability) {
    final value = double.tryParse(_scores[ability.index].text.trim());
    final range = scoreRange(test, ability);
    if (value == null || value < range.min || value > range.max) return null;
    return value;
  }

  void _scoreChanged() {
    final test = _test;
    if (test == null) return;
    setState(() {});
    final speaking = _valid(test, LanguageAbility.speaking);
    final listening = _valid(test, LanguageAbility.listening);
    final reading = _valid(test, LanguageAbility.reading);
    final writing = _valid(test, LanguageAbility.writing);
    widget.onChanged(
      speaking == null ||
              listening == null ||
              reading == null ||
              writing == null
          ? null
          : LanguageResult(
              test: test,
              speaking: speaking,
              listening: listening,
              reading: reading,
              writing: writing,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final test = _test;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QuestionLabel(question: widget.title, helper: widget.helper),
        const SizedBox(height: WsSpacing.md),
        Wrap(
          spacing: WsSpacing.sm,
          runSpacing: WsSpacing.sm,
          children: [
            ChoiceChip(
              label: const Text('No test'),
              selected: test == null,
              onSelected: (_) => _selectTest(null),
            ),
            for (final option in widget.tests)
              ChoiceChip(
                label: Text(option.label),
                selected: test == option,
                onSelected: (_) => _selectTest(option),
              ),
          ],
        ),
        if (test != null) ...[
          const SizedBox(height: WsSpacing.xl),
          for (final ability in LanguageAbility.values)
            Padding(
              padding: const EdgeInsets.only(bottom: WsSpacing.lg),
              child: _AbilityScoreField(
                test: test,
                ability: ability,
                controller: _scores[ability.index],
                onChanged: _scoreChanged,
              ),
            ),
        ],
      ],
    );
  }
}

class _AbilityScoreField extends StatelessWidget {
  const _AbilityScoreField({
    required this.test,
    required this.ability,
    required this.controller,
    required this.onChanged,
  });

  final LanguageTest test;
  final LanguageAbility ability;
  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final range = scoreRange(test, ability);
    final min = _LanguageTestEditorState.formatScore(range.min);
    final max = _LanguageTestEditorState.formatScore(range.max);
    final text = controller.text.trim();
    final value = double.tryParse(text);

    String? level;
    String? error;
    if (value != null && value >= range.min && value <= range.max) {
      level = levelName(test, levelFor(test, ability, value));
    } else if (text.isNotEmpty) {
      // Name the fix, not the failure (design system section 20).
      error = 'Enter your ${ability.label.toLowerCase()} score from $min to '
          '$max, as it appears on your ${test.label} report';
    }

    return WsField(
      label: ability.label,
      controller: controller,
      hint: '$min–$max',
      helper: level == null ? null : 'That is $level',
      error: error,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (_) => onChanged(),
    );
  }
}
