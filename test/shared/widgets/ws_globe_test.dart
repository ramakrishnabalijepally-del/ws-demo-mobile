import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worksettle_mobile/app/theme/theme.dart';
import 'package:worksettle_mobile/shared/widgets/ws_globe.dart';

Widget _host(Widget child, {bool reduceMotion = false}) => MaterialApp(
      theme: WorkSettleTheme.light,
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reduceMotion),
        child:
            Scaffold(body: Center(child: SizedBox(width: 300, child: child))),
      ),
    );

void main() {
  testWidgets('turns on its own, and keeps asking for frames', (tester) async {
    await tester.pumpWidget(_host(const WsGlobe()));
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(seconds: 2));
    // It repaints from its own clock rather than rebuilding anything a finder
    // could look at, so what a test can see is that it is still scheduling
    // frames two seconds in — and has not thrown while painting the world, six
    // arcs and their markers on every one of them.
    expect(tester.binding.hasScheduledFrame, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('reduced motion leaves it still, and assembled', (tester) async {
    await tester.pumpWidget(_host(const WsGlobe(), reduceMotion: true));
    await tester.pump(const Duration(seconds: 2));
    // Nothing moves and it stops asking for frames — but the world, the routes
    // and the markers are all drawn, which is the state the animation would
    // have settled into anyway.
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(find.byType(WsGlobe), findsOneWidget);
  });

  testWidgets('a drag spins it by hand', (tester) async {
    await tester.pumpWidget(_host(const WsGlobe(), reduceMotion: true));
    await tester.pump();
    await tester.drag(find.byType(WsGlobe), const Offset(120, 0));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('leaving the screen stops the ticker', (tester) async {
    await tester.pumpWidget(_host(const WsGlobe()));
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pumpWidget(_host(const SizedBox.shrink()));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('it is one image to a screen reader', (tester) async {
    await tester.pumpWidget(_host(const WsGlobe(), reduceMotion: true));
    expect(
      find.bySemanticsLabel(RegExp('Canada')),
      findsOneWidget,
    );
  });
}
