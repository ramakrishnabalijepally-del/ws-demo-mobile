import 'package:flutter/material.dart';

import '../../app/theme/theme.dart';
import 'ws_buttons.dart';
import 'ws_progress.dart';
import 'ws_rise_in.dart';
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
                    const SizedBox(height: WsSpacing.sm),
                    // Under the title rather than beside it: the longer
                    // verdicts ("Potential Options") and 200% text left the
                    // title no room on a 360 dp phone. It lands last, after
                    // the number has counted up, so it reads as the
                    // conclusion rather than a label.
                    WsAppear(
                      delay: 0.6,
                      duration: WsMotion.focal,
                      fromScale: 0.85,
                      distance: 0,
                      alignment: Alignment.centerLeft,
                      child:
                          WsVerdictChip(verdict: verdict, label: verdictLabel),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: WsSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              // Counts up from zero on arrival; screen readers get the final
              // figure only.
              Semantics(
                label: '$value',
                excludeSemantics: true,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: value.toDouble()),
                  duration: WsMotion.duration(context, WsMotion.focal),
                  curve: WsMotion.entrance,
                  builder: (context, counted, _) => Text(
                    value is int
                        ? '${counted.round()}'
                        : counted.toStringAsFixed(1),
                    style: context.text.displaySmall,
                  ),
                ),
              ),
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
  const WsDisclaimer({
    this.authority = 'the Government of Canada',
    this.message,
    super.key,
  });

  final String authority;

  /// Replaces the opening sentence where the thing on screen is not a result,
  /// such as an employer's stated support. The authority line always follows.
  final String? message;

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
            '${message ?? 'This result is initial and based on the information '
                'you provided.'} '
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
          // Rows arrive one after another, then the total counts up to meet
          // them — the sum is watched being made.
          for (final (i, row) in rows.indexed)
            WsAppear(
              delay: (i * 0.08).clamp(0.0, 0.7).toDouble(),
              duration: WsMotion.entranceSequence,
              child: Padding(
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
            ),
          Divider(color: context.colors.outlineVariant),
          const SizedBox(height: WsSpacing.md),
          Row(
            children: [
              Expanded(
                child: Text(totalLabel, style: context.text.titleMedium),
              ),
              Semantics(
                label: '$total',
                excludeSemantics: true,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: total.toDouble()),
                  duration:
                      WsMotion.duration(context, WsMotion.entranceSequence),
                  curve: WsMotion.entrance,
                  builder: (context, counted, _) => Text(
                    total is int
                        ? '${counted.round()}'
                        : counted.toStringAsFixed(1),
                    style: context.text.titleMedium
                        ?.copyWith(color: context.ws.redOnSurface),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// What sits in the score slot before the score has been asked for.
///
/// The same shell as [WsScoreCard] — raised card, icon tile, title, supporting
/// line — with the number replaced by the question that produces it. Keeping
/// the shell means the card does not jump when the score arrives; only its
/// contents change.
///
/// It carries no verdict and no progress bar, because there is nothing to
/// report yet. **An empty score slot is not an error state**, so it says what
/// to do rather than what is missing.
///
/// The button is optional. A screen that shows the slot but is not where the
/// score is produced leaves it off and explains where it is produced instead —
/// the CRS score is generated in Immigration and nowhere else, so only that
/// screen offers to generate it.
class WsScorePrompt extends StatelessWidget {
  const WsScorePrompt({
    required this.icon,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onPressed,
    this.supporting,
    this.note,
    super.key,
  }) : assert(
          (actionLabel == null) == (onPressed == null),
          'A label with nothing behind it is a dead button, and an action '
          'with no label cannot be pressed.',
        );

  final IconData icon;
  final String title;
  final String? supporting;

  /// One sentence on what pressing the button will do.
  final String body;

  /// Null on a screen that is not where the score is produced.
  final String? actionLabel;
  final VoidCallback? onPressed;

  /// A quieter line under the button — what is still missing, say.
  final String? note;

  @override
  Widget build(BuildContext context) {
    final supporting = this.supporting;
    final note = this.note;
    final actionLabel = this.actionLabel;
    final onPressed = this.onPressed;

    return WsCard(
      raised: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WsIconTile(icon: icon),
              const SizedBox(width: WsSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title, style: context.text.titleMedium),
                    if (supporting != null)
                      Text(
                        supporting,
                        style: context.text.bodySmall
                            ?.copyWith(color: context.ws.caption),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: WsSpacing.lg),
          Text(
            body,
            style: context.text.bodyMedium
                ?.copyWith(color: context.colors.onSurfaceVariant),
          ),
          if (actionLabel != null && onPressed != null) ...[
            const SizedBox(height: WsSpacing.lg),
            WsPrimaryButton(label: actionLabel, onPressed: onPressed),
          ],
          if (note != null) ...[
            const SizedBox(height: WsSpacing.md),
            Text(
              note,
              style:
                  context.text.bodySmall?.copyWith(color: context.ws.caption),
            ),
          ],
        ],
      ),
    );
  }
}
