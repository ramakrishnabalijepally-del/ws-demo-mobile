import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/theme.dart';
import '../data/mock_candidate.dart';

/// The candidate's avatar, in the **leading slot of every tab's app bar**.
///
/// Profile left the bottom bar when the AI agent took its place, so this is
/// now the one way in. It sits top-left on all five tabs, which is what makes
/// it findable — a control that moves is a control people stop looking for.
///
/// It opens the profile above the shell, so the bottom bar stays put
/// underneath and Back returns you to the tab you were on.
class WsProfileButton extends ConsumerWidget {
  const WsProfileButton({super.key});

  /// Inside the 48 dp touch target the app bar gives its leading slot.
  static const double _diameter = 34;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final candidate = ref.watch(candidateProvider);

    return Semantics(
      button: true,
      label: 'Your profile',
      child: Padding(
        padding: const EdgeInsets.only(left: WsSpacing.sm),
        child: InkWell(
          onTap: () => context.push('/profile'),
          customBorder: const CircleBorder(),
          child: Center(
            child: Stack(
              children: [
                Container(
                  width: _diameter,
                  height: _diameter,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.ws.verdictTintedSurface,
                    border: Border.all(color: context.colors.outlineVariant),
                  ),
                  // TODO(assets): the deck uses photography here. Initials are
                  // the honest fallback until an avatar is uploaded.
                  child: Text(
                    candidate.initials,
                    style: context.text.labelLarge,
                  ),
                ),
                if (candidate.verified)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.colors.primary,
                        border:
                            Border.all(color: context.colors.surface, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
