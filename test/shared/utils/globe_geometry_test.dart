import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:worksettle_mobile/shared/data/globe_land.dart';
import 'package:worksettle_mobile/shared/utils/globe_geometry.dart';

/// The globe is drawn from this arithmetic every frame, and the one thing it
/// must get right is which side of the world is facing the reader: Canada, at
/// rest, with the journeys running toward it.
void main() {
  const radius = 200.0;

  group('land dots', () {
    test('are whole lat/lon pairs in range', () {
      expect(kGlobeLandDots.length.isEven, isTrue);
      expect(kGlobeLandDots.length, greaterThan(2000));
      for (var i = 0; i < kGlobeLandDots.length; i += 2) {
        expect(kGlobeLandDots[i].abs(), lessThanOrEqualTo(90));
        expect(kGlobeLandDots[i + 1].abs(), lessThanOrEqualTo(180));
      }
    });

    test('every dot lands in exactly one depth band, inside the sphere', () {
      final bands = GlobeLandBuffer().update(kInitialRotation, radius);
      final total = bands.face.length + bands.rim.length + bands.back.length;
      expect(total, kGlobeLandDots.length);

      for (final band in <Float32List>[bands.face, bands.rim, bands.back]) {
        for (var i = 0; i < band.length; i += 2) {
          final r = band[i] * band[i] + band[i + 1] * band[i + 1];
          // Orthographic: every dot projects inside the disc it is drawn on.
          expect(r, lessThanOrEqualTo(radius * radius + 1));
        }
      }
    });

    test('turning the globe moves dots between the bands', () {
      final buffer = GlobeLandBuffer();
      final facing = buffer.update(kInitialRotation, radius).face.length;
      final away = buffer.update(kInitialRotation + 180, radius).face.length;
      expect(facing, isNot(away));
    });
  });

  group('places', () {
    test('Canada faces the reader at rest, and its cities sit on the face', () {
      for (final city in kGlobeCities) {
        final p = projectPlace(city, kInitialRotation, radius);
        expect(p.visible, isTrue, reason: '${city.name} should be visible');
        expect(p.depth, greaterThan(0));
      }
    });

    test('half a turn later they are all behind it', () {
      for (final city in kGlobeCities) {
        expect(
          projectPlace(city, kInitialRotation + 180, radius).visible,
          isFalse,
          reason: '${city.name} should be hidden',
        );
      }
    });

    test('every journey ends at one of the six destinations', () {
      final names = kGlobeCities.map((c) => c.name).toSet();
      for (final route in kGlobeRoutes) {
        expect(names, contains(route.to.name));
      }
      expect(kGlobeRoutes.length, kGlobeCities.length);
    });
  });

  group('arcs', () {
    test('an arc starts at its origin and ends at its destination', () {
      final route = kGlobeRoutes.firstWhere((r) => r.to.name == 'Toronto');
      final start = arcHead(route.from, route.to, kInitialRotation, radius, 0);
      final end = arcHead(route.from, route.to, kInitialRotation, radius, 1);
      final from = projectPlace(route.from, kInitialRotation, radius);
      final to = projectPlace(route.to, kInitialRotation, radius);
      expect((start.position - from.position).distance, lessThan(1));
      expect((end.position - to.position).distance, lessThan(1));
    });

    test('the far side of an arc is dropped rather than drawn through', () {
      // Manila is on the far side when Canada faces us, so this route has to
      // come over the limb — it cannot be one unbroken run.
      final route = kGlobeRoutes.firstWhere((r) => r.from.name == 'Manila');
      final runs = arcRuns(route.from, route.to, kInitialRotation, radius);
      expect(runs, isNotEmpty);
      for (final run in runs) {
        for (final point in run) {
          expect(point.distance, lessThan(radius * 1.25));
        }
      }
    });

    test('an empty stretch of a route draws nothing', () {
      final route = kGlobeRoutes.first;
      expect(
        arcRuns(
          route.from,
          route.to,
          kInitialRotation,
          radius,
          start: 0.5,
          end: 0.5,
        ),
        isEmpty,
      );
    });
  });
}
