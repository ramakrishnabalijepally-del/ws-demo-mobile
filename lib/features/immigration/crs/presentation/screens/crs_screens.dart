import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/routes.dart';
import '../../../../../app/theme/theme.dart';
import '../../../../../shared/controllers/crs_controller.dart';
import '../../../../../shared/models/ws_module.dart';
import '../../../../../shared/shared.dart';
import '../../../../../shared/utils/crs_calculator.dart';
import 'crs_calculating_screen.dart';
import '../../../data/mock_immigration.dart';

/// J2 — the CRS overview.
///
/// The score is not a separate quiz. It is calculated from the candidate's
/// profile with IRCC's published points, so this screen shows what it is
/// built from and where each piece is entered.
class CrsOverviewScreen extends ConsumerWidget {
  const CrsOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completion = ref.watch(profileCompletionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('CRS Predictor')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          WsSpacing.xl,
          WsSpacing.lg,
          WsSpacing.xl,
          WsSpacing.huge,
        ),
        children: [
          const Center(
            child: WsIconTile(
              icon: Icons.speed_rounded,
              size: WsTileSize.header,
            ),
          ),
          const SizedBox(height: WsSpacing.xl),
          Text(
            'Your CRS score, from your profile',
            style: context.text.headlineLarge,
          ),
          const SizedBox(height: WsSpacing.md),
          Text(
            'The Comprehensive Ranking System is how Express Entry ranks '
            'candidates. WorkSettle calculates yours from your profile using '
            'the points IRCC publishes, so it updates whenever your profile '
            'does.',
            style: context.text.bodyMedium
                ?.copyWith(color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(height: WsSpacing.lg),
          const WsSyncNote(
            message: 'Linked to your profile. Answers you enter here are saved '
                'to your profile, and changes to your profile update this '
                'score.',
          ),
          const SizedBox(height: WsSpacing.xxl),
          Text('What it is built from', style: context.text.titleLarge),
          const SizedBox(height: WsSpacing.md),
          WsCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (final (i, section) in completion.sections.indexed) ...[
                  if (i > 0)
                    Divider(color: context.colors.outlineVariant, height: 1),
                  WsListRow(
                    leading: WsIconTile(icon: section.icon),
                    title: section.title,
                    subtitle: completion.done.contains(section)
                        ? 'Complete'
                        : 'Not complete yet',
                    trailing: Icon(
                      completion.done.contains(section)
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      size: WsIconSize.tick,
                      color: completion.done.contains(section)
                          ? context.colors.onSurface
                          : context.ws.placeholder,
                    ),
                    onTap: () => context.push(
                      Routes.withId(Routes.crsSection, section.name),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: WsSpacing.lg),
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
          child: WsPrimaryButton(
            // The one way to a score, wherever it is asked for.
            label: 'Get my CRS score',
            onPressed: () => getMyCrsScore(context, ref),
          ),
        ),
      ),
    );
  }
}

/// J8 — the result, live from the profile.
///
/// Pattern B fixes the order: **the number, the verdict pill, and the sentence
/// that puts it in context.** When sections are missing the screen says the
/// score is an estimate so far, and leads back to the profile.
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
    final completion = ref.watch(profileCompletionProvider);
    final verdict = crsVerdict(crs.total);
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
          WsBanner(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  missing == 0
                      ? _headline(verdict.label)
                      : 'An estimate so far',
                  style: context.text.titleMedium,
                ),
                const SizedBox(height: WsSpacing.xs),
                Text(
                  missing == 0
                      ? 'Recent Express Entry draws have invited candidates '
                          'scoring $crsDrawLow to $crsDrawHigh.'
                      : '$missing profile '
                          '${missing == 1 ? 'section is' : 'sections are'} '
                          'still missing, so your score may be higher than '
                          'this.',
                  style: context.text.bodySmall
                      ?.copyWith(color: context.colors.onSurfaceVariant),
                ),
                if (completion.next case final next?)
                  // Straight into the next missing section, inside this tab.
                  // Saving it updates the profile and this score together.
                  WsLink(
                    label: 'Fill in ${next.title}',
                    underline: false,
                    onPressed: () => context.push(
                      Routes.withId(Routes.crsSection, next.name),
                    ),
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
        onTap: () => context.push(
          Routes.withId(Routes.crsSection, lever.section.name),
        ),
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
