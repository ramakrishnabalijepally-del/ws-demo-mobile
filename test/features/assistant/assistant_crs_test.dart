import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worksettle_mobile/app/router/app_router.dart';
import 'package:worksettle_mobile/app/router/routes.dart';
import 'package:worksettle_mobile/app/theme/theme.dart';
import 'package:worksettle_mobile/features/assistant/data/mock_assistant.dart';
import 'package:worksettle_mobile/features/immigration/immigration.dart';
import 'package:worksettle_mobile/shared/data/mock_candidate.dart';
import 'package:worksettle_mobile/shared/models/crs_profile.dart';
import 'package:worksettle_mobile/shared/utils/pnp_matcher.dart';
import 'package:worksettle_mobile/shared/controllers/crs_controller.dart';
import 'package:worksettle_mobile/shared/shared.dart';

/// The assistant quotes the CRS score, which makes it bound by the same two
/// rules as every other surface: the number is not shown until it has been
/// asked for, and it is never a different number from the one the app
/// calculated.
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
    container.read(routerProvider).go(Routes.assistantChat);
    await tester.pumpAndSettle();
    return container;
  }

  /// Asks, then lets the processing timeline run out to the answer.
  Future<void> ask(WidgetTester tester, String question) async {
    await tester.ensureVisible(find.text(question).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text(question).first);
    await tester.pump();
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
  }

  const crsQuestion = 'What is my CRS score and is it competitive?';

  group('nothing about the profile is written into the script', () {
    test('no stored answer quotes a score or lists the matched streams', () {
      // The two bugs behind this rule were a score written into prose, and a
      // list of matched streams written into prose. Both went stale silently.
      //
      // It does not forbid naming a stream: "British Columbia Tech needs a job
      // offer" is advice about a program, not a claim about which programs
      // match. Those paragraphs still assume the current match set — see the
      // TODO in mock_assistant.dart.
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final sentence =
          liningUpSentence(container.read(liningUpStreamsProvider));

      for (final exchange in mockExchanges) {
        for (final line in exchange.answer) {
          expect(
            line,
            isNot(contains(sentence)),
            reason: '"${exchange.question}" writes the matched-stream list '
                'into a stored line',
          );
          expect(
            line,
            isNot(matches(RegExp(r'\bYour score is \d'))),
            reason: '"${exchange.question}" writes a score into a stored line',
          );
        }
      }
    });

    test('no stored answer tells the reader where they stand', () {
      // "at 468 you are already in range" survived the first pass at this and
      // sat in a second exchange, telling a candidate the app had calculated
      // at 424 that they were in range. A standing is a fact about a person.
      for (final exchange in mockExchanges) {
        for (final line in exchange.answer) {
          expect(
            line,
            isNot(matches(RegExp(r'\bat \d{3}\b'))),
            reason: '"${exchange.question}" quotes a score at the reader',
          );
          expect(
            line.toLowerCase(),
            isNot(contains('you are already in range')),
          );
        }
      }
    });

    test('the app tells one story about job-offer points', () {
      // Four places say IRCC removed them on 25 March 2025. The assistant used
      // to say an LMIA offer was worth 50 or 200 points.
      final jobOffer = mockExchanges
          .firstWhere((e) => e.question.contains('job offer'))
          .answer
          .join(' ');
      expect(jobOffer, contains('25 March 2025'));
      expect(jobOffer, contains('removed'));
    });

    test('a stream verdict is worked out, never stored', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final all = container.read(streamMatchesProvider);
      expect(all.length, mockProvinces.expand((p) => p.streams).length);
      // Every stream is placed on the ladder, and the ladder has three rungs.
      expect(
        all.map((m) => m.assessment.fit).toSet(),
        everyElement(isA<StreamFit>()),
      );
      // Anything that cannot be confirmed from a profile is never "Good
      // Match" — a profile does not know about a job offer.
      for (final match in all) {
        if (match.assessment.unknowns.isNotEmpty) {
          expect(match.assessment.fit, isNot(StreamFit.good));
        }
        if (match.assessment.fit == StreamFit.explore) {
          expect(match.assessment.gaps, isNotEmpty);
        }
      }
    });

    test('filling in the profile moves the verdicts', () {
      // The whole point: the answer is about the candidate, so it has to move
      // when the candidate does.
      final empty = ProviderContainer();
      addTearDown(empty.dispose);
      empty.read(candidateProvider.notifier).update(
            mockCandidate.copyWith(crs: const CrsProfile()),
          );

      final full = ProviderContainer();
      addTearDown(full.dispose);

      final blankLining = empty.read(liningUpStreamsProvider).length;
      final realLining = full.read(liningUpStreamsProvider).length;
      expect(
        blankLining,
        lessThan(realLining),
        reason: 'an empty profile should line up with fewer streams than a '
            'filled-in one',
      );
      expect(
        liningUpSentence(empty.read(liningUpStreamsProvider)),
        isNot(liningUpSentence(full.read(liningUpStreamsProvider))),
      );
    });

    test('the draw range is one definition, not three', () {
      // The verdict, the score card's context line and the assistant's wording
      // all have to name the same numbers.
      expect(mockRecentDraws, contains('$crsDrawLow'));
      expect(mockRecentDraws, contains('$crsDrawHigh'));
      expect(crsStandingLine(crsDrawLow), contains('inside the range'));
      expect(crsStandingLine(crsDrawLow - 1), isNot(contains('inside')));
      expect(crsVerdict(crsDrawLow).label, 'Good Range');
      expect(crsVerdict(crsDrawLow - 1).label, 'Potential Options');
    });
  });

  group('the standing line follows the score, never a written-in number', () {
    test('it never claims to be in range when it is below the range', () {
      // The bug this replaced: a fixture opening "Your score is 468, which is
      // inside the range recent draws have been inviting" shown to a candidate
      // the app had calculated at 424.
      expect(crsStandingLine(424), contains('424'));
      expect(crsStandingLine(424), isNot(contains('inside the range')));
      expect(crsStandingLine(424), isNot(contains('468')));
    });

    test('each band says where the score actually stands', () {
      expect(crsStandingLine(480), contains('above where'));
      expect(crsStandingLine(450), contains('inside the range'));
      expect(crsStandingLine(400), contains('below that range'));
      expect(crsStandingLine(300), contains('unlikely to reach you'));
    });

    test('every band quotes its own total and no other', () {
      for (final total in <int>[300, 400, 450, 480]) {
        expect(crsStandingLine(total), contains('$total'));
      }
    });
  });

  testWidgets('a score never asked for is not handed over in chat',
      (tester) async {
    final container = await pumpApp(tester);
    expect(container.read(crsRevealedProvider), isFalse);

    await ask(tester, crsQuestion);

    // The answer really did arrive — otherwise the two expectations below
    // would pass on an empty screen.
    expect(
      find.textContaining('WorkSettle has not worked it out'),
      findsOneWidget,
    );
    expect(
      find.textContaining('It is calculated in Immigration'),
      findsOneWidget,
    );

    final score = container.read(crsResultProvider).total;
    expect(find.text('$score'), findsNothing);
    expect(find.byType(WsScoreCard), findsNothing);
  });

  testWidgets('nor to a question that was never scripted', (tester) async {
    // Every unscripted question falls back to the CRS answer, so this is the
    // widest way in: type anything at all.
    final container = await pumpApp(tester);
    await tester.enterText(find.byType(TextField).first, 'hello there');
    await tester.pump();
    await tester.tap(find.byType(WsSendButton));
    await tester.pump();
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();

    // The answer really did arrive, and it is the one that sends the reader to
    // Immigration rather than the one that quotes a score.
    expect(
      find.textContaining('WorkSettle has not worked it out'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Your score is'),
      findsNothing,
    );
    expect(
      find.text('${container.read(crsResultProvider).total}'),
      findsNothing,
    );
    expect(find.byType(WsScoreCard), findsNothing);
  });

  testWidgets(
      'once asked for, chat shows the same number as the rest of the '
      'app', (tester) async {
    final container = await pumpApp(tester);
    container.read(crsRevealedProvider.notifier).reveal();
    await tester.pumpAndSettle();

    await ask(tester, crsQuestion);

    final score = container.read(crsResultProvider).total;
    expect(find.byType(WsScoreCard), findsOneWidget);
    expect(find.textContaining('Your score is $score'), findsOneWidget);
  });
}
