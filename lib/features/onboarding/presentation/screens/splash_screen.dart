import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/theme.dart';
import '../../../../shared/shared.dart';

/// A1 — the splash.
///
/// The wordmark centred over a faded photograph of a newcomer. The photo is a
/// client asset that has not been supplied, so the ground is a tokened surface
/// for now.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  /// Cancelled on dispose — a `mounted` guard stops the callback firing but
  /// leaves the timer itself alive, which outlives the screen if it is popped.
  Timer? _advance;

  @override
  void initState() {
    super.initState();
    // A splash that never resolves is a hang, so this does not depend on the
    // fade having played.
    _advance = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) context.go(Routes.onboarding);
    });
  }

  @override
  void dispose() {
    _advance?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const _FadedPhoto(),
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: WsMotion.duration(context, WsMotion.slow),
              curve: WsMotion.standard,
              builder: (context, t, child) => Opacity(opacity: t, child: child),
              child: const WsWordmark(width: 220),
            ),
          ),
        ],
      ),
    );
  }
}

class _FadedPhoto extends StatelessWidget {
  const _FadedPhoto();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Knocked right back: the wordmark is the subject of this screen and
          // the photograph is atmosphere behind it.
          const Opacity(
            opacity: 0.16,
            child: WsHeroImage(
              hero: WsHero.jobs,
              alignment: Alignment.topCenter,
            ),
          ),
          // Fades the photo out top and bottom so the mark sits on clean ground.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  context.colors.surface,
                  context.colors.surface.withValues(alpha: 0.35),
                  context.colors.surface,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
