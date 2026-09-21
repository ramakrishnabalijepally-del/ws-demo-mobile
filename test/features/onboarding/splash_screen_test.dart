import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:worksettle_mobile/app/router/routes.dart';
import 'package:worksettle_mobile/app/theme/theme.dart';
import 'package:worksettle_mobile/features/onboarding/onboarding.dart';
import 'package:worksettle_mobile/shared/shared.dart';

/// The splash with a stand-in for the screen it hands over to, so a test can
/// see the handover happen rather than infer it from a timer.
Widget _host({bool reduceMotion = false}) {
  final router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: Routes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.onboarding,
        builder: (_, __) => const Scaffold(body: Text('onboarding')),
      ),
    ],
  );
  return MaterialApp.router(
    theme: WorkSettleTheme.light,
    routerConfig: router,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
      child: child!,
    ),
  );
}

void main() {
  setUp(() {
    // A tall phone, so the globe is sized by width the way it is on a handset.
    // ignore: deprecated_member_use
    final view = TestWidgetsFlutterBinding.ensureInitialized()
        .platformDispatcher
        .views
        .first;
    view.physicalSize = const Size(390, 844);
    view.devicePixelRatio = 1;
    addTearDown(view.reset);
  });

  testWidgets('the globe and the lockup sit on the centre line',
      (tester) async {
    await tester.pumpWidget(_host());
    await tester.pump(const Duration(seconds: 2));

    final screen = tester.getRect(find.byType(SplashScreen));
    expect(
      tester.getRect(find.byType(WsGlobe)).center.dx,
      moreOrLessEquals(screen.center.dx, epsilon: 0.5),
    );
    expect(
      tester.getRect(find.byType(WsWordmark)).center.dx,
      moreOrLessEquals(screen.center.dx, epsilon: 0.5),
    );

    await tester.pump(WsMotion.splashDwell);
    await tester.pumpAndSettle();
  });

  testWidgets('the globe holds its place while the lockup arrives',
      (tester) async {
    await tester.pumpWidget(_host());

    // The lockup fades and scales, and neither touches layout — so the globe's
    // centre must be the same number on every frame of the sequence. It was
    // not: the wordmark's artwork claimed no height until it had decoded, and
    // the globe jumped 32 px the moment it did.
    final centre = tester.getRect(find.byType(WsGlobe)).center;
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      final now = tester.getRect(find.byType(WsGlobe)).center;
      expect(now.dx, moreOrLessEquals(centre.dx, epsilon: 0.01));
      expect(now.dy, moreOrLessEquals(centre.dy, epsilon: 0.01));
    }

    await tester.pump(WsMotion.splashDwell);
    await tester.pumpAndSettle();
  });

  testWidgets('it holds for six seconds before handing over', (tester) async {
    await tester.pumpWidget(_host());

    // Five seconds in, the globe is still turning and the lockup is still up.
    await tester.pump(const Duration(seconds: 5));
    expect(find.byType(WsGlobe), findsOneWidget);
    expect(find.byType(WsWordmark), findsOneWidget);
    expect(find.text('onboarding'), findsNothing);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('onboarding'), findsOneWidget);
  });

  test('the lockup fades in rather than popping on', () {
    // The reveal is the tender curve over 0.35–0.96 of the sequence. What makes
    // it read as soft is that no single frame carries much of the fade — the
    // exponential ease-out this replaced spent over half its opacity in the
    // first few frames of its window, which is what a pop is.
    const begin = 0.3;
    const end = 0.92;
    const frames = 60; // roughly a second of the sequence, at 60 fps
    var previous = 0.0;
    var biggestStep = 0.0;
    for (var i = 0; i <= frames; i++) {
      final t = begin + (end - begin) * i / frames;
      final opacity = WsMotion.staggered(t, begin, end, curve: WsMotion.tender);
      expect(opacity, greaterThanOrEqualTo(previous));
      biggestStep = math.max(biggestStep, opacity - previous);
      previous = opacity;
    }
    expect(previous, moreOrLessEquals(1, epsilon: 0.001));
    expect(biggestStep, lessThan(0.04));
  });

  test('the dwell is six seconds', () {
    // Long enough for the sequence to be watched rather than glimpsed; the
    // animation timings themselves are unchanged.
    expect(WsMotion.splashDwell.inSeconds, 6);
    expect(
      WsMotion.splashDwell,
      greaterThan(WsMotion.splashSequence),
      reason: 'the splash must outlast its own entrance animation',
    );
  });

  testWidgets('reduced motion hands over without the long dwell',
      (tester) async {
    await tester.pumpWidget(_host(reduceMotion: true));
    await tester.pump(WsMotion.splashHold + WsMotion.slow);
    await tester.pumpAndSettle();
    expect(find.text('onboarding'), findsOneWidget);
  });
}
