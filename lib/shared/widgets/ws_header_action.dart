import 'package:flutter/material.dart';

import '../../app/theme/theme.dart';

/// A plain glyph button at the right of a top bar — the Home bell, the
/// Profile gear.
///
/// Shared so the two sit on exactly the same spot: moving from Home to
/// Profile, the gear lands where the bell was. Use it with
/// [WsHeaderAction.toolbarHeight] and [WsHeaderAction.trailingInset] so the
/// height and the right margin match as well.
class WsHeaderAction extends StatelessWidget {
  const WsHeaderAction({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.badge = 0,
    super.key,
  });

  /// Taller than the default so a lockup and its tagline are not pressed
  /// against the content below. Every bar carrying a header action uses it.
  static const double toolbarHeight = kToolbarHeight + WsSpacing.lg;

  /// The gap after the last action: the same inset from the right edge as the
  /// profile avatar has from the left, so the bar is symmetrical.
  static const Widget trailingInset = SizedBox(
    width: WsSpacing.md + WsSpacing.sm,
  );

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  /// Unread count; nothing is drawn at zero.
  final int badge;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Badge(
        isLabelVisible: badge > 0,
        label: Text('$badge'),
        backgroundColor: context.colors.primary,
        textColor: context.colors.onPrimary,
        child: Icon(icon, color: context.colors.onSurface),
      ),
    );
  }
}
