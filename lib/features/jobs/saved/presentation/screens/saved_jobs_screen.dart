import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/routes.dart';
import '../../../../../app/theme/theme.dart';
import '../../../../../shared/shared.dart';
import '../../../controllers/jobs_controller.dart';
import '../../../models/job.dart';
import '../../../widgets/job_card.dart';

/// H1–H2 — saved jobs, and the confirm sheet before one is removed.
class SavedJobsScreen extends ConsumerWidget {
  const SavedJobsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobs = ref.watch(savedJobsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Jobs')),
      body: jobs.isEmpty
          ? WsEmptyState(
              icon: Icons.bookmark_border_rounded,
              headline: 'Nothing saved yet',
              body: 'Tap the bookmark on any job and it will wait for you '
                  'here.',
              actionLabel: 'Browse jobs',
              onAction: () => context.go(Routes.jobs),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                WsSpacing.xl,
                WsSpacing.lg,
                WsSpacing.xl,
                WsSpacing.xxxl,
              ),
              itemCount: jobs.length,
              separatorBuilder: (_, __) => const SizedBox(height: WsSpacing.md),
              itemBuilder: (context, i) => Dismissible(
                key: ValueKey(jobs[i].id),
                direction: DismissDirection.endToStart,
                background: const _RemoveBackground(),
                confirmDismiss: (_) => _confirmRemove(context, jobs[i]),
                onDismissed: (_) =>
                    ref.read(savedJobIdsProvider.notifier).toggle(jobs[i].id),
                child: JobCard(
                  job: jobs[i],
                  onTap: () => context.push(
                    Routes.withId(Routes.jobDetails, jobs[i].id),
                  ),
                ),
              ),
            ),
    );
  }

  static Future<bool> _confirmRemove(BuildContext context, Job job) async {
    final confirmed = await showModalBottomSheet<bool>(
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Remove from saved?',
                style: context.text.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: WsSpacing.sm),
              Text(
                '${job.title} at ${job.company} will come off your saved list. '
                'You can save it again from the job page.',
                style: context.text.bodyMedium
                    ?.copyWith(color: context.colors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: WsSpacing.xxl),
              WsPrimaryButton(
                label: 'Remove',
                forward: false,
                onPressed: () => Navigator.of(context).pop(true),
              ),
              const SizedBox(height: WsSpacing.md),
              WsGhostButton(
                label: 'Keep it',
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        ),
      ),
    );
    return confirmed ?? false;
  }
}

class _RemoveBackground extends StatelessWidget {
  const _RemoveBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: WsSpacing.xl),
      decoration: BoxDecoration(
        color: context.ws.redTint,
        borderRadius: WsRadii.cardR,
      ),
      child: Icon(
        Icons.bookmark_remove_outlined,
        color: context.ws.redOnSurface,
        semanticLabel: 'Remove from saved',
      ),
    );
  }
}
