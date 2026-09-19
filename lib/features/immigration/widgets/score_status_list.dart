import 'package:flutter/material.dart';

import '../../../app/theme/theme.dart';
import '../../../shared/shared.dart';

/// One input a score is built from, and whether the candidate has given it.
class ScoreStatusItem {
  const ScoreStatusItem({
    required this.title,
    required this.icon,
    required this.done,
    required this.whereToFill,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool done;

  /// Where an unfilled item is answered — "In your profile", "Asked here".
  final String whereToFill;
  final VoidCallback onTap;
}

/// What is filled in and what is not, before a score can be worked out.
///
/// The open items come first, because they are the reason the reader is here.
/// Every row opens the form it is answered in, and the list is built from the
/// live profile, so a saved form moves its row across on the way back.
class ScoreStatusList extends StatelessWidget {
  const ScoreStatusList({required this.items, super.key});

  final List<ScoreStatusItem> items;

  @override
  Widget build(BuildContext context) {
    final open = items.where((item) => !item.done).toList();
    final filled = items.where((item) => item.done).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${filled.length} of ${items.length} filled in',
          style: context.text.titleMedium,
        ),
        const SizedBox(height: WsSpacing.sm),
        WsSegmentBar(total: items.length, completed: filled.length),
        if (open.isNotEmpty) ...[
          const SizedBox(height: WsSpacing.xxl),
          Text('Still to fill in', style: context.text.titleLarge),
          const SizedBox(height: WsSpacing.md),
          _Group(items: open),
        ],
        if (filled.isNotEmpty) ...[
          const SizedBox(height: WsSpacing.xxl),
          Text('Filled in', style: context.text.titleLarge),
          const SizedBox(height: WsSpacing.md),
          _Group(items: filled),
        ],
      ],
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.items});

  final List<ScoreStatusItem> items;

  @override
  Widget build(BuildContext context) {
    return WsCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (final (i, item) in items.indexed) ...[
            if (i > 0) Divider(color: context.colors.outlineVariant, height: 1),
            WsListRow(
              leading: WsIconTile(icon: item.icon),
              title: item.title,
              subtitle: item.done ? 'Complete' : item.whereToFill,
              trailing: Icon(
                item.done
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: WsIconSize.tick,
                semanticLabel: item.done ? 'Complete' : 'Not filled in',
                color: item.done
                    ? context.colors.onSurface
                    : context.ws.placeholder,
              ),
              onTap: item.onTap,
            ),
          ],
        ],
      ),
    );
  }
}
