import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/models/candidate.dart';
import '../../../../shared/shared.dart';
import '../../controllers/registration_controller.dart';
import '../screens/registration_screen.dart';

/// C6 — "What job do you want?", three to five categories.
class StepJobCategories extends ConsumerWidget {
  const StepJobCategories({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(registrationProvider).draft;
    final controller = ref.read(registrationProvider.notifier);

    return RegistrationStepScaffold(
      headline: 'What kind of work?',
      supporting: 'Choose $minJobCategories to $maxJobCategories categories '
          'and we will tune your job matches to them.',
      primaryLabel: 'Continue',
      onPrimary: draft.jobCategories.length >= minJobCategories
          ? controller.next
          : null,
      children: [
        WsJobCategoryPicker(
          selected: draft.jobCategories,
          onToggle: controller.toggleCategory,
        ),
      ],
    );
  }
}
