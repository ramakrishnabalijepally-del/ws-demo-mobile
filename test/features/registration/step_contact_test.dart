import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worksettle_mobile/app/theme/theme.dart';
import 'package:worksettle_mobile/features/registration/presentation/widgets/step_contact.dart';

Future<void> _pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(360, 740);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        theme: WorkSettleTheme.light,
        home: const Scaffold(body: StepContact()),
      ),
    ),
  );
}

Future<void> _openCities(WidgetTester tester) async {
  await tester.tap(find.widgetWithText(TextField, 'Choose a city'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('picking a listed city fills in its province', (tester) async {
    await _pump(tester);
    await _openCities(tester);

    await tester.enterText(find.byType(TextField).last, 'calg');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Calgary'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'Calgary'), findsOneWidget);
    expect(find.text('Alberta'), findsOneWidget);
  });

  testWidgets('changing to another province clears a city outside it',
      (tester) async {
    await _pump(tester);
    await _openCities(tester);
    await tester.enterText(find.byType(TextField).last, 'calg');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Calgary'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Alberta'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ontario').last);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'Calgary'), findsNothing);
    expect(find.widgetWithText(TextField, 'Choose a city'), findsOneWidget);
  });

  testWidgets('with a province chosen, only its cities are offered',
      (tester) async {
    await _pump(tester);
    await tester.tap(find.text('Choose a province'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ontario').last);
    await tester.pumpAndSettle();

    await _openCities(tester);
    expect(find.text('City in Ontario'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, 'calg');
    await tester.pumpAndSettle();
    expect(find.text('Calgary'), findsNothing);
  });

  testWidgets('a town not in the list can be used as typed', (tester) async {
    await _pump(tester);
    await _openCities(tester);

    await tester.enterText(find.byType(TextField).last, 'Canmore');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Use "Canmore"'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'Canmore'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
