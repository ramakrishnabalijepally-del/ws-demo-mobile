/// A scripted exchange with the assistant.
class AssistantExchange {
  const AssistantExchange({
    required this.question,
    required this.timeline,
    required this.answer,
    required this.followUps,
    this.scoreCard = false,
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
  /// bubble**, not text — so "468, Good Range" looks the same in chat as it
  /// does on the dashboard.
  final bool scoreCard;
}

/// L1 — the empty state's suggested questions.
const List<String> mockSuggestedQuestions = [
  'What is my CRS score and is it competitive?',
  'Which provincial programs do I qualify for?',
  'How do I get my UK degree recognised in Canada?',
  'What does a Canadian resume look like?',
  'Do I need a job offer for Express Entry?',
  'How long does permanent residence take?',
  'Can my partner work while my application is processed?',
  'What is an ECA and do I need one?',
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
    answer: [
      'Your score is 468, which is inside the range recent Express Entry draws '
          'have been inviting — the last six general draws closed between 435 '
          'and 470.',
      'That said, a score in range is not the same as an invitation. Draws move '
          'with the size of the pool, and the general draws have been trending '
          'upward this year.',
      'The largest single thing you could do is a provincial nomination, which '
          'adds 600 points and effectively guarantees an invitation. On your '
          'profile, Ontario Human Capital Priorities, BC Tech, Alberta Express '
          'Entry, Nova Scotia Labour Market Priorities and two Saskatchewan '
          'streams currently line up.',
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
      'Matching against 13 provincial programs',
      'Checking current stream requirements',
      'Writing your answer',
    ],
    answer: [
      'Six streams across five provinces currently match what you have entered: '
          'Ontario Human Capital Priorities, British Columbia Tech, Alberta '
          'Express Entry, Nova Scotia Labour Market Priorities, and two '
          'Saskatchewan streams.',
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
          'programs, and it has not been since the points for one were reduced.',
      'A valid offer supported by a Labour Market Impact Assessment is worth 50 '
          'or 200 points depending on the occupation, so it helps — but at 468 '
          'you are already in range without one.',
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
