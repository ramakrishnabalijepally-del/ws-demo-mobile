/// One step of the Smart Checklist.
class ChecklistItem {
  const ChecklistItem({
    required this.id,
    required this.title,
    required this.detail,
    required this.phase,
    this.done = false,
  });

  final String id;
  final String title;
  final String detail;
  final ChecklistPhase phase;
  final bool done;
}

enum ChecklistPhase {
  beforeArrival('Before you arrive'),
  firstWeek('Your first week'),
  firstMonth('Your first month'),
  settlingIn('Settling in');

  const ChecklistPhase(this.label);

  final String label;
}

/// A bookable consultation.
class Consultation {
  const Consultation({
    required this.id,
    required this.title,
    required this.minutes,
    required this.price,
    required this.summary,
    required this.consultant,
    required this.credential,
  });

  final String id;
  final String title;
  final int minutes;

  /// Canadian dollars. Zero means free.
  final int price;

  final String summary;
  final String consultant;
  final String credential;
}

/// A settlement resource.
class Resource {
  const Resource({
    required this.title,
    required this.summary,
    required this.category,
    this.premium = false,
  });

  final String title;
  final String summary;
  final String category;

  /// Pro+ only — French language support is on the top tier.
  final bool premium;
}

/// K2 — twelve steps across four phases.
const List<ChecklistItem> mockChecklist = [
  ChecklistItem(
    id: 'k1',
    title: 'Get your Educational Credential Assessment',
    detail: 'It takes weeks and Express Entry requires it. Start it before you '
        'think you need to.',
    phase: ChecklistPhase.beforeArrival,
    done: true,
  ),
  ChecklistItem(
    id: 'k2',
    title: 'Book your language test',
    detail: 'IELTS General or CELPIP. Language is the biggest single lever on '
        'your CRS score.',
    phase: ChecklistPhase.beforeArrival,
    done: true,
  ),
  ChecklistItem(
    id: 'k3',
    title: 'Gather your proof of funds',
    detail: 'Six months of statements from an account in your name.',
    phase: ChecklistPhase.beforeArrival,
    done: true,
  ),
  ChecklistItem(
    id: 'k4',
    title: 'Rewrite your resume in the Canadian format',
    detail: 'Two pages, no photo, no date of birth, results before duties.',
    phase: ChecklistPhase.beforeArrival,
  ),
  ChecklistItem(
    id: 'k5',
    title: 'Apply for your Social Insurance Number',
    detail: 'You cannot be paid without one. Service Canada issues it the same '
        'day in person.',
    phase: ChecklistPhase.firstWeek,
    done: true,
  ),
  ChecklistItem(
    id: 'k6',
    title: 'Open a Canadian bank account',
    detail: 'Most major banks have a newcomer package with no monthly fee for '
        'the first year.',
    phase: ChecklistPhase.firstWeek,
    done: true,
  ),
  ChecklistItem(
    id: 'k7',
    title: 'Apply for provincial health coverage',
    detail: 'Ontario has a three-month wait in some cases — apply on day one.',
    phase: ChecklistPhase.firstWeek,
  ),
  ChecklistItem(
    id: 'k8',
    title: 'Get a Canadian mobile number',
    detail: 'Employers will not always call an overseas number.',
    phase: ChecklistPhase.firstWeek,
    done: true,
  ),
  ChecklistItem(
    id: 'k9',
    title: 'Register with a settlement agency',
    detail: 'Free, government-funded, and they know the local employers.',
    phase: ChecklistPhase.firstMonth,
  ),
  ChecklistItem(
    id: 'k10',
    title: 'Start building Canadian references',
    detail: 'Volunteering counts. Employers weigh a local reference heavily.',
    phase: ChecklistPhase.firstMonth,
  ),
  ChecklistItem(
    id: 'k11',
    title: 'Check whether your occupation is regulated',
    detail: 'The provincial regulator, not the ECA, decides whether you can '
        'practise.',
    phase: ChecklistPhase.settlingIn,
  ),
  ChecklistItem(
    id: 'k12',
    title: 'Build a credit history',
    detail: 'A secured card for six months is usually enough to rent without a '
        'guarantor.',
    phase: ChecklistPhase.settlingIn,
  ),
];

/// K3–K4 — seven consultation types.
const List<Consultation> mockConsultations = [
  Consultation(
    id: 'c1',
    title: 'Profile assessment and pathway consultation',
    minutes: 60,
    price: 180,
    summary: 'A full review of your profile against every program you could '
        'reach, and a written pathway afterwards.',
    consultant: 'Daniel Okonkwo',
    credential: 'RCIC · R512844',
  ),
  Consultation(
    id: 'c2',
    title: 'General immigration consultation',
    minutes: 30,
    price: 95,
    summary: 'Bring your questions. Good for a second opinion on a decision '
        'you have already half made.',
    consultant: 'Priya Raman',
    credential: 'RCIC · R709122',
  ),
  Consultation(
    id: 'c3',
    title: 'Phone consultation',
    minutes: 15,
    price: 45,
    summary: 'One question, answered properly.',
    consultant: 'Priya Raman',
    credential: 'RCIC · R709122',
  ),
  Consultation(
    id: 'c4',
    title: 'Alberta PNP program guidance',
    minutes: 45,
    price: 140,
    summary: 'Which Alberta stream fits, and what would need to change for the '
        'others.',
    consultant: 'Mei Lin Chow',
    credential: 'RCIC · R641003',
  ),
  Consultation(
    id: 'c5',
    title: 'British Columbia PNP program guidance',
    minutes: 45,
    price: 140,
    summary: 'BC Tech and Skills Immigration, and what the job offer has to '
        'look like.',
    consultant: 'Mei Lin Chow',
    credential: 'RCIC · R641003',
  ),
  Consultation(
    id: 'c6',
    title: 'Rural and Northern Immigration Pilot consultation',
    minutes: 45,
    price: 140,
    summary: 'The participating communities, and how a recommendation works.',
    consultant: 'Daniel Okonkwo',
    credential: 'RCIC · R512844',
  ),
  Consultation(
    id: 'c7',
    title: 'Call back — within Canada only',
    minutes: 15,
    price: 0,
    summary: 'A free call back to point you at the right paid consultation, or '
        'tell you that you do not need one.',
    consultant: 'WorkSettle team',
    credential: 'Not legal advice',
  ),
];

/// K6 — settlement resources.
const List<Resource> mockResources = [
  Resource(
    title: 'French classes for newcomers',
    summary: 'Live small-group classes, twice weekly, from beginner upward.',
    category: 'Language',
    premium: true,
  ),
  Resource(
    title: 'Expert Q&A webinars',
    summary: 'Monthly sessions with licensed consultants, with recordings.',
    category: 'Guidance',
    premium: true,
  ),
  Resource(
    title: 'Finding your first place to rent',
    summary: 'What landlords ask newcomers for, and what to do when you have '
        'no credit history.',
    category: 'Housing',
  ),
  Resource(
    title: 'Understanding your first payslip',
    summary: 'Federal and provincial deductions, CPP, EI, and what is left.',
    category: 'Money',
  ),
  Resource(
    title: 'Getting a family doctor',
    summary: 'Provincial registries, walk-in clinics, and the realistic wait.',
    category: 'Health',
  ),
  Resource(
    title: 'Winter, honestly',
    summary: 'What to buy, what not to bother with, and how to drive in it.',
    category: 'Living',
  ),
];
