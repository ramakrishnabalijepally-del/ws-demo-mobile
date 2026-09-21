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
import '../../../widgets/pnp_province_grid.dart';

/// J1 — the Immigration tab.
///
/// Design system Pattern B — *assess, then disclose*. Grouped the way IRCC
/// splits the routes: **Federal score** (Express Entry, scored on the CRS)
/// first, then **PNP score** (each province on its own grid).
class ImmigrationScreen extends ConsumerWidget {
  const ImmigrationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final crs = ref.watch(crsResultProvider);
    final verdict = crsVerdict(crs.total);
    final revealed = ref.watch(crsRevealedProvider);

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
                  title: 'Federal score',
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
                    mark: const WsProvinceMark.canada(size: 44),
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
                    mark: const WsProvinceMark.canada(size: 44),
                    actionLabel: 'Get my CRS score',
                    // Always the status screen first: it says what the score
                    // is built from and what is still missing.
                    onPressed: () => context.push(Routes.crsOverview),
                  ),
                const SizedBox(height: WsSpacing.xxl),
                Divider(color: context.colors.outlineVariant, height: 1),
                const SizedBox(height: WsSpacing.xxl),
                const _GroupHeading(
                  eyebrow: 'Provincial Nominee Programs',
                  title: 'PNP score',
                  body: "Scored on each province's own points grid. Get one "
                      'province at a time; tap a score to see what counts.',
                ),
                const SizedBox(height: WsSpacing.lg),
                const PnpProvinceGrid(),
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
