import 'package:flutter/material.dart';

import 'palette.dart';

/// Every WorkSettle colour that `ColorScheme` has no honest role for.
///
/// Read it with `context.wsColors` (see `theme_context.dart`). Anything that
/// maps cleanly onto a `ColorScheme` role lives there instead, so this list
/// stays short:
///
/// | Role | `ColorScheme` |
/// | --- | --- |
/// | heading / primary text | `onSurface` |
/// | body copy | `onSurfaceVariant` |
/// | hairline border, progress track | `outlineVariant` |
/// | control rest ring | `outline` |
/// | assistant bubble, neutral pill | `surfaceContainerHighest` |
/// | user chat bubble, dark hero | `inverseSurface` / `onInverseSurface` |
@immutable
class WsColors extends ThemeExtension<WsColors> {
  const WsColors({
    required this.moduleBase,
    required this.moduleTint,
    required this.jobModuleBase,
    required this.jobModuleTint,
    required this.verdictFilledSurface,
    required this.verdictFilledLabel,
    required this.verdictOutlinedBorder,
    required this.verdictOutlinedLabel,
    required this.verdictTintedSurface,
    required this.verdictTintedLabel,
    required this.redOnSurface,
    required this.redTint,
    required this.selectedSurface,
    required this.placeholder,
    required this.caption,
    required this.fieldLabel,
    required this.bannerStart,
    required this.bannerEnd,
    required this.planProColumn,
    required this.planProPlusColumn,
    required this.scoreBreakdown,
    required this.voiceGround,
    required this.voiceForeground,
    required this.primaryShadow,
  });

  /// Module glyph colour. Ink for six of the seven — the seven-hue spectrum is
  /// retired and modules are told apart by their glyph, not by colour.
  final Color moduleBase;

  /// The tile behind a module glyph.
  final Color moduleTint;

  /// Job Matching alone keeps the brand red: it is the entry point to the
  /// product and the place the brand should appear.
  final Color jobModuleBase;
  final Color jobModuleTint;

  // The three-rung state ladder. No hue in it anywhere: filled outranks
  // outlined outranks tinted, and every chip carries its glyph.
  final Color verdictFilledSurface;
  final Color verdictFilledLabel;
  final Color verdictOutlinedBorder;
  final Color verdictOutlinedLabel;
  final Color verdictTintedSurface;
  final Color verdictTintedLabel;

  /// Red used as text, border or icon — never the base red, which fails
  /// contrast at body size on light and vibrates on dark.
  final Color redOnSurface;

  /// Tinted red ground: icon tiles, error field fills.
  final Color redTint;

  /// The fill behind a chosen selection card.
  final Color selectedSurface;

  /// Placeholders, chevrons, decorative icons. Never real content — it fails
  /// contrast on purpose.
  final Color placeholder;

  /// Supporting copy, captions, inactive nav.
  final Color caption;

  /// Field labels, which sit above the field and stay visible.
  final Color fieldLabel;

  /// The banner is the only surface in the product allowed a gradient.
  final Color bannerStart;
  final Color bannerEnd;

  final Color planProColumn;
  final Color planProPlusColumn;
  final Color scoreBreakdown;

  /// Voice mode is dark in BOTH themes — the one place the two converge rather
  /// than invert.
  final Color voiceGround;
  final Color voiceForeground;

  /// The primary button's coloured shadow, so the call to action lifts off a
  /// white screen. Settle Red at 28%, dropped on press.
  final Color primaryShadow;

  static const WsColors light = WsColors(
    moduleBase: WsPalette.grey900,
    moduleTint: WsPalette.grey100,
    jobModuleBase: WsPalette.settleRed,
    jobModuleTint: WsPalette.red100,
    verdictFilledSurface: WsPalette.grey900,
    verdictFilledLabel: WsPalette.grey0,
    verdictOutlinedBorder: WsPalette.grey300,
    verdictOutlinedLabel: WsPalette.grey700,
    verdictTintedSurface: WsPalette.grey100,
    verdictTintedLabel: WsPalette.grey600,
    redOnSurface: WsPalette.red700,
    redTint: WsPalette.red100,
    selectedSurface: WsPalette.selectedSurface,
    placeholder: WsPalette.grey400,
    caption: WsPalette.grey500,
    fieldLabel: WsPalette.grey800,
    bannerStart: WsPalette.planProColumn,
    bannerEnd: WsPalette.scoreBreakdown,
    planProColumn: WsPalette.planProColumn,
    planProPlusColumn: WsPalette.planProPlusColumn,
    scoreBreakdown: WsPalette.scoreBreakdown,
    voiceGround: WsPalette.grey950,
    voiceForeground: WsPalette.grey0,
    primaryShadow: WsPalette.redShadow,
  );

