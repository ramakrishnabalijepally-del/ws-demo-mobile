import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/routes.dart';
import '../../../../../app/theme/theme.dart';
import '../../../../../shared/controllers/crs_controller.dart';
import '../../../../../shared/models/profile_section.dart';
import '../../../../../shared/models/ws_module.dart';
import '../../../../../shared/shared.dart';
import '../../../../immigration/immigration.dart';
import '../../../../../shared/utils/crs_calculator.dart';

/// The profile checklist — where the completion ring leads.
///
/// **The candidate profile is the base of the app**: the CRS score,
/// eligibility and job matches are all calculated from it. This screen lists
/// every section the score needs, marks what is done, and highlights the next
/// gap to close.
class ProfileCompletionScreen extends ConsumerWidget {
  const ProfileCompletionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completion = ref.watch(profileCompletionProvider);
    final crs = ref.watch(crsResultProvider);
    final verdict = crsVerdict(crs.total);
    final revealed = ref.watch(crsRevealedProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Complete your profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          WsSpacing.xl,
          WsSpacing.lg,
          WsSpacing.xl,
          WsSpacing.xxxl,
        ),
        children: [
          WsAppear(child: _CompletionSummary(completion: completion)),
          const SizedBox(height: WsSpacing.lg),
          const WsSyncNote(
            message: 'Linked to your CRS score in Immigration. Anything '
                'you fill in here updates your score there, and the other way '
                'round.',
          ),
          const SizedBox(height: WsSpacing.lg),
          WsAppear(
            delay: 0.15,
            child: revealed
                ? WsScoreCard(
                    icon: WsModule.crsPredictor.icon,
                    title: 'Your CRS score',
                    supporting: completion.next == null
                        ? 'Calculated from your complete profile'
                        : 'An estimate from what you have entered so far',
                    value: crs.total,
                    maximum: crsMaximum,
                    verdict: verdict.verdict,
                    verdictLabel: verdict.label,
                    brandFill: true,
                    showDisclaimer: true,
                    onTap: () => context.push(Routes.crsResult),
                  )
                : WsScorePrompt(
                    icon: WsModule.crsPredictor.icon,
                    title: 'Your CRS score',
                    supporting: 'Comprehensive Ranking System',
                    body: 'Fill in the sections below, then ask for your '
                        'score.',
                    actionLabel: 'Get my CRS score',
                    onPressed: () =>
                        getMyCrsScore(context, ref, toResult: false),
                    note: completion.isComplete
                        ? null
                        : 'The score is worked out once every section is '
                            'filled in.',
                  ),
          ),
          const SizedBox(height: WsSpacing.xxl),
          Text('Sections', style: context.text.titleLarge),
          const SizedBox(height: WsSpacing.md),
          for (final (i, section) in completion.sections.indexed)
            WsAppear(
              delay: 0.2 + i * 0.08,
              duration: WsMotion.focal,
              child: Padding(
                padding: const EdgeInsets.only(bottom: WsSpacing.md),
                child: _SectionRow(
                  section: section,
                  done: completion.done.contains(section),
                  next: section == completion.next,
                  onTap: () => context.push(
                    Routes.withId(Routes.profileSection, section.name),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CompletionSummary extends StatelessWidget {
  const _CompletionSummary({required this.completion});

  final ProfileCompletion completion;

  @override
  Widget build(BuildContext context) {
    final next = completion.next;

    return WsCard(
      raised: true,
      child: Row(
        children: [
          WsRing(percent: completion.percent, label: 'Profile strength'),
          const SizedBox(width: WsSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  next == null
                      ? 'Your profile is complete'
                      : '${completion.done.length} of '
                          '${completion.sections.length} sections complete',
                  style: context.text.titleMedium,
                ),
                const SizedBox(height: WsSpacing.xs),
                Text(
                  next == null
                      ? 'Every CRS factor is answered, so your score is as '
                          'accurate as your answers.'
                      : 'Your CRS score, eligibility and job matches are all '
                          'built from this profile.',
                  style: context.text.bodySmall
                      ?.copyWith(color: context.ws.caption),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionRow extends StatelessWidget {
  const _SectionRow({
    required this.section,
    required this.done,
    required this.next,
    required this.onTap,
  });

  final ProfileSection section;
  final bool done;
  final bool next;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      children: [
        WsIconTile(icon: section.icon),
        const SizedBox(width: WsSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (next)
                Text(
                  'Up next',
                  style: context.text.labelLarge
                      ?.copyWith(color: context.ws.redOnSurface),
                ),
              Text(section.title, style: context.text.titleMedium),
              Text(
                section.summary,
                style:
                    context.text.bodySmall?.copyWith(color: context.ws.caption),
              ),
            ],
          ),
        ),
        const SizedBox(width: WsSpacing.md),
        Icon(
          done
              ? Icons.check_circle_rounded
              : Icons.radio_button_unchecked_rounded,
          size: WsIconSize.tick,
          color: done ? context.colors.onSurface : context.ws.placeholder,
          semanticLabel: done ? 'Complete' : 'Not complete',
        ),
        Icon(
          Icons.chevron_right_rounded,
          size: WsIconSize.chevron + 4,
          color: context.ws.placeholder,
        ),
      ],
    );

    // The next gap is the one selected card on the screen — the 2 px red
    // border says "start here" without adding a colour.
    return next
        ? WsSelectionCard(
            selected: true,
            semanticLabel: 'Up next: ${section.title}',
            onTap: onTap,
            child: content,
          )
        : WsCard(onTap: onTap, child: content);
  }
}
