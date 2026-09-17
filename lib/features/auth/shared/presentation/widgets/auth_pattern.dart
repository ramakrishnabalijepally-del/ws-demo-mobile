import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../app/theme/theme.dart';

/// A halftone field of small Settle Red diamonds — the same silhouette as the
/// milestone confetti — densest at [corner] and thinning to nothing across the
/// ground, so the brand has texture without a second hue.
///
/// [reveal] (0–1) ripples the field in outward from the corner. When it is
/// complete — always, under reduced motion — the whole field is drawn.
class AuthPattern extends StatelessWidget {
  const AuthPattern({
    required this.reveal,
    this.corner = Alignment.topRight,
    this.spread = 0.95,
    super.key,
  });

  final Animation<double> reveal;
  final Alignment corner;

  /// How far across the box the pattern reaches, as a fraction of its longest
  /// side.
  final double spread;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: reveal,
          builder: (context, _) => CustomPaint(
            size: Size.infinite,
            painter: _HalftonePainter(
              progress: reveal.value,
              corner: corner,
              spread: spread,
              color: context.colors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _HalftonePainter extends CustomPainter {
  const _HalftonePainter({
    required this.progress,
    required this.corner,
    required this.spread,
    required this.color,
  });

  final double progress;
  final Alignment corner;
  final double spread;
  final Color color;

  static const double _cell = 16;
  static const double _maxHalf = 5;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || size.isEmpty) return;

    final origin = corner.alongSize(size);
    final reach = size.longestSide * spread;
    final paint = Paint();
    final cols = (size.width / _cell).ceil() + 1;
    final rows = (size.height / _cell).ceil() + 1;

    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        // Alternate rows shift half a cell so the grid reads as a weave
        // rather than graph paper.
        final x = c * _cell + (r.isOdd ? _cell / 2 : 0);
        final y = r * _cell;
        final distance = (Offset(x, y) - origin).distance / reach;
        final density = (1 - distance).clamp(0.0, 1.0);
        if (density <= 0.05) continue;

        // Cells nearer the corner arrive first.
        final arrived = ((progress * 1.4 - distance) / 0.4).clamp(0.0, 1.0);
        final half = _maxHalf * math.pow(density, 1.6).toDouble() * arrived;
        if (half < 0.4) continue;

        paint.color = color.withValues(alpha: 0.15 + 0.45 * density);
        canvas.drawPath(
          Path()
            ..moveTo(x, y - half)
            ..lineTo(x + half, y)
            ..lineTo(x, y + half)
            ..lineTo(x - half, y)
            ..close(),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_HalftonePainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.corner != corner ||
      old.spread != spread;
}
