import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worksettle_mobile/app/router/app_router.dart';
import 'package:worksettle_mobile/app/router/routes.dart';
import 'package:worksettle_mobile/app/theme/theme.dart';
import 'package:worksettle_mobile/shared/data/mock_candidate.dart';
import 'package:worksettle_mobile/shared/shared.dart';

/// The Basic profile shows exactly what the edit form edits, and lives on the
/// Overview tab alone — there is no Basic profile tab to repeat it.
void main() {
  Future<ProviderContainer> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Consumer(
          builder: (context, ref, _) => MaterialApp.router(
            theme: WorkSettleTheme.light,
            routerConfig: ref.watch(routerProvider),
          ),
        ),
      ),
    );
    return container;
  }

  Future<void> go(WidgetTester tester, ProviderContainer c, String to) async {
    c.read(routerProvider).go(to);
    await tester.pumpAndSettle();
  }

  testWidgets('Overview summarises both profiles, each with its own Edit',
      (tester) async {
    final container = await pumpApp(tester);
    await go(tester, container, Routes.profile);

    // Both cards, and one Edit button each.
    expect(find.text('Basic profile'), findsWidgets);
    expect(find.text('Immigration profile'), findsWidgets);
    expect(find.widgetWithText(TextButton, 'Edit'), findsNWidgets(2));
    // The basic card is the whole profile, so it links nowhere further.
    expect(find.text('See the full basic profile'), findsNothing);
    expect(find.text('See the full immigration profile'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Goals is gone and the tabs run Overview to Documents',
      (tester) async {
    final container = await pumpApp(tester);
    await go(tester, container, Routes.profile);

    final tabs =
        tester.widgetList<Tab>(find.byType(Tab)).map((t) => t.text).toList();
    expect(tabs, [
      'Overview',
      'Immigration profile',
      'Jobs',
      'Documents',
    ]);
    expect(find.text('Goals'), findsNothing);
  });

  testWidgets('the basic profile shows From with a flag, and no Location',
      (tester) async {
    final container = await pumpApp(tester);
    await go(tester, container, Routes.profile);

    expect(find.text('From'), findsOneWidget);
    expect(find.text('United Kingdom'), findsOneWidget);
    expect(find.text('Location'), findsNothing);

    // The country flag is drawn in the standard mark frame.
    final marks = tester.widgetList<WsProvinceMark>(
      find.byType(WsProvinceMark),
    );
    expect(marks.any((m) => m.code == 'gb'), isTrue);
  });

  testWidgets('the edit form edits every field the basic profile shows',
      (tester) async {
    final container = await pumpApp(tester);
    await go(tester, container, Routes.profileEdit);

    // Field labels are rich text, so the finder has to look inside it.
    for (final label in [
      'Email',
      'Phone',
      'Date of Birth',
      'Country you are from',
      'You are a',
    ]) {
      expect(
        find.textContaining(label, findRichText: true),
        findsWidgets,
        reason: label,
      );
    }
    // The header's own fields, and nothing the profile does not show.
    expect(
      find.textContaining('First Name', findRichText: true),
      findsOneWidget,
    );
    expect(
      find.textContaining('Occupation', findRichText: true),
      findsOneWidget,
    );
    expect(find.textContaining('City', findRichText: true), findsNothing);
  });

  testWidgets('editing the country and profile type reaches the profile',
      (tester) async {
    final container = await pumpApp(tester);
    await go(tester, container, Routes.profileEdit);

    await tester.enterText(
      find.widgetWithText(TextField, 'United Kingdom'),
      'India',
    );
    await tester.ensureVisible(find.text('Student'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Student'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    final saved = container.read(candidateProvider);
    expect(saved.countryOfOrigin, 'India');
    expect(saved.profileType, 'Student');
  });

  test('country names find their flag, whatever the casing', () {
    expect(WsProvinceMark.countryCodeFor('United Kingdom'), 'gb');
    expect(WsProvinceMark.countryCodeFor('  india '), 'in');
    expect(WsProvinceMark.countryCodeFor('USA'), 'us');
    expect(WsProvinceMark.countryCodeFor('Atlantis'), isNull);
  });
}
