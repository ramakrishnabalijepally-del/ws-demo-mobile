import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/theme.dart';
import '../../../../shared/shared.dart';
import '../../controllers/registration_controller.dart';
import '../../data/mock_registration_options.dart';
import '../screens/registration_screen.dart';

/// C5 — Your Goals. Multi-select, at least one.
class StepGoals extends ConsumerWidget {
  const StepGoals({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(registrationProvider).draft;
    final controller = ref.read(registrationProvider.notifier);

    return RegistrationStepScaffold(
      headline: 'What do you want to achieve?',
      supporting: 'Pick everything that applies. Your checklist and your '
          'matches are built from these.',
      primaryLabel: 'Continue',
      onPrimary: draft.goals.isEmpty ? null : controller.next,
      children: [
        WsCard(
          padding: const EdgeInsets.symmetric(
            horizontal: WsSpacing.lg,
            vertical: WsSpacing.sm,
          ),
          child: Column(
            children: [
              for (var i = 0; i < mockGoals.length; i++) ...[
                WsCheckboxRow(
                  label: mockGoals[i],
                  value: draft.goals.contains(mockGoals[i]),
                  onChanged: (_) => controller.toggleGoal(mockGoals[i]),
                ),
                if (i != mockGoals.length - 1)
                  Divider(color: context.colors.outlineVariant, height: 1),
              ],
            ],
          ),
        ),
        const SizedBox(height: WsSpacing.md),
        Text(
          '${draft.goals.length} selected',
          style: context.text.bodySmall?.copyWith(color: context.ws.caption),
        ),
      ],
    );
  }
}