  static const WsColors dark = WsColors(
    moduleBase: WsPalette.darkHeading,
    moduleTint: WsPalette.darkNeutral,
    jobModuleBase: WsPalette.red400,
    jobModuleTint: WsPalette.darkRedTint,
    verdictFilledSurface: WsPalette.darkHeading,
    verdictFilledLabel: WsPalette.darkCard,
    verdictOutlinedBorder: WsPalette.darkRestRing,
    verdictOutlinedLabel: WsPalette.darkChipOutlineLabel,
    verdictTintedSurface: WsPalette.darkNeutral,
    verdictTintedLabel: WsPalette.darkLabel,
    redOnSurface: WsPalette.red400,
    redTint: WsPalette.darkRedTint,
    selectedSurface: WsPalette.darkSelectedSurface,
    placeholder: WsPalette.darkPlaceholder,
    caption: WsPalette.darkCaption,
    fieldLabel: WsPalette.darkLabel,
    bannerStart: WsPalette.darkSelectedSurface,
    bannerEnd: WsPalette.darkNeutral,
    planProColumn: WsPalette.darkPlanProColumn,
    planProPlusColumn: WsPalette.darkPlanProPlusColumn,
    scoreBreakdown: WsPalette.darkScoreBreakdown,
    voiceGround: WsPalette.grey950,
    voiceForeground: WsPalette.grey0,
    primaryShadow: WsPalette.redShadow,
  );

  @override
  WsColors copyWith({
    Color? moduleBase,
    Color? moduleTint,
    Color? jobModuleBase,
    Color? jobModuleTint,
    Color? verdictFilledSurface,
    Color? verdictFilledLabel,
    Color? verdictOutlinedBorder,
    Color? verdictOutlinedLabel,
    Color? verdictTintedSurface,
    Color? verdictTintedLabel,
    Color? redOnSurface,
    Color? redTint,
    Color? selectedSurface,
    Color? placeholder,
    Color? caption,
    Color? fieldLabel,
    Color? bannerStart,
    Color? bannerEnd,
    Color? planProColumn,
    Color? planProPlusColumn,
    Color? scoreBreakdown,
    Color? voiceGround,
    Color? voiceForeground,
    Color? primaryShadow,
  }) {
    return WsColors(
      moduleBase: moduleBase ?? this.moduleBase,
      moduleTint: moduleTint ?? this.moduleTint,
      jobModuleBase: jobModuleBase ?? this.jobModuleBase,
      jobModuleTint: jobModuleTint ?? this.jobModuleTint,
      verdictFilledSurface: verdictFilledSurface ?? this.verdictFilledSurface,
      verdictFilledLabel: verdictFilledLabel ?? this.verdictFilledLabel,
      verdictOutlinedBorder:
          verdictOutlinedBorder ?? this.verdictOutlinedBorder,
      verdictOutlinedLabel: verdictOutlinedLabel ?? this.verdictOutlinedLabel,
      verdictTintedSurface: verdictTintedSurface ?? this.verdictTintedSurface,
      verdictTintedLabel: verdictTintedLabel ?? this.verdictTintedLabel,
      redOnSurface: redOnSurface ?? this.redOnSurface,
      redTint: redTint ?? this.redTint,
      selectedSurface: selectedSurface ?? this.selectedSurface,
      placeholder: placeholder ?? this.placeholder,
      caption: caption ?? this.caption,
      fieldLabel: fieldLabel ?? this.fieldLabel,
      bannerStart: bannerStart ?? this.bannerStart,
      bannerEnd: bannerEnd ?? this.bannerEnd,
      planProColumn: planProColumn ?? this.planProColumn,
      planProPlusColumn: planProPlusColumn ?? this.planProPlusColumn,
      scoreBreakdown: scoreBreakdown ?? this.scoreBreakdown,
      voiceGround: voiceGround ?? this.voiceGround,
      voiceForeground: voiceForeground ?? this.voiceForeground,
      primaryShadow: primaryShadow ?? this.primaryShadow,
    );
  }

  @override
  WsColors lerp(covariant WsColors? other, double t) {
    if (other == null) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return WsColors(
      moduleBase: mix(moduleBase, other.moduleBase),
      moduleTint: mix(moduleTint, other.moduleTint),
      jobModuleBase: mix(jobModuleBase, other.jobModuleBase),
      jobModuleTint: mix(jobModuleTint, other.jobModuleTint),
      verdictFilledSurface:
          mix(verdictFilledSurface, other.verdictFilledSurface),
      verdictFilledLabel: mix(verdictFilledLabel, other.verdictFilledLabel),
      verdictOutlinedBorder:
          mix(verdictOutlinedBorder, other.verdictOutlinedBorder),
      verdictOutlinedLabel:
          mix(verdictOutlinedLabel, other.verdictOutlinedLabel),
      verdictTintedSurface:
          mix(verdictTintedSurface, other.verdictTintedSurface),
      verdictTintedLabel: mix(verdictTintedLabel, other.verdictTintedLabel),
      redOnSurface: mix(redOnSurface, other.redOnSurface),
      redTint: mix(redTint, other.redTint),
      selectedSurface: mix(selectedSurface, other.selectedSurface),
      placeholder: mix(placeholder, other.placeholder),
      caption: mix(caption, other.caption),
      fieldLabel: mix(fieldLabel, other.fieldLabel),
      bannerStart: mix(bannerStart, other.bannerStart),
      bannerEnd: mix(bannerEnd, other.bannerEnd),
      planProColumn: mix(planProColumn, other.planProColumn),
      planProPlusColumn: mix(planProPlusColumn, other.planProPlusColumn),
      scoreBreakdown: mix(scoreBreakdown, other.scoreBreakdown),
      voiceGround: mix(voiceGround, other.voiceGround),
      voiceForeground: mix(voiceForeground, other.voiceForeground),
      primaryShadow: mix(primaryShadow, other.primaryShadow),
    );
  }
}
