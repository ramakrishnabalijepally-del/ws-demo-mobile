import 'package:flutter/material.dart';

/// Something the agent noticed on its own, without being asked.
///
/// **This is what makes the feature agentic rather than a chat box**: the
/// agent reads the whole profile — documents, language results, CRS factors,
/// job matches — and raises the things that are about to matter.
class AgentNotice {
  const AgentNotice({
    required this.id,
    required this.title,
    required this.detail,
    required this.icon,
    required this.actionLabel,
    required this.route,
    this.urgent = false,
  });

  final String id;
  final String title;
  final String detail;

  /// Outlined — these sit in list rows (`.agents/rules/01-stack.md`).
  final IconData icon;

  final String actionLabel;

  /// Where the reader fixes it. The agent always ends at a next move.
  final String route;

  /// The one notice worth acting on first. **At most one at a time** — a
  /// screen where everything is urgent has no hierarchy left.
  final bool urgent;
}

/// What the agent can do, said plainly. Shown on the hub so the reader knows
/// what it is for before they ask it anything.
const List<({IconData icon, String label})> mockAgentCapabilities = [
  (icon: Icons.person_search_outlined, label: 'Reads your whole profile'),
  (icon: Icons.notifications_active_outlined, label: 'Warns you before a date'),
  (icon: Icons.work_outline_rounded, label: 'Matches jobs to your skills'),
  (icon: Icons.calculate_outlined, label: 'Explains every CRS point'),
];
