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
    // Each card is a summary of its own tab, and links to it.
    expect(find.text('See the full basic profile'), findsOneWidget);
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
      'Basic profile',
      'Immigration profile',
      'Jobs',
      'Documents',
    ]);
    expect(find.text('Goals'), findsNothing);
  });

  testWidgets('the basic profile shows every registration answer',
      (tester) async {
    final container = await pumpApp(tester);
    await go(tester, container, Routes.profile);
    await tester.tap(find.text('See the full basic profile'));
    await tester.pumpAndSettle();

    for (final card in [
      'Personal details',
      'Contact',
      'Location',
      'Profile type',
      'Your goals',
      'Job interests',
    ]) {
      expect(find.text(card), findsOneWidget, reason: card);
    }
    expect(find.text('Citizenship'), findsOneWidget);
    expect(find.text('United Kingdom'), findsOneWidget);
    // Location, goals and job interests are asked in registration, so they
    // are shown here too.
    expect(find.text('Toronto'), findsOneWidget);
    expect(find.text('Ontario'), findsOneWidget);
    expect(find.text('Design, Content, Marketing'), findsOneWidget);

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
      'Country of citizenship',
      'You are a',
      'City',
      'Province or Territory',
      'Your goals',
      'Job interests',
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
  });

  testWidgets('editing the country and profile type reaches the profile',
      (tester) async {
    final container = await pumpApp(tester);
    await go(tester, container, Routes.profileEdit);

    // The country is picked from the list, not typed.
    await tester.tap(find.widgetWithText(TextField, 'United Kingdom'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'India');
    await tester.pumpAndSettle();
    await tester.tap(find.text('India').last);
    await tester.pumpAndSettle();

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

  testWidgets('goals and job interests edited here reach the profile',
      (tester) async {
    final container = await pumpApp(tester);
    await go(tester, container, Routes.profileEdit);

    await tester.ensureVisible(find.text('Predict my CRS score'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Predict my CRS score'));
    await tester.ensureVisible(find.text('Healthcare'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Healthcare'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    final saved = container.read(candidateProvider);
    expect(saved.goals, contains('Predict my CRS score'));
    expect(saved.jobCategories, contains('Healthcare'));
  });

  test('country names find their flag, whatever the casing', () {
    expect(WsProvinceMark.countryCodeFor('United Kingdom'), 'gb');
    expect(WsProvinceMark.countryCodeFor('  india '), 'in');
    expect(WsProvinceMark.countryCodeFor('USA'), 'us');
    expect(WsProvinceMark.countryCodeFor('Atlantis'), isNull);
  });
}
