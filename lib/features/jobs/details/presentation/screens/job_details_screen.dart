import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/routes.dart';
import '../../../../../app/theme/theme.dart';
import '../../../../../shared/shared.dart';
import '../../../controllers/jobs_controller.dart';
import '../../../models/job.dart';

/// E7–E8 — the job detail, and the share sheet.
class JobDetailsScreen extends ConsumerWidget {
  const JobDetailsScreen({required this.jobId, super.key});

  final String jobId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final job = jobById(ref, jobId);

    if (job == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Job')),
        body: WsEmptyState(
          icon: Icons.work_off_outlined,
          headline: 'This posting has closed',
          body: 'The employer has taken it down. There are similar roles on '
              'the board.',
          actionLabel: 'Back to jobs',
          onAction: () => context.pop(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        actions: [
          IconButton(
            tooltip: job.saved ? 'Remove from saved' : 'Save this job',
            onPressed: () =>
                ref.read(savedJobIdsProvider.notifier).toggle(job.id),
            icon: Icon(
              job.saved
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color: job.saved ? context.colors.primary : null,
            ),
          ),
          IconButton(
            tooltip: 'Share',
            onPressed: () => _showShareSheet(context, job),
            icon: const Icon(Icons.ios_share_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          WsSpacing.xl,
          WsSpacing.lg,
          WsSpacing.xl,
          WsSpacing.huge,
        ),
        children: [
          WsCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const WsIconTile(
                  icon: Icons.business_rounded,
                  size: WsTileSize.header,
                ),
                const SizedBox(width: WsSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(job.title, style: context.text.titleLarge),
                      const SizedBox(height: WsSpacing.xs),
                      Text(
                        job.company,
                        style: context.text.bodyMedium
                            ?.copyWith(color: context.colors.onSurfaceVariant),
                      ),
                      const SizedBox(height: WsSpacing.sm),
                      Text(
                        'Posted ${job.postedAgo}',
                        style: context.text.bodySmall
                            ?.copyWith(color: context.ws.caption),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (job.permitFriendly) ...[
            const SizedBox(height: WsSpacing.md),
            WsBanner(
              child: Row(
                children: [
                  Icon(
                    Icons.verified_outlined,
                    color: context.colors.onSurface,
                  ),
                  const SizedBox(width: WsSpacing.md),
                  Expanded(
                    child: Text(
                      'This employer has hired candidates on a work permit '
                      'before.',
                      style: context.text.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: WsSpacing.xl),
          _Facts(job: job),
          const SizedBox(height: WsSpacing.xxl),
          Text('About the role', style: context.text.titleLarge),
          const SizedBox(height: WsSpacing.md),
          Text(
            job.summary,
            style: context.text.bodyMedium
                ?.copyWith(color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(height: WsSpacing.xxl),
          Text('Requirements', style: context.text.titleLarge),
          const SizedBox(height: WsSpacing.md),
          for (final requirement in job.requirements)
            Padding(
              padding: const EdgeInsets.only(bottom: WsSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: WsIconSize.tick,
                    color: context.colors.onSurface,
                  ),
                  const SizedBox(width: WsSpacing.md),
                  Expanded(
                    child: Text(requirement, style: context.text.bodyMedium),
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
            label: 'Apply Now',
            onPressed: () =>
                context.push(Routes.withId(Routes.jobApply, job.id)),
          ),
        ),
      ),
    );
  }

  static void _showShareSheet(BuildContext context, Job job) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            WsSpacing.xl,
            WsSpacing.sm,
            WsSpacing.xl,
            WsSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Share this job', style: context.text.titleLarge),
              const SizedBox(height: WsSpacing.xs),
              Text(
                '${job.title} at ${job.company}',
                style:
                    context.text.bodySmall?.copyWith(color: context.ws.caption),
              ),
              const SizedBox(height: WsSpacing.xl),
              // TODO(backend): no share intent is fired. The deck shows eight
              // full-colour brand tiles here; those are dropped — a share sheet
              // is the one place the OS should supply its own chrome anyway.
              const Wrap(
                spacing: WsSpacing.md,
                runSpacing: WsSpacing.md,
                children: [
                  _ShareTarget(label: 'Copy link', icon: Icons.link_rounded),
                  _ShareTarget(
                    label: 'Email',
                    icon: Icons.mail_outline_rounded,
                  ),
                  _ShareTarget(
                    label: 'Message',
                    icon: Icons.chat_bubble_outline_rounded,
                  ),
                  _ShareTarget(label: 'More', icon: Icons.more_horiz_rounded),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Facts extends StatelessWidget {
  const _Facts({required this.job});

  final Job job;

  @override
  Widget build(BuildContext context) {
    final facts = <(String, String)>[
      ('Salary', '${job.salaryRange} per year'),
      ('Type', job.employment.label),
      ('Location', job.location),
      ('NOC code', job.nocCode),
    ];

    return WsCard(
      child: Column(
        children: [
          for (var i = 0; i < facts.length; i++) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    facts[i].$1,
                    style: context.text.bodyMedium
                        ?.copyWith(color: context.ws.caption),
                  ),
                ),
                Flexible(
                  child: Text(
                    facts[i].$2,
                    style: context.text.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            if (i != facts.length - 1)
              Divider(
                color: context.colors.outlineVariant,
                height: WsSpacing.xxl,
              ),
          ],
        ],
      ),
    );
  }
}

class _ShareTarget extends StatelessWidget {
  const _ShareTarget({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: Column(
        children: [
          WsIconTile(icon: icon),
          const SizedBox(height: WsSpacing.sm),
          Text(
            label,
            style: context.text.bodySmall,
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
