/// Geometry for [WsGlobe] — an orthographic sphere spun about its vertical
/// axis, with Canada facing the reader.
///
/// This is the same construction as the marketing site's hero globe
/// (`ws-marketing/src/lib/globe.ts`), so the two WorkSettle surfaces show the
/// same world, the same destinations and the same routes. Only the output
/// differs: the web draws SVG paths, this fills point buffers for a
/// `CustomPainter`.
///
/// Everything here is pure maths on unit vectors — no Flutter, no state — so
/// it can be exercised in a plain unit test.
library;

import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show Offset;

import '../data/globe_land.dart';

/// Where the globe starts: Canada facing the reader.
const double kInitialRotation = 95;

const double _degrees = math.pi / 180;

/// How far the north pole leans toward the reader, so Canada sits on the face:
/// 28°, precomputed because the lean never changes and the spin loop runs it
/// thousands of times a frame.
const double _cosPitch = 0.8829475928589269;
const double _sinPitch = 0.4694715627858908;

/// A place on the globe.
class GlobePlace {
  const GlobePlace({required this.name, required this.lat, required this.lon});

  final String name;
  final double lat;
  final double lon;
}

/// WorkSettle's destinations — drawn in the brand red.
const List<GlobePlace> kGlobeCities = <GlobePlace>[
  GlobePlace(name: 'Vancouver', lat: 49.3, lon: -123.1),
  GlobePlace(name: 'Calgary', lat: 51.0, lon: -114.1),
  GlobePlace(name: 'Saskatoon', lat: 52.1, lon: -106.7),
  GlobePlace(name: 'Toronto', lat: 43.7, lon: -79.4),
  GlobePlace(name: 'Montréal', lat: 45.5, lon: -73.6),
  GlobePlace(name: 'Halifax', lat: 44.6, lon: -63.6),
];

/// One newcomer's journey: where they started, and the city they settled in.
class GlobeRoute {
  const GlobeRoute({required this.from, required this.to});

  final GlobePlace from;
  final GlobePlace to;
}

/// Where the newcomers in our stories come from, each routed to a city.
const List<GlobeRoute> kGlobeRoutes = <GlobeRoute>[
  GlobeRoute(
    from: GlobePlace(name: 'Manila', lat: 14.6, lon: 121.0),
    to: GlobePlace(name: 'Calgary', lat: 51.0, lon: -114.1),
  ),
  GlobeRoute(
    from: GlobePlace(name: 'Lagos', lat: 6.5, lon: 3.4),
    to: GlobePlace(name: 'Halifax', lat: 44.6, lon: -63.6),
  ),
  GlobeRoute(
    from: GlobePlace(name: 'Colombo', lat: 6.9, lon: 79.9),
    to: GlobePlace(name: 'Toronto', lat: 43.7, lon: -79.4),
  ),
  GlobeRoute(
    from: GlobePlace(name: 'Warsaw', lat: 52.2, lon: 21.0),
    to: GlobePlace(name: 'Saskatoon', lat: 52.1, lon: -106.7),
  ),
  GlobeRoute(
    from: GlobePlace(name: 'Delhi', lat: 28.6, lon: 77.2),
    to: GlobePlace(name: 'Montréal', lat: 45.5, lon: -73.6),
  ),
  GlobeRoute(
    from: GlobePlace(name: 'Dubai', lat: 25.2, lon: 55.3),
    to: GlobePlace(name: 'Vancouver', lat: 49.3, lon: -123.1),
  ),
];

/// A point on the unit sphere, in the globe's own frame.
class _Vec {
  const _Vec(this.x, this.y, this.z);

  final double x;
  final double y;
  final double z;
}

_Vec _toVec(double lat, double lon) {
  final phi = lat * _degrees;
  final lambda = lon * _degrees;
  return _Vec(
    math.cos(phi) * math.sin(lambda),
    math.sin(phi),
    math.cos(phi) * math.cos(lambda),
  );
}

/// Spin about the polar axis, then lean the whole globe toward the reader.
_Vec _spin(_Vec v, double rotation) {
  final t = rotation * _degrees;
  final cosT = math.cos(t);
  final sinT = math.sin(t);
  final sx = v.x * cosT + v.z * sinT;
  final sz = v.z * cosT - v.x * sinT;
  return _Vec(
    sx,
    v.y * _cosPitch - sz * _sinPitch,
    v.y * _sinPitch + sz * _cosPitch,
  );
}

/// A projected point: where it lands on screen, and whether it faces us.
typedef GlobePoint = ({Offset position, bool visible, double depth});

/// Land dots at [rotation], sorted into three depth bands by how directly they
/// face the reader: the centre of the face, the rim, and the far side showing
/// faintly through. Depth is carried by tone, not by effects.
///
/// Each band is a raw point buffer — one `drawRawPoints` call paints a whole
/// hemisphere, rather than a thousand canvas operations.
class GlobeLandBands {
  GlobeLandBands(this.face, this.rim, this.back);

  final Float32List face;
  final Float32List rim;
  final Float32List back;
}

