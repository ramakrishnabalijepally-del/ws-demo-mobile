import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/theme.dart';
import '../../../../shared/data/mock_candidate.dart';
import '../../../../shared/models/ws_module.dart';
import '../../../../shared/shared.dart';
import '../../data/mock_home.dart';
import '../widgets/module_grid.dart';
import '../widgets/quick_access.dart';
import '../widgets/tip_card.dart';

/// D1 — the dashboard. `design/worksettle-design-system.md` section 18.
///
/// **Assembled entirely from the shared components — no bespoke parts.** If a
/// screen cannot be built from that inventory, either the screen is wrong or
/// the system is missing something; both are worth stopping for.
///
/// The app bar carries the wordmark instead of a title, which is the one screen
/// where section 14 allows that.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final candidate = ref.watch(candidateProvider);
    final unread = mockNotifications.where((n) => n.unread).length;

    return Scaffold(
      appBar: AppBar(
        title: const WsWordmark(width: 150),
        actions: [
          const WsThemeToggle(),
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => context.push(Routes.notifications),
            icon: Badge(
              isLabelVisible: unread > 0,
              label: Text('$unread'),
              backgroundColor: context.colors.primary,
              textColor: context.colors.onPrimary,
              child: const Icon(Icons.notifications_none_rounded),
            ),
          ),
          const SizedBox(width: WsSpacing.sm),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          WsSpacing.xl,
          WsSpacing.lg,
          WsSpacing.xl,
          WsSpacing.xxxl,
        ),
        children: [
          // The three routes the client wants a newcomer to land on, before
          // anything else on the screen.
          const QuickAccess(),
          const SizedBox(height: WsSpacing.xxl),

          _ProfileHeader(
            name: candidate.firstName,
            strength: candidate.profileStrength,
          ),
          const SizedBox(height: WsSpacing.xxl),

          _SectionHeader(
            title: 'Your tools',
            actionLabel: 'See all',
            onAction: () => context.push(Routes.featureHub),
          ),
          const SizedBox(height: WsSpacing.md),
          // Four on the dashboard; the hub screen carries all seven.
          const ModuleGrid(
            modules: [
              WsModule.jobMatching,
              WsModule.crsPredictor,
              WsModule.assistant,
              WsModule.checklist,
            ],
          ),
          const SizedBox(height: WsSpacing.xxl),

          _SectionHeader(
            title: 'Tips for you',
            actionLabel: 'See all',
            onAction: () => context.push(Routes.tips),
          ),
          const SizedBox(height: WsSpacing.md),
          TipCard(
            tip: mockTips.first,
            onTap: () => context.push(
              Routes.withId(Routes.tipArticle, mockTips.first.id),
            ),
          ),
          const SizedBox(height: WsSpacing.xxl),

          _SectionHeader(
            title: 'Where you stand',
            actionLabel: 'Immigration',
            onAction: () => context.go(Routes.immigration),
          ),
          const SizedBox(height: WsSpacing.md),
          WsScoreCard(
            icon: WsModule.crsPredictor.icon,
            title: 'CRS Predictor',
            supporting: 'Comprehensive Ranking System',
            value: 468,
            maximum: 1200,
            verdict: WsVerdict.eligible,
            verdictLabel: 'Good Range',
            contextLine: 'Recent draws: 435–470',
            brandFill: true,
            showDisclaimer: true,
            onTap: () => context.go(Routes.crsResult),
          ),
        ],
      ),
    );
  }
}

/// The greeting and the profile-strength ring.
///
/// **This is the only ring in the product** — it reports completeness of one
/// thing, never a score (design system section 13).
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.name, required this.strength});

  final String name;
  final int strength;

  @override
  Widget build(BuildContext context) {
    return WsCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Hello, $name', style: context.text.titleLarge),
                const SizedBox(height: WsSpacing.xs),
                Text(
                  strength >= 90
                      ? 'Your profile is ready for every program.'
                      : 'Adding your language test would lift this the most.',
                  style: context.text.bodySmall
                      ?.copyWith(color: context.ws.caption),
                ),
              ],
            ),
          ),
          const SizedBox(width: WsSpacing.lg),
          WsRing(percent: strength, label: 'Profile strength'),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: context.text.titleLarge)),
        if (actionLabel != null)
          WsLink(label: actionLabel!, underline: false, onPressed: onAction),
      ],
    );
  }
}
