import 'package:flutter/material.dart';

/// Spacing scale — a 4 px base unit.
/// `design/worksettle-design-system.md` section 5.
abstract final class WsSpacing {
  /// 4 — icon to label.
  static const double xs = 4;

  /// 8 — inside a pill.
  static const double sm = 8;

  /// 12 — between stacked cards.
  static const double md = 12;

  /// 16 — card padding.
  static const double lg = 16;

  /// 20 — screen gutter.
  static const double xl = 20;

  /// 24 — section gap.
  static const double xxl = 24;

  /// 32 — above a bottom CTA.
  static const double xxxl = 32;

  /// 48 — around a full-screen glyph.
  static const double huge = 48;

  /// The screen gutter, named for what it is.
  static const EdgeInsets gutter = EdgeInsets.symmetric(horizontal: xl);

  /// Card padding.
  static const EdgeInsets card = EdgeInsets.all(lg);
}

/// Corner radii.
///
/// **The radius encodes the shape of the thing.** Anything you press is a full
/// pill; anything that holds content is 16; anything you type into is 12. That
/// difference is how a button and an input stay distinguishable at a glance in
/// a form.
abstract final class WsRadii {
  /// Buttons, pills, avatars, toggles.
  static const double pill = 999;

  /// Cards, banners, sheets.
  static const double card = 16;

  /// List rows, the chat composer.
  static const double row = 14;

  /// Inputs, selects, icon tiles.
  static const double field = 12;

  /// Compact tiles, flag frames.
  static const double tileSmall = 10;

  /// The checkbox, and nothing else.
  static const double checkbox = 6;

  static const BorderRadius pillR = BorderRadius.all(Radius.circular(pill));
  static const BorderRadius cardR = BorderRadius.all(Radius.circular(card));
  static const BorderRadius rowR = BorderRadius.all(Radius.circular(row));
  static const BorderRadius fieldR = BorderRadius.all(Radius.circular(field));
  static const BorderRadius tileSmallR =
      BorderRadius.all(Radius.circular(tileSmall));
  static const BorderRadius checkboxR =
      BorderRadius.all(Radius.circular(checkbox));
}

/// Icon sizes, per design system section 7.
abstract final class WsIconSize {
  /// Module tile glyph.
  static const double moduleGlyph = 22;

  /// Bottom navigation.
  static const double nav = 21;

  /// Field leading icon.
  static const double field = 18;

  /// Row chevron.
  static const double chevron = 16;

  /// Button trailing arrow — inherits the button's text colour.
  static const double buttonArrow = 17;

  /// Checklist tick.
  static const double tick = 18;

  /// Glyph inside a state chip.
  static const double chipGlyph = 12;
}

/// The one accessibility floor that is not negotiable.
abstract final class WsTouch {
  /// Minimum touch target on every control, chevron rows included.
  static const double minTarget = 48;
}
