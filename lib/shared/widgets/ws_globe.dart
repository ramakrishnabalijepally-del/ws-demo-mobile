import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show PointMode;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../app/theme/theme.dart';
import '../utils/globe_geometry.dart';

/// The WorkSettle globe: the world's land as a field of dots, Canadian cities
/// in the brand red, and the routes newcomers took to reach them.
///
/// It is the marketing site's hero globe brought over intact — the same
/// geometry, the same six destinations, the same six journeys — rebuilt on
/// Flutter's own animation framework and a `CustomPainter`, because nothing in
/// that stack transfers (`.agents/rules/04-animation.md`).
///
/// Depth comes from tone, not from effects: dots facing the reader are
/// darkest, dots toward the rim lighter, and the far side shows faintly
/// through. Red is kept for the destinations and the routes into them.
///
/// Three things move:
///
/// - the globe turns slowly on its own, starting with Canada facing the reader;
/// - a red streak runs down each route in turn and lands on its city, which
///   pulses once as it arrives;
/// - a horizontal drag spins it by hand, and it carries on with a little
///   inertia when released.
///
/// Under reduced motion it neither spins nor sends streaks: the routes stay
/// drawn as faint lines with every marker in place, which is the same final
/// state the animation settles into. Dragging still works — that motion is the
/// reader's own.
class WsGlobe extends StatefulWidget {
  const WsGlobe({
    this.interactive = true,
    this.showRoutes = true,
    this.semanticLabel =
        'A globe showing routes from the Philippines, Nigeria, Sri Lanka, '
            'Poland, India and the UAE to cities across Canada',
    super.key,
  });

  /// Whether the reader can spin it by hand.
  final bool interactive;

  /// Whether the journeys are drawn at all. A globe on its own is the quieter
  /// variant, for a screen that already has a story of its own to tell.
  final bool showRoutes;

  final String semanticLabel;

  /// Degrees per second when nobody is touching it — one turn a minute.
  static const double autoSpeed = 6;

  /// Degrees of spin per logical pixel dragged.
  static const double dragRatio = 0.45;

  @override
  State<WsGlobe> createState() => _WsGlobeState();
}

class _WsGlobeState extends State<WsGlobe> with SingleTickerProviderStateMixin {
  /// A free-running ticker rather than a timed controller: the globe has no
  /// end state to animate toward, it simply turns until it leaves the screen.
  late final Ticker _ticker = createTicker(_tick);

  final GlobeLandBuffer _land = GlobeLandBuffer();
  final _GlobeClock _clock = _GlobeClock();

  /// Head and tail of each streak along its route, 0–1. Head beyond tail is a
  /// streak in flight.
  late final List<_Flight> _flights =
      List<_Flight>.generate(kGlobeRoutes.length, (_) => _Flight());

  Duration _last = Duration.zero;
  double _inertia = 0;
  bool _dragging = false;
  bool _reduced = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = WsMotion.reduced(context);
    if (reduced == _reduced && _ticker.isActive) return;
    _reduced = reduced;
    if (reduced) {
      // The same final state the sequence would settle into: every route drawn,
      // no streak in flight.
      for (final flight in _flights) {
        flight
          ..head = 0
          ..tail = 0
          ..pulse = 0;
      }
      _clock
        ..rotation = kInitialRotation
        ..frame();
      if (_ticker.isActive) _ticker.stop();
    } else if (!_ticker.isActive) {
      _last = Duration.zero;
      _ticker.start();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _clock.dispose();
    super.dispose();
  }

  void _tick(Duration elapsed) {
    // Clamped so a dropped frame or a backgrounded app does not jump the globe
    // a third of a turn on the next tick.
    final dt =
        math.min((elapsed - _last).inMicroseconds / 1e6, 0.05).clamp(0.0, 0.05);
    _last = elapsed;
    if (dt == 0) return;

    if (!_dragging) {
      _clock.rotation += (WsGlobe.autoSpeed + _inertia) * dt;
      _inertia *= math.pow(0.04, dt).toDouble(); // settles within a second
      if (_inertia.abs() < 0.5) _inertia = 0;
    }

    if (widget.showRoutes) _advanceFlights(dt);
    // The painter listens to the clock, so a frame repaints it without
    // rebuilding the subtree above it.
    _clock.frame();
  }

