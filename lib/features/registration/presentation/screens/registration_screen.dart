import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/theme.dart';
import '../../../../shared/shared.dart';
import '../../controllers/registration_controller.dart';
import '../widgets/step_basic_info.dart';
import '../widgets/step_contact.dart';
import '../widgets/step_goals.dart';
import '../widgets/step_job_categories.dart';
import '../widgets/step_profile_type.dart';
import '../widgets/step_review.dart';

/// C1–C7 — the registration flow.
///
/// Design system Pattern A: **one decision per screen, a segment bar
/// throughout, a full-width primary at the bottom, and a review screen before
/// anything is committed.** Every field entered is echoed back on the review
/// screen with an inline Edit link, so the user never has to go back through
/// the flow to change one answer.
class RegistrationScreen extends ConsumerWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(registrationProvider);
    final controller = ref.read(registrationProvider.notifier);

    return PopScope(
      // The step is the back target, not the screen — so Android's back gesture
      // walks the flow rather than dropping out of it.
      canPop: state.step == RegistrationStep.basicInfo,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) controller.back();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(state.step.title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'Back',
            onPressed: () {
              if (state.step == RegistrationStep.basicInfo) {
                context.go(Routes.signUp);
              } else {
                controller.back();
              }
            },
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(WsSpacing.xxl),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                WsSpacing.xl,
                0,
                WsSpacing.xl,
                WsSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WsSegmentBar(
                    total: state.totalSteps,
                    completed: state.stepNumber,
                  ),
                  const SizedBox(height: WsSpacing.sm),
                  Text(
                    'Step ${state.stepNumber} of ${state.totalSteps}',
                    style: context.text.bodySmall
                        ?.copyWith(color: context.ws.caption),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: switch (state.step) {
            RegistrationStep.basicInfo => const StepBasicInfo(),
            RegistrationStep.contact => const StepContact(),
            RegistrationStep.profileType => const StepProfileType(),
            RegistrationStep.goals => const StepGoals(),
            RegistrationStep.jobCategories => const StepJobCategories(),
            RegistrationStep.review => const StepReview(),
          },
        ),
      ),
    );
  }
}

/// The shape every registration step shares: scrolling content above, one
/// full-width primary pinned below.
class RegistrationStepScaffold extends StatelessWidget {
  const RegistrationStepScaffold({
    required this.headline,
    required this.supporting,
    required this.children,
    required this.primaryLabel,
    required this.onPrimary,
    super.key,
  });

  final String headline;
  final String supporting;
  final List<Widget> children;
  final String primaryLabel;

  /// Null disables the button — the step is incomplete.
  final VoidCallback? onPrimary;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              WsSpacing.xl,
              WsSpacing.sm,
              WsSpacing.xl,
              WsSpacing.xl,
            ),
            children: [
              Text(headline, style: context.text.headlineLarge),
              const SizedBox(height: WsSpacing.sm),
              Text(
                supporting,
                style: context.text.bodyMedium
                    ?.copyWith(color: context.colors.onSurfaceVariant),
              ),
              const SizedBox(height: WsSpacing.xxl),
              ...children,
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            WsSpacing.xl,
            WsSpacing.md,
            WsSpacing.xl,
            WsSpacing.xl,
          ),
          child: WsPrimaryButton(label: primaryLabel, onPressed: onPrimary),
        ),
      ],
    );
  }
}
