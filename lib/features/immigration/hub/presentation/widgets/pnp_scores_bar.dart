import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/routes.dart';
import '../../../../../app/theme/theme.dart';
import '../../../../../shared/shared.dart';
import '../../../../../shared/utils/pnp_calculator.dart';

/// PNP scores — one card per province with a points grid, side by side.
///
/// Each card is the score against that province's own maximum, because the
/// grids are not on one scale: 58 of 110 in Saskatchewan and 345 of 1,000 in
/// Manitoba cannot share an axis. The meter is what makes them comparable.
class PnpScoresBar extends StatelessWidget {
  const PnpScoresBar({required this.scores, super.key});

  final List<PnpScore> scores;

  /// Wide enough for "British Columbia" and a three-digit score at 360 dp,
  /// narrow enough that the next card peeks in to say the bar scrolls.
  static const double _cardWidth = 196;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      // The bar runs edge to edge, so its padding carries the page gutter.
      padding: WsSpacing.gutter,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, score) in scores.indexed) ...[
              if (i > 0) const SizedBox(width: WsSpacing.md),
              SizedBox(
                width: _cardWidth,
                child: WsAppear(
                  delay: 0.1 + i * 0.08,
                  duration: WsMotion.entranceSequence,
                  child: _PnpScoreCard(
                    score: score,
                    onTap: () => showPnpScoreSheet(context, score),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PnpScoreCard extends StatelessWidget {
  const _PnpScoreCard({required this.score, required this.onTap});

  final PnpScore score;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final passMark = score.passMark;

    return Semantics(
      button: true,
      label: '${score.province}, ${score.total} out of ${score.maximum}',
      excludeSemantics: true,
      child: WsCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                WsProvinceMark(
                  code: score.code,
                  label: score.province,
                  size: 32,
                ),
                const SizedBox(width: WsSpacing.sm),
                Expanded(
                  child: Text(
                    score.province,
                    style: context.text.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: WsSpacing.md),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${score.total}',
                    style: context.text.displaySmall,
                  ),
                  TextSpan(
                    text: ' / ${score.maximum}',
                    style: WsTypography.denominator(context.ws.caption),
                  ),
                ],
              ),
            ),
            const SizedBox(height: WsSpacing.sm),
            WsMeter(value: score.total, maximum: score.maximum),
            const SizedBox(height: WsSpacing.sm),
            const Spacer(),
            Text(
              passMark == null
                  ? score.program
                  : score.total >= passMark
                      ? 'Meets the pass mark of $passMark'
                      : '${passMark - score.total} below the pass mark',
              style:
                  context.text.bodySmall?.copyWith(color: context.ws.caption),
            ),
          ],
        ),
      ),
    );
  }
}

/// Where the score comes from, what it leaves out, and the way into the
/// province's streams.
void showPnpScoreSheet(BuildContext context, PnpScore score) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.92,
      builder: (context, scroll) => ListView(
        controller: scroll,
        padding: const EdgeInsets.fromLTRB(
          WsSpacing.xl,
          WsSpacing.sm,
          WsSpacing.xl,
          WsSpacing.xxl,
        ),
        children: [
          Row(
            children: [
              WsProvinceMark(code: score.code, label: score.province),
              const SizedBox(width: WsSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(score.province, style: context.text.titleLarge),
                    Text(
                      score.program,
                      style: context.text.bodySmall
                          ?.copyWith(color: context.ws.caption),
                    ),
                  ],
                ),
              ),
              Text('${score.total}', style: context.text.displaySmall),
              Text(
                ' / ${score.maximum}',
                style: WsTypography.denominator(context.ws.caption),
              ),
            ],
          ),
          const SizedBox(height: WsSpacing.xl),
          WsCard(
            child: Column(
              children: [
                for (final (i, line) in score.lines.indexed) ...[
                  if (i > 0)
                    Divider(
                      height: WsSpacing.xl,
                      color: context.colors.outlineVariant,
                    ),
                  _LineRow(line: line),
                ],
              ],
            ),
          ),
          const SizedBox(height: WsSpacing.xl),
          Text('Not counted yet', style: context.text.titleMedium),
          const SizedBox(height: WsSpacing.xs),
          Text(
            'These are worth points but are not part of your profile, so '
            'your real score could be higher.',
            style: context.text.bodySmall?.copyWith(color: context.ws.caption),
          ),
          const SizedBox(height: WsSpacing.md),
          for (final item in score.notCounted)
            Padding(
              padding: const EdgeInsets.only(bottom: WsSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text('—', style: context.text.bodyMedium),
                  ),
                  const SizedBox(width: WsSpacing.md),
                  Expanded(
                    child: Text(item, style: context.text.bodyMedium),
                  ),
                ],
              ),
            ),
          const SizedBox(height: WsSpacing.lg),
          WsSecondaryButton(
            label: 'See ${score.province} streams',
            onPressed: () {
              Navigator.of(sheetContext).pop();
              context.push(Routes.withId(Routes.pnpStreams, score.code));
            },
          ),
          const SizedBox(height: WsSpacing.lg),
          const WsDisclaimer(authority: 'the province'),
        ],
      ),
    ),
  );
}

class _LineRow extends StatelessWidget {
  const _LineRow({required this.line});

  final PnpLine line;

  @override
  Widget build(BuildContext context) {
    final points = line.points < 0
        ? '−${line.points.abs()}'
        : line.maximum == 0
            ? '${line.points}'
            : '${line.points} / ${line.maximum}';

    return Row(
      children: [
        Expanded(child: Text(line.label, style: context.text.bodyMedium)),
        const SizedBox(width: WsSpacing.md),
        Text(
          points,
          style: context.text.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
