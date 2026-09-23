import '../../../shared/controllers/crs_controller.dart';
import '../../../shared/utils/pnp_matcher.dart';
import '../../immigration/controllers/stream_matches.dart';

/// A scripted exchange with the assistant.
class AssistantExchange {
  const AssistantExchange({
    required this.question,
    required this.timeline,
    required this.answer,
    required this.followUps,
    this.scoreCard = false,
    this.live = AssistantLiveLines.none,
  });

  final String question;

  /// What the assistant says it is doing, one line at a time. **This is what
  /// the product shows instead of a spinner** — naming the work is what makes a
  /// four-second wait feel like diligence rather than lag.
  final List<String> timeline;

  final List<String> answer;

  /// The assistant never ends on a full stop: every answer is followed by two
  /// to five next actions, so the conversation routes back into the product.
  final List<String> followUps;

  /// Answers that carry a score render a **real score card inside the
  /// bubble**, not text — so the number looks the same in chat as it does on
  /// the dashboard.
  ///
  /// It also means the answer opens with [crsStandingLine], because where a
  /// score sits against the draws cannot be written in advance: see that
  /// function for why.
  final bool scoreCard;

  /// Which sentences of this answer are written from the candidate's own
  /// profile rather than stored here.
  final AssistantLiveLines live;
}

/// The parts of an answer the fixture is not allowed to write down.
///
/// Anything that names the candidate's score, or the streams their profile
/// matches, is a second copy of something the app already knows — and a second
/// copy is a contradiction waiting to be shipped. [answerLines] builds those
/// sentences at render time from the same sources the Immigration tab reads.
enum AssistantLiveLines {
  /// Nothing in this answer depends on the profile.
  none,

  /// Opens with where the score stands, and closes with the streams it opens.
  crsStanding,

  /// Opens with the streams the profile matches.
  matchedStreams,
}

/// The answer as it is spoken, with the live sentences filled in.
///
/// [total] and [matches] both come from the candidate's profile, so the same
/// question asked before and after filling in a language test gets a different
/// — and correct — answer.
List<String> answerLines(
  AssistantExchange exchange,
  int total,
  List<StreamMatch> matches,
) =>
    switch (exchange.live) {
      AssistantLiveLines.none => exchange.answer,
      AssistantLiveLines.crsStanding => <String>[
          crsStandingLine(total),
          ...exchange.answer,
          streamStandingLine(matches),
        ],
      AssistantLiveLines.matchedStreams => <String>[
          streamStandingLine(matches),
          ...exchange.answer,
        ],
    };

/// Where the candidate stands on provincial streams, said honestly.
///
/// The two rungs are kept apart on purpose. A stream WorkSettle can confirm
/// end to end is named; a stream waiting on a job offer or an occupation code
/// is counted and the reason given, because calling it a match would be the
/// same overclaim as telling someone on 424 they are in range.
String streamStandingLine(List<StreamMatch> matches) {
  final confirmed =
      matches.where((m) => m.assessment.fit == StreamFit.good).toList();
  final open =
      matches.where((m) => m.assessment.fit == StreamFit.potential).toList();

  final more = countWord(open.length);
  final openClause = open.isEmpty
      ? ''
      : ' ${more[0].toUpperCase()}${more.substring(1)} more '
          '${open.length == 1 ? 'stays' : 'stay'} open, each waiting on '
          'something your profile cannot answer — a job offer, an occupation '
          'code, or an address in the province.';

  if (confirmed.isEmpty) {
    if (open.isEmpty) {
      return 'Nothing lines up with a provincial stream yet on what you have '
          'entered — the sections still open in your profile are what would '
          'change that.';
    }
    return 'No provincial stream is settled on your profile alone, but '
        '${countWord(open.length)} stay open, each waiting on something a '
        'profile cannot answer — a job offer, an occupation code, or an '
        'address in the province.';
  }

  return 'On your profile, ${liningUpSentence(confirmed)} '
      '${confirmed.length == 1 ? 'lines' : 'line'} up on everything '
      'WorkSettle can check.$openClause';
}

/// Where the candidate's score stands against recent draws, as the assistant
/// says it.
///
/// **The number is never written into the script.** A fixture that opened with
/// "Your score is 468" sat directly above a card rendering the score the app
/// had actually calculated — and told a candidate on 424 that they were inside
/// a 435–470 draw range. An immigration assistant that contradicts its own
/// score card, in the optimistic direction, is worse than one that says
/// nothing.
///
/// The wording follows the verdict ladder in `crsVerdict`, and never states an
/// outcome as certain (design system section 20).
// TODO(backend): the range is the same fixture `crsVerdict` uses; real draws
// move every round.
String crsStandingLine(int total) {
  if (total >= crsDrawHigh) {
    return 'Your score is $total, above where the last six general Express '
        'Entry draws have closed — they ranged from $crsDrawLow to '
        '$crsDrawHigh.';
  }
  if (total >= crsDrawLow) {
    return 'Your score is $total, inside the range the last six general '
        'Express Entry draws have been inviting — they closed between '
        '$crsDrawLow and $crsDrawHigh.';
  }
  if (total >= crsExploreBelow) {
    return 'Your score is $total. The last six general Express Entry draws '
        'closed between $crsDrawLow and $crsDrawHigh, so it sits below that '
        'range for now — which is what the options below are for.';
  }
  return 'Your score is $total. The last six general Express Entry draws '
      'closed between $crsDrawLow and $crsDrawHigh, so a general draw is '
      'unlikely to reach you on this score alone — a provincial nomination is '
      'the route that changes that.';
}

