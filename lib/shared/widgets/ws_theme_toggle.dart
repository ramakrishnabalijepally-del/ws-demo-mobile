import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme/theme.dart';

/// A one-tap light/dark switch for an app bar.
///
/// The full control — including "follow my device" — lives in Settings >
/// Appearance. This is the shortcut, because switching theme is something
/// people do while looking at a screen, not while sitting in a settings menu.
///
/// The icon shows **what you will get**, not what you are in: a moon while
/// you are in light means "tap for dark". That is the convention every OS
/// uses, and the tooltip says it in words for anyone it is not obvious to.
class WsThemeToggle extends ConsumerWidget {
  const WsThemeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watched so the icon flips the instant the theme does, including when the
    // change came from the Settings screen rather than from here.
    ref.watch(themeModeProvider);
    final notifier = ref.read(themeModeProvider.notifier);
    final isDark = notifier.isDark(context);

    return IconButton(
      tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
      onPressed: () => notifier.setDark(!isDark),
      icon: AnimatedSwitcher(
        duration: WsMotion.duration(context, WsMotion.fast),
        transitionBuilder: (child, animation) => RotationTransition(
          turns: Tween<double>(begin: 0.75, end: 1).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: Icon(
          isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          // Keyed so AnimatedSwitcher sees a genuinely different child.
          key: ValueKey<bool>(isDark),
        ),
      ),
    );
  }
}
