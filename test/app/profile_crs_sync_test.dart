import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worksettle_mobile/app/router/app_router.dart';
import 'package:worksettle_mobile/app/router/routes.dart';
import 'package:worksettle_mobile/app/theme/theme.dart';
import 'package:worksettle_mobile/shared/controllers/crs_controller.dart';
import 'package:worksettle_mobile/shared/data/mock_candidate.dart';
import 'package:worksettle_mobile/shared/shared.dart';

/// The profile and the CRS Predictor share one set of answers. Whichever side
/// the candidate fills in, the other already has it.
///
/// Driven through the real router and the real section form, so a regression
/// in either route or in the save path fails here.
void main() {
  Future<ProviderContainer> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 1600);
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

  Future<void> answerNominationYesAndSave(WidgetTester tester) async {
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yes').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
  }

  testWidgets('answers entered in Immigration reach the profile',
      (tester) async {
    final container = await pumpApp(tester);
    final before = container.read(crsResultProvider).total;
    expect(container.read(candidateProvider).crs.provincialNomination, isNull);

    container
        .read(routerProvider)
        .go(Routes.withId(Routes.crsSection, 'additional'));
    await tester.pumpAndSettle();
    // The nomination counts toward the CRS but is never shown on the
    // profile, so the form says so rather than claiming it is saved there.
    expect(
      find.text('This answer counts toward your CRS score. It is not shown '
          'on your profile.'),
      findsOneWidget,
    );

    await answerNominationYesAndSave(tester);

    // Written to the profile itself, and the score moved with it.
    expect(container.read(candidateProvider).crs.provincialNomination, isTrue);
    final after = container.read(crsResultProvider).total;
    expect(after, before + 600);
    // The score has not been asked for yet, so the save does not name it —
    // and the nomination is not shown on the profile, so it does not claim
    // to have gone there.
    expect(find.text('Saved.'), findsOneWidget);
    expect(find.textContaining('to your profile'), findsNothing);
    expect(find.textContaining('$after'), findsNothing);

    // Opening the same section from Profile shows the answer already there.
    container
        .read(routerProvider)
        .go(Routes.withId(Routes.profileSection, 'additional'));
    await tester.pumpAndSettle();
    final yes = tester.widget<WsSelectionCard>(
      find
          .ancestor(
            of: find.text('Yes').first,
            matching: find.byType(WsSelectionCard),
          )
          .first,
    );
    expect(yes.selected, isTrue);
  });

  testWidgets('answers entered in the profile reach the CRS score',
      (tester) async {
    final container = await pumpApp(tester);
    final before = container.read(crsResultProvider).total;

    container
        .read(routerProvider)
        .go(Routes.withId(Routes.profileSection, 'additional'));
    await tester.pumpAndSettle();
    // The nomination counts toward the CRS but is never shown on the
    // profile, so the form says so rather than claiming it is saved there.
    expect(
      find.text('This answer counts toward your CRS score. It is not shown '
          'on your profile.'),
      findsOneWidget,
    );

    await answerNominationYesAndSave(tester);
    final after = container.read(crsResultProvider).total;
    expect(after, before + 600);

    // The CRS result in Immigration shows the new score without re-entry.
    container.read(routerProvider).go(Routes.crsResult);
    await tester.pumpAndSettle();
    expect(find.textContaining('$after'), findsWidgets);
  });
}
