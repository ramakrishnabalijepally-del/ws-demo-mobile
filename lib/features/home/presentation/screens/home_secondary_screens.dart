import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/theme.dart';
import '../../../../shared/models/ws_module.dart';
import '../../../../shared/shared.dart';
import '../../data/mock_home.dart';
import '../../models/tip.dart';
import '../widgets/module_grid.dart';
import '../widgets/tip_card.dart';

/// D2 — notifications.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  static IconData _glyph(NotificationKind kind) => switch (kind) {
        NotificationKind.application => Icons.description_outlined,
        NotificationKind.job => Icons.work_outline_rounded,
        NotificationKind.immigration => Icons.flight_takeoff_outlined,
        NotificationKind.message => Icons.chat_bubble_outline_rounded,
        NotificationKind.system => Icons.checklist_outlined,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: mockNotifications.isEmpty
          ? const WsEmptyState(
              icon: Icons.notifications_none_rounded,
              headline: 'Nothing new',
              body: 'Updates on your applications and immigration programs '
                  'will appear here.',
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: WsSpacing.sm),
              itemCount: mockNotifications.length,
              separatorBuilder: (_, __) =>
                  Divider(color: context.colors.outlineVariant, height: 1),
              itemBuilder: (context, i) {
                final n = mockNotifications[i];
                return WsListRow(
                  leading: WsIconTile(
                    icon: _glyph(n.kind),
                    size: WsTileSize.compact,
                  ),
                  title: n.title,
                  subtitle: n.time,
                  // Unread is carried by a dot and a weight, not a colour.
                  trailing: n.unread
                      ? Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: context.colors.primary,
                          ),
                        )
                      : null,
                  chevron: false,
                  onTap: () {},
                );
              },
            ),
    );
  }
}

/// D3 — the tips list.
class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tips for you')),
      body: ListView.separated(
        padding: const EdgeInsets.all(WsSpacing.xl),
        itemCount: mockTips.length,
        separatorBuilder: (_, __) => const SizedBox(height: WsSpacing.md),
        itemBuilder: (context, i) => TipCard(
          tip: mockTips[i],
          onTap: () =>
              context.push(Routes.withId(Routes.tipArticle, mockTips[i].id)),
        ),
      ),
    );
  }
}

/// D4 — a tip article.
class TipArticleScreen extends StatelessWidget {
  const TipArticleScreen({required this.tipId, super.key});

  final String tipId;

  @override
  Widget build(BuildContext context) {
    final tip = mockTips.where((t) => t.id == tipId).firstOrNull;

    if (tip == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tips')),
        body: WsEmptyState(
          icon: Icons.article_outlined,
          headline: 'That article has moved',
          body: 'It is no longer available. The rest are still here.',
          actionLabel: 'Back to tips',
          onAction: () => context.pop(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Tips for you')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          WsSpacing.xl,
          WsSpacing.lg,
          WsSpacing.xl,
          WsSpacing.huge,
        ),
        children: [
          Text(tip.title, style: context.text.headlineLarge),
          const SizedBox(height: WsSpacing.md),
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: context.ws.verdictTintedSurface,
                child: Text(
                  tip.authorName.split(' ').map((w) => w[0]).take(2).join(),
                  style: context.text.labelLarge,
                ),
              ),
              const SizedBox(width: WsSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(tip.authorName, style: context.text.titleMedium),
                    Text(
                      '${tip.authorRole} · ${tip.readMinutes} min read',
                      style: context.text.bodySmall
                          ?.copyWith(color: context.ws.caption),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: WsSpacing.xxl),
          for (final paragraph in tip.body) ...[
            Text(
              paragraph,
              style: context.text.bodyMedium
                  ?.copyWith(color: context.colors.onSurfaceVariant),
            ),
            const SizedBox(height: WsSpacing.lg),
          ],
        ],
      ),
    );
  }
}

/// D5 — the feature hub: all seven modules, two per row.
class FeatureHubScreen extends StatelessWidget {
  const FeatureHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your tools')),
      body: ListView(
        padding: const EdgeInsets.all(WsSpacing.xl),
        children: [
          Text(
            'Seven ways WorkSettle helps',
            style: context.text.titleLarge,
          ),
          const SizedBox(height: WsSpacing.sm),
          Text(
            'Basic profile and job search are always free.',
            style: context.text.bodyMedium
                ?.copyWith(color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(height: WsSpacing.xxl),
          const ModuleGrid(modules: WsModule.values),
        ],
      ),
    );
  }
}
