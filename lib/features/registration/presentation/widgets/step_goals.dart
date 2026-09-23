import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import '../../../../shared/shared.dart';
import '../../controllers/registration_controller.dart';
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
        WsGoalsChecklist(
          selected: draft.goals,
          onToggle: controller.toggleGoal,
        ),
      ],
    );
  }
}
