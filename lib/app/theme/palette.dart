import 'package:flutter/material.dart';

/// Raw colour values from `design/worksettle-design-system.md` section 2.
///
/// This is the ONLY file in the app allowed to hold a colour literal
/// (`.agents/rules/03-styling.md` rule 1). Nothing outside `lib/app/theme/`
/// may import it — widgets read colours through `Theme.of(context)` or the
/// [WsColors] extension.
///
/// One red, one true-neutral grey, and nothing else. There is no second accent
/// hue anywhere in the product.
abstract final class WsPalette {
  // ---------------------------------------------------------------------------
  // Settle Red — the brand and every primary action.
  // 500 is not the base: the brand red sits between 500 and 600 because it was
  // sampled from the filled CTA buttons across all seven design boards.
  // ---------------------------------------------------------------------------
  static const Color red100 = Color(0xFFFBE7E8);
  static const Color red200 = Color(0xFFF5CDCF);
  static const Color red300 = Color(0xFFEDA3A6);
  static const Color red400 = Color(0xFFEE6A6F);
  static const Color red500 = Color(0xFFF0353C);

  /// The brand. All primary fills, active nav, tab underline, focus ring.
  static const Color settleRed = Color(0xFFE4101B);

  static const Color red600 = Color(0xFFF0272E);
  static const Color red700 = Color(0xFFB00A13);
  static const Color red800 = Color(0xFF7E060D);
  static const Color red900 = Color(0xFF4A0308);

  /// The client artwork's red. Belongs to the logo FILE alone and is never used
  /// as a fill, text or border anywhere else. Kept here only so nobody
  /// "corrects" it to [settleRed].
  static const Color logoRed = Color(0xFFB80404);

  /// Inside the reversed logo file only.
  static const Color logoRedReverse = Color(0xFFEF4444);

  /// The primary button's coloured shadow: Settle Red at 28% (0x47).
  static const Color redShadow = Color(0x47E4101B);

  // ---------------------------------------------------------------------------
  // Grey — a TRUE neutral at zero saturation. Not blue-leaning: a blue cast is
  // itself a colour, and next to a warm red it reads as a second hue.
  // ---------------------------------------------------------------------------
  static const Color grey0 = Color(0xFFFFFFFF);
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF4F4F4);
  static const Color grey200 = Color(0xFFE6E6E6);
  static const Color grey300 = Color(0xFFD1D1D1);
  static const Color grey400 = Color(0xFFA3A3A3);
  static const Color grey500 = Color(0xFF757575);
  static const Color grey600 = Color(0xFF525252);
  static const Color grey700 = Color(0xFF3D3D3D);
  static const Color grey800 = Color(0xFF262626);
  static const Color grey900 = Color(0xFF111111);
  static const Color grey950 = Color(0xFF000000);

  // ---------------------------------------------------------------------------
  // Dark theme ramp. The ramp inverts; the brand red does not.
  // ---------------------------------------------------------------------------
  static const Color darkGround = Color(0xFF0A0A0A);
  static const Color darkCard = Color(0xFF141414);
  static const Color darkNeutral = Color(0xFF1C1C1C);
  static const Color darkHairline = Color(0xFF2A2A2A);
  static const Color darkRestRing = Color(0xFF3D3D3D);
  static const Color darkPlaceholder = Color(0xFF707070);
  static const Color darkCaption = Color(0xFF969696);
  static const Color darkBody = Color(0xFFB5B5B5);
  static const Color darkLabel = Color(0xFFE0E0E0);
  static const Color darkHeading = Color(0xFFF5F5F5);
  static const Color darkChipOutlineLabel = Color(0xFFCACACA);
  static const Color darkWarningTint = Color(0xFF161616);
  static const Color darkSelectedSurface = Color(0xFF2A1011);
  static const Color darkRedTint = Color(0xFF2E1213);

  // ---------------------------------------------------------------------------
  // Tinted surfaces. The palest surfaces in the product, so they invert to the
  // deepest.
  // ---------------------------------------------------------------------------
  static const Color selectedSurface = Color(0xFFFDF3F3);
  static const Color planProColumn = Color(0xFFFDF4F4);
  static const Color planProPlusColumn = Color(0xFFF6F6F6);
  static const Color scoreBreakdown = Color(0xFFF7F7F7);
  static const Color successTint = Color(0xFFEDEDED);

  static const Color darkPlanProColumn = Color(0xFF1E1414);
  static const Color darkPlanProPlusColumn = Color(0xFF171717);
  static const Color darkScoreBreakdown = Color(0xFF161616);
}
