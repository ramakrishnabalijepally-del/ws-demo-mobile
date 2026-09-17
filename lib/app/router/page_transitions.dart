import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/theme.dart';

/// The one screen transition for the whole app, configured once here rather
/// than per screen (`.agents/rules/04-animation.md` rule 7).
///
/// Android, web and desktop get Material's fade-forwards — the incoming screen
/// rises and fades in while the outgoing one steps back. iOS and macOS keep the
/// Cupertino slide, because its edge swipe-back is a gesture people rely on.
/// Under reduced motion every push is an instant cut.
const PageTransitionsTheme wsPageTransitions = PageTransitionsTheme(
  builders: {
    TargetPlatform.android: _MotionAware(FadeForwardsPageTransitionsBuilder()),
    TargetPlatform.fuchsia: _MotionAware(FadeForwardsPageTransitionsBuilder()),
    TargetPlatform.linux: _MotionAware(FadeForwardsPageTransitionsBuilder()),
    TargetPlatform.windows: _MotionAware(FadeForwardsPageTransitionsBuilder()),
    TargetPlatform.iOS: _MotionAware(CupertinoPageTransitionsBuilder()),
    TargetPlatform.macOS: _MotionAware(CupertinoPageTransitionsBuilder()),
  },
);

/// Delegates to [inner], except when the reader has asked for less motion.
class _MotionAware extends PageTransitionsBuilder {
  const _MotionAware(this.inner);

  final PageTransitionsBuilder inner;

  @override
  Duration get transitionDuration => inner.transitionDuration;

  @override
  Duration get reverseTransitionDuration => inner.reverseTransitionDuration;

  @override
  DelegatedTransitionBuilder? get delegatedTransition =>
      inner.delegatedTransition;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (WsMotion.reduced(context)) return child;
    return inner.buildTransitions(
      route,
      context,
      animation,
      secondaryAnimation,
      child,
    );
  }
}
