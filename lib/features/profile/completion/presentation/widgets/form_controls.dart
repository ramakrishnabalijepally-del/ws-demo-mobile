import 'package:flutter/material.dart';

import '../../../../../app/theme/theme.dart';
import '../../../../../shared/models/crs_profile.dart';
import '../../../../../shared/shared.dart';

/// The question above a control: the label sits above and stays visible
/// (design system section 12), with an optional line saying why it matters.
class QuestionLabel extends StatelessWidget {
  const QuestionLabel({required this.question, this.helper, super.key});

  final String question;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    final helper = this.helper;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(question, style: context.text.titleMedium),
        if (helper != null) ...[
          const SizedBox(height: WsSpacing.xs),
          Text(
            helper,
            style: context.text.bodySmall?.copyWith(color: context.ws.caption),
          ),
        ],
      ],
    );
  }
}

/// One answer from a list, on selection cards.
class ChoiceGroup<T> extends StatelessWidget {
  const ChoiceGroup({
    required this.question,
    required this.options,
    required this.labelOf,
    required this.selected,
    required this.onSelected,
    this.helper,
    super.key,
  });

  final String question;
  final String? helper;
  final List<T> options;
  final String Function(T option) labelOf;
  final T? selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QuestionLabel(question: question, helper: helper),
        const SizedBox(height: WsSpacing.md),
        for (final option in options)
          Padding(
            padding: const EdgeInsets.only(bottom: WsSpacing.sm),
            child: WsSelectionCard(
              selected: option == selected,
              semanticLabel: labelOf(option),
              onTap: () => onSelected(option),
              child: Text(labelOf(option), style: context.text.bodyMedium),
            ),
          ),
      ],
    );
  }
}

/// A yes-or-no question as two selection cards. Null means unanswered.
class YesNoQuestion extends StatelessWidget {
  const YesNoQuestion({
    required this.question,
    required this.value,
    required this.onChanged,
    this.helper,
    super.key,
  });

  final String question;
  final String? helper;
  final bool? value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QuestionLabel(question: question, helper: helper),
        const SizedBox(height: WsSpacing.md),
        Row(
          children: [
            for (final (i, answer) in const [false, true].indexed) ...[
              if (i > 0) const SizedBox(width: WsSpacing.md),
              Expanded(
                child: WsSelectionCard(
                  selected: value == answer,
                  semanticLabel: answer ? 'Yes' : 'No',
                  onTap: () => onChanged(answer),
                  child: Center(
                    child: Text(
                      answer ? 'Yes' : 'No',
                      style: context.text.titleMedium,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// Whole years, from none up to [max] "or more". Null means unanswered.
class YearsStepper extends StatelessWidget {
  const YearsStepper({
    required this.question,
    required this.value,
    required this.max,
    required this.onChanged,
    this.helper,
    super.key,
  });

  final String question;
  final String? helper;
  final int? value;
  final int max;
  final ValueChanged<int> onChanged;

  String _label(int years) {
    if (years == 0) return 'None';
    if (years >= max) return '$max years or more';
    return years == 1 ? '1 year' : '$years years';
  }

  @override
  Widget build(BuildContext context) {
    final current = value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        QuestionLabel(question: question, helper: helper),
        const SizedBox(height: WsSpacing.md),
        WsCard(
          padding: const EdgeInsets.symmetric(
            horizontal: WsSpacing.sm,
            vertical: WsSpacing.xs,
          ),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Fewer years',
                onPressed: current == null
                    ? () => onChanged(0)
                    : current > 0
                        ? () => onChanged(current - 1)
                        : null,
                icon: const Icon(Icons.remove_rounded),
              ),
              Expanded(
                child: Semantics(
                  liveRegion: true,
                  child: AnimatedSwitcher(
                    duration: WsMotion.duration(context, WsMotion.medium),
                    child: Text(
                      current == null ? 'Not answered' : _label(current),
                      key: ValueKey(current),
                      textAlign: TextAlign.center,
                      style: current == null
                          ? context.text.bodyMedium
                              ?.copyWith(color: context.ws.caption)
                          : context.text.titleMedium,
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'More years',
                onPressed: current == null
                    ? () => onChanged(1)
                    : current < max
                        ? () => onChanged(current + 1)
                        : null,
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Close family in Canada: brother, sister, parents, or none of them.
///
/// Asked in the CRS additional factors and in the immigration profile, and
/// saved to the same answer, so whichever the candidate fills in, the other
/// already shows it. Null means unanswered; an empty set is none.
class FamilyInCanadaQuestion extends StatelessWidget {
  const FamilyInCanadaQuestion({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final Set<FamilyInCanada>? value;
  final ValueChanged<Set<FamilyInCanada>> onChanged;

  @override
  Widget build(BuildContext context) {
    final chosen = value ?? const <FamilyInCanada>{};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const QuestionLabel(
          question: 'Who in your family lives in Canada?',
          helper: 'Aged 18 or over, and a citizen or permanent resident. A '
              'brother or sister adds 15 CRS points.',
        ),
        const SizedBox(height: WsSpacing.md),
        for (final member in FamilyInCanada.values)
          Padding(
            padding: const EdgeInsets.only(bottom: WsSpacing.sm),
            child: WsSelectionCard(
              selected: chosen.contains(member),
              semanticLabel: member.label,
              onTap: () => onChanged(
                chosen.contains(member)
                    ? ({...chosen}..remove(member))
                    : {...chosen, member},
              ),
              child: _FamilyOption(
                label: member.label,
                selected: chosen.contains(member),
              ),
            ),
          ),
        WsSelectionCard(
          selected: value != null && chosen.isEmpty,
          semanticLabel: 'None of them',
          onTap: () => onChanged(const {}),
          child: _FamilyOption(
            label: 'None of them',
            selected: value != null && chosen.isEmpty,
          ),
        ),
      ],
    );
  }
}

/// A check glyph beside the label, so a multi-select reads differently from
/// the single-choice cards above it — and survives the greyscale test.
class _FamilyOption extends StatelessWidget {
  const _FamilyOption({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          selected
              ? Icons.check_box_rounded
              : Icons.check_box_outline_blank_rounded,
          size: WsIconSize.field,
          color: selected ? context.colors.primary : context.ws.placeholder,
        ),
        const SizedBox(width: WsSpacing.md),
        Expanded(child: Text(label, style: context.text.bodyMedium)),
      ],
    );
  }
}
