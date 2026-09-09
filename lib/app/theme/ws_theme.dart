import 'package:flutter/material.dart';

import 'dimensions.dart';
import 'elevation.dart';
import 'palette.dart';
import 'typography.dart';
import 'ws_colors.dart';

/// The two themes.
///
/// **Component appearance is set here, once.** A widget that styles a
/// `FilledButton` at its call site is a bug — change the component theme
/// instead (`.agents/rules/03-styling.md` rule 4).
///
/// The rule that shapes dark: **the ramp inverts, the brand red does not.** A
/// primary button is `#E4101B` with a white label in both themes, so the
/// product's one loud object looks the same to everyone. Red used as *text,
/// border or icon* does change, because it vibrates on a dark ground.
abstract final class WorkSettleTheme {
  static ThemeData get light => _build(
        brightness: Brightness.light,
        ws: WsColors.light,
        scheme: const ColorScheme.light(
          primary: WsPalette.settleRed,
          onPrimary: WsPalette.grey0,
          primaryContainer: WsPalette.red100,
          onPrimaryContainer: WsPalette.red800,
          secondary: WsPalette.grey900,
          onSecondary: WsPalette.grey0,
          surface: WsPalette.grey0,
          onSurface: WsPalette.grey900,
          onSurfaceVariant: WsPalette.grey600,
          surfaceContainerLowest: WsPalette.grey0,
          surfaceContainerLow: WsPalette.grey50,
          surfaceContainer: WsPalette.grey50,
          surfaceContainerHigh: WsPalette.grey100,
          surfaceContainerHighest: WsPalette.grey100,
          outline: WsPalette.grey300,
          outlineVariant: WsPalette.grey200,
          inverseSurface: WsPalette.grey900,
          onInverseSurface: WsPalette.grey0,
          error: WsPalette.red700,
          onError: WsPalette.grey0,
          errorContainer: WsPalette.red100,
          onErrorContainer: WsPalette.red800,
        ),
        ground: WsPalette.grey50,
      );

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        ws: WsColors.dark,
        scheme: const ColorScheme.dark(
          // Unchanged: the fill and its label are the same in both themes.
          primary: WsPalette.settleRed,
          onPrimary: WsPalette.grey0,
          primaryContainer: WsPalette.darkRedTint,
          onPrimaryContainer: WsPalette.red400,
          secondary: WsPalette.darkHeading,
          onSecondary: WsPalette.darkCard,
          surface: WsPalette.darkCard,
          onSurface: WsPalette.darkHeading,
          onSurfaceVariant: WsPalette.darkBody,
          surfaceContainerLowest: WsPalette.darkGround,
          surfaceContainerLow: WsPalette.darkCard,
          surfaceContainer: WsPalette.darkCard,
          surfaceContainerHigh: WsPalette.darkNeutral,
          surfaceContainerHighest: WsPalette.darkNeutral,
          outline: WsPalette.darkRestRing,
          outlineVariant: WsPalette.darkHairline,
          inverseSurface: WsPalette.darkHeading,
          onInverseSurface: WsPalette.darkCard,
          error: WsPalette.red400,
          onError: WsPalette.darkCard,
          errorContainer: WsPalette.darkRedTint,
          onErrorContainer: WsPalette.red400,
        ),
        ground: WsPalette.darkGround,
      );

  static ThemeData _build({
    required Brightness brightness,
    required WsColors ws,
    required ColorScheme scheme,
    required Color ground,
  }) {
    final TextTheme text = WsTypography.textTheme(scheme.onSurface);
    final BorderSide hairline = BorderSide(color: scheme.outlineVariant);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: ground,
      canvasColor: ground,
      textTheme: text,
      fontFamily: WsTypography.family,
      extensions: <ThemeExtension<dynamic>>[ws],
      splashFactory: InkSparkle.splashFactory,

      // --- App bar -----------------------------------------------------------
      // Back chevron left, title centred at 16/800, at most two trailing icons.
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: text.titleMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
        iconTheme: IconThemeData(color: scheme.onSurface, size: 22),
      ),

      // --- Buttons — every one of them a full pill --------------------------
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return scheme.primary.withValues(alpha: 0.45);
            }
            if (states.contains(WidgetState.pressed)) return WsPalette.red700;
            if (states.contains(WidgetState.hovered)) return WsPalette.red600;
            return scheme.primary;
          }),
          foregroundColor: WidgetStatePropertyAll(scheme.onPrimary),
          textStyle: WidgetStatePropertyAll(
            WsTypography.button(scheme.onPrimary),
          ),
          minimumSize: const WidgetStatePropertyAll(
            Size.fromHeight(WsTouch.minTarget),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: WsSpacing.xxl),
          ),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: WsRadii.pillR),
          ),
          elevation: const WidgetStatePropertyAll(0),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(ws.redOnSurface),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) return WsPalette.red200;
            if (states.contains(WidgetState.hovered)) return ws.redTint;
            return Colors.transparent;
          }),
          side: WidgetStatePropertyAll(
            BorderSide(color: scheme.primary, width: 1.5),
          ),
          textStyle: WidgetStatePropertyAll(
            WsTypography.button(ws.redOnSurface),
          ),
          minimumSize: const WidgetStatePropertyAll(
            Size.fromHeight(WsTouch.minTarget),
          ),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: WsRadii.pillR),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(ws.redOnSurface),
          textStyle: WidgetStatePropertyAll(
            WsTypography.button(ws.redOnSurface).copyWith(fontSize: 14),
          ),
          minimumSize: const WidgetStatePropertyAll(Size(0, WsTouch.minTarget)),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: WsRadii.pillR),
          ),
        ),
      ),

      // --- Cards — hairline first, shadow second ----------------------------
      cardTheme: CardThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: WsRadii.cardR,
          side: hairline,
        ),
      ),

      // --- Forms — the label sits above the field and stays visible ----------
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: WsSpacing.lg,
          vertical: 14,
        ),
        hintStyle: text.bodyMedium?.copyWith(color: ws.placeholder),
        helperStyle: text.bodySmall?.copyWith(color: ws.caption),
        errorStyle: text.bodySmall?.copyWith(
          color: scheme.error,
          fontWeight: FontWeight.w600,
        ),
        prefixIconColor: ws.placeholder,
        suffixIconColor: ws.placeholder,
        border: OutlineInputBorder(
          borderRadius: WsRadii.fieldR,
          borderSide: BorderSide(color: scheme.outlineVariant, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: WsRadii.fieldR,
          borderSide: BorderSide(color: scheme.outlineVariant, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: WsRadii.fieldR,
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: WsRadii.fieldR,
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: WsRadii.fieldR,
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
      ),

      // --- Controls ---------------------------------------------------------
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return scheme.primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStatePropertyAll(scheme.onPrimary),
        side: BorderSide(color: scheme.outline, width: 2),
        shape: const RoundedRectangleBorder(borderRadius: WsRadii.checkboxR),
        materialTapTargetSize: MaterialTapTargetSize.padded,
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return scheme.primary;
          return scheme.outline;
        }),
        materialTapTargetSize: MaterialTapTargetSize.padded,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStatePropertyAll(scheme.surface),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return scheme.primary;
          return scheme.outline;
        }),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),

      // --- Chips ------------------------------------------------------------
      // The verdict ladder is WsVerdictChip, not this: `ChipTheme` covers the
      // plain filter chips only.
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surface,
        selectedColor: scheme.primary,
        checkmarkColor: scheme.onPrimary,
        labelStyle: WsTypography.chip(scheme.onSurface),
        secondaryLabelStyle: WsTypography.chip(scheme.onPrimary),
        side: hairline,
        shape: const RoundedRectangleBorder(borderRadius: WsRadii.pillR),
        padding: const EdgeInsets.symmetric(
          horizontal: WsSpacing.md,
          vertical: WsSpacing.sm,
        ),
        showCheckmark: false,
      ),

      // --- Navigation -------------------------------------------------------
      // Five fixed destinations. Active icon AND label both go Settle Red;
      // labels never hide.
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        elevation: 0,
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: WsIconSize.nav,
            color: selected ? scheme.primary : ws.caption,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return text.labelSmall?.copyWith(
            color: selected ? scheme.primary : ws.caption,
            letterSpacing: 0,
          );
        }),
      ),

      // The underline is the only indicator — no pill, no fill.
      tabBarTheme: TabBarThemeData(
        labelColor: scheme.primary,
        unselectedLabelColor: ws.caption,
        labelStyle: text.labelLarge,
        unselectedLabelStyle: text.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        indicatorSize: TabBarIndicatorSize.label,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: scheme.primary, width: 2.5),
          insets: const EdgeInsets.symmetric(horizontal: 2),
        ),
        dividerColor: scheme.outlineVariant,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      ),

      // --- Surfaces ---------------------------------------------------------
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalBarrierColor: WsShadows.scrim,
        showDragHandle: true,
        dragHandleColor: scheme.outline,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(WsRadii.card),
          ),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        barrierColor: WsShadows.scrim,
        shape: const RoundedRectangleBorder(borderRadius: WsRadii.cardR),
        titleTextStyle: text.titleMedium,
        contentTextStyle: text.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),

      // Track height 8, radius 999, Grey 200 track.
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.onSurface,
        linearTrackColor: scheme.outlineVariant,
        linearMinHeight: 8,
        circularTrackColor: scheme.outlineVariant,
      ),

      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: WsSpacing.lg,
          vertical: WsSpacing.sm,
        ),
        minVerticalPadding: WsSpacing.md,
        titleTextStyle: text.titleMedium,
        subtitleTextStyle: text.bodySmall?.copyWith(color: ws.caption),
        iconColor: ws.placeholder,
        shape: const RoundedRectangleBorder(borderRadius: WsRadii.rowR),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: text.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
        ),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: WsRadii.rowR),
      ),

      iconTheme: IconThemeData(color: scheme.onSurface, size: 22),
    );
  }
}
