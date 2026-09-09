import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/candidate.dart';

/// The one candidate the mock app is signed in as.
///
/// Adam Smith comes from the design deck's own screens. Everything else is
/// consistent with a newcomer to Canada working in design: the CRS score, the
/// province, the goals and the job categories all line up with the fixtures in
/// the immigration and jobs features, so the screens tell one coherent story
/// rather than five unrelated ones.
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
  profileStrength: 72,
  verified: true,
  profileType: 'Job Seeker',
  goals: [
    'Find a job in my field',
    'Apply for permanent residence',
    'Improve my French',
  ],
  jobCategories: ['Design', 'Content', 'Marketing'],
);

/// The candidate, editable in memory so the profile form can write to it.
final candidateProvider =
    NotifierProvider<CandidateNotifier, Candidate>(CandidateNotifier.new);

class CandidateNotifier extends Notifier<Candidate> {
  @override
  Candidate build() => mockCandidate;

  void update(Candidate next) => state = next;
}