  /// Each route departs in turn, a beat apart, and the whole cycle repeats.
  void _advanceFlights(double dt) {
    for (var i = 0; i < _flights.length; i++) {
      final flight = _flights[i];
      flight.clock += dt;
      final start = i * _Flight.stagger;
      final t = (flight.clock - start) % _Flight.cycle;
      if (flight.clock < start) continue;

      flight.head = _eased(t / _Flight.flightTime);
      flight.tail = _eased((t - _Flight.tailDelay) / _Flight.flightTime);
      flight.pulse =
          ((t - _Flight.flightTime) / _Flight.pulseTime).clamp(0.0, 1.0);
    }
  }

  /// `power2.inOut` — the ease the web globe's streaks use, so a flight leaves
  /// and arrives at the same pace on both surfaces.
  static double _eased(double t) => t <= 0
      ? 0
      : t >= 1
          ? 1
          : Curves.easeInOutQuad.transform(t);

  void _onDragStart(DragStartDetails _) {
    _dragging = true;
    _inertia = 0;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _clock
      ..rotation += details.delta.dx * WsGlobe.dragRatio
      ..frame();
    // A flick should carry: the velocity the finger left with, in degrees.
    _inertia = details.delta.dx * WsGlobe.dragRatio * 30;
  }

  void _onDragEnd(DragEndDetails _) {
    _dragging = false;
    if (_reduced) _inertia = 0;
  }

  @override
  Widget build(BuildContext context) {
    final globe = RepaintBoundary(
      child: CustomPaint(
        painter: _GlobePainter(
          clock: _clock,
          land: _land,
          flights: widget.showRoutes ? _flights : const <_Flight>[],
          sphereInner: context.colors.surface,
          sphereOuter: context.colors.surfaceContainerHigh,
          edge: context.colors.outlineVariant,
          faceDot: context.colors.onSurfaceVariant,
          rimDot: context.ws.placeholder,
          backDot: context.colors.outlineVariant,
          route: context.colors.primary,
          marker: context.colors.primary,
          markerRing: context.colors.surface,
          origin: context.colors.onSurface,
        ),
        size: Size.infinite,
      ),
    );

    return Semantics(
      label: widget.semanticLabel,
      image: true,
      child: AspectRatio(
        aspectRatio: 1,
        child: widget.interactive
            ? GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragStart: _onDragStart,
                onHorizontalDragUpdate: _onDragUpdate,
                onHorizontalDragEnd: _onDragEnd,
                child: globe,
              )
            : globe,
      ),
    );
  }
}

/// One journey's state: where its streak is, and how far through its arrival
/// pulse the destination city is.
class _Flight {
  /// Seconds the route has been running, across repeats.
  double clock = 0;

  double head = 0;
  double tail = 0;
  double pulse = 0;

  /// Seconds for a streak to run the length of its route.
  static const double flightTime = 1.8;

  /// How long after the head leaves the tail follows, which is what gives the
  /// streak its length.
  static const double tailDelay = 0.7;

  /// Seconds the destination's arrival ring takes to bloom and fade.
  static const double pulseTime = 1.2;

  /// A beat between one route departing and the next, so they read as six
  /// journeys rather than one burst.
  static const double stagger = 0.9;

  /// A whole flight plus a rest, before the route runs again.
  static const double cycle = flightTime + pulseTime + 2.4;
}

/// The globe's frame clock: one turn value, and a repaint signal the painter
/// listens to. A [ChangeNotifier] rather than a `ValueNotifier<double>` because
/// a frame can change a streak without changing the rotation — while a finger
/// is holding the globe still, for instance.
class _GlobeClock extends ChangeNotifier {
  double rotation = kInitialRotation;

  void frame() => notifyListeners();
}

class _GlobePainter extends CustomPainter {
  _GlobePainter({
    required this.clock,
    required this.land,
    required this.flights,
    required this.sphereInner,
    required this.sphereOuter,
    required this.edge,
    required this.faceDot,
    required this.rimDot,
    required this.backDot,
    required this.route,
    required this.marker,
    required this.markerRing,
    required this.origin,
  }) : super(repaint: clock);

  final _GlobeClock clock;
  final GlobeLandBuffer land;
  final List<_Flight> flights;

  final Color sphereInner;
  final Color sphereOuter;
  final Color edge;
  final Color faceDot;
  final Color rimDot;
  final Color backDot;
  final Color route;
  final Color marker;
  final Color markerRing;
  final Color origin;

