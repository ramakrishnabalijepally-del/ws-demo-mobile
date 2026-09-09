import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/routes.dart';
import '../../../../../app/theme/theme.dart';
import '../../../../../shared/shared.dart';
import '../../../controllers/jobs_controller.dart';
import '../../../models/job.dart';

/// Maps an application status onto the three-rung ladder.
///
/// **The deck's green / amber / red is gone.** Red is brand and action only,
/// and "Not Selected" in red reads as a rebuke — so it is an outlined chip,
/// the same rung as a status still in progress, with the explanation carrying
/// the actual news (design system sections 2 and 9).
({WsVerdict verdict, String label}) verdictFor(ApplicationStatus status) =>
    switch (status) {
      ApplicationStatus.offer => (verdict: WsVerdict.eligible, label: 'Offer'),
      ApplicationStatus.interview => (
          verdict: WsVerdict.eligible,
          label: 'Interview'
        ),
      ApplicationStatus.underReview => (
          verdict: WsVerdict.potential,
          label: 'Under Review'
        ),
      ApplicationStatus.notSelected => (
          verdict: WsVerdict.potential,
          label: 'Not Selected'
        ),
      ApplicationStatus.submitted => (
          verdict: WsVerdict.explore,
          label: 'Submitted'
        ),
    };

/// G1 — the applications list.
class ApplicationsScreen extends ConsumerStatefulWidget {
  const ApplicationsScreen({super.key});

  @override
  ConsumerState<ApplicationsScreen> createState() => _ApplicationsScreenState();
}

class _ApplicationsScreenState extends ConsumerState<ApplicationsScreen> {
  static const List<String> _filters = [
    'All',
    'In progress',
    'Interview',
    'Offer',
    'Closed',
  ];

  String _filter = 'All';

  bool _matches(JobApplication a) => switch (_filter) {
        'In progress' => a.status == ApplicationStatus.submitted ||
            a.status == ApplicationStatus.underReview,
        'Interview' => a.status == ApplicationStatus.interview,
        'Offer' => a.status == ApplicationStatus.offer,
        'Closed' => a.status == ApplicationStatus.notSelected,
        _ => true,
      };

  @override
  Widget build(BuildContext context) {
    final applications =
        ref.watch(applicationsProvider).where(_matches).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Applications')),
      body: Column(
        children: [
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: WsSpacing.gutter,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: WsSpacing.sm),
              itemBuilder: (context, i) => ChoiceChip(
                label: Text(_filters[i]),
                selected: _filter == _filters[i],
                onSelected: (_) => setState(() => _filter = _filters[i]),
                labelStyle: WsTypography.chip(
                  _filter == _filters[i]
                      ? context.colors.onPrimary
                      : context.colors.onSurface,
                ),
              ),
            ),
          ),
          Expanded(
            child: applications.isEmpty
                ? WsEmptyState(
                    icon: Icons.description_outlined,
                    headline: 'Nothing here yet',
                    body: _filter == 'All'
                        ? 'Applications you send will be tracked here, from '
                            'submitted through to an offer.'
                        : 'No applications are at that stage right now.',
                    actionLabel: 'Find jobs',
                    onAction: () => context.go(Routes.jobs),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      WsSpacing.xl,
                      WsSpacing.md,
                      WsSpacing.xl,
                      WsSpacing.xxxl,
                    ),
                    itemCount: applications.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: WsSpacing.md),
                    itemBuilder: (context, i) => _ApplicationCard(
                      application: applications[i],
                      onTap: () => context.push(
                        Routes.withId(
                          Routes.applicationDetail,
                          applications[i].id,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({required this.application, required this.onTap});

  final JobApplication application;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final v = verdictFor(application.status);

    return WsCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const WsIconTile(icon: Icons.business_rounded),
              const SizedBox(width: WsSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      application.job.title,
                      style: context.text.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      application.job.company,
                      style: context.text.bodySmall
                          ?.copyWith(color: context.ws.caption),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: WsSpacing.md),
          // The chip keeps its natural width — a verdict must never be
          // truncated — so the date takes the remaining space and ellipsises
          // instead. "Not Selected" plus a long date overflows 360 dp otherwise.
          Row(
            children: [
              WsVerdictChip(verdict: v.verdict, label: v.label),
              const SizedBox(width: WsSpacing.sm),
              Expanded(
                child: Text(
                  'Applied ${application.appliedOn}',
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodySmall
                      ?.copyWith(color: context.ws.caption),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
