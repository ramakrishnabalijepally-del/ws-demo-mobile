import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/routes.dart';
import '../../../../../app/theme/theme.dart';
import '../../../../../shared/shared.dart';
import '../../../controllers/jobs_controller.dart';
import '../../../models/job.dart';
import 'applications_screen.dart';

/// G2–G5 — one application, in whichever of the four states it is in.
///
/// The status chip, the letter and the action all come from the same status, so
/// there is one screen rather than four near-copies.
class ApplicationDetailScreen extends ConsumerWidget {
  const ApplicationDetailScreen({required this.applicationId, super.key});

  final String applicationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final application = ref
        .watch(applicationsProvider)
        .where((a) => a.id == applicationId)
        .firstOrNull;

    if (application == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Application')),
        body: WsEmptyState(
          icon: Icons.description_outlined,
          headline: 'We cannot find that application',
          body: 'It may have been withdrawn. The rest are still listed.',
          actionLabel: 'Back to applications',
          onAction: () => context.pop(),
        ),
      );
    }

    final v = verdictFor(application.status);
    final job = application.job;

    return Scaffold(
      appBar: AppBar(title: const Text('Application')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          WsSpacing.xl,
          WsSpacing.lg,
          WsSpacing.xl,
          WsSpacing.huge,
        ),
        children: [
          WsCard(
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
                          Text(job.title, style: context.text.titleMedium),
                          Text(
                            '${job.company} · ${job.location}',
                            style: context.text.bodySmall
                                ?.copyWith(color: context.ws.caption),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: WsSpacing.md),
                Divider(color: context.colors.outlineVariant),
                const SizedBox(height: WsSpacing.md),
                // The verdict keeps its natural width; the date gives way.
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
          ),
          if (application.interviewOn != null) ...[
            const SizedBox(height: WsSpacing.md),
            WsBanner(
              child: Row(
                children: [
                  Icon(
                    Icons.event_available_rounded,
                    color: context.colors.onSurface,
                  ),
                  const SizedBox(width: WsSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Interview', style: context.text.titleMedium),
                        Text(
                          application.interviewOn!,
                          style: context.text.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: WsSpacing.xxl),
          Text('From the employer', style: context.text.titleLarge),
          const SizedBox(height: WsSpacing.md),
          WsCard(
            child: Text(
              application.message,
              style: context.text.bodyMedium
                  ?.copyWith(color: context.colors.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: WsSpacing.xxl),
          Text('Salary and terms', style: context.text.titleLarge),
          const SizedBox(height: WsSpacing.md),
          WsCard(
            child: Column(
              children: [
                _Fact(label: 'Salary', value: '${job.salaryRange} per year'),
                _Fact(label: 'Type', value: job.employment.label),
                _Fact(label: 'Location', value: job.location, last: true),
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
          child: _Action(application: application),
        ),
      ),
    );
  }
}

/// One action per status — and never two primaries on a screen.
class _Action extends StatelessWidget {
  const _Action({required this.application});

  final JobApplication application;

  @override
  Widget build(BuildContext context) {
    return switch (application.status) {
      ApplicationStatus.interview => WsPrimaryButton(
          label: 'Join Interview',
          icon: Icons.videocam_rounded,
          forward: false,
          onPressed: () => context.push(
            Routes.withId(Routes.call, 'c1'),
          ),
        ),
      ApplicationStatus.offer => WsPrimaryButton(
          label: 'Message the recruiter',
          forward: false,
          onPressed: () => context.push(
            Routes.withId(Routes.chatThread, 'c1'),
          ),
        ),
      ApplicationStatus.notSelected => WsSecondaryButton(
          label: 'Find similar roles',
          onPressed: () => context.go(Routes.jobs),
        ),
      _ => WsSecondaryButton(
          label: 'Message the recruiter',
          onPressed: () => context.push(
            Routes.withId(Routes.chatThread, 'c1'),
          ),
        ),
    };
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value, this.last = false});

  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: context.text.bodyMedium
                    ?.copyWith(color: context.ws.caption),
              ),
            ),
            Flexible(
              child: Text(
                value,
                style: context.text.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        if (!last)
          Divider(color: context.colors.outlineVariant, height: WsSpacing.xxl),
      ],
    );
  }
}
