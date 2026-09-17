import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/routes.dart';
import '../../../../../app/theme/theme.dart';
import '../../../../../shared/controllers/crs_controller.dart';
import '../../../../../shared/models/ws_module.dart';
import '../../../../../shared/shared.dart';
import '../../../../../shared/utils/crs_calculator.dart';
import '../../../data/mock_immigration.dart';
import '../../../crs/presentation/screens/crs_calculating_screen.dart';
import '../widgets/pnp_scores_bar.dart';

/// J1 — the Immigration tab.
///
/// Design system Pattern B — *assess, then disclose*. The two scores lead,
/// both calculated from the profile: the federal CRS score with its verdict,
/// then a bar of provincial scores. The tools and program list follow.
class ImmigrationScreen extends ConsumerWidget {
  const ImmigrationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final crs = ref.watch(crsResultProvider);
    final verdict = crsVerdict(crs.total);
    final revealed = ref.watch(crsRevealedProvider);
    final pnpScores = ref.watch(pnpScoresProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const WsProfileButton(),
        leadingWidth: WsTouch.minTarget + WsSpacing.md,
        title: const Text('Immigration'),
      ),
      body: ListView(
        padding: const EdgeInsets.only(
          top: WsSpacing.lg,
          bottom: WsSpacing.xxxl,
        ),
        children: [
          Padding(
            padding: WsSpacing.gutter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionHeading(
                  title: 'CRS Predictor',
                  action: 'How it works',
                  onAction: () => context.push(Routes.crsOverview),
                ),
                const SizedBox(height: WsSpacing.md),
                // Until it is asked for, the slot holds the question rather
                // than the number. Same card shell either way, so nothing
                // jumps when the score arrives.
                if (revealed)
                  WsScoreCard(
                    icon: WsModule.crsPredictor.icon,
                    title: 'Your CRS score',
                    supporting: 'Comprehensive Ranking System',
                    value: crs.total,
                    maximum: crsMaximum,
                    verdict: verdict.verdict,
                    verdictLabel: verdict.label,
                    contextLine: mockRecentDraws,
                    brandFill: true,
                    showDisclaimer: true,
                    onTap: () => context.push(Routes.crsResult),
                  )
                else
                  WsScorePrompt(
                    icon: WsModule.crsPredictor.icon,
                    title: 'Your CRS score',
                    supporting: 'Comprehensive Ranking System',
                    body: 'WorkSettle works it out from your profile using '
                        'the points IRCC publishes, and shows what would '
                        'move it.',
                    actionLabel: 'Get my CRS score',
                    onPressed: () => getMyCrsScore(context, ref),
                  ),
                const SizedBox(height: WsSpacing.xxl),
                _SectionHeading(
                  title: 'PNP scores',
                  action: 'All provinces',
                  onAction: () => context.push(Routes.pnpProvinces),
                ),
                const SizedBox(height: WsSpacing.xs),
                Text(
                  "Your points on each province's own grid, from your "
                  'profile. Tap one to see what counts.',
                  style: context.text.bodySmall
                      ?.copyWith(color: context.ws.caption),
                ),
                const SizedBox(height: WsSpacing.md),
              ],
            ),
          ),
          // Edge to edge, so cards scroll under the gutter rather than being
          // clipped at it.
          PnpScoresBar(scores: pnpScores),
          Padding(
            padding: WsSpacing.gutter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: WsSpacing.xxl),
                Text('Tools', style: context.text.titleLarge),
                const SizedBox(height: WsSpacing.md),
                WsCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      WsListRow(
                        leading: const WsIconTile(icon: Icons.speed_rounded),
                        title: 'CRS Predictor',
                        subtitle:
                            'Calculated from your profile — see what it uses',
                        onTap: () => context.push(Routes.crsOverview),
                      ),
                      Divider(color: context.colors.outlineVariant, height: 1),
                      WsListRow(
                        leading: const WsIconTile(icon: Icons.map_rounded),
                        title: 'Provincial Nominee Programs',
                        subtitle: 'Pick a province, then a stream',
                        onTap: () => context.push(Routes.pnpProvinces),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: WsSpacing.xxl),
                Text('Where you stand', style: context.text.titleLarge),
                const SizedBox(height: WsSpacing.md),
                for (final program in mockFederalPrograms.take(3))
                  Padding(
                    padding: const EdgeInsets.only(bottom: WsSpacing.md),
                    child: _ProgramCard(program: program),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.action,
    required this.onAction,
  });

  final String title;
  final String action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: context.text.titleLarge)),
        WsLink(label: action, underline: false, onPressed: onAction),
      ],
    );
  }
}

class _ProgramCard extends StatelessWidget {
  const _ProgramCard({required this.program});

  final FederalProgram program;

  @override
  Widget build(BuildContext context) {
    return WsCard(
      onTap: () => context.push(Routes.programs),
      child: Row(
        children: [
          const WsProvinceMark.canada(),
          const SizedBox(width: WsSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(program.name, style: context.text.titleMedium),
                const SizedBox(height: 2),
                Text(
                  program.summary,
                  style: context.text.bodySmall
                      ?.copyWith(color: context.ws.caption),
                ),
              ],
            ),
          ),
          const SizedBox(width: WsSpacing.md),
          WsVerdictChip(
            verdict:
                program.eligible ? WsVerdict.eligible : WsVerdict.potential,
            label: program.eligible ? 'Eligible' : 'Potential',
          ),
        ],
      ),
    );
  }
}
