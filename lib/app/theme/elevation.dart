import 'package:flutter/material.dart';

import 'palette.dart';

/// Elevation. `design/worksettle-design-system.md` section 6.
///
/// **The product is nearly flat.** A card separates from the ground with a
/// hairline border first and a shadow second — the shadow alone is never the
/// boundary. In dark a black shadow does nothing, so elevation is carried by
/// the hairline plus a faint top highlight instead.
abstract final class WsShadows {
  /// Score cards, plan cards. 2–3 blur, 1 down, ink at 5%.
  static const List<BoxShadow> raised = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 3,
      offset: Offset(0, 1),
    ),
  ];

  /// Bottom sheet, app bar on scroll. 14 blur, 4 down, ink at 9%.
  static const List<BoxShadow> floating = [
    BoxShadow(
      color: Color(0x17000000),
      blurRadius: 14,
      offset: Offset(0, 4),
    ),
  ];

  /// Dialogs. 40 blur, 18 down, ink at 18%, over a 40% scrim.
  static const List<BoxShadow> modal = [
    BoxShadow(
      color: Color(0x2E000000),
      blurRadius: 40,
      offset: Offset(0, 18),
    ),
  ];

  /// The one exception to the flat rule: the primary button carries a coloured
  /// shadow so the call to action lifts off a white screen. Dropped on press.
  static const List<BoxShadow> primaryButton = [
    BoxShadow(
      color: WsPalette.redShadow,
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  // --- Dark ------------------------------------------------------------------
  // A black shadow on a black ground is invisible, so dark deepens the shadow
  // and adds a 1 px top highlight inside the top edge.

  static const List<BoxShadow> darkRaised = [
    BoxShadow(
      color: Color(0x8C000000),
      blurRadius: 3,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> darkFloating = [
    BoxShadow(
      color: Color(0x8C000000),
      blurRadius: 14,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> darkModal = [
    BoxShadow(
      color: Color(0xB8000000),
      blurRadius: 40,
      offset: Offset(0, 18),
    ),
  ];

  /// White at 5%, painted as a 1 px inset line along the top edge of a raised
  /// dark surface.
  static const Color darkTopHighlight = Color(0x0DFFFFFF);

  /// The scrim behind a modal: ink at 40%.
  static const Color scrim = Color(0x66000000);
}

/// Durations and curves. Motion is part of the design system, like colour —
/// there are no ad-hoc `Duration(milliseconds: 317)` values in widget code.
abstract final class WsMotion {
  /// Micro-interactions: a chip toggling, a check appearing.
  static const Duration fast = Duration(milliseconds: 150);

  /// The default: sheets, fades, selection states.
  static const Duration medium = Duration(milliseconds: 250);

  /// Entrances and page transitions.
  static const Duration slow = Duration(milliseconds: 400);

  /// The typing-dot stagger.
  static const Duration typingCycle = Duration(milliseconds: 1200);

  /// An authored entrance — one per screen, e.g. an onboarding slide
  /// assembling its cards.
  static const Duration focal = Duration(milliseconds: 900);

  /// The launch sequence: the globe resolving, then the lockup pulling into
  /// focus over it. Unhurried on purpose — the splash holds for
  /// [splashDwell] either way, so there is nothing to be gained by rushing the
  /// one moment the brand introduces itself.
  static const Duration splashSequence = Duration(milliseconds: 3000);

  /// How long the splash stays on screen before it hands over.
  ///
  /// Long by the standards of a splash, and deliberately so: the globe is the
  /// product's own story — people arriving in Canada from around the world —
  /// and the sequence needs room to be seen rather than glimpsed.
  static const Duration splashDwell = Duration(seconds: 6);

  /// How long the splash holds when reduced motion skips the sequence.
  static const Duration splashHold = Duration(milliseconds: 1200);

  /// One slow breath of the floating onboarding cards.
  static const Duration ambientFloat = Duration(milliseconds: 3200);

  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeOutQuart;
  static const Curve exit = Curves.easeInCubic;

  /// A soft, symmetric ramp for something that should *appear* rather than
  /// arrive — the splash lockup, and anything else where the eye should not be
  /// able to name the moment it started.
  ///
  /// [entrance] and [standard] both spend most of their travel in the first few
  /// frames, which is right for an object moving into place and wrong for a
  /// fade: it reads as a pop. This eases in and out, so opacity never jumps.
  static const Curve tender = Curves.easeInOutSine;

  /// A screen assembling several sections in order, e.g. the dashboard.
  static const Duration entranceSequence = Duration(milliseconds: 1300);

  /// Exponential ease-out for confident arrivals.
  static const Curve entrance = Cubic(0.16, 1, 0.3, 1);

  /// Maps a parent timeline [t] (0–1) onto a child window [begin]–[end], eased
  /// with [curve].
  ///
  /// A pure function rather than a `CurvedAnimation`, so widgets can derive a
  /// stagger in `build` without registering listeners they would have to
  /// dispose.
  static double staggered(
    double t,
    double begin,
    double end, {
    Curve curve = entrance,
  }) =>
      curve.transform(Interval(begin, end).transform(t));

  /// Honour the OS reduced-motion setting. An accessibility requirement, not a
  /// nicety — and the no-motion branch must end in the same final state.
  static bool reduced(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);

  /// A duration that collapses to zero when the reader has asked for less
  /// motion.
  static Duration duration(BuildContext context, Duration wanted) =>
      reduced(context) ? Duration.zero : wanted;
}
