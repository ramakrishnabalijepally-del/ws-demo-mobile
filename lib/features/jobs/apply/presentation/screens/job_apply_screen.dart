import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/routes.dart';
import '../../../../../app/theme/theme.dart';
import '../../../../../shared/shared.dart';
import '../../../controllers/jobs_controller.dart';
import '../../../models/job.dart';

/// F1–F6 — the apply flow: upload a résumé, then submit.
///
/// Four upload states live on one screen, which is how the deck has it, and it
/// is right: the reader is doing one thing and the screen reports on it. The
/// two outcome screens are separate because they are milestones.
enum _UploadState { empty, uploading, failed, uploaded }

class JobApplyScreen extends ConsumerStatefulWidget {
  const JobApplyScreen({required this.jobId, super.key});

  final String jobId;

  @override
  ConsumerState<JobApplyScreen> createState() => _JobApplyScreenState();
}

class _JobApplyScreenState extends ConsumerState<JobApplyScreen> {
  _UploadState _state = _UploadState.empty;

  Future<void> _upload() async {
    setState(() => _state = _UploadState.uploading);
    // TODO(backend): no file is picked or uploaded. The delay stands in for the
    // round trip so the uploading state is visible.
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    // The first attempt fails, so F3 is reachable; every attempt after it
    // succeeds, so a retry is a real retry. The counter lives in a provider
    // rather than in this State, or it would reset with the widget and loop.
    final attempts = ref.read(uploadAttemptsProvider);
    ref.read(uploadAttemptsProvider.notifier).state = attempts + 1;
    setState(() {
      _state = attempts == 0 ? _UploadState.failed : _UploadState.uploaded;
    });
  }

  void _submit(Job job) {
    final attempts = ref.read(submitAttemptsProvider);
    ref.read(submitAttemptsProvider.notifier).state = attempts + 1;

    // Same shape as the upload: the first submit fails so F6 is reachable, and
    // "Try again" then goes through.
    if (attempts == 0) {
      context.go(
        '${Routes.withId(Routes.jobApplyResult, job.id)}?status=failed',
      );
      return;
    }

    ref.read(applicationsProvider.notifier).add(
          JobApplication(
            id: 'a-${DateTime.now().millisecondsSinceEpoch}',
            job: job,
            status: ApplicationStatus.submitted,
            appliedOn: 'Today',
            message: 'Your application has been received. Nothing is needed '
                'from you right now.',
          ),
        );
    context.go(Routes.withId(Routes.jobApplyResult, job.id));
  }

  @override
  Widget build(BuildContext context) {
    final job = jobById(ref, widget.jobId);
    if (job == null) return const _MissingJob();

    return Scaffold(
      appBar: AppBar(title: const Text('Apply')),
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
                        job.company,
                        style: context.text.bodySmall
                            ?.copyWith(color: context.ws.caption),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: WsSpacing.xxl),
          Text('Your résumé', style: context.text.titleLarge),
          const SizedBox(height: WsSpacing.sm),
          Text(
            'A PDF is safest — it keeps your layout on any machine the '
            'employer opens it on.',
            style: context.text.bodyMedium
                ?.copyWith(color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(height: WsSpacing.xl),
          switch (_state) {
            _UploadState.empty => _DropTarget(onTap: _upload),
            _UploadState.uploading => const _Uploading(),
            _UploadState.failed => _Failed(onRetry: _upload),
            _UploadState.uploaded => _Uploaded(onReplace: _upload),
          },
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
            label: 'Submit Application',
            isLoading: _state == _UploadState.uploading,
            onPressed:
                _state == _UploadState.uploaded ? () => _submit(job) : null,
          ),
        ),
      ),
    );
  }
}

class _DropTarget extends StatelessWidget {
  const _DropTarget({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: WsRadii.cardR,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: WsRadii.cardR,
          border: Border.all(color: context.colors.outline, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const WsIconTile(
              icon: Icons.upload_file_rounded,
              size: WsTileSize.header,
            ),
            const SizedBox(height: WsSpacing.lg),
            Text('Upload your résumé', style: context.text.titleMedium),
            const SizedBox(height: WsSpacing.xs),
            Text(
              'PDF or Word, up to 10 MB',
              style:
                  context.text.bodySmall?.copyWith(color: context.ws.caption),
            ),
          ],
        ),
      ),
    );
  }
}

class _Uploading extends StatelessWidget {
  const _Uploading();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: WsRadii.cardR,
        border: Border.all(color: context.colors.primary, width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: context.colors.primary,
            ),
          ),
          const SizedBox(height: WsSpacing.lg),
          Text('Uploading…', style: context.text.titleMedium),
        ],
      ),
    );
  }
}

class _Failed extends StatelessWidget {
  const _Failed({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Upload failure is the one place red text is correct: it is a
        // validation error, not a state (design system section 2).
        Container(
          padding: const EdgeInsets.all(WsSpacing.md),
          decoration: BoxDecoration(
            color: context.ws.redTint,
            borderRadius: WsRadii.fieldR,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 18,
                color: context.colors.error,
              ),
              const SizedBox(width: WsSpacing.md),
              Expanded(
                child: Text(
                  'That upload did not finish. Check your connection and try '
                  'the file again.',
                  style: context.text.bodySmall?.copyWith(
                    color: context.colors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: WsSpacing.md),
        _DropTarget(onTap: onRetry),
      ],
    );
  }
}

class _Uploaded extends StatelessWidget {
  const _Uploaded({required this.onReplace});

  final VoidCallback onReplace;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WsCard(
          child: Row(
            children: [
              const WsIconTile(icon: Icons.picture_as_pdf_rounded),
              const SizedBox(width: WsSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Resume — Adam Smith.pdf',
                      style: context.text.titleMedium,
                    ),
                    Text(
                      '440 KB · uploaded just now',
                      style: context.text.bodySmall
                          ?.copyWith(color: context.ws.caption),
                    ),
                  ],
                ),
              ),
              const WsVerdictChip(
                verdict: WsVerdict.eligible,
                label: 'Ready',
              ),
            ],
          ),
        ),
        const SizedBox(height: WsSpacing.md),
        WsSecondaryButton(label: 'Replace file', onPressed: onReplace),
      ],
    );
  }
}

class _MissingJob extends StatelessWidget {
  const _MissingJob();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Apply')),
      body: WsEmptyState(
        icon: Icons.work_off_outlined,
        headline: 'This posting has closed',
        body: 'You can no longer apply to it. Similar roles are on the board.',
        actionLabel: 'Back to jobs',
        onAction: () => context.pop(),
      ),
    );
  }
}
