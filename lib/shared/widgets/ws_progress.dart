/// Six progress devices. `design/worksettle-design-system.md` section 13.
///
/// The product is a sequence of long forms and long processes, so it carries
/// six of them. **Each answers a different question, and using the wrong one is
/// the most common way a screen becomes confusing:**
///
/// | Device | Answers |
/// | --- | --- |
/// | [WsSegmentBar] | How far through a long linear form |
/// | [WsDotRail] | How many short steps remain |
/// | [WsNumberedStepper] | Which named step, and can I go back |
/// | [WsMeter] | A score against its maximum |
/// | [WsRing] | Completeness of one thing — **profile strength only** |
/// | [WsProcessingTimeline] | What the system is doing right now |
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/theme.dart';

/// How far through a long linear form. Registration (6 segments), the CRS
/// calculator. Completed segments are red.
class WsSegmentBar extends StatelessWidget {
  const WsSegmentBar({
    required this.total,
    required this.completed,
    super.key,
  });

  final int total;
  final int completed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Step $completed of $total',
      child: Row(
        children: List.generate(total, (i) {
          return Expanded(
            child: Padding(
              padding:
                  EdgeInsets.only(right: i == total - 1 ? 0 : WsSpacing.xs),
              child: AnimatedContainer(
                duration: WsMotion.duration(context, WsMotion.medium),
                height: 5,
                decoration: BoxDecoration(
                  color: i < completed
                      ? context.colors.primary
                      : context.colors.outlineVariant,
                  borderRadius: WsRadii.pillR,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// How many short steps remain. Quick onboarding (4 dots).
class WsDotRail extends StatelessWidget {
  const WsDotRail({required this.total, required this.active, super.key});

  final int total;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Slide ${active + 1} of $total',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(total, (i) {
          final isActive = i == active;
          return AnimatedContainer(
            duration: WsMotion.duration(context, WsMotion.medium),
            margin: const EdgeInsets.symmetric(horizontal: WsSpacing.xs),
            width: isActive ? 22 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: isActive
                  ? context.colors.primary
                  : context.colors.outlineVariant,
              borderRadius: WsRadii.pillR,
            ),
          );
        }),
      ),
    );
  }
}

/// Which named step, and can I go back. The CRS calculator, BC PNP
/// eligibility. Circles are 24 px with 11.5/700 numerals.
class WsNumberedStepper extends StatelessWidget {
  const WsNumberedStepper({
    required this.steps,
    required this.current,
    this.onStepTapped,
    super.key,
  });

  /// Step names, in order.
  final List<String> steps;
  final int current;

  /// Non-null on completed steps only — you can go back, not forward.
  final void Function(int index)? onStepTapped;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: WsSpacing.gutter,
      child: Row(
        children: List.generate(steps.length, (i) {
          final done = i < current;
          final active = i == current;
          final canTap = done && onStepTapped != null;

          return Padding(
            padding: EdgeInsets.only(
              right: i == steps.length - 1 ? 0 : WsSpacing.md,
            ),
            child: Semantics(
              label: '${steps[i]}, step ${i + 1} of ${steps.length}',
              selected: active,
              child: InkWell(
                onTap: canTap ? () => onStepTapped!(i) : null,
                borderRadius: WsRadii.pillR,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: done || active
                            ? context.colors.primary
                            : Colors.transparent,
                        border: Border.all(
                          color: done || active
                              ? context.colors.primary
                              : context.colors.outline,
                          width: 2,
                        ),
                      ),
                      child: done
                          ? Icon(
                              Icons.check_rounded,
                              size: 14,
                              color: context.colors.onPrimary,
                            )
                          : Text(
                              '${i + 1}',
                              style: WsTypography.micro(
                                active
                                    ? context.colors.onPrimary
                                    : context.ws.caption,
                              ).copyWith(fontWeight: FontWeight.w700),
                            ),
                    ),
                    const SizedBox(width: WsSpacing.sm),
                    Text(
                      steps[i],
                      style: context.text.labelLarge?.copyWith(
                        color: active
                            ? context.colors.onSurface
                            : context.ws.caption,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// A score against its maximum. CRS, PNP, profile strength.
///
/// **It reports *how far*, never *how good*** — only the verdict pill reports
/// the verdict. The bar is ink on a Grey 200 track; the CRS bar is the one bar
/// allowed to fill in red, because CRS is the product's headline number.
class WsMeter extends StatelessWidget {
  const WsMeter({
    required this.value,
    required this.maximum,
    this.useBrandFill = false,
    this.semanticLabel,
    super.key,
  });

  final num value;
  final num maximum;

  /// CRS only.
  final bool useBrandFill;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final fraction = maximum == 0 ? 0.0 : (value / maximum).clamp(0.0, 1.0);
    return Semantics(
      label: semanticLabel ?? '$value out of $maximum',
      child: ClipRRect(
        borderRadius: WsRadii.pillR,
        child: LinearProgressIndicator(
          value: fraction.toDouble(),
          minHeight: 8,
          backgroundColor: context.colors.outlineVariant,
          valueColor: AlwaysStoppedAnimation<Color>(
            useBrandFill ? context.colors.primary : context.colors.onSurface,
          ),
        ),
      ),
    );
  }
}

/// Completeness of one thing. **Profile strength only — never a score.**
/// 7 px stroke, ink on Grey 200.
class WsRing extends StatelessWidget {
  const WsRing({
    required this.percent,
    this.diameter = 72,
    this.label,
    super.key,
  });

  /// 0–100.
  final int percent;
  final double diameter;

  /// Sits under the figure inside the ring.
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label == null
          ? '$percent per cent complete'
          : '$label, $percent per cent complete',
      child: SizedBox(
        width: diameter,
        height: diameter,
        child: CustomPaint(
          painter: _RingPainter(
            fraction: (percent / 100).clamp(0.0, 1.0),
            track: context.colors.outlineVariant,
            fill: context.colors.onSurface,
          ),
          child: Center(
            child: Text(
              '$percent%',
              style: context.text.titleMedium,
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.fraction,
    required this.track,
    required this.fill,
  });

  final double fraction;
  final Color track;
  final Color fill;

  static const double _stroke = 7;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (math.min(size.width, size.height) - _stroke) / 2;

    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke;

    final fillPaint = Paint()
      ..color = fill
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * fraction,
      false,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.fraction != fraction || old.track != track || old.fill != fill;
}

/// One step of the AI assistant's processing timeline.
class WsTimelineStep {
  const WsTimelineStep(this.label, {this.done = false});

  final String label;
  final bool done;
}

/// What the system is doing right now — **the assistant shows this instead of
/// a spinner.**
///
/// It names the actual work being done, one line at a time, which is what makes
/// a four-second wait feel like diligence rather than lag. Each row resolves in
/// order; the pending row is a hollow ring.
class WsProcessingTimeline extends StatelessWidget {
  const WsProcessingTimeline({required this.steps, super.key});

  final List<WsTimelineStep> steps;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final step in steps)
          Padding(
            padding: const EdgeInsets.only(bottom: WsSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (step.done)
                  Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: context.colors.onSurface,
                  )
                else
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: context.colors.outline, width: 2),
                    ),
                  ),
                const SizedBox(width: WsSpacing.md),
                Expanded(
                  child: Text(
                    step.label,
                    style: context.text.bodyMedium?.copyWith(
                      color: step.done
                          ? context.colors.onSurface
                          : context.ws.caption,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
