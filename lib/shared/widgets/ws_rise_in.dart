import 'package:flutter/material.dart';

import '../../app/theme/theme.dart';

/// Rises and fades [child] into place over the [begin]–[end] window of
/// [entrance], optionally breathing on [float] once it has arrived, and
/// drifting sideways by [drift] logical pixels (for parallax).
///
/// One parent controller drives a whole screen; each section picks its own
/// window, so a sequence stays one orchestrated moment rather than a dozen
/// independent timers.
///
/// The resting state is fully visible: when [entrance] is complete — which it
/// always is under reduced motion — nothing is offset or transparent.
class WsRiseIn extends StatelessWidget {
  const WsRiseIn({
    required this.entrance,
    required this.child,
    this.begin = 0,
    this.end = 1,
    this.fromScale = 1,
    this.float,
    this.floatPhase = 1,
    this.drift = 0,
    super.key,
  });

  /// How far a section travels as it rises into place.
  static const double distance = WsSpacing.xxl;

  /// How far a floating element drifts over one [WsMotion.ambientFloat].
  static const double floatAmplitude = WsSpacing.xs;

  final Animation<double> entrance;
  final Widget child;
  final double begin;
  final double end;

  /// Cards grow slightly as they land; text does not.
  final double fromScale;

  final Animation<double>? float;

  /// +1 or −1, so neighbouring elements breathe in opposition.
  final double floatPhase;

  final double drift;

  @override
  Widget build(BuildContext context) {
    final float = this.float;
    return AnimatedBuilder(
      animation: float == null ? entrance : Listenable.merge([entrance, float]),
      child: child,
      builder: (context, child) {
        final t = WsMotion.staggered(entrance.value, begin, end);
        final bob = float == null
            ? 0.0
            : (Curves.easeInOut.transform(float.value) - 0.5) *
                2 *
                floatAmplitude *
                floatPhase;
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(drift, (1 - t) * distance + bob),
            child: Transform.scale(
              scale: fromScale + (1 - fromScale) * t,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// Plays [child] into place once, the first time it is built — for things
/// that are not part of a screen-wide sequence: a new chat bubble, a result's
/// verdict, the first rows of a list.
///
/// [delay] is the fraction (0–1) of [duration] to wait before rising. Under
/// reduced motion the duration collapses to zero and [child] is simply there.
class WsAppear extends StatelessWidget {
  const WsAppear({
    required this.child,
    this.delay = 0,
    this.duration = WsMotion.slow,
    this.fromScale = 1,
    this.distance = WsRiseIn.distance / 2,
    this.alignment = Alignment.center,
    super.key,
  });

  final Widget child;
  final double delay;
  final Duration duration;
  final double fromScale;
  final double distance;

  /// The point [fromScale] grows from — a bubble grows from its tail corner.
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: WsMotion.duration(context, duration),
      child: child,
      builder: (context, value, child) {
        final t = WsMotion.staggered(value, delay.clamp(0.0, 0.95), 1);
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, (1 - t) * distance),
            child: Transform.scale(
              scale: fromScale + (1 - fromScale) * t,
              alignment: alignment,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// Cross-slides between the steps of a wizard — the CRS calculator,
/// registration. The incoming step fades in from slightly to the right; the
/// outgoing one leaves faster than it arrived.
class WsStepSwitcher extends StatelessWidget {
  const WsStepSwitcher({
    required this.stepKey,
    required this.child,
    super.key,
  });

  /// Changing this is what triggers the transition.
  final Object stepKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: WsMotion.duration(context, WsMotion.slow),
      reverseDuration: WsMotion.duration(context, WsMotion.fast),
      switchInCurve: WsMotion.entrance,
      switchOutCurve: WsMotion.exit,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: animation.drive(
            Tween(begin: const Offset(0.06, 0), end: Offset.zero),
          ),
          child: child,
        ),
      ),
      child: KeyedSubtree(key: ValueKey(stepKey), child: child),
    );
  }
}
