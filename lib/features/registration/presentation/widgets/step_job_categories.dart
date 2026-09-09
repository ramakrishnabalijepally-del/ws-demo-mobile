import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/theme.dart';
import '../../controllers/registration_controller.dart';
import '../../data/mock_registration_options.dart';
import '../screens/registration_screen.dart';

/// C6 — "What job do you want?", three to five categories.
///
/// The deck lays these out as a two-column tile grid. They are chips here: a
/// chip is the right shape for a small multi-select, it survives 200% text
/// scaling where a fixed grid cell does not, and it keeps the pill radius
/// meaning "you press this".
class StepJobCategories extends ConsumerWidget {
  const StepJobCategories({super.key});

  static const int _minimum = 3;
  static const int _maximum = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(registrationProvider).draft;
    final controller = ref.read(registrationProvider.notifier);
    final count = draft.jobCategories.length;
    final complete = count >= _minimum;

    return RegistrationStepScaffold(
      headline: 'What kind of work?',
      supporting: 'Choose $_minimum to $_maximum categories and we will tune '
          'your job matches to them.',
      primaryLabel: 'Continue',
      onPrimary: complete ? controller.next : null,
      children: [
        Wrap(
          spacing: WsSpacing.sm,
          runSpacing: WsSpacing.md,
          children: [
            for (final category in mockJobCategories)
              _CategoryChip(
                label: category,
                selected: draft.jobCategories.contains(category),
                // At the ceiling, only already-chosen chips stay live — so the
                // limit is visible rather than enforced by a rejection.
                enabled:
                    draft.jobCategories.contains(category) || count < _maximum,
                onTap: () => controller.toggleCategory(category),
              ),
          ],
        ),
        const SizedBox(height: WsSpacing.xl),
        Text(
          complete
              ? '$count of $_maximum selected'
              : 'Choose at least ${_minimum - count} more',
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
