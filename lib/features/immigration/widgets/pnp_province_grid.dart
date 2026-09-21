import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/theme.dart';
import '../../../shared/controllers/crs_controller.dart';
import '../../../shared/shared.dart';
import '../../../shared/utils/pnp_calculator.dart';
import '../controllers/pnp_status.dart';
import '../data/mock_immigration.dart';
import 'pnp_score_sheet.dart';

/// PNP scores, one small card per province, two to a row.
///
/// **Each province is generated on its own.** A card starts as a way to get
/// that province's score and becomes the score once asked for; nothing about
/// Alberta waits on Manitoba. A generated card opens the breakdown.
///
/// The four provinces with a points grid lead; the rest have no grid to score
/// against, so their cards say so and open the province's streams instead.
/// Six show at first and the rest sit behind "Show all provinces".
class PnpProvinceGrid extends ConsumerStatefulWidget {
  const PnpProvinceGrid({this.canGenerate = true, super.key});

  /// False on the profile: scores are generated in Immigration, so an
  /// ungenerated card there says so — and a tap still takes the reader to
  /// that province's status screen, with Back returning to the profile.
  final bool canGenerate;

  @override
  ConsumerState<PnpProvinceGrid> createState() => _PnpProvinceGridState();
}

class _PnpProvinceGridState extends ConsumerState<PnpProvinceGrid> {
  static const int _collapsed = 6;
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final scores = ref.watch(pnpScoresProvider);
    final revealed = ref.watch(pnpRevealedProvider);
    final scored = {for (final s in scores) s.code};

    final cards = <Widget>[
      for (final score in scores)
        _ProvinceCard(
          code: score.code,
          name: score.province,
          score: revealed.contains(score.code) ? score : null,
          canGenerate: widget.canGenerate,
        ),
      for (final province in mockProvinces)
        if (!scored.contains(province.abbreviation))
          _ProvinceCard(
            code: province.abbreviation,
            name: province.name,
            hasGrid: false,
            canGenerate: widget.canGenerate,
          ),
    ];
    final visible = _expanded ? cards : cards.take(_collapsed).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < visible.length; i += 2) ...[
          if (i > 0) const SizedBox(height: WsSpacing.md),
          // Rows rather than a GridView: a grid fixes each card's height, and
          // at 200% text a fixed height clips. A row grows to its taller card.
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: visible[i]),
                const SizedBox(width: WsSpacing.md),
                Expanded(
                  child: i + 1 < visible.length
                      ? visible[i + 1]
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
        if (cards.length > _collapsed) ...[
          const SizedBox(height: WsSpacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: WsLink(
              label: _expanded
                  ? 'Show fewer provinces'
                  : 'Show all provinces (${cards.length})',
              underline: false,
              onPressed: () => setState(() => _expanded = !_expanded),
            ),
          ),
        ],
      ],
    );
  }
}

class _ProvinceCard extends StatelessWidget {
  const _ProvinceCard({
    required this.code,
    required this.name,
    required this.canGenerate,
    this.score,
    this.hasGrid = true,
  });

  final String code;
  final String name;

  /// Null until this province's score has been asked for.
  final PnpScore? score;
  final bool hasGrid;
  final bool canGenerate;

  @override
  Widget build(BuildContext context) {
    final score = this.score;

    // Pushed, never `go`: these screens open above whatever the grid sits
    // in — the Immigration tab or Profile — so Back returns there.
    final VoidCallback onTap = switch ((hasGrid, score)) {
      (false, _) => () => context.push(Routes.withId(Routes.pnpStreams, code)),
      (true, final PnpScore s) => () => showPnpScoreSheet(context, s),
      (true, null) => () => context.push(Routes.withId(Routes.pnpStatus, code)),
    };

    return Semantics(
      button: true,
      label: switch ((hasGrid, score)) {
        (false, _) => '$name, no points grid. Opens its streams.',
        (true, final PnpScore s) =>
          '$name, ${s.total} out of ${s.maximum}. Opens the breakdown.',
        _ => '$name, score not generated yet',
      },
      excludeSemantics: true,
      child: WsCard(
        onTap: onTap,
        padding: const EdgeInsets.all(WsSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                WsProvinceMark(code: code, label: name, size: 28),
                const Spacer(),
                Icon(
                  Icons.chevron_right_rounded,
                  size: WsIconSize.chevron + 4,
                  color: context.ws.placeholder,
                ),
              ],
            ),
            const SizedBox(height: WsSpacing.sm),
            Text(
              name,
              style: context.text.titleMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: WsSpacing.sm),
            const Spacer(),
            if (score != null)
              _ScoreReadout(score: score)
            else if (hasGrid && canGenerate)
              // A link's colour, because it is the way to the score.
              Text(
                'Get score',
                style: context.text.labelLarge
                    ?.copyWith(color: context.ws.redOnSurface),
              )
            else
              Text(
                hasGrid ? 'Get it in Immigration' : 'No points grid',
                style:
                    context.text.bodySmall?.copyWith(color: context.ws.caption),
              ),
          ],
        ),
      ),
    );
  }
}

class _ScoreReadout extends StatelessWidget {
  const _ScoreReadout({required this.score});

  final PnpScore score;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: '${score.total}',
                style: context.text.headlineLarge?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              TextSpan(
                text: ' / ${score.maximum}',
                style: WsTypography.denominator(context.ws.caption),
              ),
            ],
          ),
        ),
        const SizedBox(height: WsSpacing.xs),
        WsMeter(value: score.total, maximum: score.maximum),
      ],
    );
  }
}
