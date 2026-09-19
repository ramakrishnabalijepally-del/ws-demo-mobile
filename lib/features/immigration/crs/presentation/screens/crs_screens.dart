import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/routes.dart';
import '../../../../../app/theme/theme.dart';
import '../../../../../shared/controllers/crs_controller.dart';
import '../../../../../shared/models/profile_section.dart';
import '../../../../../shared/models/ws_module.dart';
import '../../../../../shared/shared.dart';
import '../../../../../shared/utils/crs_calculator.dart';
import '../../../data/mock_immigration.dart';
import '../../../widgets/score_status_list.dart';

/// Where a section's answers are entered: the profile's own form, except the
/// nomination, which the profile does not ask and so is asked in Immigration.
String _formFor(ProfileSection section) => section == ProfileSection.additional
    ? Routes.withId(Routes.crsSection, section.name)
    : Routes.withId(Routes.profileSection, section.name);

/// J2 — what the CRS score needs, and what is still missing.
///
/// Opened by "Get my CRS score". The score is calculated from the profile, so
/// this screen shows each section as filled in or not, and every row opens
/// the form it is answered in — the profile's own section for profile
/// questions, and a form here for the one question the profile does not ask.
/// It watches the profile, so a saved section moves across on the way back,
/// and the button only works once nothing is missing.
class CrsOverviewScreen extends ConsumerWidget {
  const CrsOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completion = ref.watch(profileCompletionProvider);
    final missing = completion.sections.length - completion.done.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Your CRS score')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          WsSpacing.xl,
          WsSpacing.lg,
          WsSpacing.xl,
          WsSpacing.huge,
        ),
        children: [
          Text(
            completion.isComplete
                ? 'Everything is filled in'
                : 'Fill these in to get your CRS score',
            style: context.text.headlineLarge,
          ),
          const SizedBox(height: WsSpacing.md),
          Text(
            'WorkSettle calculates your Comprehensive Ranking System score '
            'from your profile, using the points IRCC publishes. Anything you '
            'save in your profile shows here straight away.',
            style: context.text.bodyMedium
                ?.copyWith(color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(height: WsSpacing.xxl),
          ScoreStatusList(
            items: [
              for (final section in completion.sections)
                ScoreStatusItem(
                  title: section.title,
                  icon: section.icon,
                  done: completion.done.contains(section),
                  // A nomination is not a profile question, so it is asked
                  // here; everything else opens the profile's own section.
                  whereToFill: section == ProfileSection.additional
                      ? 'Asked here — not part of your profile'
                      : 'Fill in on your profile',
                  onTap: () => context.push(_formFor(section)),
                ),
            ],
          ),
          const SizedBox(height: WsSpacing.xxl),
          const WsDisclaimer(),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!completion.isComplete) ...[
                Text(
                  missing == 1
                      ? 'Fill in 1 more section to get your score.'
                      : 'Fill in $missing more sections to get your score.',
                  textAlign: TextAlign.center,
                  style: context.text.bodySmall
                      ?.copyWith(color: context.ws.caption),
                ),
                const SizedBox(height: WsSpacing.sm),
              ],
              WsPrimaryButton(
                label: 'Get my CRS score',
                onPressed: completion.isComplete
                    ? () => context.push('${Routes.crsCalculating}?result=true')
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// J8 — the result, live from the profile.
///
/// Pattern B fixes the order: **the number, the verdict pill, and the sentence
/// that puts it in context.** The score is only calculated from a complete
/// profile (see [CrsOverviewScreen]), so there is no partial-estimate state.
class CrsResultScreen extends ConsumerWidget {
  const CrsResultScreen({super.key});

  static String _headline(String verdictLabel) => switch (verdictLabel) {
        'High Potential' => 'You are above the range of recent draws',
        'Good Range' => 'You are in a competitive range',
        'Potential Options' => 'You are close to the range of recent draws',
        _ => 'There are routes worth exploring',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final crs = ref.watch(crsResultProvider);
    final levers = ref.watch(crsLeversProvider);
    final verdict = crsVerdict(crs.total);

    return Scaffold(
      appBar: AppBar(title: const Text('Your CRS score')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          WsSpacing.xl,
          WsSpacing.lg,
          WsSpacing.xl,
          WsSpacing.huge,
        ),
        children: [
          WsBanner(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _headline(verdict.label),
                  style: context.text.titleMedium,
                ),
                const SizedBox(height: WsSpacing.xs),
                Text(
                  'Recent Express Entry draws have invited candidates '
                  'scoring $crsDrawLow to $crsDrawHigh.',
                  style: context.text.bodySmall
                      ?.copyWith(color: context.colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(height: WsSpacing.lg),
          WsScoreCard(
            icon: WsModule.crsPredictor.icon,
            title: 'Comprehensive Ranking System',
            supporting: 'Calculated from your profile',
            value: crs.total,
            maximum: crsMaximum,
            verdict: verdict.verdict,
            verdictLabel: verdict.label,
            contextLine: '${crs.total} — $mockRecentDraws',
            brandFill: true,
            showDisclaimer: true,
          ),
          if (levers.isNotEmpty) ...[
            const SizedBox(height: WsSpacing.xxl),
            Text('What would move it', style: context.text.titleLarge),
            const SizedBox(height: WsSpacing.md),
            for (final (i, lever) in levers.indexed)
              WsAppear(
                delay: 0.45 + i * 0.1,
                duration: WsMotion.entranceSequence,
                child: _Lever(lever: lever),
              ),
          ],
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
            label: 'See the breakdown',
            onPressed: () => context.push(Routes.crsBreakdown),
          ),
        ),
      ),
    );
  }
}

/// A change that would raise the score. Tapping it opens the profile section
/// where it would be recorded.
class _Lever extends StatelessWidget {
  const _Lever({required this.lever});

  final CrsLever lever;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: WsSpacing.md),
      child: WsCard(
        onTap: () => context.push(_formFor(lever.section)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(lever.title, style: context.text.titleMedium),
                ),
                Text(
                  '+${lever.gain}',
                  style: context.text.titleMedium
                      ?.copyWith(color: context.ws.redOnSurface),
                ),
              ],
            ),
            const SizedBox(height: WsSpacing.xs),
            Text(
              lever.detail,
              style:
                  context.text.bodySmall?.copyWith(color: context.ws.caption),
            ),
          ],
        ),
      ),
    );
  }
}

