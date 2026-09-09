import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worksettle_mobile/app/theme/theme.dart';

/// Verifies the two themes actually produce the contrast ratios
/// `design/worksettle-design-system.md` section 21 measured.
///
/// This is the check that a screenshot cannot give you: it catches a token
/// wired to the wrong `ColorScheme` role, which looks plausible on screen and
/// fails an accessibility audit later.
void main() {
  /// WCAG 2.1 relative luminance.
  double luminance(Color c) {
    double channel(double v) {
      final s = v;
      return s <= 0.03928
          ? s / 12.92
          : math.pow((s + 0.055) / 1.055, 2.4) as double;
    }

    return 0.2126 * channel(c.r) +
        0.7152 * channel(c.g) +
        0.0722 * channel(c.b);
  }

  double ratio(Color a, Color b) {
    final la = luminance(a);
    final lb = luminance(b);
    final hi = math.max(la, lb);
    final lo = math.min(la, lb);
    return (hi + 0.05) / (lo + 0.05);
  }

  void expectRatio(
    String what,
    Color fg,
    Color bg,
    double documented,
  ) {
    final actual = ratio(fg, bg);
    expect(
      actual,
      closeTo(documented, 0.15),
      reason: '$what should measure $documented:1, measured '
          '${actual.toStringAsFixed(2)}:1',
    );
  }

  group('light theme contrast', () {
    final t = WorkSettleTheme.light;
    final c = t.colorScheme;
    final ws = t.extension<WsColors>()!;

    test('headings and primary text — 18.88:1 AAA', () {
      expectRatio('onSurface on surface', c.onSurface, c.surface, 18.88);
    });

    test('body copy on cards — 7.81:1 AAA', () {
      expectRatio(
        'onSurfaceVariant on surface',
        c.onSurfaceVariant,
        c.surface,
        7.81,
      );
    });

    test('supporting lines and captions — 4.61:1 AA', () {
      expectRatio('caption on surface', ws.caption, c.surface, 4.61);
    });

    test('primary button label — 4.78:1 AA', () {
      expectRatio('onPrimary on primary', c.onPrimary, c.primary, 4.78);
    });

    test('red text at body size uses Red 700, not the base — 7.24:1 AAA', () {
      expectRatio('redOnSurface on surface', ws.redOnSurface, c.surface, 7.24);
    });

    test('module glyph on its tile — one pair for all seven, 17.17:1', () {
      expectRatio(
        'moduleBase on moduleTint',
        ws.moduleBase,
        ws.moduleTint,
        17.17,
      );
    });

    test('filled verdict chip label — 18.88:1', () {
      expectRatio(
        'verdictFilledLabel on verdictFilledSurface',
        ws.verdictFilledLabel,
        ws.verdictFilledSurface,
        18.88,
      );
    });

    test('outlined verdict chip label — 10.86:1', () {
      expectRatio(
        'verdictOutlinedLabel on surface',
        ws.verdictOutlinedLabel,
        c.surface,
        10.86,
      );
    });

    test('tinted verdict chip label — 7.10:1', () {
      expectRatio(
        'verdictTintedLabel on verdictTintedSurface',
        ws.verdictTintedLabel,
        ws.verdictTintedSurface,
        7.10,
      );
    });
  });

  group('dark theme contrast', () {
    final t = WorkSettleTheme.dark;
    final c = t.colorScheme;
    final ws = t.extension<WsColors>()!;

    test('headings on a card — 16.90:1 AAA', () {
      expectRatio('onSurface on surface', c.onSurface, c.surface, 16.90);
    });

    test('body copy on cards — 8.98:1 AAA', () {
      expectRatio(
        'onSurfaceVariant on surface',
        c.onSurfaceVariant,
        c.surface,
        8.98,
      );
    });

    test('supporting lines — 6.23:1 AA', () {
      expectRatio('caption on surface', ws.caption, c.surface, 6.23);
    });

    test('the brand red is UNCHANGED where it fills a shape', () {
      expect(
        WorkSettleTheme.dark.colorScheme.primary,
        WorkSettleTheme.light.colorScheme.primary,
        reason: 'a primary button must look the same in both themes',
      );
      expectRatio('onPrimary on primary', c.onPrimary, c.primary, 4.78);
    });

    test('red as text lightens to #EE6A6F — 6.08:1 AA', () {
      expectRatio('redOnSurface on surface', ws.redOnSurface, c.surface, 6.08);
    });

    test('module glyph on its tile — 15.63:1', () {
      expectRatio(
        'moduleBase on moduleTint',
        ws.moduleBase,
        ws.moduleTint,
        15.63,
      );
    });
  });

  test('voice mode is black in BOTH themes — the one convergence', () {
    expect(
      WorkSettleTheme.light.extension<WsColors>()!.voiceGround,
      WorkSettleTheme.dark.extension<WsColors>()!.voiceGround,
    );
  });

  test('no hue leaks into the neutral ramp — greys are truly neutral', () {
    final ws = WorkSettleTheme.light.extension<WsColors>()!;
    final c = WorkSettleTheme.light.colorScheme;
    for (final entry in <String, Color>{
      'surface': c.surface,
      'onSurface': c.onSurface,
      'onSurfaceVariant': c.onSurfaceVariant,
      'outline': c.outline,
      'outlineVariant': c.outlineVariant,
      'caption': ws.caption,
      'placeholder': ws.placeholder,
      'fieldLabel': ws.fieldLabel,
      'moduleTint': ws.moduleTint,
    }.entries) {
      final col = entry.value;
      expect(
        col.r == col.g && col.g == col.b,
        isTrue,
        reason: '${entry.key} must be a true neutral (zero saturation), '
            'got r=${col.r} g=${col.g} b=${col.b}',
      );
    }
  });
}
