import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worksettle_mobile/app/theme/theme.dart';
import 'package:worksettle_mobile/shared/widgets/ws_date_field.dart';

Widget _host(TextEditingController controller, {double textScale = 1}) =>
    MaterialApp(
      theme: WorkSettleTheme.light,
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            size: const Size(360, 740),
            textScaler: TextScaler.linear(textScale),
          ),
          child: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(WsSpacing.xl),
              child:
                  WsDateField(label: 'Date of birth', controller: controller),
            ),
          ),
        ),
      ),
    );

void main() {
  testWidgets('opens the wheels and writes the date back as YYYY-MM-DD',
      (tester) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final controller = TextEditingController(text: '1995-12-27');
    addTearDown(controller.dispose);

    await tester.pumpWidget(_host(controller));
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();

    expect(find.textContaining('27 December 1995'), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(controller.text, '1995-12-27');
    expect(find.text('Done'), findsNothing);
  });

  testWidgets('the sheet does not overflow at 200% text on a 360 dp phone',
      (tester) async {
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(_host(controller, textScale: 2));
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Done'), findsOneWidget);
  });
}
