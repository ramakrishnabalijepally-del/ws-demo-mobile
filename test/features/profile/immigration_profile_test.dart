import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worksettle_mobile/app/router/app_router.dart';
import 'package:worksettle_mobile/app/router/routes.dart';
import 'package:worksettle_mobile/app/theme/theme.dart';
import 'package:worksettle_mobile/shared/controllers/crs_controller.dart';
import 'package:worksettle_mobile/shared/data/mock_candidate.dart';
import 'package:worksettle_mobile/shared/models/crs_profile.dart';
import 'package:worksettle_mobile/shared/models/immigration_details.dart';
import 'package:worksettle_mobile/shared/models/profile_section.dart';
import 'package:worksettle_mobile/features/immigration/immigration.dart';
import 'package:worksettle_mobile/shared/shared.dart';

void main() {
  Future<ProviderContainer> pumpApp(
    WidgetTester tester, {
    Size size = const Size(390, 2400),
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

  testWidgets(
      'the basic profile is on Overview, the CRS under Immigration '
      'profile', (tester) async {
    final container = await pumpApp(tester);
    // The score is asked for, not served; this test is about what the tab
    // shows once it exists.
    container.read(crsRevealedProvider.notifier).reveal();
    await go(tester, container, Routes.profile);

    expect(find.text('Basic profile'), findsWidgets);
    expect(find.widgetWithText(Tab, 'Basic profile'), findsNothing);
    expect(find.text('Immigration profile'), findsWidgets);
    expect(find.text('CRS score'), findsNothing);

    // Tabs scroll on a phone, so bring this one on screen before tapping.
    final tab = find.widgetWithText(Tab, 'Immigration profile');
    await tester.ensureVisible(tab);
    await tester.pumpAndSettle();
    await tester.tap(tab);
    await tester.pumpAndSettle();

    expect(find.text('Passport'), findsOneWidget);
    expect(find.text('•••• 1736'), findsOneWidget);
    expect(find.text('Status in Canada'), findsOneWidget);
    expect(find.text('Visitor'), findsOneWidget);
    expect(find.text('Family in Canada'), findsOneWidget);
    expect(find.text('CRS score'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the immigration profile reads in the agreed order',
      (tester) async {
    final container = await pumpApp(tester, size: const Size(390, 4000));
    await go(tester, container, Routes.profile);

    final tab = find.widgetWithText(Tab, 'Immigration profile');
    await tester.ensureVisible(tab);
    await tester.pumpAndSettle();
    await tester.tap(tab);
    await tester.pumpAndSettle();

    // Who you are, what you have done, then the documents and the people
    // behind it — and the total last, because a score placed above its own
    // inputs asks the reader to take it on trust.
    double top(Finder f) => tester.getRect(f.first).top;

    final order = <String, double>{
      'About you': top(find.text(ProfileSection.aboutYou.title)),
      'Education': top(find.text(ProfileSection.education.title)),
      'Work experience': top(find.text(ProfileSection.work.title)),
      'Passport': top(find.text('Passport')),
      'Language tests': top(find.text(ProfileSection.language.title)),
      'Status in Canada': top(find.text('Status in Canada')),
      'Family in Canada': top(find.text('Family in Canada')),
      'CRS score': top(find.text('CRS score')),
    };

    final sorted = order.keys.toList()
      ..sort((a, b) => order[a]!.compareTo(order[b]!));
    expect(sorted, order.keys.toList());
  });

  testWidgets(
      'without a score, the slot says where to get one and cannot '
      'generate it', (tester) async {
    final container = await pumpApp(tester, size: const Size(390, 4000));
    await go(tester, container, Routes.profile);

    final tab = find.widgetWithText(Tab, 'Immigration profile');
    await tester.ensureVisible(tab);
    await tester.pumpAndSettle();
    await tester.tap(tab);
    await tester.pumpAndSettle();

    // Generated in Immigration and nowhere else: the tile names the place
    // and offers no button of its own.
    expect(container.read(crsRevealedProvider), isFalse);
    expect(find.text('Not generated yet'), findsOneWidget);
    expect(find.text('Tap to get it in Immigration.'), findsOneWidget);
    expect(find.text('Get my CRS score'), findsNothing);
    expect(find.byType(WsPrimaryButton), findsNothing);
  });

  testWidgets(
      'once there is a score, the tile shows it and opens the '
      'breakdown', (tester) async {
    final container = await pumpApp(tester, size: const Size(390, 4000));
    container.read(crsRevealedProvider.notifier).reveal();
    await go(tester, container, Routes.profile);

    final tab = find.widgetWithText(Tab, 'Immigration profile');
    await tester.ensureVisible(tab);
    await tester.pumpAndSettle();
    await tester.tap(tab);
    await tester.pumpAndSettle();

    final total = container.read(crsResultProvider).total;
    final score = find.textContaining('$total', findRichText: true);
    expect(score, findsOneWidget);
    expect(find.text('Get my CRS score'), findsNothing);

    await tester.ensureVisible(score);
    await tester.pumpAndSettle();
    await tester.tap(score);
    await tester.pumpAndSettle();
    expect(find.byType(CrsBreakdownScreen), findsOneWidget);
  });

  testWidgets('family chosen in Edit profile moves the CRS score',
      (tester) async {
    final container = await pumpApp(tester);
    final before = container.read(crsResultProvider).total;

    await go(tester, container, '${Routes.profileEdit}?tab=immigration');
    await tester.tap(find.text('Sister'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(
      container.read(candidateProvider).crs.familyInCanada,
      {FamilyInCanada.sister},
    );
    expect(container.read(crsResultProvider).total, before + 15);
  });

  testWidgets('an expiry before the issue date is caught and not saved',
      (tester) async {
    final container = await pumpApp(tester);
    await go(tester, container, '${Routes.profileEdit}?tab=immigration');

    final expiry = find.widgetWithText(TextField, '2027-01-20');
    await tester.enterText(expiry, '2010-01-01');
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(
      find.text('The expiry date must be after the passport issue date'),
      findsOneWidget,
    );
    expect(
      container.read(candidateProvider).immigration.passportExpiryDate,
      '2027-01-20',
    );
  });

  testWidgets(
      'Immigration tab groups the CRS score and a PNP score per '
      'province', (tester) async {
    final container = await pumpApp(tester, size: const Size(360, 1600));
    container.read(pnpRevealedProvider.notifier)
      ..reveal('AB')
      ..reveal('SK');
    await go(tester, container, Routes.immigration);

    expect(find.text('Federal score'), findsOneWidget);
    expect(find.text('PNP score'), findsOneWidget);
    // The program lists are gone; only the two scores remain.
    expect(find.text('Where you stand'), findsNothing);
    expect(find.text('Provincial Nominee Programs'), findsNothing);
    expect(
      tester.getTopLeft(find.text('Your CRS score')).dy,
      lessThan(tester.getTopLeft(find.text('PNP score')).dy),
    );
    // The CRS score card is the way in; there is no separate Predictor row.
    expect(find.text('CRS Predictor'), findsNothing);
    for (final score in container.read(pnpScoresProvider)) {
      expect(find.text(score.province), findsWidgets, reason: score.province);
    }

    await tester.ensureVisible(find.text('Saskatchewan').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Saskatchewan').first);
    await tester.pumpAndSettle();
    expect(find.text('Not counted yet'), findsOneWidget);
    expect(find.text('See Saskatchewan streams'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'the CRS answers are shown and editable in the immigration profile',
      (tester) async {
    final container = await pumpApp(tester, size: const Size(390, 4000));
    // The score is asked for, not served; this test is about what the tab
    // shows once it exists.
    container.read(crsRevealedProvider.notifier).reveal();
    await go(tester, container, Routes.profile);

    final tab = find.widgetWithText(Tab, 'Immigration profile');
    await tester.ensureVisible(tab);
    await tester.pumpAndSettle();
    await tester.tap(tab);
    await tester.pumpAndSettle();

    // The section owns a score, it does not only predict one. It sits under
    // Federal score, and the federal program list is gone from this tab.
    expect(find.text('CRS score'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Federal score')).dy,
      lessThan(tester.getTopLeft(find.text('CRS score')).dy),
    );
    expect(find.text('Federal programs'), findsNothing);
    expect(find.text('Where you stand'), findsNothing);
    expect(find.text('CRS Predictor'), findsNothing);
    // The questions are on this tab, so nothing sends the reader to a
    // separate copy of them.
    expect(find.text('Answer CRS questions'), findsNothing);

    // Every CRS question section but Additional factors.
    for (final section in [
      ProfileSection.aboutYou,
      ProfileSection.education,
      ProfileSection.language,
      ProfileSection.work,
    ]) {
      expect(find.text(section.title), findsOneWidget, reason: section.name);
    }
    expect(find.text(ProfileSection.additional.title), findsNothing);

    expect(tester.takeException(), isNull);
  });

  testWidgets('each CRS section card opens its own form', (tester) async {
    final container = await pumpApp(tester, size: const Size(390, 4000));
    await go(tester, container, Routes.profile);

    final tab = find.widgetWithText(Tab, 'Immigration profile');
    await tester.ensureVisible(tab);
    await tester.pumpAndSettle();
    await tester.tap(tab);
    await tester.pumpAndSettle();

    final card = find.ancestor(
      of: find.text(ProfileSection.education.title),
      matching: find.byType(WsCard),
    );
    await tester.ensureVisible(card.first);
    await tester.pumpAndSettle();
    await tester.tap(card.first);
    await tester.pumpAndSettle();

    // The section's own form, not a separate copy of the questions.
    expect(find.text(ProfileSection.education.summary), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('the score shown in the immigration profile is live',
      (tester) async {
    final container = await pumpApp(tester, size: const Size(390, 4000));
    // The score is asked for, not served; this test is about what the tab
    // shows once it exists.
    container.read(crsRevealedProvider.notifier).reveal();
    await go(tester, container, Routes.profile);

    final tab = find.widgetWithText(Tab, 'Immigration profile');
    await tester.ensureVisible(tab);
    await tester.pumpAndSettle();
    await tester.tap(tab);
    await tester.pumpAndSettle();

    final before = container.read(crsResultProvider).total;
    expect(find.textContaining('$before', findRichText: true), findsWidgets);

    // An answer changed anywhere moves the number on this tab.
    final candidate = container.read(candidateProvider);
    container.read(candidateProvider.notifier).update(
          candidate.copyWith(
            crs: candidate.crs.copyWith(
              education: EducationLevel.doctoral,
            ),
          ),
        );
    await tester.pumpAndSettle();

    final after = container.read(crsResultProvider).total;
    expect(after, greaterThan(before));
    expect(find.textContaining('$after', findRichText: true), findsWidgets);
  });

  testWidgets('every fact value ends flush with the card content edge',
      (tester) async {
    final container = await pumpApp(tester, size: const Size(390, 4000));
    await go(tester, container, Routes.profile);

    final tab = find.widgetWithText(Tab, 'Immigration profile');
    await tester.ensureVisible(tab);
    await tester.pumpAndSettle();
    await tester.tap(tab);
    await tester.pumpAndSettle();

    // A value sized to half the row but placed right after a short label
    // leaves a ragged gap at the card edge. Measure it rather than trust it.
    for (final value in ['•••• 1736', '2017-01-20', 'Visitor']) {
      final card = find
          .ancestor(of: find.text(value), matching: find.byType(WsCard))
          .first;
      final edge = tester.getRect(card).right - WsSpacing.lg;
      expect(
        tester.getRect(find.text(value)).right,
        moreOrLessEquals(edge, epsilon: 0.5),
        reason: value,
      );
    }
  });

  test('expiry lines read naturally', () {
    final today = DateTime(2026, 9, 16);
    expect(relativeToToday(DateTime(2027, 1, 20), today), 'in 4 months');
    expect(relativeToToday(DateTime(2026, 9, 26), today), 'in 10 days');
    expect(relativeToToday(DateTime(2026, 9, 1), today), '15 days ago');
  });
}
