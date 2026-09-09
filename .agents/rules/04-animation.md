---
trigger: model_decision
description: Apply when writing, editing, or reviewing animation code — AnimationController, implicit animations, transitions, hero animations, page transitions, or scroll effects in Flutter.
---

# Animation — Flutter's own framework

Flutter ships a complete animation system. **Use it.** GSAP, Framer Motion and
every other web animation library are irrelevant here — if you are porting a
pattern from `ws-frontend`, port the *intent*, never the API.

**No animation package at all** — not `flutter_animate`, not `rive`, not
`lottie`. Everything the design system asks for (confetti, typing dots, the
processing timeline, the voice waveform, entrance sequences) is built from
`AnimationController`, the implicit widgets and `CustomPainter`. See
`01-stack.md`.

**Rule 1 — Reach for implicit animations first.** `AnimatedContainer`,
`AnimatedOpacity`, `AnimatedSwitcher`, `AnimatedAlign`, `TweenAnimationBuilder`
cover most of what a screen needs and cannot leak.

```dart
AnimatedOpacity(
  opacity: isVisible ? 1 : 0,
  duration: WsMotion.medium,
  curve: WsMotion.easeOut,
  child: child,
)
```

**Rule 2 — When you need a controller, dispose it.** An explicit
`AnimationController` requires `SingleTickerProviderStateMixin` (or
`TickerProviderStateMixin`) and a `dispose()` that disposes the controller.
An undisposed controller is a leak and a test failure.

```dart
class _HeroState extends State<Hero> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: WsMotion.slow,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

**Rule 3 — Durations and curves come from the theme.**
`lib/app/theme/motion.dart` defines `WsMotion.fast/medium/slow` and the standard
curves. No `Duration(milliseconds: 317)` scattered through widgets — motion is
part of the design system, like colour.

**Rule 4 — Non-trivial sequences live in `animations/`.** A multi-step or
reused sequence goes in `features/<name>/animations/<name>.dart` as a function or
small class returning the animations, so the widget stays readable.

**Rule 5 — Respect the OS reduced-motion setting.** This is an accessibility
requirement, not a nicety. Check it and provide a no-motion branch:

```dart
final reduceMotion = MediaQuery.disableAnimationsOf(context);
final duration = reduceMotion ? Duration.zero : WsMotion.medium;
```

Never animate content into view in a way that leaves it invisible when motion is
disabled — the reduced-motion branch must end in the same final state.

**Rule 6 — Animate cheap properties.** Opacity, transforms, and colour are
fine. Avoid animating anything that relayouts the whole subtree every frame
(intrinsic-sizing widgets inside a scroll view, `ListView` item heights). Use
`RepaintBoundary` around a continuously-animating element so it does not repaint
its siblings.

**Rule 7 — Page transitions belong to the router.** Configure them once in
`lib/app/router/`, not per screen. Do not hand-roll a transition that
`go_router` + `CustomTransitionPage` already gives you.

**Rule 8 — Motion must survive a hot restart and a scroll.** Nothing may depend
on an entrance animation having played: if a widget starts at `opacity: 0`, some
code path must always bring it to `1`, including when the screen is rebuilt
mid-animation.

## Sanity limits

Sixty frames per second is the budget. If a screen janks on a mid-range Android
device, the animation is wrong — no matter how good it looks in the simulator.
Prefer one orchestrated moment per screen over motion on every element.
