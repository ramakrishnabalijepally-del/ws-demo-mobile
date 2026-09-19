import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worksettle_mobile/app/router/app_router.dart';
import 'package:worksettle_mobile/app/router/routes.dart';
import 'package:worksettle_mobile/app/theme/theme.dart';
import 'package:worksettle_mobile/features/immigration/immigration.dart';
import 'package:worksettle_mobile/features/profile/profile.dart';
import 'package:worksettle_mobile/shared/controllers/crs_controller.dart';
import 'package:worksettle_mobile/shared/data/mock_candidate.dart';
import 'package:worksettle_mobile/shared/models/crs_profile.dart';
import 'package:worksettle_mobile/shared/shared.dart';

/// The PNP scores follow the CRS pattern: asked for, and only from the profile
/// sections the provincial grids read.
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

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  /// From the PNP status screen: answers the provincial factors — a cousin in
  /// Saskatchewan, no other family, no Canadian work, no job offer. The mock
  /// candidate has no Canadian study, so that question is not asked.
  Future<void> answerProvincialFactors(WidgetTester tester) async {
    await tester.tap(find.text('Provincial factors'));
    await tester.pumpAndSettle();
    expect(find.text('Study in Canada'), findsNothing);

    await tapVisible(tester, find.text('None of these').first);
    // Saskatchewan in the second family question.
    await tapVisible(tester, find.text('Saskatchewan').at(1));
    await tapVisible(tester, find.text('I have not worked in Canada'));
    await tapVisible(tester, find.text('No, or somewhere else'));
    await tapVisible(tester, find.widgetWithText(WsPrimaryButton, 'Save'));
    // Let the "Saved" snackbar go, or it sits over the status screen button.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  }

  WsPrimaryButton pnpButton(WidgetTester tester) =>
      tester.widget<WsPrimaryButton>(
        find.widgetWithText(WsPrimaryButton, 'Get my PNP scores'),
      );

  testWidgets('a fresh session shows the way to the PNP scores, not the bar',
      (tester) async {
    final container = await pumpApp(tester);
    await go(tester, container, Routes.immigration);

    expect(container.read(pnpRevealedProvider), isFalse);
    expect(
      find.widgetWithText(WsScorePrompt, 'Your PNP scores'),
      findsOneWidget,
    );
    expect(find.text('Saskatchewan'), findsNothing);
  });

  testWidgets(
      'the status screen waits for missing sections and updates as they '
      'are saved', (tester) async {
    final container = await pumpApp(tester);
    final notifier = container.read(candidateProvider.notifier);
    final candidate = container.read(candidateProvider);
    notifier.update(
      candidate.copyWith(
        crs: candidate.crs.copyWith(certificateOfQualification: null),
      ),
    );
    await go(tester, container, Routes.immigration);

    await tester.tap(find.text('Get my PNP scores'));
    await tester.pumpAndSettle();
    // Work experience and the provincial factors are both open.
    expect(find.text('3 of 5 filled in'), findsOneWidget);
    expect(pnpButton(tester).onPressed, isNull);

    // The missing row opens the profile's own section form.
    await tester.tap(find.text('Work experience'));
    await tester.pumpAndSettle();
    expect(find.byType(ProfileSectionScreen), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // A save anywhere in the profile shows here straight away.
    notifier.update(candidate);
    await tester.pumpAndSettle();
    expect(find.text('4 of 5 filled in'), findsOneWidget);
    await answerProvincialFactors(tester);
    expect(find.text('Everything is filled in'), findsOneWidget);
    expect(pnpButton(tester).onPressed, isNotNull);
  });

  testWidgets('getting the scores returns to the tab with the bar showing',
      (tester) async {
    final container = await pumpApp(tester);
    await go(tester, container, Routes.immigration);

    await tester.tap(find.text('Get my PNP scores'));
    await tester.pumpAndSettle();
    await answerProvincialFactors(tester);
    await tester.tap(find.text('Get my PNP scores'));
    await tester.pumpAndSettle();

    expect(container.read(pnpRevealedProvider), isTrue);
    expect(find.byType(ImmigrationScreen), findsOneWidget);
    for (final score in container.read(pnpScoresProvider).take(2)) {
      expect(find.text(score.province), findsWidgets, reason: score.province);
    }
  });

  testWidgets('provincial factors score on that province\'s grid',
      (tester) async {
    final container = await pumpApp(tester);
    int connection() => container
        .read(pnpScoresProvider)
        .firstWhere((score) => score.code == 'SK')
        .lines
        .firstWhere((line) => line.label == 'Connection to Saskatchewan')
        .points;
    expect(connection(), 0);

    await go(tester, container, Routes.pnpStatus);
    await answerProvincialFactors(tester);

    // A cousin in Saskatchewan is 20 of the 30 connection points.
    expect(connection(), 20);
    expect(
      container.read(candidateProvider).crs.provincial.extendedFamily,
      {ProvinceTie.saskatchewan},
    );
  });

  testWidgets('follow-up questions appear only when they change a score',
      (tester) async {
    final container = await pumpApp(tester);
    await go(tester, container, Routes.pnpTies);

    const skYear = 'Was your Saskatchewan work 12 months or more, in the '
        'last five years?';
    expect(find.text(skYear), findsNothing);
    await tapVisible(tester, find.text('Saskatchewan').at(2));
    expect(find.text(skYear), findsOneWidget);

    const wage = 'Hourly wage of the job offer (CAD)';
    expect(find.text(wage), findsNothing);
    await tapVisible(tester, find.text('British Columbia'));
    expect(find.text(wage), findsOneWidget);
  });

  testWidgets('the profile tab carries the PNP scores under PNP programs',
      (tester) async {
    final container = await pumpApp(tester);
    // Taller than pumpApp's default: the PNP group is at the foot of the tab.
    tester.view.physicalSize = const Size(390, 5000);
    container.read(pnpRevealedProvider.notifier).reveal();
    await go(tester, container, Routes.profile);

    final tab = find.widgetWithText(Tab, 'Immigration profile');
    await tester.ensureVisible(tab);
    await tester.pumpAndSettle();
    await tester.tap(tab);
    await tester.pumpAndSettle();

    expect(find.text('PNP programs'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('PNP programs')).dy,
      greaterThan(tester.getTopLeft(find.text('Federal programs')).dy),
    );
    final sk = container
        .read(pnpScoresProvider)
        .firstWhere((score) => score.code == 'SK');
    expect(find.text('${sk.total} / ${sk.maximum}'), findsOneWidget);
  });
}
