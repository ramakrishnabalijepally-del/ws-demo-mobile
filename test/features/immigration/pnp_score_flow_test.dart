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

  /// From Saskatchewan's status screen: answers its factors — a cousin
  /// there, no immediate family, no work there, no job offer. The mock
  /// candidate has no Canadian study, so that question is not asked.
  Future<void> answerSaskatchewan(WidgetTester tester) async {
    await tester.tap(find.text('Saskatchewan factors'));
    await tester.pumpAndSettle();
    expect(find.text('Study in Canada'), findsNothing);

    // Four yes/no questions in order: immediate family, extended family,
    // work, job offer.
    await tapVisible(tester, find.text('No').at(0));
    await tapVisible(tester, find.text('Yes').at(1));
    await tapVisible(tester, find.text('No').at(2));
    await tapVisible(tester, find.text('No').at(3));
    await tapVisible(tester, find.widgetWithText(WsPrimaryButton, 'Save'));
    // Let the "Saved" snackbar go, or it sits over the status screen button.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  }

  WsPrimaryButton skButton(WidgetTester tester) =>
      tester.widget<WsPrimaryButton>(
        find.widgetWithText(WsPrimaryButton, 'Get my Saskatchewan score'),
      );

  String skStatus() => Routes.withId(Routes.pnpStatus, 'SK');

  testWidgets('a fresh session shows a card per province, none generated',
      (tester) async {
    final container = await pumpApp(tester);
    await go(tester, container, Routes.immigration);

    expect(container.read(pnpRevealedProvider), isEmpty);
    expect(find.byType(PnpProvinceGrid), findsOneWidget);
    // Six cards, then the rest behind "Show all".
    expect(find.text('Get score'), findsNWidgets(4));
    expect(find.text('Quebec'), findsNothing);
    await tapVisible(tester, find.textContaining('Show all provinces'));
    expect(find.text('Quebec'), findsOneWidget);
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

    await tapVisible(tester, find.text('Saskatchewan'));
    // Work experience and Saskatchewan's own factors are both open.
    expect(find.text('3 of 5 filled in'), findsOneWidget);
    expect(skButton(tester).onPressed, isNull);

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
    await answerSaskatchewan(tester);
    expect(find.text('Everything is filled in'), findsOneWidget);
    expect(skButton(tester).onPressed, isNotNull);
  });

  testWidgets('getting one province reveals that province and no other',
      (tester) async {
    final container = await pumpApp(tester);
    await go(tester, container, Routes.immigration);

    await tapVisible(tester, find.text('Saskatchewan'));
    await answerSaskatchewan(tester);
    await tester.tap(find.text('Get my Saskatchewan score'));
    await tester.pumpAndSettle();

    expect(container.read(pnpRevealedProvider), {'SK'});
    expect(find.byType(ImmigrationScreen), findsOneWidget);
    final sk = container
        .read(pnpScoresProvider)
        .firstWhere((score) => score.code == 'SK');
    expect(
      find.textContaining('${sk.total}', findRichText: true),
      findsWidgets,
    );
    // Alberta, British Columbia and Manitoba still wait to be asked for.
    expect(find.text('Get score'), findsNWidgets(3));

    // The generated card opens its breakdown.
    await tapVisible(tester, find.text('Saskatchewan'));
    expect(find.text('Not counted yet'), findsOneWidget);
  });

  testWidgets("a province's factors score on its own grid", (tester) async {
    final container = await pumpApp(tester);
    int connection() => container
        .read(pnpScoresProvider)
        .firstWhere((score) => score.code == 'SK')
        .lines
        .firstWhere((line) => line.label == 'Connection to Saskatchewan')
        .points;
    expect(connection(), 0);

    await go(tester, container, skStatus());
    await answerSaskatchewan(tester);

    // A cousin in Saskatchewan is 20 of the 30 connection points.
    expect(connection(), 20);
    final f = container.read(candidateProvider).crs.provincial;
    expect(f.extendedFamily, {ProvinceTie.saskatchewan});
    expect(f.answeredFor, {ProvinceTie.saskatchewan});
  });

  testWidgets('follow-up questions appear only when they change a score',
      (tester) async {
    final container = await pumpApp(tester);
    await go(tester, container, Routes.withId(Routes.pnpTies, 'SK'));

    const skYear = 'Was it 12 months or more, in the last five years?';
    expect(find.text(skYear), findsNothing);
    // The third question: worked in Saskatchewan.
    await tapVisible(tester, find.text('Yes').at(2));
    expect(find.text(skYear), findsOneWidget);

    await go(tester, container, Routes.withId(Routes.pnpTies, 'BC'));
    const wage = 'Hourly wage of the job offer (CAD)';
    expect(find.text(wage), findsNothing);
    await tapVisible(tester, find.text('Yes').last);
    expect(find.text(wage), findsOneWidget);
  });

  testWidgets('the profile tab shows the PNP scores but cannot generate them',
      (tester) async {
    final container = await pumpApp(tester);
    // Taller than pumpApp's default: the PNP group is at the foot of the tab.
    tester.view.physicalSize = const Size(390, 5000);
    container.read(pnpRevealedProvider.notifier).reveal('SK');
    await go(tester, container, Routes.profile);

    final tab = find.widgetWithText(Tab, 'Immigration profile');
    await tester.ensureVisible(tab);
    await tester.pumpAndSettle();
    await tester.tap(tab);
    await tester.pumpAndSettle();

    expect(find.text('PNP score'), findsOneWidget);
    expect(find.text('Federal programs'), findsNothing);
    expect(
      tester.getTopLeft(find.text('PNP score')).dy,
      greaterThan(tester.getTopLeft(find.text('Federal score')).dy),
    );
    final sk = container
        .read(pnpScoresProvider)
        .firstWhere((score) => score.code == 'SK');
    expect(
      find.textContaining('${sk.total}', findRichText: true),
      findsWidgets,
    );
    expect(find.text('Get score'), findsNothing);
    expect(find.text('Generate in Immigration'), findsNWidgets(3));
  });
}
