import 'package:flutter/material.dart';

import '../../app/theme/theme.dart';
import '../models/candidate.dart';
import 'ws_forms.dart';
import 'ws_surfaces.dart';

/// The goals checklist, asked in registration and editable on the profile.
class WsGoalsChecklist extends StatelessWidget {
  const WsGoalsChecklist({
    required this.selected,
    required this.onToggle,
    super.key,
  });

  final List<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        WsCard(
          padding: const EdgeInsets.symmetric(
            horizontal: WsSpacing.lg,
            vertical: WsSpacing.sm,
          ),
          child: Column(
            children: [
              for (final (i, goal) in candidateGoals.indexed) ...[
                WsCheckboxRow(
                  label: goal,
                  value: selected.contains(goal),
                  onChanged: (_) => onToggle(goal),
                ),
                if (i != candidateGoals.length - 1)
                  Divider(color: context.colors.outlineVariant, height: 1),
              ],
            ],
          ),
        ),
        const SizedBox(height: WsSpacing.md),
        Text(
          '${selected.length} selected',
          style: context.text.bodySmall?.copyWith(color: context.ws.caption),
        ),
      ],
    );
  }
}

/// Job interests as pills, [minJobCategories] to [maxJobCategories] of them.
///
/// Pills rather than a tile grid: the right shape for a small multi-select,
/// they survive 200% text where a fixed grid cell does not, and the pill
/// radius keeps meaning "you press this".
class WsJobCategoryPicker extends StatelessWidget {
  const WsJobCategoryPicker({
    required this.selected,
    required this.onToggle,
    super.key,
  });

  final List<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    final count = selected.length;
    final complete = count >= minJobCategories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: WsSpacing.sm,
          runSpacing: WsSpacing.md,
          children: [
            for (final category in candidateJobCategories)
              _CategoryChip(
                label: category,
                selected: selected.contains(category),
                // At the ceiling, only already-chosen chips stay live — so the
                // limit is visible rather than enforced by a rejection.
                enabled:
                    selected.contains(category) || count < maxJobCategories,
                onTap: () => onToggle(category),
              ),
          ],
        ),
        const SizedBox(height: WsSpacing.xl),
        Text(
          complete
              ? '$count of $maxJobCategories selected'
              : 'Choose at least ${minJobCategories - count} more',
          style: context.text.bodySmall?.copyWith(
            color: complete ? context.ws.caption : context.ws.redOnSurface,
          ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      enabled: enabled,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: WsRadii.pillR,
        child: AnimatedContainer(
          duration: WsMotion.duration(context, WsMotion.fast),
          constraints: const BoxConstraints(minHeight: 40),
          padding: const EdgeInsets.symmetric(
            horizontal: WsSpacing.lg,
            vertical: WsSpacing.md,
          ),
          decoration: BoxDecoration(
            color: selected ? context.colors.primary : context.colors.surface,
            borderRadius: WsRadii.pillR,
            border: Border.all(
              color: selected
                  ? context.colors.primary
                  : context.colors.outlineVariant,
            ),
          ),
          child: Opacity(
            opacity: enabled ? 1 : 0.45,
            child: Text(
              label,
              style: context.text.labelLarge?.copyWith(
                color: selected
                    ? context.colors.onPrimary
                    : context.colors.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
