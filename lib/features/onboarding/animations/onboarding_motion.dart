import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/theme.dart';

/// [WsMotion.staggered], eased with [WsMotion.entrance] unless something
/// travels rather than arrives.
double staggered(
  double t,
  double begin,
  double end, {
  Curve curve = WsMotion.entrance,
}) =>
    WsMotion.staggered(t, begin, end, curve: curve);

/// A cubic flight path in fractions of the box it is drawn in, so the same
/// route scales to any screen.
class FlightPoints {
  const FlightPoints({
    required this.start,
    required this.control1,
    required this.control2,
    required this.end,
  });

  final Offset start;
  final Offset control1;
  final Offset control2;
  final Offset end;

  Path toPath(Size size) {
    Offset at(Offset f) => Offset(f.dx * size.width, f.dy * size.height);
    final c1 = at(control1);
    final c2 = at(control2);
    final e = at(end);
    final s = at(start);
    return Path()
      ..moveTo(s.dx, s.dy)
      ..cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, e.dx, e.dy);
  }
}

/// Where the plane is, and which way it faces, [progress] of the way along.
({Offset position, double rotation})? planeAlong(
  FlightPoints points,
  Size size,
  double progress,
) {
  if (progress <= 0 || size.isEmpty) return null;
  final metric = points.toPath(size).computeMetrics().first;
  final tangent = metric.getTangentForOffset(metric.length * progress);
  if (tangent == null) return null;
  // Material's flight glyph points up; turn it onto the direction of travel.
  final rotation =
      math.atan2(tangent.vector.dy, tangent.vector.dx) + math.pi / 2;
  return (position: tangent.position, rotation: rotation);
}

/// Draws the dashed route up to [progress].
class FlightPathPainter extends CustomPainter {
  FlightPathPainter({
    required this.points,
    required this.progress,
    required this.color,
  });

  final FlightPoints points;
  final double progress;
  final Color color;

  static const double _dash = 7;
  static const double _gap = 6;
  static const double _stroke = 2;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final metric = points.toPath(size).computeMetrics().first;
    final end = metric.length * progress.clamp(0.0, 1.0);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round;

    for (var d = 0.0; d < end; d += _dash + _gap) {
      canvas.drawPath(
        metric.extractPath(d, math.min(d + _dash, end)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(FlightPathPainter old) =>
      old.progress != progress || old.color != color || old.points != points;
}
