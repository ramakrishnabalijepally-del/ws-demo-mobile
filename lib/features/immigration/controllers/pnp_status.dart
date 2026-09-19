import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/data/mock_candidate.dart';
import '../../../shared/models/profile_section.dart';

/// The profile sections the provincial points grids read: age, education,
/// language and work. Marital status, a spouse and a nomination do not score
/// on any of the four grids, so they do not hold the PNP scores back.
const List<ProfileSection> pnpSections = [
  ProfileSection.aboutYou,
  ProfileSection.education,
  ProfileSection.language,
  ProfileSection.work,
];

/// Which of [pnpSections] the candidate has filled in, from the live profile.
final pnpCompletionProvider = Provider<ProfileCompletion>((ref) {
  final candidate = ref.watch(candidateProvider);
  return ProfileCompletion(
    sections: pnpSections,
    done: {
      for (final section in pnpSections)
        if (section.isComplete(
          candidate.crs,
          hasDateOfBirth: candidate.birthDate != null,
        ))
          section,
    },
  );
});

/// Whether the provincial factors are answered — family, work and study in a
/// province and a job offer, the PNP inputs that are not a profile section.
final pnpTiesAnsweredProvider = Provider<bool>(
  (ref) => ref.watch(candidateProvider).crs.provincialFactorsAnswered,
);

/// Whether the candidate has asked for their PNP scores yet — asked for, not
/// served, for the same reason as the CRS score (`crsRevealedProvider`).
// TODO(backend): session-only, so it resets on every launch.
final pnpRevealedProvider = NotifierProvider<PnpRevealed, bool>(
  PnpRevealed.new,
);

class PnpRevealed extends Notifier<bool> {
  @override
  bool build() => false;

  void reveal() => state = true;
}
