import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/routes.dart';
import '../../../../../app/theme/theme.dart';
import '../../../../../shared/controllers/crs_controller.dart';
import '../../../controllers/pnp_status.dart';
import '../../../../../shared/models/ws_module.dart';
import '../../../../../shared/shared.dart';
import '../../../../../shared/utils/crs_calculator.dart';
import '../../../data/mock_immigration.dart';
import '../widgets/pnp_scores_bar.dart';

/// J1 — the Immigration tab.
///
/// Design system Pattern B — *assess, then disclose*. Grouped the way IRCC
/// splits the routes: **Federal programs** (Express Entry, scored on the CRS)
/// first, then **PNP programs** (each province on its own grid).
class ImmigrationScreen extends ConsumerWidget {
  const ImmigrationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final crs = ref.watch(crsResultProvider);
    final verdict = crsVerdict(crs.total);
    final revealed = ref.watch(crsRevealedProvider);
    final pnpScores = ref.watch(pnpScoresProvider);
    final pnpRevealed = ref.watch(pnpRevealedProvider);

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
                const _GroupHeading(
                  eyebrow: 'Express Entry',
                  title: 'Federal programs',
                  body: 'Scored on the Comprehensive Ranking System (CRS).',
                ),
                const SizedBox(height: WsSpacing.lg),
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
                    // Always the status screen first: it says what the score
                    // is built from and what is still missing.
                    onPressed: () => context.push(Routes.crsOverview),
                  ),
                const SizedBox(height: WsSpacing.xxl),
                _SectionHeading(
                  title: 'Where you stand',
                  action: 'All federal programs',
                  onAction: () => context.push(Routes.programs),
                ),
                const SizedBox(height: WsSpacing.md),
                for (final program in mockFederalPrograms.take(3))
                  Padding(
                    padding: const EdgeInsets.only(bottom: WsSpacing.md),
                    child: _ProgramCard(program: program),
                  ),
                const SizedBox(height: WsSpacing.xxl),
                Divider(color: context.colors.outlineVariant, height: 1),
                const SizedBox(height: WsSpacing.xxl),
                const _GroupHeading(
                  eyebrow: 'Provincial Nominee Programs',
                  title: 'PNP programs',
                  body: "Scored on each province's own points grid.",
                ),
                const SizedBox(height: WsSpacing.lg),
                _SectionHeading(
                  title: 'PNP scores',
                  action: 'All provinces',
                  onAction: () => context.push(Routes.pnpProvinces),
                ),
                if (pnpRevealed) ...[
                  const SizedBox(height: WsSpacing.xs),
                  Text(
                    "Your points on each province's own grid, from your "
                    'profile. Tap one to see what counts.',
                    style: context.text.bodySmall
                        ?.copyWith(color: context.ws.caption),
                  ),
                ] else ...[
                  const SizedBox(height: WsSpacing.md),
                  WsScorePrompt(
                    icon: Icons.map_rounded,
                    title: 'Your PNP scores',
                    supporting: 'Provincial points grids',
                    body: 'WorkSettle works out your points on the Alberta, '
                        'British Columbia, Saskatchewan and Manitoba grids '
                        'from your profile.',
                    actionLabel: 'Get my PNP scores',
                    onPressed: () => context.push(Routes.pnpStatus),
                  ),
                ],
                const SizedBox(height: WsSpacing.md),
              ],
            ),
          ),
          // Edge to edge, so cards scroll under the gutter rather than being
          // clipped at it.
          if (pnpRevealed) PnpScoresBar(scores: pnpScores),
          Padding(
            padding: WsSpacing.gutter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: WsSpacing.lg),
                WsCard(
                  padding: EdgeInsets.zero,
                  child: WsListRow(
                    leading: const WsIconTile(icon: Icons.map_rounded),
                    title: 'Provincial Nominee Programs',
                    subtitle: 'Pick a province, then a stream',
                    onTap: () => context.push(Routes.pnpProvinces),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Heads one program family, so the CRS and PNP scores read as answers to
/// two different routes rather than two numbers on one scale.
class _GroupHeading extends StatelessWidget {
  const _GroupHeading({
    required this.eyebrow,
    required this.title,
    required this.body,
  });

  final String eyebrow;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow.toUpperCase(),
            style: context.text.labelSmall?.copyWith(color: context.ws.caption),
          ),
          const SizedBox(height: WsSpacing.xs),
          Text(title, style: context.text.headlineLarge),
          const SizedBox(height: WsSpacing.xs),
          Text(
            body,
            style: context.text.bodySmall?.copyWith(color: context.ws.caption),
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
        Expanded(child: Text(title, style: context.text.titleMedium)),
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
