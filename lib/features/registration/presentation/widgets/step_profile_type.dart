import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/theme.dart';
import '../../../../shared/shared.dart';
import '../../controllers/registration_controller.dart';
import '../../data/mock_registration_options.dart';
import '../screens/registration_screen.dart';

/// C4 — Profile Type. One choice, as selection cards.
class StepProfileType extends ConsumerWidget {
  const StepProfileType({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(registrationProvider).draft;
    final controller = ref.read(registrationProvider.notifier);

    return RegistrationStepScaffold(
      headline: 'What brings you to Canada?',
      supporting: 'This decides which programs and checklists you see first. '
          'You can change it later.',
      primaryLabel: 'Continue',
      onPrimary: draft.profileType.isEmpty ? null : controller.next,
      children: [
        for (final type in mockProfileTypes) ...[
          WsSelectionCard(
            selected: draft.profileType == type.label,
            semanticLabel: '${type.label}. ${type.blurb}',
            onTap: () =>
                controller.update(draft.copyWith(profileType: type.label)),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(type.label, style: context.text.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        type.blurb,
                        style: context.text.bodySmall
                            ?.copyWith(color: context.ws.caption),
                      ),
                    ],
                  ),
                ),
                if (draft.profileType == type.label)
                  Icon(
                    Icons.check_circle_rounded,
                    color: context.colors.primary,
                  ),
              ],
            ),
          ),
          const SizedBox(height: WsSpacing.md),
        ],
      ],
    );
  }
}
