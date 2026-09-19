import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worksettle_mobile/app/router/app_router.dart';
import 'package:worksettle_mobile/app/router/routes.dart';
import 'package:worksettle_mobile/app/theme/theme.dart';
import 'package:worksettle_mobile/shared/controllers/crs_controller.dart';
import 'package:worksettle_mobile/shared/data/mock_candidate.dart';
import 'package:worksettle_mobile/shared/shared.dart';

/// The score is asked for, not served, and only from a complete profile.
///
/// "Get my CRS score" opens a status screen that lists what is filled in and
/// what is not. Each missing row opens the form it is answered in, the list
/// updates as soon as that form saves, and the button only calculates once
/// nothing is missing.
void main() {
  Future<ProviderContainer> pumpApp(
    WidgetTester tester, {
    Size size = const Size(390, 2600),
  }) async {
    tester.view.physicalSize = size;
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

  WsPrimaryButton getScoreButton(WidgetTester tester) =>
      tester.widget<WsPrimaryButton>(
        find.widgetWithText(WsPrimaryButton, 'Get my CRS score').last,
      );

  /// From the Immigration tab: opens the status screen and fills in the two
  /// sections the mock candidate is missing, each in its own form.
  Future<void> fillInTheMissingSections(WidgetTester tester) async {
    await tester.tap(find.text('Get my CRS score'));
    await tester.pumpAndSettle();
    expect(find.text('Fill these in to get your CRS score'), findsOneWidget);

    await tester.tap(find.text('Family in Canada'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('None of them'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    // Let the "Saved" snackbar go, or it sits over the next form's Save.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Additional factors'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('No'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    expect(find.text('Everything is filled in'), findsOneWidget);
  }

  /// Presses the status screen's button and lets the reveal run to its end.
  Future<void> getTheScore(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(WsPrimaryButton, 'Get my CRS score'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Working out your score'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  }

  testWidgets('a fresh session shows no score, only the way to get one',
      (tester) async {
    final container = await pumpApp(tester);
    await go(tester, container, Routes.immigration);

    expect(container.read(crsRevealedProvider), isFalse);
    expect(
      find.widgetWithText(WsScorePrompt, 'Your CRS score'),
      findsOneWidget,
    );
    expect(find.byType(WsScoreCard), findsNothing);
    expect(find.text('Get my CRS score'), findsWidgets);

    // The number itself is nowhere on the screen.
    final score = container.read(crsResultProvider).total;
    expect(find.text('$score'), findsNothing);
  });

  testWidgets(
      'the status screen lists what is missing and will not calculate yet',
      (tester) async {
    final container = await pumpApp(tester);
    await go(tester, container, Routes.immigration);

    await tester.tap(find.text('Get my CRS score'));
    await tester.pumpAndSettle();

    expect(find.text('4 of 6 filled in'), findsOneWidget);
    expect(find.text('Still to fill in'), findsOneWidget);
    expect(find.text('Filled in'), findsOneWidget);
    expect(
      find.text('Fill in 2 more sections to get your score.'),
      findsOneWidget,
    );
    expect(getScoreButton(tester).onPressed, isNull);
    expect(container.read(crsRevealedProvider), isFalse);
  });

  testWidgets(
      'a section saved from the status screen moves across straight away',
      (tester) async {
    final container = await pumpApp(tester);
    await go(tester, container, Routes.immigration);
    await tester.tap(find.text('Get my CRS score'));
    await tester.pumpAndSettle();

    // Family in Canada is a profile question, so it opens the profile's form.
    await tester.tap(find.text('Family in Canada'));
    await tester.pumpAndSettle();
    expect(
      find.text('These answers also calculate your CRS score in Immigration.'),
      findsOneWidget,
    );
    await tester.tap(find.text('None of them'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Back on the status screen, one section left.
    expect(find.text('5 of 6 filled in'), findsOneWidget);
    expect(
      find.text('Fill in 1 more section to get your score.'),
      findsOneWidget,
    );
    expect(container.read(candidateProvider).crs.familyInCanada, isEmpty);
  });

  testWidgets('Additional factors asks only for a nomination', (tester) async {
    final container = await pumpApp(tester);
    await go(tester, container, Routes.withId(Routes.crsSection, 'additional'));

    expect(
      find.text('Do you have a provincial or territorial nomination?'),
      findsOneWidget,
    );
    // Siblings are asked in the profile, not a second time here.
    expect(find.text('Who in your family lives in Canada?'), findsNothing);
  });

  testWidgets('once everything is filled in, the score is calculated',
      (tester) async {
    final container = await pumpApp(tester);
    await go(tester, container, Routes.immigration);

    await fillInTheMissingSections(tester);
    expect(getScoreButton(tester).onPressed, isNotNull);
    await getTheScore(tester);

    expect(container.read(crsRevealedProvider), isTrue);
    expect(find.text('See the breakdown'), findsOneWidget);
    expect(
      find.text('${container.read(crsResultProvider).total}'),
      findsWidgets,
    );
  });

  testWidgets('the score reaches the profile once it has been generated',
      (tester) async {
    final container = await pumpApp(tester, size: const Size(390, 4000));

    // Before: the immigration profile offers the button, not a number.
    await go(tester, container, Routes.profile);
    final tab = find.widgetWithText(Tab, 'Immigration profile');
    await tester.ensureVisible(tab);
    await tester.pumpAndSettle();
    await tester.tap(tab);
    await tester.pumpAndSettle();
    expect(
      find.widgetWithText(WsScorePrompt, 'Your CRS score'),
      findsOneWidget,
    );
    expect(find.byType(WsScoreCard), findsNothing);

    // Generated in Immigration.
    await go(tester, container, Routes.immigration);
    await fillInTheMissingSections(tester);
    await getTheScore(tester);

    // After: the same tab now carries the score, and it is still a readout.
    await go(tester, container, Routes.profile);
    await tester.ensureVisible(tab);
    await tester.pumpAndSettle();
    await tester.tap(tab);
    await tester.pumpAndSettle();

    final card = tester.widget<WsScoreCard>(
      find.widgetWithText(WsScoreCard, 'Your CRS score'),
    );
    expect(card.value, container.read(crsResultProvider).total);
    expect(card.onTap, isNull);
    expect(
      find.widgetWithText(WsScorePrompt, 'Your CRS score'),
      findsNothing,
    );
  });
}