/// J9 — the breakdown, one table per group of the IRCC grid.
class CrsBreakdownScreen extends ConsumerWidget {
  const CrsBreakdownScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final crs = ref.watch(crsResultProvider);
    final groups = [
      for (final group in CrsGroup.values)
        if (crs.lines.any((line) => line.group == group)) group,
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Score breakdown')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          WsSpacing.xl,
          WsSpacing.lg,
          WsSpacing.xl,
          WsSpacing.huge,
        ),
        children: [
          Text('How ${crs.total} adds up', style: context.text.titleLarge),
          const SizedBox(height: WsSpacing.md),
          Text(
            "Every line comes from IRCC's published points grid and the "
            'answers in your profile.',
            style: context.text.bodyMedium
                ?.copyWith(color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(height: WsSpacing.xl),
          for (final group in groups) ...[
            Text(group.label, style: context.text.titleMedium),
            const SizedBox(height: WsSpacing.sm),
            WsScoreBreakdown(
              rows: [
                for (final line in crs.lines)
                  if (line.group == group)
                    (label: line.label, value: line.points),
              ],
              totalLabel: 'Subtotal',
              total: crs.subtotal(group),
            ),
            const SizedBox(height: WsSpacing.xl),
          ],
          Row(
            children: [
              Expanded(
                child: Text('Total CRS score', style: context.text.titleLarge),
              ),
              Text(
                '${crs.total}',
                style: context.text.titleLarge
                    ?.copyWith(color: context.ws.redOnSurface),
              ),
            ],
          ),
          const SizedBox(height: WsSpacing.lg),
          Text(
            'Job offers no longer add CRS points — IRCC removed them on 25 '
            'March 2025.',
            style: context.text.bodySmall?.copyWith(color: context.ws.caption),
          ),
          const SizedBox(height: WsSpacing.md),
          const WsDisclaimer(),
        ],
      ),
    );
  }
}
