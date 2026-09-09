import 'package:flutter/material.dart';

import '../../app/theme/theme.dart';
import 'ws_progress.dart';
import 'ws_surfaces.dart';
import 'ws_verdict_chip.dart';

/// The score card. `design/worksettle-design-system.md` section 11.
///
/// Icon tile · title · supporting line · metric with denominator · verdict pill
/// · progress bar · context line · disclaimer.
///
/// **The progress bar reports *how far*, never *how good*** — only the pill
/// reports the verdict. The CRS bar is the one bar allowed to fill in red,
/// because CRS is the product's headline number.
///
/// The same card renders inside an assistant answer bubble, so "468, Good
/// Range" looks identical in chat and on the dashboard.
class WsScoreCard extends StatelessWidget {
  const WsScoreCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.maximum,
    required this.verdict,
    required this.verdictLabel,
    this.supporting,
    this.contextLine,
    this.brandFill = false,
    this.brandIcon = false,
    this.onTap,
    this.showDisclaimer = false,
    super.key,
  });

  final IconData icon;
  final String title;

  /// The line under the title.
  final String? supporting;

  final num value;
  final num maximum;

  final WsVerdict verdict;
  final String verdictLabel;

  /// Puts the number in context — "Recent Draws: 435–470". A number alone is
  /// not an answer.
  final String? contextLine;

  /// CRS only.
  final bool brandFill;

  /// Job Matching only.
  final bool brandIcon;

  final VoidCallback? onTap;

  /// Every eligibility result carries the provisional disclaimer. It lives in
  /// the component so no screen can forget it.
  final bool showDisclaimer;

  @override
  Widget build(BuildContext context) {
    return WsCard(
      raised: true,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WsIconTile(icon: icon, brand: brandIcon),
              const SizedBox(width: WsSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, style: context.text.titleMedium),
                    if (supporting != null)
                      Text(
                        supporting!,
                        style: context.text.bodySmall
                            ?.copyWith(color: context.ws.caption),
                      ),
                  ],
                ),
              ),
              WsVerdictChip(verdict: verdict, label: verdictLabel),
            ],
          ),
          const SizedBox(height: WsSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('$value', style: context.text.displaySmall),
              const SizedBox(width: WsSpacing.xs + 2),
              Text(
                '/ $maximum',
                style: WsTypography.denominator(context.ws.caption),
              ),
            ],
          ),
          const SizedBox(height: WsSpacing.md),
          WsMeter(
            value: value,
            maximum: maximum,
            useBrandFill: brandFill,
            semanticLabel: '$title: $value out of $maximum, $verdictLabel',
          ),
          if (contextLine != null) ...[
            const SizedBox(height: WsSpacing.md),
            Text(
              contextLine!,
              style:
                  context.text.bodySmall?.copyWith(color: context.ws.caption),
            ),
          ],
          if (showDisclaimer) ...[
            const SizedBox(height: WsSpacing.md),
            const WsDisclaimer(),
          ],
        ],
      ),
    );
  }
}

/// The provisional-eligibility disclaimer.
///
/// **Never state an immigration outcome as certain.** Assessments are based on
/// what the user provided and results are initial — final eligibility rests
/// with IRCC or the province. This is a legal requirement and a trust
/// requirement, and it belongs in the component so no screen can forget it.
class WsDisclaimer extends StatelessWidget {
  const WsDisclaimer({this.authority = 'the Government of Canada', super.key});

  final String authority;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline_rounded,
          size: 14,
          color: context.ws.caption,
        ),
        const SizedBox(width: WsSpacing.sm),
        Expanded(
          child: Text(
            'This result is initial and based on the information you provided. '
            'Final eligibility is determined by $authority.',
            style: context.text.bodySmall?.copyWith(color: context.ws.caption),
          ),
        ),
      ],
    );
  }
}

/// The score breakdown table. Section 16.
///
/// Label/value rows on a tinted card, values right-aligned and tabular, a
/// hairline above the total, and **the total in Settle Red.**
class WsScoreBreakdown extends StatelessWidget {
  const WsScoreBreakdown({
    required this.rows,
    required this.totalLabel,
    required this.total,
    super.key,
  });

  final List<({String label, num value})> rows;
  final String totalLabel;
  final num total;

  @override
  Widget build(BuildContext context) {
    return WsCard(
      color: context.ws.scoreBreakdown,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: WsSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Text(row.label, style: context.text.bodyMedium),
                  ),
                  Text(
                    '${row.value}',
                    style: context.text.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          Divider(color: context.colors.outlineVariant),
          const SizedBox(height: WsSpacing.md),
          Row(
            children: [
              Expanded(
                child: Text(totalLabel, style: context.text.titleMedium),
              ),
              Text(
                '$total',
                style: context.text.titleMedium
                    ?.copyWith(color: context.ws.redOnSurface),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
