import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/providers.dart';
import '../../../../../app/router/routes.dart';
import '../../../../../shared/shared.dart';

/// B7 — account created.
///
/// One of the three full-screen moments in the product. It takes the **open red
/// ring**, because account creation is a step completed — the filled ink disc
/// is reserved for a transaction settled (design system section 17).
class AccountCreatedScreen extends ConsumerWidget {
  const AccountCreatedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WsSuccessScreen(
      milestone: WsMilestone.step,
      headline: 'Welcome to WorkSettle',
      body:
          'Your account is ready. Your profile is what the AI matches you on, '
          'so the more you add, the better it gets.',
      primaryLabel: 'Go to Dashboard',
      confetti: true,
      onPrimary: () {
        ref.read(signedInProvider.notifier).signIn();
        context.go(Routes.home);
      },
    );
  }
}
