import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/routes.dart';
import '../../../../../shared/shared.dart';

/// Password saved. A completed step, so the open red ring; the only way on is
/// signing in again with the new password.
class PasswordResetSuccessScreen extends StatelessWidget {
  const PasswordResetSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // The reset is finished — Back must not return to the code screens.
      canPop: false,
      child: WsSuccessScreen(
        milestone: WsMilestone.step,
        icon: Icons.lock_open_rounded,
        headline: 'Password updated',
        body: 'Your password has been changed. Sign in with your new '
            'password to continue.',
        primaryLabel: 'Sign In',
        onPrimary: () => context.go(Routes.signIn),
      ),
    );
  }
}
