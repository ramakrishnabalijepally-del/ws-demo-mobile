import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/theme.dart';
import '../../../../shared/shared.dart';
import '../../data/mock_settlement.dart';

/// K1 — the Settlement tab.
class SettlementScreen extends StatelessWidget {
  const SettlementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final done = mockChecklist.where((i) => i.done).length;

    return Scaffold(
      appBar: AppBar(
        leading: const WsProfileButton(),
        leadingWidth: WsTouch.minTarget + WsSpacing.md,
        title: const Text('Settlement'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          WsSpacing.xl,
          WsSpacing.lg,
          WsSpacing.xl,
          WsSpacing.xxxl,
        ),
        children: [
          WsCard(
            onTap: () => context.push(Routes.checklist),
            raised: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const WsIconTile(icon: Icons.checklist_rounded),
                    const SizedBox(width: WsSpacing.md),
                    Expanded(
                      child: Text(
                        'Smart Checklist',
                        style: context.text.titleMedium,
                      ),
                    ),
                    Text(
                      '$done of ${mockChecklist.length}',
                      style: context.text.bodySmall
                          ?.copyWith(color: context.ws.caption),
                    ),
                  ],
                ),
                const SizedBox(height: WsSpacing.lg),
                WsMeter(
                  value: done,
                  maximum: mockChecklist.length,
                  semanticLabel:
                      'Checklist: $done of ${mockChecklist.length} done',
                ),
                const SizedBox(height: WsSpacing.md),
                Text(
                  'Health coverage is the one worth doing this week — some '
                  'provinces have a waiting period.',
                  style: context.text.bodySmall
                      ?.copyWith(color: context.ws.caption),
                ),
              ],
            ),
          ),
          const SizedBox(height: WsSpacing.xxl),
          Text('Get help', style: context.text.titleLarge),
          const SizedBox(height: WsSpacing.md),
          WsCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                WsListRow(
                  leading: const WsIconTile(icon: Icons.menu_book_rounded),
                  title: 'Resources',
                  subtitle: 'Housing, money, health, language',
                  onTap: () => context.push(Routes.resources),
                ),
                Divider(color: context.colors.outlineVariant, height: 1),
                // Booking a consultant moved to the AI agent, which is what
                // works out that you need one. The row stays here so the path
                // from Settlement is not a dead end.
                WsListRow(
                  leading: const WsIconTile(icon: Icons.auto_awesome_rounded),
                  title: 'Book a consultation',
                  subtitle: 'Licensed RCICs, through the AI agent',
                  onTap: () => context.push(Routes.appointments),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// K2 — the Smart Checklist, grouped by phase.
class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  late final Set<String> _done = {
    for (final item in mockChecklist)
      if (item.done) item.id,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Checklist')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          WsSpacing.xl,
          WsSpacing.lg,
          WsSpacing.xl,
          WsSpacing.xxxl,
        ),
        children: [
          WsMeter(
            value: _done.length,
            maximum: mockChecklist.length,
            semanticLabel:
                '${_done.length} of ${mockChecklist.length} steps done',
          ),
          const SizedBox(height: WsSpacing.sm),
          // The count rolls to its new value as the meter above glides.
          AnimatedSwitcher(
            duration: WsMotion.duration(context, WsMotion.medium),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: animation.drive(
                  Tween(begin: const Offset(0, 0.4), end: Offset.zero),
                ),
                child: child,
              ),
            ),
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.centerLeft,
              children: [...previous, if (current != null) current],
            ),
            child: Text(
              '${_done.length} of ${mockChecklist.length} done',
              key: ValueKey(_done.length),
              style:
                  context.text.bodySmall?.copyWith(color: context.ws.caption),
            ),
          ),
          const SizedBox(height: WsSpacing.xxl),
          for (final phase in ChecklistPhase.values) ...[
            Text(phase.label, style: context.text.titleLarge),
            const SizedBox(height: WsSpacing.md),
            WsCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (final item
                      in mockChecklist.where((i) => i.phase == phase))
                    _ChecklistRow(
                      title: item.title,
                      detail: item.detail,
                      done: _done.contains(item.id),
                      onToggle: () => setState(() {
                        _done.contains(item.id)
                            ? _done.remove(item.id)
                            : _done.add(item.id);
                      }),
                    ),
                ],
              ),
            ),
            const SizedBox(height: WsSpacing.xxl),
          ],
        ],
      ),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({
    required this.title,
    required this.detail,
    required this.done,
    required this.onToggle,
  });

  final String title;
  final String detail;
  final bool done;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: done,
      button: true,
      child: InkWell(
        onTap: onToggle,
        child: Container(
          constraints: const BoxConstraints(minHeight: WsTouch.minTarget),
          padding: const EdgeInsets.all(WsSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // A filled ink disc when done, a hollow ring when not: the same
              // open-versus-filled signal the milestone screens use.
              AnimatedContainer(
                duration: WsMotion.duration(context, WsMotion.fast),
                width: WsIconSize.tick + 4,
                height: WsIconSize.tick + 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? context.colors.onSurface : Colors.transparent,
                  border: Border.all(
                    color: done
                        ? context.colors.onSurface
                        : context.colors.outline,
                    width: 2,
                  ),
                ),
                // The tick pops in when an item is done — a small reward for a
                // real step forward.
                child: AnimatedSwitcher(
                  duration: WsMotion.duration(context, WsMotion.medium),
                  switchInCurve: Curves.easeOutBack,
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: done
                      ? Icon(
                          Icons.check_rounded,
                          key: const ValueKey(true),
                          size: 12,
                          color: context.colors.surface,
                        )
                      : const SizedBox.shrink(key: ValueKey(false)),
                ),
              ),
              const SizedBox(width: WsSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: context.text.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: done
                            ? context.ws.caption
                            : context.colors.onSurface,
                        decoration: done ? TextDecoration.lineThrough : null,
                        decorationColor: context.ws.caption,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detail,
                      style: context.text.bodySmall
                          ?.copyWith(color: context.ws.caption),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// K6 — resources, with the Pro+ ones locked.
class ResourcesScreen extends ConsumerWidget {
  const ResourcesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tier = ref.watch(planTierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Resources')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          WsSpacing.xl,
          WsSpacing.lg,
          WsSpacing.xl,
          WsSpacing.xxxl,
        ),
        children: [
          for (final resource in mockResources)
            Padding(
              padding: const EdgeInsets.only(bottom: WsSpacing.md),
              child: WsCard(
                onTap: () {
                  final locked = resource.premium && tier != PlanTier.proPlus;
                  if (locked) {
                    context.push(Routes.paywall, extra: resource.title);
                  }
                },
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            resource.category.toUpperCase(),
                            style: context.text.labelSmall
                                ?.copyWith(color: context.ws.caption),
                          ),
                          const SizedBox(height: WsSpacing.xs),
                          Text(
                            resource.title,
                            style: context.text.titleMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            resource.summary,
                            style: context.text.bodySmall
                                ?.copyWith(color: context.ws.caption),
                          ),
                        ],
                      ),
                    ),
                    if (resource.premium && tier != PlanTier.proPlus) ...[
                      const SizedBox(width: WsSpacing.md),
                      Icon(
                        Icons.lock_outline_rounded,
                        size: 18,
                        color: context.ws.placeholder,
                        semanticLabel: 'Pro+ feature',
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
