import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/theme.dart';
import '../../../../shared/shared.dart';
import '../../animations/onboarding_motion.dart';

/// A1 — the splash. "Your Journey Starts Here", told once.
///
/// Hands over to the three onboarding slides once the globe sequence has
/// played.
///
/// The globe rises into place with Canada already facing the reader and turns
/// slowly, while red streaks run from Manila, Lagos, Colombo, Warsaw, Delhi
/// and Dubai and land on the Canadian cities they settled in. The wordmark
/// settles in beneath it as the first flights arrive.
///
/// It is the marketing site's hero globe, here — the same world, the same six
/// journeys — so a newcomer who came to the app from the site meets the same
/// object. The globe itself lives in [WsGlobe]; this screen only stages its
/// arrival.
///
/// The wordmark is scaled and faded as a whole — never redrawn or animated
/// letter by letter (design system section 1). Under reduced motion the globe
/// is simply there, routes drawn and still, and so is the wordmark.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sequence = AnimationController(
    vsync: this,
    duration: WsMotion.splashSequence,
  );

  /// Cancelled on dispose — a `mounted` guard stops the callback firing but
  /// leaves the timer itself alive, which outlives the screen if it is popped.
  Timer? _advance;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_advance != null) return;

    final reduced = WsMotion.reduced(context);
    if (reduced) {
      _sequence.value = 1;
    } else {
      _sequence.forward();
    }
    // A splash that never resolves is a hang, so leaving does not wait on the
    // animation's status — only on the clock. The globe would happily turn all
    // day.
    //
    // Reduced motion keeps the short hold: the dwell exists so the journeys can
    // be watched, and for a reader who has asked for less motion there is
    // nothing moving to watch.
    _advance = Timer(
      reduced ? WsMotion.splashHold : WsMotion.splashDwell,
      () {
        if (mounted) context.go(Routes.onboarding);
      },
    );
  }

  @override
  void dispose() {
    _advance?.cancel();
    _sequence.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // The globe takes the room the lockup does not, capped so it never
            // fills a tall screen edge to edge and never squeezes to nothing on
            // a short one.
            final diameter = _globeDiameter(constraints);
            // The column shrink-wraps to its widest child — the globe — so
            // without this it sits flush against the left edge rather than
            // under the middle of the screen.
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Slightly above centre: the lockup reads as sitting under the
                  // globe rather than the two floating apart.
                  const Spacer(flex: 4),
                  _SplashGlobe(sequence: _sequence, diameter: diameter),
                  const SizedBox(height: WsSpacing.huge),
                  Padding(
                    padding: WsSpacing.gutter,
                    child: _SplashMark(sequence: _sequence),
                  ),
                  const Spacer(flex: 5),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  static double _globeDiameter(BoxConstraints constraints) {
    final byWidth = constraints.maxWidth * 0.82;
    final byHeight = constraints.maxHeight * 0.46;
    return byWidth < byHeight ? byWidth : byHeight;
  }
}

class _SplashGlobe extends StatelessWidget {
  const _SplashGlobe({required this.sequence, required this.diameter});

  final Animation<double> sequence;
  final double diameter;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: diameter,
      height: diameter,
      // The globe paints continuously; boundary it so it never drags the
      // wordmark into its repaints.
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: sequence,
          child: const WsGlobe(),
          builder: (context, child) {
            // Same split as the lockup: a soft fade, an eased-out scale, so
            // the globe resolves out of the page instead of blinking on.
            final fade = WsMotion.staggered(
              sequence.value,
              0,
              0.7,
              curve: WsMotion.tender,
            );
            final arrived = staggered(sequence.value, 0, 0.62);
            return Opacity(
              opacity: fade,
              child: Transform.scale(scale: 0.9 + 0.1 * arrived, child: child),
            );
          },
        ),
      ),
    );
  }
}

/// The lockup's entrance.
///
/// The artwork is scaled and faded **as a whole** — never redrawn, re-lettered
/// or re-coloured (design system section 1) — so opacity and scale are the
/// only two channels there are. What makes it read as considered rather than
/// as a cross-fade is that they run on different curves over a long window:
/// just under two seconds, which the splash can well afford.
///
/// A defocus-to-sharp reveal was tried here and removed. Blurring ink on a
/// white ground at any sigma large enough to notice turns the letters and the
/// tagline into a grey smudge — it reads as dirty, not soft.
class _SplashMark extends StatelessWidget {
  const _SplashMark({required this.sequence});

  final Animation<double> sequence;

  /// How small it starts. Enough to feel it breathe into place, not enough to
  /// look like it flew in.
  static const double _from = 0.92;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: sequence,
      child: const WsWordmark(width: 220),
      builder: (context, child) {
        // Symmetric and slow: there is no frame where the mark suddenly
        // exists, and none where it suddenly stops arriving.
        final appear = WsMotion.staggered(
          sequence.value,
          0.3,
          0.92,
          curve: WsMotion.tender,
        );
        // Runs past the fade on the exponential ease-out, so the last of the
        // movement happens under a mark that is already fully opaque — a long
        // tail settling rather than a scale that lands with the fade.
        final settle = staggered(sequence.value, 0.3, 1);
        return Opacity(
          opacity: appear,
          child: Transform.scale(
            scale: _from + (1 - _from) * settle,
            child: child,
          ),
        );
      },
    );
  }
}
