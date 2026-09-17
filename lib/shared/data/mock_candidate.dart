import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/candidate.dart';
import '../models/crs_profile.dart';
import '../models/immigration_details.dart';

/// The one candidate the mock app is signed in as.
///
/// Adam Smith comes from the design deck's own screens: a UI/UX designer from
/// the United Kingdom, 30, single, with a bachelor's degree, IELTS results at
/// CLB 9 and three years of skilled work abroad. On IRCC's grid that is a CRS
/// score of 424.
///
/// The additional factors are deliberately left unanswered, so the profile has
/// one real gap for the completion ring to lead to.
const Candidate mockCandidate = Candidate(
  firstName: 'Adam',
  lastName: 'Smith',
  email: 'adam.smith@yourdomain.com',
  phone: '+1 416 555 0142',
  dateOfBirth: '1995-12-27',
  occupation: 'UI/UX Designer',
  city: 'Toronto',
  province: 'Ontario',
  countryOfOrigin: 'United Kingdom',
  verified: true,
  profileType: 'Job Seeker',
  goals: [
    'Find a job in my field',
    'Apply for permanent residence',
    'Improve my French',
  ],
  jobCategories: ['Design', 'Content', 'Marketing'],
  crs: CrsProfile(
    maritalStatus: MaritalStatus.single,
    education: EducationLevel.bachelors,
    canadianEducation: CanadianEducation.none,
    englishTest: LanguageResult(
      test: LanguageTest.ielts,
      speaking: 7.0,
      listening: 8.0,
      reading: 7.0,
      writing: 7.0,
    ),
    canadianWorkYears: 0,
    foreignWorkYears: 3,
    certificateOfQualification: false,
  ),
  // The passport expiry sits four months out, which is what the AI Agent's
  // "passport expires soon" notice is about.
  immigration: ImmigrationDetails(
    passportNumber: 'P4821736',
    passportIssueDate: '2017-01-20',
    passportExpiryDate: '2027-01-20',
    status: CanadianStatus.visitor,
    statusIssueDate: '2026-06-02',
    statusExpiryDate: '2026-12-02',
  ),
);

/// The candidate, editable in memory so the profile forms can write to it.
// TODO(backend): nothing persists; a restart returns to the fixture.
final candidateProvider =
    NotifierProvider<CandidateNotifier, Candidate>(CandidateNotifier.new);

class CandidateNotifier extends Notifier<Candidate> {
  @override
  Candidate build() => mockCandidate;

  void update(Candidate next) => state = next;
}
