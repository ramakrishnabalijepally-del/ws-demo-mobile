/// A document on the candidate's file.
class ProfileDocument {
  const ProfileDocument({
    required this.name,
    required this.detail,
    required this.uploaded,
  });

  final String name;
  final String detail;
  final bool uploaded;
}

/// M8 — what an Express Entry application actually asks for.
const List<ProfileDocument> mockDocuments = [
  ProfileDocument(
    name: 'Passport',
    detail: 'PDF · uploaded 12 January 2026',
    uploaded: true,
  ),
  ProfileDocument(
    name: 'Educational Credential Assessment',
    detail: 'PDF · World Education Services · 3 February 2026',
    uploaded: true,
  ),
  ProfileDocument(
    name: 'Language test results',
    detail: 'IELTS General or CELPIP',
    uploaded: false,
  ),
  ProfileDocument(
    name: 'Résumé',
    detail: 'PDF · 440 KB · 6 March 2026',
    uploaded: true,
  ),
  ProfileDocument(
    name: 'Proof of funds',
    detail: 'Six months of statements',
    uploaded: false,
  ),
  ProfileDocument(
    name: 'Police certificate',
    detail: 'From each country you have lived in for six months or more',
    uploaded: false,
  ),
];

/// N6 — FAQ, grouped.
class FaqEntry {
  const FaqEntry({
    required this.category,
    required this.question,
    required this.answer,
  });

  final String category;
  final String question;
  final String answer;
}

const List<String> mockFaqCategories = [
  'General',
  'Account',
  'Immigration',
  'Jobs',
  'Billing',
];

const List<FaqEntry> mockFaq = [
  FaqEntry(
    category: 'General',
    question: 'What is WorkSettle?',
    answer: 'WorkSettle is an AI platform for work and immigration settlement '
        'in Canada. You build one profile, and it matches you to jobs, scores '
        'your immigration eligibility and answers your questions.',
  ),
  FaqEntry(
    category: 'General',
    question: 'Is WorkSettle free?',
    answer: 'Your basic profile and job search are always free. Pro at \$10 a '
        'month unlocks the AI tools, and Pro+ at \$50 a month adds French '
        'language support, priority appointments, expert Q&A and webinars.',
  ),
  FaqEntry(
    category: 'General',
    question: 'Does WorkSettle give legal advice?',
    answer:
        'No. WorkSettle gives you assessments and information based on what '
        'you tell it. Legal advice comes from a Regulated Canadian Immigration '
        'Consultant or a lawyer, and you can book one through Appointments.',
  ),
  FaqEntry(
    category: 'Account',
    question: 'How do I change my email address?',
    answer: 'Open Profile, tap Edit profile, and change the email field. You '
        'will be asked to confirm the new address before it takes effect.',
  ),
  FaqEntry(
    category: 'Account',
    question: 'How do I delete my account?',
    answer: 'Settings, then Security, then Delete account. Your profile and '
        'documents are removed within 30 days.',
  ),
  FaqEntry(
    category: 'Immigration',
    question: 'How accurate is the CRS predictor?',
    answer: 'It uses the published Comprehensive Ranking System point tables, '
        'so the arithmetic is exact. What it cannot know is anything you have '
        'not entered — and final eligibility is always decided by IRCC, not by '
        'us.',
  ),
  FaqEntry(
    category: 'Immigration',
    question: 'What is an ECA?',
    answer: 'An Educational Credential Assessment tells IRCC what your foreign '
        'degree is worth in Canadian terms. Express Entry requires one, it '
        'takes seven to twelve weeks, and it is separate from any professional '
        'licensing your occupation may need.',
  ),
  FaqEntry(
    category: 'Jobs',
    question: 'What does "hires on work permits" mean?',
    answer:
        'It means that employer has hired someone on a Canadian work permit '
        'before. It is not a guarantee they will sponsor you, but it does mean '
        'the process is not new to them.',
  ),
  FaqEntry(
    category: 'Jobs',
    question: 'Why do jobs show an NOC code?',
    answer: 'The National Occupational Classification code is what immigration '
        'programs match on. Knowing the code for a role tells you whether the '
        'experience will count toward a program you are aiming at.',
  ),
  FaqEntry(
    category: 'Billing',
    question: 'Can I cancel any time?',
    answer: 'Yes. Cancelling stops the next renewal and you keep access until '
        'the end of the period you have paid for.',
  ),
  FaqEntry(
    category: 'Billing',
    question: 'Do you offer a refund?',
    answer: 'If something has gone wrong, contact support within 14 days of a '
        'charge and we will sort it out.',
  ),
];

/// N7–N8 — the legal pages.
const List<String> mockTerms = [
  'These terms govern your use of WorkSettle. By creating an account you agree '
      'to them, and if you do not agree you should not use the service.',
  'WorkSettle provides information and assessment tools relating to work and '
      'immigration in Canada. It is not a law firm and it does not provide '
      'legal advice. Assessments produced by the service are initial and are '
      'based solely on the information you provide. Final decisions on '
      'immigration eligibility rest with Immigration, Refugees and Citizenship '
      'Canada or the relevant provincial authority.',
  'You are responsible for the accuracy of the information you enter. Where an '
      'assessment depends on a document — a language test, a credential '
      'assessment, a work reference — the assessment assumes that document says '
      'what you have told us it says.',
  'Consultations booked through WorkSettle are provided by independent '
      'Regulated Canadian Immigration Consultants. Your professional '
      'relationship in that consultation is with the consultant, not with '
      'WorkSettle.',
  'Subscriptions renew automatically until cancelled. You may cancel at any '
      'time and retain access until the end of the paid period.',
  'We may update these terms. Where a change is material we will tell you '
      'before it takes effect.',
];

const List<String> mockPrivacy = [
  'This policy explains what WorkSettle collects, why, and what we do with it.',
  'We collect the profile information you enter — your name, contact details, '
      'date of birth, education, work history, language results and immigration '
      'goals — because the assessments and job matches are calculated from it. '
      'Without it, the product cannot do its job.',
  'We collect documents you upload so they can be attached to applications you '
      'choose to make. They are encrypted at rest and are not shared with any '
      'employer or consultant without an action you take.',
  'We do not sell your personal information. We do not share it with employers '
      'unless you apply to them, and we do not share it with consultants unless '
      'you book with them.',
  'Your questions to the AI assistant are processed to produce an answer and '
      'are retained so you can find the conversation again. You can delete a '
      'saved conversation at any time.',
  'You can export or delete your data from Settings. Deletion removes your '
      'profile and documents within 30 days, except where we are required to '
      'retain a record of a transaction.',
  'If you have a question about any of this, contact privacy@worksettle.ca.',
];
