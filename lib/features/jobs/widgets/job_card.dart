import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/theme.dart';
import '../../../shared/shared.dart';
import '../controllers/jobs_controller.dart';
import '../models/job.dart';

/// A job row, used by search, recommendations and the saved list.
///
/// The deck sets the salary in a saturated blue and the company logo in full
/// brand colour. Neither survives: **the salary is ink like every other value,
/// and the leading tile is the standard module tile** — a job board where each
/// row carries a different brand colour has no visual hierarchy left for the
/// things that matter, like whether the employer hires on a work permit.
class JobCard extends ConsumerWidget {
  const JobCard({required this.job, required this.onTap, super.key});

  final Job job;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WsCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WsIconTile(icon: Icons.business_rounded, brand: job.saved),
              const SizedBox(width: WsSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      job.title,
                      style: context.text.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${job.company} · ${job.location}',
                      style: context.text.bodySmall
                          ?.copyWith(color: context.ws.caption),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: job.saved ? 'Remove from saved' : 'Save this job',
                onPressed: () =>
                    ref.read(savedJobIdsProvider.notifier).toggle(job.id),
                icon: Icon(
                  job.saved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: job.saved
                      ? context.colors.primary
                      : context.ws.placeholder,
                ),
              ),
            ],
          ),
          const SizedBox(height: WsSpacing.md),
          Wrap(
            spacing: WsSpacing.sm,
            runSpacing: WsSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                job.salaryRange,
                style: context.text.titleMedium,
              ),
              _Meta(label: job.employment.label),
              _Meta(label: 'NOC ${job.nocCode}'),
              if (job.permitFriendly)
                // The one badge that earns its place on a job row: it is the
                // reason a newcomer is using this product at all.
                const WsVerdictChip(
                  verdict: WsVerdict.eligible,
                  label: 'Hires on work permits',
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: context.ws.verdictTintedSurface,
        borderRadius: WsRadii.pillR,
      ),
      child:
          Text(label, style: WsTypography.chip(context.ws.verdictTintedLabel)),
    );
  }
}
