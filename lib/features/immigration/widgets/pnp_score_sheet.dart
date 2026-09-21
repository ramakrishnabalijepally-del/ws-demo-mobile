import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/theme.dart';
import '../../../shared/shared.dart';
import '../../../shared/utils/pnp_calculator.dart';

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
