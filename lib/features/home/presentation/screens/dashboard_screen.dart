import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/theme.dart';
import '../../../../shared/controllers/crs_controller.dart';
import '../../../../shared/data/mock_candidate.dart';
import '../../../../shared/models/ws_module.dart';
import '../../../../shared/shared.dart';
import '../../data/mock_home.dart';
import '../widgets/module_grid.dart';
import '../widgets/quick_access.dart';

/// D1 — the dashboard. `design/worksettle-design-system.md` section 18.
///
/// **Assembled entirely from the shared components — no bespoke parts.** If a
/// screen cannot be built from that inventory, either the screen is wrong or
/// the system is missing something; both are worth stopping for.
///
/// The app bar carries the wordmark instead of a title, which is the one screen
/// where section 14 allows that.
///
/// On first arrival the screen assembles top to bottom from one controller:
/// the greeting lands and its strength ring fills, then the tools and the
/// explore banners follow. It plays once per visit to the tab's stack, and
/// under reduced motion everything is simply there.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: WsMotion.entranceSequence,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (WsMotion.reduced(context)) {
      _entrance.value = 1;
    } else if (_entrance.isDismissed) {
      _entrance.forward();
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final candidate = ref.watch(candidateProvider);
    final completion = ref.watch(profileCompletionProvider);
    final nextSection = completion.next;
    final unread = mockNotifications.where((n) => n.unread).length;

    return Scaffold(
      appBar: AppBar(
        // Taller than the default so the lockup and its tagline are not pressed
        // against the content below.
        toolbarHeight: kToolbarHeight + WsSpacing.lg,
        // Profile left the bottom bar when the AI agent took its place; the
        // avatar is now the way in, in the same slot on every tab.
        leading: const WsProfileButton(),
        leadingWidth: WsTouch.minTarget + WsSpacing.md,
        title: WsRiseIn(
          entrance: _entrance,
          end: 0.45,
          fromScale: 0.92,
          child: const WsWordmark(width: 150),
        ),
        actions: [
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
          WsSpacing.xxl,
          WsSpacing.xl,
          WsSpacing.xxxl,
        ),
        children: [
          WsRiseIn(
            entrance: _entrance,
            begin: 0.05,
            end: 0.5,
            fromScale: 0.96,
            child: _ProfileHeader(
              name: candidate.firstName,
              strength: completion.percent,
              hint: nextSection == null
                  ? 'Your profile is complete, so your CRS score is as '
                      'accurate as your answers.'
                  : 'Next: ${nextSection.title.toLowerCase()}. Tap to '
                      'finish your profile.',
              onTap: () => context.push(Routes.profileCompletion),
              entrance: _entrance,
            ),
          ),
          const SizedBox(height: WsSpacing.xxxl),

          WsRiseIn(
            entrance: _entrance,
            begin: 0.2,
            end: 0.6,
            child: _SectionHeader(
              title: 'Your tools',
              actionLabel: 'See all',
              onAction: () => context.push(Routes.featureHub),
            ),
          ),
          const SizedBox(height: WsSpacing.md),
          // Four on the dashboard; the hub screen carries all seven.
          ModuleGrid(
            modules: const [
              WsModule.jobMatching,
              WsModule.crsPredictor,
              WsModule.assistant,
              WsModule.checklist,
            ],
            entrance: _entrance,
          ),
          const SizedBox(height: WsSpacing.xxxl),

          // The three photo banners are a separate block from the tool cards.
          WsRiseIn(
            entrance: _entrance,
            begin: 0.4,
            end: 0.8,
            child: const _SectionHeader(title: 'Explore'),
          ),
          const SizedBox(height: WsSpacing.md),
          QuickAccess(entrance: _entrance),
        ],
      ),
    );
  }
}

/// The greeting and the profile-strength ring.
///
/// **This is the only ring in the product** — it reports completeness of one
/// thing, never a score (design system section 13). On arrival it sweeps from
/// empty while the figure counts up, and gives one small settle as it lands.
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.strength,
    required this.hint,
    required this.onTap,
    required this.entrance,
  });

  final String name;
  final int strength;

  /// Names the next profile section to finish.
  final String hint;

  /// Opens the profile checklist — the profile is what the scores are built
  /// from, so its strength leads straight to it.
  final VoidCallback onTap;

  final Animation<double> entrance;

  @override
  Widget build(BuildContext context) {
    return WsCard(
      raised: true,
      onTap: onTap,
      padding: const EdgeInsets.all(WsSpacing.xl),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Hello, $name', style: context.text.titleLarge),
                const SizedBox(height: WsSpacing.sm),
                Text(
                  hint,
                  style: context.text.bodySmall
                      ?.copyWith(color: context.ws.caption),
                ),
              ],
            ),
          ),
          const SizedBox(width: WsSpacing.lg),
          AnimatedBuilder(
            animation: entrance,
            builder: (context, _) {
              final fill = WsMotion.staggered(entrance.value, 0.15, 0.8);
              // A single soft bump once the sweep has arrived.
              final settle = const Interval(0.72, 1).transform(entrance.value);
              return Transform.scale(
                scale: 1 + 0.06 * math.sin(math.pi * settle),
                child: WsRing(
                  percent: (strength * fill).round(),
                  label: 'Profile strength',
                ),
              );
            },
          ),
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