/// What the assistant says when it is asked about a score the candidate has
/// not asked for yet.
///
/// The CRS score is generated in Immigration and nowhere else, so the
/// assistant answers the question by saying where the number comes from rather
/// than producing it. Its timeline does no calculating, because it is not
/// calculating anything.
const AssistantExchange mockCrsNotAskedExchange = AssistantExchange(
  question: 'What is my CRS score and is it competitive?',
  timeline: [
    'Reading your profile',
    'Checking where your score is worked out',
    'Writing your answer',
  ],
  answer: [
    'You have not asked for your score yet, so WorkSettle has not worked it '
        'out. It is calculated in Immigration, from your profile and the '
        'points IRCC publishes.',
    'Open Immigration and tap Get my CRS score. It takes a moment, and two '
        'questions about additional factors first — a provincial nomination '
        'is worth 600 points, so the score cannot be calculated without '
        'knowing about it.',
    'Once it is there, ask again and this answer will carry the number and '
        'what moves it.',
  ],
  followUps: [
    'Which provincial programs do I qualify for?',
    'How do I raise my score without a nomination?',
    'What is an ECA and do I need one?',
  ],
);

/// L1 — the empty state's frequently asked questions.
///
/// Built from the scripted answers, so every question listed has a real
/// answer behind it. A question typed that has no script falls back to the
/// CRS answer; listing one here would make that fallback look like a bug.
// TODO(backend): the real assistant answers anything; this list then comes
// from what candidates actually ask most.
final List<String> mockFrequentlyAskedQuestions = [
  for (final exchange in mockExchanges) exchange.question,
];

/// L2–L5 — four scripted answers.
const List<AssistantExchange> mockExchanges = [
  AssistantExchange(
    question: 'What is my CRS score and is it competitive?',
    timeline: [
      'Reading your profile',
      'Checking the latest IRCC draw results',
      'Calculating your Comprehensive Ranking System score',
      'Writing your answer',
    ],
    scoreCard: true,
    live: AssistantLiveLines.crsStanding,
    // The score and the stream list are added by [answerLines]. What is stored
    // here is only what holds at any score, for any profile.
    answer: [
      'A score is not an invitation either way — draws move with the size of '
          'the pool, and the general draws have been trending upward this '
          'year.',
      'The largest single thing you could do is a provincial nomination, '
          'which adds 600 points — in practice that puts you at the top of '
          'the pool, though the invitation is still IRCC\'s decision.',
    ],
    followUps: [
      'Which provincial stream should I try first?',
      'How do I raise my score without a nomination?',
      'Book a consultation about a nomination',
    ],
  ),
  AssistantExchange(
    question: 'Which provincial programs do I qualify for?',
    timeline: [
      'Reading your profile',
      'Matching against every provincial stream',
      'Checking current stream requirements',
      'Writing your answer',
    ],
    live: AssistantLiveLines.matchedStreams,
    // The matched list is [matchedStreamsOpening], read from the same data the
    // PNP screens read.
    // TODO(backend): the paragraphs below still assume *which* streams matched
    // — "British Columbia Tech needs a job offer … and yours qualifies" is a
    // claim about this candidate. Per-stream advice needs the real matcher
    // behind it; until then it is stored prose and will go stale if the
    // fixture's `matched` flags move.
    answer: [
      'Ontario and Alberta both draw directly from the Express Entry pool, so '
          'you do not need to apply separately — keeping your profile current '
          'is what matters. British Columbia Tech needs a job offer of at least '
          'one year in an eligible occupation, and yours qualifies.',
      'Saskatchewan Occupations In-Demand is the one that does not need a job '
          'offer at all, which makes it the most straightforward starting '
          'point if you are not tied to a city yet.',
    ],
    followUps: [
      'Tell me more about Saskatchewan',
      'What does the BC Tech job offer have to look like?',
      'Compare all six side by side',
    ],
  ),
  AssistantExchange(
    question: 'How do I get my UK degree recognised in Canada?',
    timeline: [
      'Reading your profile',
      'Checking designated assessment organisations',
      'Writing your answer',
    ],
    answer: [
      'You need an Educational Credential Assessment from an organisation IRCC '
          'has designated. World Education Services and Comparative Education '
          'Service are the two most commonly used for UK degrees.',
      'It takes roughly seven to twelve weeks once they have your documents, '
          'and it costs around 250 Canadian dollars including the transcript '
          'request. The assessment is valid for five years.',
      'One thing worth separating: an ECA tells immigration what your degree is '
          'worth. It does not license you to practise a regulated profession — '
          'that is the provincial regulator, and it runs as its own process. '
          'Design is not regulated, so this does not affect you.',
    ],
    followUps: [
      'How many CRS points is my degree worth?',
      'What documents does WES need?',
      'Add this to my checklist',
    ],
  ),
  AssistantExchange(
    question: 'Do I need a job offer for Express Entry?',
    timeline: [
      'Reading your profile',
      'Checking Express Entry requirements',
      'Writing your answer',
    ],
    answer: [
      'No. A job offer is not required for any of the three Express Entry '
          'programs.',
      'It does not add to your score either: IRCC removed job-offer points '
          'from the Comprehensive Ranking System on 25 March 2025. An offer '
          'that would once have been worth 50 or 200 points is now worth '
          'nothing on the federal grid.',
      'What a job offer does unlock is several provincial streams, including BC '
          'Tech. So it is worth pursuing for the nomination route rather than '
          'for the points themselves.',
    ],
    followUps: [
      'Show me employers who hire on work permits',
      'Which streams need a job offer?',
      'What is an LMIA?',
    ],
  ),
];