  /// The radius the web globe's stroke widths were chosen against. Everything
  /// drawn here is scaled from it, so the globe reads the same on a 360 dp
  /// phone as on a 430 dp one instead of thinning out as it shrinks.
  static const double _referenceRadius = 200;

  /// The globe leans a little off vertical, as it does on the web.
  static const double _tilt = -8 * math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    // Room for the markers and the lifted arcs, which sit outside the sphere.
    final radius = math.min(size.width, size.height) / 2 - 14;
    if (radius <= 0) return;
    final scale = radius / _referenceRadius;
    final turn = clock.rotation;

    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);

    final sphere = Rect.fromCircle(center: Offset.zero, radius: radius);
    canvas.drawCircle(
      Offset.zero,
      radius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.24, -0.36),
          radius: 0.72,
          colors: <Color>[sphereInner, sphereOuter],
        ).createShader(sphere),
    );
    canvas.drawCircle(
      Offset.zero,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = edge,
    );

    canvas.rotate(_tilt);

    final bands = land.update(turn, radius);
    _dots(canvas, bands.back, backDot.withValues(alpha: 0.35), 1.8 * scale);
    _dots(canvas, bands.rim, rimDot.withValues(alpha: 0.8), 2.1 * scale);
    _dots(canvas, bands.face, faceDot, 2.3 * scale);

    if (flights.isNotEmpty) _paintJourneys(canvas, turn, radius, scale);

    for (final city in kGlobeCities) {
      final p = projectPlace(city, turn, radius);
      if (!p.visible) continue;
      _marker(canvas, p.position, 4.5 * scale);
    }

    canvas.restore();
  }

  void _paintJourneys(Canvas canvas, double turn, double radius, double scale) {
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // The routes themselves, faint and always present — the streaks are what
    // move along them.
    line
      ..color = route.withValues(alpha: 0.3)
      ..strokeWidth = 1.25 * scale;
    for (final journey in kGlobeRoutes) {
      _stroke(canvas, arcRuns(journey.from, journey.to, turn, radius), line);
    }

    line
      ..color = route
      ..strokeWidth = 2.25 * scale;
    for (var i = 0; i < kGlobeRoutes.length; i++) {
      final journey = kGlobeRoutes[i];
      final flight = flights[i];

      if (flight.head > flight.tail) {
        _stroke(
          canvas,
          arcRuns(
            journey.from,
            journey.to,
            turn,
            radius,
            start: flight.tail,
            end: flight.head,
          ),
          line,
        );
        if (flight.head < 1) {
          final tip =
              arcHead(journey.from, journey.to, turn, radius, flight.head);
          if (tip.visible) _marker(canvas, tip.position, 3.5 * scale);
        }
      }

      final from = projectPlace(journey.from, turn, radius);
      if (from.visible) {
        canvas
          ..drawCircle(from.position, 3 * scale, Paint()..color = origin)
          ..drawCircle(
            from.position,
            3 * scale,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.25 * scale
              ..color = markerRing,
          );
      }

      // The arrival: a ring blooming out of the destination and fading.
      if (flight.pulse > 0 && flight.pulse < 1) {
        final to = projectPlace(journey.to, turn, radius);
        if (to.visible) {
          final bloom = Curves.easeOut.transform(flight.pulse);
          canvas.drawCircle(
            to.position,
            4.5 * scale * (1 + 3 * bloom),
            Paint()..color = marker.withValues(alpha: 0.45 * (1 - bloom)),
          );
        }
      }
    }
  }

  void _marker(Canvas canvas, Offset at, double r) {
    canvas
      ..drawCircle(at, r, Paint()..color = marker)
      ..drawCircle(
        at,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = r / 3
          ..color = markerRing,
      );
  }

  void _stroke(Canvas canvas, List<List<Offset>> runs, Paint paint) {
    for (final run in runs) {
      final path = Path()..moveTo(run.first.dx, run.first.dy);
      for (var i = 1; i < run.length; i++) {
        path.lineTo(run[i].dx, run[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  void _dots(Canvas canvas, Float32List points, Color color, double width) {
    if (points.isEmpty) return;
    canvas.drawRawPoints(
      PointMode.points,
      points,
      Paint()
        ..color = color
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round,
    );
  }

  /// The painter repaints from [clock]; a rebuild only matters if the theme
  /// changed underneath it.
  @override
  bool shouldRepaint(_GlobePainter old) =>
      old.faceDot != faceDot ||
      old.route != route ||
      old.sphereInner != sphereInner ||
      old.flights != flights;
}
