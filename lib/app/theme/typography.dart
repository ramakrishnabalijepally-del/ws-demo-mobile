import 'package:flutter/material.dart';

/// One family across the whole product: Plus Jakarta Sans.
///
/// `design/worksettle-design-system.md` section 4 names eight roles. They map
/// onto Flutter's `TextTheme` slots as below — use the Flutter name in widget
/// code, and the design system name when talking to a designer.
///
/// | Design system | `TextTheme` | Size / line | Weight |
/// | --- | --- | --- | --- |
/// | display | `headlineLarge` | 28 / 34 | 800 |
/// | title-lg | `titleLarge` | 22 / 28 | 800 |
/// | title | `titleMedium` | 17 / 23 | 700 |
/// | metric | `displaySmall` | 26 / 30 | 800, tabular |
/// | body | `bodyMedium` | 15 / 23 | 500 |
/// | label | `labelLarge` | 13 / 18 | 700 |
/// | caption | `bodySmall` | 12 / 17 | 500 |
/// | overline | `labelSmall` | 10 / 12 | 700 |
abstract final class WsTypography {
  /// Null until the font files land in `assets/fonts/`, at which point the
  /// platform sans stops being the fallback. See `assets/fonts/README.md`.
  // TODO(assets): set to 'PlusJakartaSans' once the four weights are bundled.
  static const String? family = null;

  /// Line height as a Flutter multiplier: line ÷ size.
  static double _h(double line, double size) => line / size;

  static TextTheme textTheme(Color ink) {
    return TextTheme(
      // display — screen titles.
      headlineLarge: TextStyle(
        fontFamily: family,
        fontSize: 28,
        height: _h(34, 28),
        fontWeight: FontWeight.w800,
        letterSpacing: 28 * -0.03,
        color: ink,
      ),
      // title-lg — section headings inside a screen.
      titleLarge: TextStyle(
        fontFamily: family,
        fontSize: 22,
        height: _h(28, 22),
        fontWeight: FontWeight.w800,
        letterSpacing: 22 * -0.025,
        color: ink,
      ),
      // title — card titles, app bar title, module names.
      titleMedium: TextStyle(
        fontFamily: family,
        fontSize: 17,
        height: _h(23, 17),
        fontWeight: FontWeight.w700,
        letterSpacing: 17 * -0.015,
        color: ink,
      ),
      // metric — scores. Tabular figures so digits share one width and a
      // column of numbers aligns.
      displaySmall: TextStyle(
        fontFamily: family,
        fontSize: 26,
        height: _h(30, 26),
        fontWeight: FontWeight.w800,
        letterSpacing: 26 * -0.03,
        fontFeatures: const [FontFeature.tabularFigures()],
        color: ink,
      ),
      // body — running copy, list rows, field values.
      bodyMedium: TextStyle(
        fontFamily: family,
        fontSize: 15,
        height: _h(23, 15),
        fontWeight: FontWeight.w500,
        color: ink,
      ),
      // label — field labels, tab labels.
      labelLarge: TextStyle(
        fontFamily: family,
        fontSize: 13,
        height: _h(18, 13),
        fontWeight: FontWeight.w700,
        color: ink,
      ),
      // caption — supporting lines, helper text.
      bodySmall: TextStyle(
        fontFamily: family,
        fontSize: 12,
        height: _h(17, 12),
        fontWeight: FontWeight.w500,
        color: ink,
      ),
      // overline — uppercase eyebrows, bottom-nav labels.
      labelSmall: TextStyle(
        fontFamily: family,
        fontSize: 10,
        height: _h(12, 10),
        fontWeight: FontWeight.w700,
        letterSpacing: 10 * 0.12,
        color: ink,
      ),
    );
  }

  /// The denominator beside a metric: `468 / 1200` — the 1200 half.
  static TextStyle denominator(Color caption) => TextStyle(
        fontFamily: family,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        fontFeatures: const [FontFeature.tabularFigures()],
        color: caption,
      );

  /// Button labels: 700 at 14.5.
  static TextStyle button(Color label) => TextStyle(
        fontFamily: family,
        fontSize: 14.5,
        height: _h(20, 14.5),
        fontWeight: FontWeight.w700,
        color: label,
      );

  /// State chips and badges: 700 at 11.5.
  static TextStyle chip(Color label) => TextStyle(
        fontFamily: family,
        fontSize: 11.5,
        height: _h(16, 11.5),
        fontWeight: FontWeight.w700,
        color: label,
      );

  /// Presence line, stepper numerals: 600 at 11.5.
  static TextStyle micro(Color label) => TextStyle(
        fontFamily: family,
        fontSize: 11.5,
        height: _h(16, 11.5),
        fontWeight: FontWeight.w600,
        color: label,
      );
}
