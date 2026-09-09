import 'package:flutter/material.dart';

import 'ws_colors.dart';

/// Shorthands so widget code reads as design intent rather than as plumbing.
///
/// `context.ws.moduleTint` instead of
/// `Theme.of(context).extension<WsColors>()!.moduleTint`.
extension WsThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get colors => Theme.of(this).colorScheme;

  TextTheme get text => Theme.of(this).textTheme;

  /// The WorkSettle colours `ColorScheme` has no role for.
  WsColors get ws => Theme.of(this).extension<WsColors>()!;

  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
