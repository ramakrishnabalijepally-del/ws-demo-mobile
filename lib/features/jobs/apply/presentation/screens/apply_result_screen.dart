import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/routes.dart';
import '../../../../../shared/shared.dart';

/// F5 — the application went through.
///
/// It takes the **filled ink disc**, not the red ring: an application submitted
/// is an outcome settled, and the open ring is reserved for a step completed
/// (design system section 17). No confetti — confetti belongs to three screens
/// only, and this is not one of them.
class ApplySuccessScreen extends StatelessWidget {
  const ApplySuccessScreen({required this.jobId, super.key});

  final String jobId;

  @override
  Widget build(BuildContext context) {
    return WsSuccessScreen(
      milestone: WsMilestone.settled,
      headline: 'Application sent',
      body: 'You will see it under Applications, and we will tell you as soon '
          'as the employer opens it.',
      primaryLabel: 'See my applications',
      onPrimary: () => context.go(Routes.applications),
      secondaryLabel: 'Keep looking',
      onSecondary: () => context.go(Routes.jobs),
    );
  }
}

/// F6 — the application did not send.
///
/// The deck renders this as a red cross on a red disc. That is dropped: red
/// reports brand and action, never a state, and an app that flashes red at a
/// newcomer reads as rejection rather than as a network problem. The neutral
/// disc plus a sentence that names the fix does the same job without the alarm.
class ApplyFailedScreen extends StatelessWidget {
  const ApplyFailedScreen({required this.jobId, super.key});

  final String jobId;

  @override
  Widget build(BuildContext context) {
    return WsSuccessScreen(
      milestone: WsMilestone.settled,
      icon: Icons.wifi_off_rounded,
      headline: 'That did not send',
      body: 'Your application is saved as a draft. Check your connection and '
          'try again — nothing has been lost.',
      primaryLabel: 'Try again',
      onPrimary: () => context.go(Routes.withId(Routes.jobApply, jobId)),
      secondaryLabel: 'Back to jobs',
      onSecondary: () => context.go(Routes.jobs),
    );
  }
}
