import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worksettle_mobile/app/theme/theme.dart';
import 'package:worksettle_mobile/features/jobs/jobs.dart';

/// The filter sheet builds on a small phone, Field of work opens from its
/// dropdown, and picking an option updates the result count.
void main() {
  testWidgets('filter sheet sections work at 360 dp', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: WorkSettleTheme.light,
          home: const JobsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.bySemanticsLabel('Filter jobs'));
    await tester.pumpAndSettle();

    // The sheet's own list, not the jobs list behind it.
    final sheetList = find
        .descendant(
          of: find.byType(DraggableScrollableSheet),
          matching: find.byType(Scrollable),
        )
        .first;

    // Short sections start open, so Job type's options are already there.
    await tester.scrollUntilVisible(
      find.text('Seasonal'),
      200,
      scrollable: sheetList,
    );
    expect(find.text('Seasonal'), findsOneWidget);
    // Built is not the same as fully on screen: bring the whole tile clear of
    // the sheet's bottom edge before tapping it.
    await tester.ensureVisible(find.text('Seasonal'));
    await tester.pumpAndSettle();
    final before = find.textContaining(RegExp(r'^Show \d+ jobs?$'));
    expect(before, findsOneWidget);
    final allLabel = tester.widget<Text>(before).data;

    await tester.tap(find.text('Seasonal'));
    await tester.pumpAndSettle();
    final after = tester
        .widget<Text>(find.textContaining(RegExp(r'^Show \d+ jobs?$')))
        .data;
    expect(after, isNot(allLabel));

    // Field of work is the long list, so it starts closed.
    expect(find.text('Healthcare'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Field of work'),
      200,
      scrollable: sheetList,
    );
    await tester.tap(find.text('Field of work'));
    await tester.pumpAndSettle();
    expect(find.text('Healthcare'), findsOneWidget);

    expect(tester.takeException(), isNull);
  });
}
