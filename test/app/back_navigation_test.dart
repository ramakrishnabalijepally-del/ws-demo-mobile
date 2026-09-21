import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worksettle_mobile/app/router/app_router.dart';
import 'package:worksettle_mobile/app/router/routes.dart';
import 'package:worksettle_mobile/app/theme/theme.dart';
import 'package:worksettle_mobile/features/assistant/assistant.dart';
import 'package:worksettle_mobile/features/home/home.dart';
import 'package:worksettle_mobile/features/immigration/immigration.dart';
import 'package:worksettle_mobile/features/jobs/jobs.dart';
import 'package:worksettle_mobile/features/profile/profile.dart';
import 'package:worksettle_mobile/shared/controllers/crs_controller.dart';
import 'package:worksettle_mobile/shared/data/mock_candidate.dart';
import 'package:worksettle_mobile/shared/models/crs_profile.dart';
import 'package:worksettle_mobile/shared/shared.dart';

/// Whatever a screen opens, Back returns to that screen.
///
/// Profile sits above the tab bar, and a screen that belongs to a tab used to
/// open in that tab's own stack: the push either did nothing, or jumped tabs
/// with no back arrow, or (with `go`) came back to the Immigration tab rather
/// than the profile. These pin each way out of Profile to its way back.
void main() {
  Future<ProviderContainer> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 4000);
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

  Future<void> openImmigrationProfile(
    WidgetTester tester,
    ProviderContainer c,
  ) async {
    c.read(routerProvider).go(Routes.profile);
    await tester.pumpAndSettle();
    final tab = find.widgetWithText(Tab, 'Immigration profile');
    await tester.ensureVisible(tab);
    await tester.pumpAndSettle();
    await tester.tap(tab);
    await tester.pumpAndSettle();
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  /// The on-screen back arrow, not the system back — an iPhone has only this.
  Future<void> back(WidgetTester tester) async {
    await tester.tap(find.byType(BackButton).hitTestable());
    await tester.pumpAndSettle();
  }

  void expectImmigrationProfile(WidgetTester tester) {
    expect(find.byType(ProfileScreen).hitTestable(), findsOneWidget);
    expect(find.text('Federal score').hitTestable(), findsOneWidget);
  }

  testWidgets('the CRS breakdown returns to the immigration profile',
      (tester) async {
    final c = await pumpApp(tester);
    c.read(crsRevealedProvider.notifier).reveal();
    await openImmigrationProfile(tester, c);

    await tapVisible(tester, find.text('CRS score'));
    expect(find.byType(CrsBreakdownScreen), findsOneWidget);

    await back(tester);
    expectImmigrationProfile(tester);
  });

  testWidgets(
      'an ungenerated CRS score opens the status screen, and Back returns',
      (tester) async {
    final c = await pumpApp(tester);
    await openImmigrationProfile(tester, c);

    await tapVisible(tester, find.text('Not generated yet'));
    expect(find.byType(CrsOverviewScreen), findsOneWidget);

    await back(tester);
    expectImmigrationProfile(tester);
  });

  testWidgets('generating the score from the profile ends back on the profile',
      (tester) async {
    final c = await pumpApp(tester);
    final candidate = c.read(candidateProvider);
    c.read(candidateProvider.notifier).update(
          candidate.copyWith(
            crs: candidate.crs.copyWith(
              provincialNomination: false,
              familyInCanada: const <FamilyInCanada>{},
            ),
          ),
        );
    await openImmigrationProfile(tester, c);

    await tapVisible(tester, find.text('Not generated yet'));
    await tester.tap(find.widgetWithText(WsPrimaryButton, 'Get my CRS score'));
    // The calculating screen hands over to the result by itself.
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.byType(CrsResultScreen), findsOneWidget);

    await back(tester);
    expect(find.byType(CrsOverviewScreen), findsOneWidget);
    await back(tester);
    expectImmigrationProfile(tester);
    // And the tile now carries the score it just generated.
    expect(find.text('Not generated yet'), findsNothing);
  });

  testWidgets('an ungenerated PNP card opens its province, and Back returns',
      (tester) async {
    final c = await pumpApp(tester);
    await openImmigrationProfile(tester, c);

    await tapVisible(tester, find.text('Saskatchewan'));
    expect(find.byType(PnpStatusScreen), findsOneWidget);

    await back(tester);
    expectImmigrationProfile(tester);
  });

  testWidgets('the Jobs rows on the profile come back to the profile',
      (tester) async {
    final c = await pumpApp(tester);
    c.read(routerProvider).go(Routes.profile);
    await tester.pumpAndSettle();
    await tapVisible(tester, find.widgetWithText(Tab, 'Jobs'));

    for (final (row, screen) in [
      ('Your applications', ApplicationsScreen),
      ('Saved jobs', SavedJobsScreen),
      ('Messages', ChatListScreen),
    ]) {
      await tapVisible(tester, find.text(row));
      expect(find.byType(screen), findsOneWidget, reason: row);
      await back(tester);
      expect(
        find.byType(ProfileScreen).hitTestable(),
        findsOneWidget,
        reason: row,
      );
    }
  });

  testWidgets('Help opens the assistant chat and comes back', (tester) async {
    final c = await pumpApp(tester);
    c.read(routerProvider).go(Routes.help);
    await tester.pumpAndSettle();

    await tapVisible(tester, find.text('Ask the assistant'));
    expect(find.byType(AssistantScreen), findsOneWidget);
    await back(tester);
    expect(find.text('Ask the assistant').hitTestable(), findsOneWidget);
  });

  testWidgets('the dashboard has Settings beside notifications',
      (tester) async {
    final c = await pumpApp(tester);
    c.read(routerProvider).go(Routes.home);
    await tester.pumpAndSettle();
    expect(find.byType(DashboardScreen), findsOneWidget);

    final settings = find.byTooltip('Settings');
    expect(
      tester.getCenter(settings).dx,
      lessThan(tester.getCenter(find.byTooltip('Notifications')).dx),
    );
    await tester.tap(settings);
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
  });

  testWidgets('each score heading explains itself behind an ⓘ button',
      (tester) async {
    final c = await pumpApp(tester);
    await openImmigrationProfile(tester, c);

    // One plain line under each title; the detail waits behind the ⓘ.
    expect(find.text("Canada's Express Entry ranking score."), findsOneWidget);
    expect(find.text('Your points with each province.'), findsOneWidget);
    expect(find.textContaining('1,200 points'), findsNothing);
    await tapVisible(tester, find.byTooltip('About the federal score'));
    expect(find.textContaining('1,200 points'), findsOneWidget);
    await tapVisible(tester, find.text('Got it'));
    expect(find.textContaining('1,200 points'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('saving Additional factors does not claim it went to the profile',
      (tester) async {
    final c = await pumpApp(tester);
    c.read(routerProvider).go(Routes.crsOverview);
    await tester.pumpAndSettle();
    c.read(routerProvider).push(
          Routes.withId(Routes.crsSection, 'additional'),
        );
    await tester.pumpAndSettle();

    expect(find.textContaining('not shown on your profile'), findsOneWidget);
    await tapVisible(tester, find.text('No').first);
    await tapVisible(tester, find.widgetWithText(WsPrimaryButton, 'Save'));
    expect(find.text('Saved.'), findsOneWidget);
    expect(find.textContaining('to your profile'), findsNothing);
  });
}
