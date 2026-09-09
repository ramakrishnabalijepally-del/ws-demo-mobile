import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/theme.dart';

/// The five destinations, fixed for the life of the app.
/// `design/worksettle-design-system.md` section 14.
///
/// **Home · Jobs · Immigration · Settlement · Profile.** Everything else is
/// reached from inside one of them. Active icon *and* label both go Settle Red;
/// inactive is Grey 500. **Labels never hide.**
///
/// The filled icon marks the active tab and the outline marks the rest — the
/// two Material icon styles doing the job the design system gives them
/// (`.agents/rules/01-stack.md`).
class ShellScaffold extends StatelessWidget {
  const ShellScaffold({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static const List<({String label, IconData icon, IconData active})>
      destinations = [
    (
      label: 'Home',
      icon: Icons.home_outlined,
      active: Icons.home_rounded,
    ),
    (
      label: 'Jobs',
      icon: Icons.work_outline_rounded,
      active: Icons.work_rounded,
    ),
    (
      label: 'Immigration',
      icon: Icons.flight_takeoff_outlined,
      active: Icons.flight_takeoff_rounded,
    ),
    (
      label: 'Settlement',
      icon: Icons.checklist_outlined,
      active: Icons.checklist_rounded,
    ),
    (
      label: 'Profile',
      icon: Icons.person_outline_rounded,
      active: Icons.person_rounded,
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
