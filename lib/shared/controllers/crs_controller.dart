import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_candidate.dart';
import '../models/profile_section.dart';
import '../utils/crs_calculator.dart';
import '../utils/pnp_calculator.dart';
import '../widgets/ws_verdict_chip.dart';

/// Live views of the candidate profile. Every screen that shows a CRS score or
/// profile strength reads it from here, so one edit updates them all.

int? _ageToday(DateTime? birth) =>
    birth == null ? null : ageOn(birth, DateTime.now());

final crsResultProvider = Provider<CrsResult>((ref) {
  final candidate = ref.watch(candidateProvider);
  return calculateCrs(candidate.crs, age: _ageToday(candidate.birthDate));
});

final crsLeversProvider = Provider<List<CrsLever>>((ref) {
  final candidate = ref.watch(candidateProvider);
  return crsLevers(candidate.crs, age: _ageToday(candidate.birthDate));
});

final profileCompletionProvider = Provider<ProfileCompletion>((ref) {
  final candidate = ref.watch(candidateProvider);
  return completionOf(
    candidate.crs,
    hasDateOfBirth: candidate.birthDate != null,
  );
});

/// The draw range every verdict and every sentence about a score is measured
/// against.
///
/// **One definition, read by everything that talks about where a score
/// stands** — the verdict ladder below and the assistant's wording both come
/// from here. Written twice, they drift, and the reader is told two different
/// things about the same number on two screens.
// TODO(backend): a fixture; real draws move every round, and the range should
// come from the last six results rather than a constant.
const int crsDrawLow = 435;
const int crsDrawHigh = 470;

/// The score below which a general draw is not the route to plan around.
const int crsExploreBelow = 380;

/// Where a score sits against recent Express Entry draws, in the product's
/// fixed verdict wording. Never pass or fail — a low score reads "Explore
/// Further", because a nomination or a French result can change it entirely.
({WsVerdict verdict, String label}) crsVerdict(int total) {
  if (total >= crsDrawHigh) {
    return (verdict: WsVerdict.eligible, label: 'High Potential');
  }
  if (total >= crsDrawLow) {
    return (verdict: WsVerdict.eligible, label: 'Good Range');
  }
  if (total >= crsExploreBelow) {
    return (verdict: WsVerdict.potential, label: 'Potential Options');
  }
  return (verdict: WsVerdict.explore, label: 'Explore Further');
}

/// PNP points for every province with a points grid, from the same profile.
final pnpScoresProvider = Provider<List<PnpScore>>(
  (ref) => calculatePnpScores(ref.watch(candidateProvider)),
);

/// Whether the candidate has asked for their CRS score yet.
///
/// The score is always calculable from the profile, but it is not shown until
/// it is asked for. A number that simply appears — on the Immigration tab, in
/// the profile, on every launch — is wallpaper: the reader stops seeing it,
/// and an immigration score is too consequential to become furniture. Asking
/// for it makes the result an answer to a question the candidate actually
/// put.
///
/// Once revealed it stays revealed for the session, and every screen that
/// shows the score reads this one flag, so the score appears in all of them at
/// the same moment.
// TODO(backend): session-only, so it resets on every launch. The real app
// remembers when the candidate last generated a score, and whether the profile
// has changed since.
final crsRevealedProvider = NotifierProvider<CrsRevealed, bool>(
  CrsRevealed.new,
);

class CrsRevealed extends Notifier<bool> {
  @override
  bool build() => false;

  void reveal() => state = true;
}
