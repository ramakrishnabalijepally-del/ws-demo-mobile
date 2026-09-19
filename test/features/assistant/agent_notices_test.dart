import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:worksettle_mobile/features/assistant/controllers/agent_notices.dart';
import 'package:worksettle_mobile/shared/controllers/crs_controller.dart';
import 'package:worksettle_mobile/shared/data/mock_candidate.dart';

/// The agent's claim is that it read your profile. These check that it did.
void main() {
  ProviderContainer container() {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    return c;
  }

  test('the score gap waits for a score to exist', () {
    final c = container();
    expect(
      c.read(agentNoticesProvider).map((n) => n.id),
      isNot(contains('crs-gap')),
    );

    c.read(crsRevealedProvider.notifier).reveal();
    final gap =
        c.read(agentNoticesProvider).firstWhere((n) => n.id == 'crs-gap');
    // Computed, not written down: the old fixture said "11 points below" to
    // every candidate, whatever their score was.
    final total = c.read(crsResultProvider).total;
    expect(gap.title, contains('${crsDrawLow - total} points'));
  });

  test('a score inside the draw range raises no gap at all', () {
    final c = container();
    c.read(crsRevealedProvider.notifier).reveal();
    c.read(candidateProvider.notifier).update(
          mockCandidate.copyWith(
            crs: mockCandidate.crs.copyWith(provincialNomination: true),
          ),
        );
    // A nomination is 600 points, so nothing is below anything.
    expect(c.read(crsResultProvider).total, greaterThanOrEqualTo(crsDrawLow));
    expect(
      c.read(agentNoticesProvider).map((n) => n.id),
      isNot(contains('crs-gap')),
    );
  });

  test('expiry notices follow the dates in the profile', () {
    final c = container();
    expect(
      c.read(agentNoticesProvider).map((n) => n.id),
      contains('passport'),
    );

    final far = DateTime.now().add(const Duration(days: 365 * 5));
    c.read(candidateProvider.notifier).update(
          mockCandidate.copyWith(
            immigration: mockCandidate.immigration.copyWith(
              passportExpiryDate: '${far.year}-01-01',
              statusExpiryDate: '${far.year}-01-01',
            ),
          ),
        );
    final ids = c.read(agentNoticesProvider).map((n) => n.id);
    expect(ids, isNot(contains('passport')));
    expect(ids, isNot(contains('status')));
  });

  test('what is raised shrinks as the profile is filled in', () {
    final c = container();
    final before = c.read(agentNoticesProvider).map((n) => n.id).toList();

    final far = DateTime.now().add(const Duration(days: 365 * 5));
    c.read(candidateProvider.notifier).update(
          mockCandidate.copyWith(
            immigration: mockCandidate.immigration.copyWith(
              passportExpiryDate: '${far.year}-01-01',
              statusExpiryDate: '${far.year}-01-01',
            ),
          ),
        );
    final after = c.read(agentNoticesProvider).map((n) => n.id).toList();

    expect(after.length, lessThan(before.length));
    // What is left is the profile section still open — raised as itself, and
    // named, rather than as a fixed line about a score.
    expect(after, contains('completion'));
    final completion =
        c.read(agentNoticesProvider).firstWhere((n) => n.id == 'completion');
    expect(
      completion.title,
      contains(c.read(profileCompletionProvider).next!.title),
    );
  });
}
