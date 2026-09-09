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
        title: const Text('Settlement'),
        actions: const [WsThemeToggle()],
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
                  leading:
                      const WsIconTile(icon: Icons.event_available_rounded),
                  title: 'Appointments',
                  subtitle: 'Consultations with licensed RCICs',
                  onTap: () => context.push(Routes.appointments),
                ),
                Divider(color: context.colors.outlineVariant, height: 1),
                WsListRow(
                  leading: const WsIconTile(icon: Icons.menu_book_rounded),
                  title: 'Resources',
                  subtitle: 'Housing, money, health, language',
                  onTap: () => context.push(Routes.resources),
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
          Text(
            '${_done.length} of ${mockChecklist.length} done',
            style: context.text.bodySmall?.copyWith(color: context.ws.caption),
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
                child: done
                    ? Icon(
                        Icons.check_rounded,
                        size: 12,
                        color: context.colors.surface,
                      )
                    : null,
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

/// K3 — the consultation list.
class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Appointments')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          WsSpacing.xl,
          WsSpacing.lg,
          WsSpacing.xl,
          WsSpacing.xxxl,
        ),
        children: [
          WsBanner(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Talk to a licensed consultant',
                  style: context.text.titleMedium,
                ),
                const SizedBox(height: WsSpacing.xs),
                Text(
                  'Every consultant here is a Regulated Canadian Immigration '
                  'Consultant in good standing. WorkSettle does not give legal '
                  'advice; they do.',
                  style: context.text.bodySmall
                      ?.copyWith(color: context.colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(height: WsSpacing.xl),
          for (final consultation in mockConsultations)
            Padding(
              padding: const EdgeInsets.only(bottom: WsSpacing.md),
              child: WsCard(
                onTap: () => context.push(
                  Routes.withId(Routes.appointmentDetail, consultation.id),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(consultation.title, style: context.text.titleMedium),
                    const SizedBox(height: WsSpacing.xs),
                    Text(
                      consultation.summary,
                      style: context.text.bodySmall
                          ?.copyWith(color: context.ws.caption),
                    ),
                    const SizedBox(height: WsSpacing.md),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_outlined,
                          size: 14,
                          color: context.ws.placeholder,
                        ),
                        const SizedBox(width: WsSpacing.xs + 2),
                        Text(
                          '${consultation.minutes} min',
                          style: context.text.bodySmall
                              ?.copyWith(color: context.ws.caption),
                        ),
                        const Spacer(),
                        Text(
                          consultation.price == 0
                              ? 'Free'
                              : '\$${consultation.price}',
                          style: context.text.titleMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// K4 — one consultation, and booking it.
class AppointmentDetailScreen extends StatelessWidget {
  const AppointmentDetailScreen({required this.consultationId, super.key});

  final String consultationId;

  @override
  Widget build(BuildContext context) {
    final consultation =
        mockConsultations.where((c) => c.id == consultationId).firstOrNull;

    if (consultation == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Appointments')),
        body: WsEmptyState(
          icon: Icons.event_busy_outlined,
          headline: 'That consultation is not available',
          body: 'The list of what we currently offer is one screen back.',
          actionLabel: 'Back to appointments',
          onAction: () => context.pop(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Book a consultation')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          WsSpacing.xl,
          WsSpacing.lg,
          WsSpacing.xl,
          WsSpacing.huge,
        ),
        children: [
          Text(consultation.title, style: context.text.headlineLarge),
          const SizedBox(height: WsSpacing.md),
          Text(
            consultation.summary,
            style: context.text.bodyMedium
                ?.copyWith(color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(height: WsSpacing.xl),
          WsCard(
            child: Row(
              children: [
                const WsIconTile(icon: Icons.verified_user_rounded),
                const SizedBox(width: WsSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        consultation.consultant,
                        style: context.text.titleMedium,
                      ),
                      Text(
                        consultation.credential,
                        style: context.text.bodySmall
                            ?.copyWith(color: context.ws.caption),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: WsSpacing.md),
          WsCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Length',
                        style: context.text.bodyMedium
                            ?.copyWith(color: context.ws.caption),
                      ),
                    ),
                    Text(
                      '${consultation.minutes} minutes',
                      style: context.text.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                Divider(
                  color: context.colors.outlineVariant,
                  height: WsSpacing.xxl,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Price',
                        style: context.text.bodyMedium
                            ?.copyWith(color: context.ws.caption),
                      ),
                    ),
                    Text(
                      consultation.price == 0
                          ? 'Free'
                          : '\$${consultation.price} CAD',
                      style: context.text.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            WsSpacing.xl,
            WsSpacing.md,
            WsSpacing.xl,
            WsSpacing.lg,
          ),
          child: WsPrimaryButton(
            label: 'Book this',
            // TODO(backend): no calendar, no payment. This goes straight to the
            // confirmation so the flow is walkable.
            onPressed: () => context.push(Routes.appointmentBooked),
          ),
        ),
      ),
    );
  }
}

/// K5 — booking confirmed.
class AppointmentBookedScreen extends StatelessWidget {
  const AppointmentBookedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WsSuccessScreen(
      // A booking is a transaction settled, so it takes the filled ink disc.
      milestone: WsMilestone.settled,
      headline: 'Your consultation is booked',
      body: 'You will get a calendar invitation and a reminder the day before. '
          'Bring your questions written down — the time goes quickly.',
      primaryLabel: 'Back to Settlement',
      onPrimary: () => context.go(Routes.settlement),
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
