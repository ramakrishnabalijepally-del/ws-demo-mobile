/// One step of the CRS calculator.
class CrsStep {
  const CrsStep({
    required this.title,
    required this.question,
    required this.options,
    required this.answerIndex,
  });

  final String title;
  final String question;
  final List<CrsOption> options;

  /// What the mock candidate answered — so the wizard is pre-filled and the
  /// result adds up to the score the rest of the app shows.
  final int answerIndex;
}

class CrsOption {
  const CrsOption(this.label, this.points);

  final String label;
  final int points;
}

/// A provincial nominee stream.
class PnpStream {
  const PnpStream({
    required this.name,
    required this.summary,
    required this.requirements,
    required this.matched,
  });

  final String name;
  final String summary;
  final List<String> requirements;

  /// Whether the mock candidate's profile lines up with it.
  final bool matched;
}

class Province {
  const Province({
    required this.name,
    required this.abbreviation,
    required this.programName,
    required this.streams,
  });

  final String name;
  final String abbreviation;
  final String programName;
  final List<PnpStream> streams;
}

/// A federal program on the "Other programs" list.
class FederalProgram {
  const FederalProgram({
    required this.name,
    required this.summary,
    required this.eligible,
    required this.note,
  });

  final String name;
  final String summary;
  final bool eligible;
  final String note;
}

/// J3–J7 — the five calculator steps.
///
/// The point values are the ones the Comprehensive Ranking System actually
/// publishes for a single applicant, so the arithmetic on the result screen is
/// real rather than decorative.
const List<CrsStep> mockCrsSteps = [
  CrsStep(
    title: 'Age',
    question: 'How old are you?',
    answerIndex: 1,
    options: [
      CrsOption('18 to 19', 99),
      CrsOption('20 to 29', 110),
      CrsOption('30 to 34', 95),
      CrsOption('35 to 39', 70),
      CrsOption('40 or older', 25),
    ],
  ),
  CrsStep(
    title: 'Education',
    question: 'What is your highest completed qualification?',
    answerIndex: 2,
    options: [
      CrsOption('Secondary school', 30),
      CrsOption('One-year post-secondary credential', 90),
      CrsOption("Bachelor's degree or three-year credential", 120),
      CrsOption('Two or more credentials, one three years or longer', 128),
      CrsOption("Master's degree", 135),
      CrsOption('Doctoral degree', 150),
    ],
  ),
  CrsStep(
    title: 'Language',
    question: 'What is your Canadian Language Benchmark in English?',
    answerIndex: 2,
    options: [
      CrsOption('CLB 7 in all four abilities', 68),
      CrsOption('CLB 8 in all four abilities', 92),
      CrsOption('CLB 9 in all four abilities', 116),
      CrsOption('CLB 10 or higher in all four abilities', 136),
    ],
  ),
  CrsStep(
    title: 'Work Experience',
    question: 'How many years of skilled work experience do you have?',
    answerIndex: 2,
    options: [
      CrsOption('Less than one year', 0),
      CrsOption('One year', 40),
      CrsOption('Two to three years', 53),
      CrsOption('Four to five years', 63),
      CrsOption('Six years or more', 72),
    ],
  ),
  CrsStep(
    title: 'Adaptability',
    question: 'Do any of these apply to you?',
    answerIndex: 1,
    options: [
      CrsOption('None of these', 0),
      CrsOption('A sibling who is a citizen or permanent resident', 15),
      CrsOption('Canadian post-secondary study', 30),
      CrsOption('A provincial nomination', 600),
    ],
  ),
];

/// J9 — the breakdown that adds up to 468.
///
/// The rows total the core factors; skill transferability is the remainder the
/// system awards for combinations, which is why it appears as its own line
/// rather than being folded into the others.
const List<({String label, num value})> mockCrsBreakdown = [
  (label: 'Age', value: 110),
  (label: 'Education', value: 120),
  (label: 'Language — first official language', value: 116),
  (label: 'Language — second official language', value: 0),
  (label: 'Canadian work experience', value: 0),
  (label: 'Foreign work experience', value: 53),
  (label: 'Skill transferability', value: 54),
  (label: 'Sibling in Canada', value: 15),
  (label: 'Provincial nomination', value: 0),
];

const int mockCrsScore = 468;
const int mockCrsMaximum = 1200;
const String mockRecentDraws = 'Recent draws: 435–470';

