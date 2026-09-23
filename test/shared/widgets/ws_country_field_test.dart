import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worksettle_mobile/app/theme/theme.dart';
import 'package:worksettle_mobile/shared/data/countries.dart';
import 'package:worksettle_mobile/shared/widgets/ws_country_field.dart';
import 'package:worksettle_mobile/shared/widgets/ws_province_mark.dart';

Widget _host(TextEditingController controller, {double textScale = 1}) =>
    MaterialApp(
      theme: WorkSettleTheme.light,
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
          ),
          child: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(WsSpacing.xl),
              child: WsCountryField(
                label: 'Country of Citizenship',
                controller: controller,
              ),
            ),
          ),
        ),
      ),
    );

void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(360, 740);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

void main() {
  test('every country has a unique two-letter code', () {
    final codes = countries.map((c) => c.$2).toSet();
    expect(codes.length, countries.length);
    expect(countries.every((c) => c.$2.length == 2), isTrue);
  });

  testWidgets('search narrows the list and a tap saves the name',
      (tester) async {
    _phone(tester);
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(_host(controller));
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).last, 'phil');
    await tester.pumpAndSettle();
    expect(find.text('Philippines'), findsOneWidget);
    expect(find.text('Afghanistan'), findsNothing);

    await tester.tap(find.text('Philippines'));
    await tester.pumpAndSettle();

    expect(controller.text, 'Philippines');
    expect(find.byType(WsProvinceMark), findsOneWidget);
  });

  testWidgets('a search with no match says how to fix it', (tester) async {
    _phone(tester);
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(_host(controller));
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'zzzz');
    await tester.pumpAndSettle();

    expect(find.textContaining('Nothing matches'), findsOneWidget);
  });

  testWidgets('the sheet does not overflow at 200% text', (tester) async {
    _phone(tester);
    final controller = TextEditingController(text: 'India');
    addTearDown(controller.dispose);

    await tester.pumpWidget(_host(controller, textScale: 2));
    await tester.tap(find.byType(TextField));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
