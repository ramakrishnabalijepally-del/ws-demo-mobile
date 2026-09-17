import '../../../shared/controllers/crs_controller.dart';
import '../../../shared/models/crs_profile.dart';
import '../../../shared/utils/pnp_matcher.dart';

/// A provincial nominee stream.
class PnpStream {
  const PnpStream({
    required this.name,
    required this.summary,
    required this.requirements,
    required this.criteria,
  });

  final String name;
  final String summary;

  /// The published requirements, as a reader reads them.
  final List<String> requirements;

  /// The same requirements, in the form [assessStream] can check against a
  /// profile. **The two lists say the same thing** — if you edit one, edit the
  /// other.
  ///
  /// This replaced a stored `matched` flag. A stream's verdict is a fact about
  /// a candidate, not about the stream, so it cannot live here.
  final StreamCriteria criteria;
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

// The CRS score is no longer a fixture: it is calculated from the candidate's
// profile (`lib/shared/utils/crs_calculator.dart`). Only the draw range stays
// mocked.
// TODO(backend): recent draw cut-offs should come from a live feed.
/// Built from [crsDrawLow]/[crsDrawHigh] rather than written out, so the
/// context line under a score card can never name a different range from the
/// verdict beside it.
const String mockRecentDraws = 'Recent draws: $crsDrawLow–$crsDrawHigh';

/// J10–J13 — provinces and their streams.
///
/// Seven provinces with real program names and their published requirements.
///
/// **No stream says whether it matches.** That is a fact about a candidate,
/// and it is worked out by `assessStream` against the live profile — see
/// `controllers/stream_matches.dart`.
const List<Province> mockProvinces = [
  Province(
    name: 'Ontario',
    abbreviation: 'ON',
    programName: 'Ontario Immigrant Nominee Program',
    streams: [
      PnpStream(
        name: 'Human Capital Priorities',
        summary: 'Draws from the Express Entry pool for in-demand skills.',
        criteria: StreamCriteria(
          minClb: 7,
          minEducation: EducationLevel.bachelors,
          minCrs: 400,
        ),
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
        criteria: StreamCriteria(
          minWorkYears: 2,
          unknowns: [StreamUnknown.jobOffer],
        ),
        requirements: [
          'A permanent, full-time job offer in a skilled occupation',
          'The employer meets revenue and staffing thresholds',
          'Two years of experience in the same occupation',
        ],
      ),
      PnpStream(
        name: 'Masters Graduate',
        summary: 'For recent graduates of an Ontario masters program.',
        criteria: StreamCriteria(
          minClb: 7,
          minEducation: EducationLevel.masters,
          unknowns: [
            StreamUnknown.studiedInProvince,
            StreamUnknown.livingInProvince,
          ],
        ),
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
        criteria: StreamCriteria(
          minClb: 4,
          minWorkYears: 2,
          unknowns: [StreamUnknown.jobOffer],
        ),
        requirements: [
          'An indeterminate full-time job offer from a BC employer',
          'Two years of directly related experience',
          'CLB 4 or above for some occupations, higher for others',
        ],
      ),
      PnpStream(
        name: 'Tech',
        summary: 'Priority processing for 29 technology occupations.',
        criteria: StreamCriteria(
          minClb: 4,
          unknowns: [StreamUnknown.jobOffer, StreamUnknown.occupationList],
        ),
        requirements: [
          'A job offer of at least one year in an eligible tech occupation',
          'At least 120 days remaining on the offer',
          'Meets the Skills Immigration criteria',
        ],
      ),
      PnpStream(
        name: 'International Graduate',
        summary: 'For graduates of a Canadian institution within three years.',
        criteria: StreamCriteria(
          needsCanadianEducation: true,
          unknowns: [
            StreamUnknown.studiedInProvince,
            StreamUnknown.jobOffer,
          ],
        ),
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
        criteria: StreamCriteria(
          minCrs: 300,
          unknowns: [StreamUnknown.occupationList],
        ),
        requirements: [
          'An active Express Entry profile',
          'A CRS score of at least 300',
          'Work experience in an occupation supporting Alberta priorities',
        ],
      ),
      PnpStream(
        name: 'Alberta Opportunity',
        summary: 'For those already working in Alberta on a valid permit.',
        criteria: StreamCriteria(
          minClb: 4,
          unknowns: [
            StreamUnknown.livingInProvince,
            StreamUnknown.jobOffer,
          ],
        ),
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
        criteria: StreamCriteria(
          minClb: 7,
          unknowns: [StreamUnknown.targetedDraw],
        ),
        requirements: [
          'An active Express Entry profile',
          'Meets the criteria of a current targeted draw',
          'CLB 7 or above',
        ],
      ),
      PnpStream(
        name: 'Skilled Worker',
        summary: 'For applicants with a Nova Scotia employer offer.',
        criteria: StreamCriteria(
          minClb: 5,
          minWorkYears: 1,
          unknowns: [StreamUnknown.jobOffer],
        ),
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
        criteria: StreamCriteria(
          needsFrench: 7,
          unknowns: [StreamUnknown.targetedDraw],
        ),
        requirements: [
          'A points score meeting the current cut-off',
          'Intermediate French is heavily weighted',
          'A Quebec Selection Certificate before federal application',
        ],
      ),
      PnpStream(
        name: 'Quebec Experience Program',
        summary: 'For those who have studied or worked in Quebec.',
        criteria: StreamCriteria(
          needsFrench: 7,
          unknowns: [
            StreamUnknown.livingInProvince,
            StreamUnknown.studiedInProvince,
          ],
        ),
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
        criteria: StreamCriteria(
          minClb: 7,
          provincialGridCode: 'SK',
          unknowns: [StreamUnknown.occupationList],
        ),
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
        criteria: StreamCriteria(
          minClb: 4,
          minWorkYears: 1,
          provincialGridCode: 'SK',
          unknowns: [StreamUnknown.occupationList],
        ),
        requirements: [
          'An occupation on the in-demand list',
          'One year of related experience in the last ten years',
          'CLB 4 or above',
        ],
      ),
    ],
  ),
  Province(
    name: 'Manitoba',
    abbreviation: 'MB',
    programName: 'Manitoba Provincial Nominee Program',
    streams: [
      PnpStream(
        name: 'Skilled Worker Overseas',
        summary: 'For skilled workers abroad with a strong connection to '
            'Manitoba, invited through Expression of Interest draws.',
        criteria: StreamCriteria(
          minClb: 5,
          minWorkYears: 1,
          unknowns: [StreamUnknown.connectionToProvince],
        ),
        requirements: [
          'A close relative, past work or study in Manitoba, or an invitation '
              'through a strategic initiative',
          'CLB 5 or above in English or French',
          'Six months of full-time experience in your occupation',
        ],
      ),
      PnpStream(
        name: 'Skilled Worker in Manitoba',
        summary: 'For people already working in Manitoba on a work permit.',
        criteria: StreamCriteria(
          minClb: 4,
          unknowns: [
            StreamUnknown.livingInProvince,
            StreamUnknown.jobOffer,
          ],
        ),
        requirements: [
          'Six months of full-time work for a Manitoba employer',
          'A permanent, full-time job offer from that employer',
          'CLB 4 or above, or higher for some occupations',
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
