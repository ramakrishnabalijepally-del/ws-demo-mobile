import 'package:flutter/material.dart';

import '../../../../app/theme/theme.dart';
import '../../animations/onboarding_motion.dart';

/// A dashed route drawn up to [progress], with a plane riding its leading
/// edge and, optionally, a destination pin that drops in on arrival.
///
/// The journey is the product's own metaphor — "Your Journey Starts Here" —
/// which is why this, not a generic fade, carries the launch.
class FlightArc extends StatelessWidget {
  const FlightArc({
    required this.points,
    required this.progress,
    required this.pathColor,
    required this.planeColor,
    this.planeSize = 26,
    this.destinationColor,
    super.key,
  });

  final FlightPoints points;

  /// 0–1 along the route.
  final double progress;

  final Color pathColor;
  final Color planeColor;
  final double planeSize;

  /// Null draws no pin.
  final Color? destinationColor;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          final plane = planeAlong(points, size, progress);
          final end = points.end;
          final arrival = ((progress - 0.9) / 0.1).clamp(0.0, 1.0);
          final shadow = [
            Shadow(
              color: context.colors.scrim.withValues(alpha: 0.35),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ];

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: FlightPathPainter(
                    points: points,
                    progress: progress,
                    color: pathColor,
                  ),
                ),
              ),
              if (destinationColor != null && arrival > 0)
                Positioned(
                  left: end.dx * size.width - planeSize / 2,
                  top: end.dy * size.height - planeSize,
                  child: Transform.scale(
                    scale: WsMotion.entrance.transform(arrival),
                    alignment: Alignment.bottomCenter,
                    child: Icon(
                      Icons.location_on_rounded,
                      size: planeSize,
                      color: destinationColor,
                      shadows: shadow,
                    ),
                  ),
                ),
              if (plane != null && arrival < 1)
                Positioned(
                  left: plane.position.dx - planeSize / 2,
                  top: plane.position.dy - planeSize / 2,
                  child: Opacity(
                    opacity: 1 - arrival,
                    child: Transform.rotate(
                      angle: plane.rotation,
                      child: Icon(
                        Icons.flight_rounded,
                        size: planeSize,
                        color: planeColor,
                        shadows: shadow,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