/// Reused across frames so a spin allocates nothing: the bands are rebuilt in
/// place every redraw and never outlive the painter that reads them.
class GlobeLandBuffer {
  GlobeLandBuffer() : _dotCount = kGlobeLandDots.length ~/ 2 {
    _face = Float32List(_dotCount * 2);
    _rim = Float32List(_dotCount * 2);
    _back = Float32List(_dotCount * 2);
  }

  final int _dotCount;
  late final Float32List _face;
  late final Float32List _rim;
  late final Float32List _back;

  /// Fills the three bands for [rotation] at [radius] and returns views onto
  /// them. The views are only valid until the next [update].
  GlobeLandBands update(double rotation, double radius) {
    var f = 0;
    var r = 0;
    var b = 0;
    final t = rotation * _degrees;
    final cosT = math.cos(t);
    final sinT = math.sin(t);
    for (var i = 0; i < _dotCount; i++) {
      final phi = kGlobeLandDots[i * 2] * _degrees;
      final lambda = kGlobeLandDots[i * 2 + 1] * _degrees;
      final cosPhi = math.cos(phi);
      final vx = cosPhi * math.sin(lambda);
      final vy = math.sin(phi);
      final vz = cosPhi * math.cos(lambda);

      final sx = vx * cosT + vz * sinT;
      final sz = vz * cosT - vx * sinT;
      final y = vy * _cosPitch - sz * _sinPitch;
      final z = vy * _sinPitch + sz * _cosPitch;

      final px = sx * radius;
      final py = -y * radius;

      if (z > 0.35) {
        _face[f++] = px;
        _face[f++] = py;
      } else if (z > 0) {
        _rim[r++] = px;
        _rim[r++] = py;
      } else {
        _back[b++] = px;
        _back[b++] = py;
      }
    }

    return GlobeLandBands(
      Float32List.sublistView(_face, 0, f),
      Float32List.sublistView(_rim, 0, r),
      Float32List.sublistView(_back, 0, b),
    );
  }
}

/// Screen position of a place at [rotation], and whether it is on the near
/// side. A little past the horizon counts as hidden, so a marker fades out
/// before it would smear along the rim.
GlobePoint projectPlace(GlobePlace place, double rotation, double radius) {
  final v = _spin(_toVec(place.lat, place.lon), rotation);
  return (
    position: Offset(v.x * radius, -v.y * radius),
    visible: v.z > 0.05,
    depth: v.z,
  );
}

_Vec _arcPoint(_Vec a, _Vec b, double omega, double t, double rotation) {
  final sinOmega = math.sin(omega) == 0 ? 1.0 : math.sin(omega);
  final wa = math.sin((1 - t) * omega) / sinOmega;
  final wb = math.sin(t * omega) / sinOmega;
  // Lifted off the surface, more so the further it travels, so a long flight
  // reads as an arc rather than as a line ruled on the sphere.
  final h = 1 + (0.04 + omega * 0.06) * math.sin(math.pi * t);
  return _spin(
    _Vec(
      (a.x * wa + b.x * wb) * h,
      (a.y * wa + b.y * wb) * h,
      (a.z * wa + b.z * wb) * h,
    ),
    rotation,
  );
}

double _angleBetween(_Vec a, _Vec b) =>
    math.acos((a.x * b.x + a.y * b.y + a.z * b.z).clamp(-1.0, 1.0));

/// A great-circle arc from [from] to [to], over the stretch [start]–[end] of
/// its length, as the visible runs of a path.
///
/// Points behind the globe break the run rather than draw through it, so an
/// arc disappears around the limb instead of cutting across the face.
List<List<Offset>> arcRuns(
  GlobePlace from,
  GlobePlace to,
  double rotation,
  double radius, {
  double start = 0,
  double end = 1,
}) {
  if (end <= start) return const <List<Offset>>[];
  final a = _toVec(from.lat, from.lon);
  final b = _toVec(to.lat, to.lon);
  final omega = _angleBetween(a, b);
  final steps = math.max(2, ((end - start) * 48).ceil());

  final runs = <List<Offset>>[];
  var run = <Offset>[];
  for (var i = 0; i <= steps; i++) {
    final v =
        _arcPoint(a, b, omega, start + (end - start) * i / steps, rotation);
    if (v.z > 0) {
      run.add(Offset(v.x * radius, -v.y * radius));
    } else if (run.length > 1) {
      runs.add(run);
      run = <Offset>[];
    } else {
      run = <Offset>[];
    }
  }
  if (run.length > 1) runs.add(run);
  return runs;
}

/// The point [t] of the way along an arc, and whether it can be seen — where
/// the streak's leading edge is.
GlobePoint arcHead(
  GlobePlace from,
  GlobePlace to,
  double rotation,
  double radius,
  double t,
) {
  final a = _toVec(from.lat, from.lon);
  final b = _toVec(to.lat, to.lon);
  final v = _arcPoint(a, b, _angleBetween(a, b), t, rotation);
  return (
    position: Offset(v.x * radius, -v.y * radius),
    visible: v.z > 0,
    depth: v.z,
  );
}
