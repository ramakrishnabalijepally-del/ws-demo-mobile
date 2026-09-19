import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worksettle_mobile/app/theme/theme.dart';
import 'package:worksettle_mobile/features/jobs/controllers/jobs_controller.dart';
import 'package:worksettle_mobile/features/jobs/jobs.dart';

Widget _host(Widget child) => ProviderScope(
      child: MaterialApp(theme: WorkSettleTheme.light, home: child),
    );

void main() {
  test('top jobs are the 15 most searched, highest first', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final top = container.read(topSearchedJobsProvider);
    expect(top, hasLength(15));
    for (var i = 1; i < top.length; i++) {
      expect(top[i - 1].searchCount, greaterThanOrEqualTo(top[i].searchCount));
    }
  });

  test('a posting is new for 48 hours and no longer', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    for (final job in container.read(allJobsProvider)) {
      expect(job.isNew, job.postedHoursAgo <= 48);
    }
  });

  testWidgets('New button narrows the list to recent postings', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_host(const JobsScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Top jobs'), findsOneWidget);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(JobsScreen)),
    );
    final newCount = container.read(newJobsCountProvider);

    await tester.tap(
      find.bySemanticsLabel('$newCount new jobs in the last 48 hours'),
    );
    await tester.pumpAndSettle();

    expect(find.text('New in the last 48 hours'), findsOneWidget);
    expect(find.text('$newCount found'), findsOneWidget);
    // Top jobs steps aside once a filter is on.
    expect(find.text('Top jobs'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('job details show every required section at 360 dp',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_host(const JobDetailsScreen(jobId: 'j10')));
    await tester.pumpAndSettle();

    final list = find.byType(Scrollable).first;
    for (final heading in [
      'Job type',
      'Job description',
      'Read full description',
      'Tasks and duties',
      'Requirements',
      'Experience',
      'Education',
      'Certifications',
      'Skills',
      'Benefits',
      'Accommodation',
      'Immigration support',
      'LMIA',
    ]) {
      await tester.scrollUntilVisible(
        find.text(heading),
        200,
        scrollable: list,
      );
      expect(find.text(heading), findsOneWidget, reason: heading);
    }
    expect(tester.takeException(), isNull);
  });
}