/// J10–J13 — provinces and their streams.
///
/// Six provinces with real program names. The matched flag reflects the mock
/// candidate: a UI/UX designer in Toronto with CLB 9 English and no Canadian
/// work experience.
const List<Province> mockProvinces = [
  Province(
    name: 'Ontario',
    abbreviation: 'ON',
    programName: 'Ontario Immigrant Nominee Program',
    streams: [
      PnpStream(
        name: 'Human Capital Priorities',
        summary: 'Draws from the Express Entry pool for in-demand skills.',
        matched: true,
        requirements: [
          'An active Express Entry profile',
          'A CRS score in the range of recent Ontario draws',
          'A bachelor degree or higher',
          'CLB 7 or above in English or French',
        ],
      ),
      PnpStream(
        name: 'Employer Job Offer — Foreign Worker',
        summary: 'For applicants holding a job offer from an Ontario employer.',
        matched: false,
        requirements: [
          'A permanent, full-time job offer in a skilled occupation',
          'The employer meets revenue and staffing thresholds',
          'Two years of experience in the same occupation',
        ],
      ),
      PnpStream(
        name: 'Masters Graduate',
        summary: 'For recent graduates of an Ontario masters program.',
        matched: false,
        requirements: [
          'A masters degree from an eligible Ontario institution',
          'CLB 7 or above',
          'Living in Ontario at the time of application',
        ],
      ),
    ],
  ),
  Province(
    name: 'British Columbia',
    abbreviation: 'BC',
    programName: 'BC Provincial Nominee Program',
    streams: [
      PnpStream(
        name: 'Skills Immigration — Skilled Worker',
        summary: 'For skilled workers with a BC job offer.',
        matched: false,
        requirements: [
          'An indeterminate full-time job offer from a BC employer',
          'Two years of directly related experience',
          'CLB 4 or above for some occupations, higher for others',
        ],
      ),
      PnpStream(
        name: 'Tech',
        summary: 'Priority processing for 29 technology occupations.',
        matched: true,
        requirements: [
          'A job offer of at least one year in an eligible tech occupation',
          'At least 120 days remaining on the offer',
          'Meets the Skills Immigration criteria',
        ],
      ),
      PnpStream(
        name: 'International Graduate',
        summary: 'For graduates of a Canadian institution within three years.',
        matched: false,
        requirements: [
          'A degree or diploma from an eligible Canadian institution',
          'Graduated within the last three years',
          'A BC job offer',
        ],
      ),
    ],
  ),
  Province(
    name: 'Alberta',
    abbreviation: 'AB',
    programName: 'Alberta Advantage Immigration Program',
    streams: [
      PnpStream(
        name: 'Alberta Express Entry',
        summary: 'Nominates candidates already in the Express Entry pool.',
        matched: true,
        requirements: [
          'An active Express Entry profile',
          'A CRS score of at least 300',
          'Work experience in an occupation supporting Alberta priorities',
        ],
      ),
      PnpStream(
        name: 'Alberta Opportunity',
        summary: 'For those already working in Alberta on a valid permit.',
        matched: false,
        requirements: [
          'Currently working in Alberta on an eligible work permit',
          'A full-time job offer from an Alberta employer',
          'CLB 4 or above, higher for some occupations',
        ],
      ),
    ],
  ),
  Province(
    name: 'Nova Scotia',
    abbreviation: 'NS',
    programName: 'Nova Scotia Nominee Program',
    streams: [
      PnpStream(
        name: 'Labour Market Priorities',
        summary: 'Targeted draws from the Express Entry pool.',
        matched: true,
        requirements: [
          'An active Express Entry profile',
          'Meets the criteria of a current targeted draw',
          'CLB 7 or above',
        ],
      ),
      PnpStream(
        name: 'Skilled Worker',
        summary: 'For applicants with a Nova Scotia employer offer.',
        matched: false,
        requirements: [
          'A full-time permanent job offer from a Nova Scotia employer',
          'One year of related work experience',
          'CLB 5 or above',
        ],
      ),
    ],
  ),
  Province(
    name: 'Quebec',
    abbreviation: 'QC',
    programName: 'Programme régulier des travailleurs qualifiés',
    streams: [
      PnpStream(
        name: 'Regular Skilled Worker Program',
        summary: 'Quebec selects its own skilled workers, outside Express '
            'Entry.',
        matched: false,
        requirements: [
          'A points score meeting the current cut-off',
          'Intermediate French is heavily weighted',
          'A Quebec Selection Certificate before federal application',
        ],
      ),
      PnpStream(
        name: 'Quebec Experience Program',
        summary: 'For those who have studied or worked in Quebec.',
        matched: false,
        requirements: [
          'Twelve months of skilled work in Quebec, or a Quebec diploma',
          'Level 7 oral French',
        ],
      ),
    ],
  ),
  Province(
    name: 'Saskatchewan',
    abbreviation: 'SK',
    programName: 'Saskatchewan Immigrant Nominee Program',
    streams: [
      PnpStream(
        name: 'International Skilled Worker — Express Entry',
        summary: 'Draws from the Express Entry pool against an in-demand list.',
        matched: true,
        requirements: [
          'An active Express Entry profile',
          'An occupation on the in-demand list',
          'CLB 7 or above',
          'At least 60 points on the Saskatchewan grid',
        ],
      ),
      PnpStream(
        name: 'Occupations In-Demand',
        summary: 'For skilled workers without a job offer.',
        matched: true,
        requirements: [
          'An occupation on the in-demand list',
          'One year of related experience in the last ten years',
          'CLB 4 or above',
        ],
      ),
    ],
  ),
];

/// J14 — federal programs beyond the provincial route.
const List<FederalProgram> mockFederalPrograms = [
  FederalProgram(
    name: 'Federal Skilled Worker Program',
    summary: 'The main Express Entry stream for skilled workers with foreign '
        'experience.',
    eligible: true,
    note: 'You meet the minimum requirements and your score is within the '
        'range of recent draws.',
  ),
  FederalProgram(
    name: 'Canadian Experience Class',
    summary: 'For applicants with skilled work experience gained in Canada.',
    eligible: false,
    note: 'This one opens up once you have twelve months of skilled work in '
        'Canada.',
  ),
  FederalProgram(
    name: 'Federal Skilled Trades Program',
    summary: 'For qualified tradespeople in specific occupations.',
    eligible: false,
    note: 'Your occupation is not on the trades list. Nothing about your '
        'profile is a problem here — it is simply a different route.',
  ),
  FederalProgram(
    name: 'Atlantic Immigration Program',
    summary: 'Employer-driven, for the four Atlantic provinces.',
    eligible: false,
    note: 'A job offer from a designated Atlantic employer would open this.',
  ),
  FederalProgram(
    name: 'Rural and Northern Immigration Pilot',
    summary: 'Community-recommended, for participating smaller communities.',
    eligible: false,
    note: 'Requires a job offer within a participating community.',
  ),
];
