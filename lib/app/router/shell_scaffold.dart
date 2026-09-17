import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/shared.dart';
import '../theme/theme.dart';

/// The five destinations.
///
/// **Home · Immigration · AI Agent · Jobs · Settlement.** The agent takes the
/// middle slot: it is the thumb's easiest reach and the first place the eye
/// lands, and it sits between the two things the product is actually about —
/// immigration on its left, jobs on its right.
///
/// **Profile is no longer a destination.** It moved to the avatar in the
/// leading slot of every tab's app bar, because five is the ceiling for a
/// bottom bar — a sixth tab leaves 60 dp per label on a 360 dp phone, and the
/// design system says labels never hide.
///
/// Active icon *and* label both go Settle Red; inactive is Grey 500. The
/// filled icon marks the active tab and the outline marks the rest — the two
/// Material icon styles doing the job the design system gives them
/// (`.agents/rules/01-stack.md`).
class ShellScaffold extends StatelessWidget {
  const ShellScaffold({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  /// The order here **is** the branch order in `app_router.dart`. Changing one
  /// without the other silently sends a tab to the wrong stack.
  static const List<({String label, IconData icon, IconData active})>
      destinations = [
    (
      label: 'Home',
      icon: Icons.home_outlined,
      active: Icons.home_rounded,
    ),
    (
      label: 'Immigration',
      icon: Icons.flight_takeoff_outlined,
      active: Icons.flight_takeoff_rounded,
    ),
    // TODO(assets): the client's agent logo replaces these two glyphs. The
    // placeholder lives in `WsAgentMark` so the tab and the screen change
    // together.
    (
      label: 'AI Agent',
      icon: WsAgentMark.navIcon,
      active: WsAgentMark.navIconActive,
    ),
    (
      label: 'Jobs',
      icon: Icons.work_outline_rounded,
      active: Icons.work_rounded,
    ),
    (
      label: 'Settlement',
      icon: Icons.checklist_outlined,
      active: Icons.checklist_rounded,
    ),
  ];

  void _onTap(int index) {
    // Tapping the active tab returns it to its root, which is what people
    // expect from a persistent bar.
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: context.colors.outlineVariant),
          ),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _onTap,
          destinations: [
            for (final d in destinations)
              NavigationDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.active),
                label: d.label,
                tooltip: d.label,
              ),
          ],
        ),
      ),
    );
  }
}
