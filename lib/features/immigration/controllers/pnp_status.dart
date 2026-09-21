import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/data/mock_candidate.dart';
import '../../../shared/models/profile_section.dart';
import '../../../shared/models/provincial_factors.dart';

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

/// Whether one province's own questions are answered — family, work and
/// study there, and a job offer. Keyed by the province's two-letter code.
final pnpFactorsAnsweredProvider = Provider.family<bool, String>((ref, code) {
  final province = ProvinceTie.forCode(code);
  return province != null &&
      ref.watch(candidateProvider).crs.provincial.isAnsweredFor(province);
});

/// The provinces whose PNP score the candidate has asked for, by code.
///
/// Each province is generated on its own: asking for Alberta's score does not
/// reveal Manitoba's. Asked for, not served, for the same reason as the CRS
/// score (`crsRevealedProvider`). Once revealed, a score follows the profile
/// live — change an answer and the number moves.
// TODO(backend): session-only, so it resets on every launch.
final pnpRevealedProvider = NotifierProvider<PnpRevealed, Set<String>>(
  PnpRevealed.new,
);

class PnpRevealed extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  void reveal(String code) => state = {...state, code};
}
