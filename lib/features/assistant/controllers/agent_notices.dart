import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/controllers/crs_controller.dart';
import '../../../shared/data/mock_candidate.dart';
import '../data/mock_agent.dart';

/// What the agent has noticed, worked out from the profile as it stands.
///
/// **The whole claim of this screen is that the agent read your profile.** A
/// fixed list of notices makes that claim false: it told every candidate their
/// passport expired in four months whatever date they had entered, and named a
/// CRS gap in points whether or not they had ever asked for a score.
///
/// Each notice here is raised by a condition on the live profile, and the
/// screen shows what is left. "Nothing needs you today" is a real answer;
/// inventing four things to say is not.
// TODO(backend): two notices the fixture used to carry cannot be raised yet.
// Job matches need a live feed and a matcher. Language-test expiry needs the
// date the test was taken, which `LanguageResult` does not collect — add the
// field before adding the notice back, rather than guessing at a date.
final agentNoticesProvider = Provider<List<AgentNotice>>((ref) {
  final candidate = ref.watch(candidateProvider);
  final completion = ref.watch(profileCompletionProvider);
  final crs = ref.watch(crsResultProvider);
  final revealed = ref.watch(crsRevealedProvider);
  final today = DateTime.now();

  final notices = <AgentNotice>[];

  /// Whole months until [date]; null when there is no date, or it has passed.
  int? monthsUntil(DateTime? date) {
    if (date == null) return null;
    final days = date.difference(today).inDays;
    return days <= 0 ? null : (days / 30).floor();
  }

  String inWords(int months) => switch (months) {
        0 => 'this month',
        1 => 'in a month',
        _ => 'in $months months',
      };

  // A passport is the hard stop on any application, so it outranks everything
  // else and is the one notice allowed to be urgent.
  final passport = monthsUntil(candidate.immigration.passportExpiry);
  if (passport != null && passport <= 9) {
    notices.add(
      AgentNotice(
        id: 'passport',
        title: 'Your passport expires ${inWords(passport)}',
        detail: 'IRCC will not issue permanent residence past your passport '
            'date, and renewals are taking six to eight weeks. Start it now.',
        icon: Icons.badge_outlined,
        actionLabel: 'Open documents',
        route: '/profile',
        urgent: true,
      ),
    );
  }

  final status = monthsUntil(candidate.immigration.statusExpiry);
  if (status != null && status <= 6) {
    notices.add(
      AgentNotice(
        id: 'status',
        title: 'Your status in Canada expires ${inWords(status)}',
        detail: 'Staying in status is what keeps your application and your '
            'work permit intact. An extension is filed before the date, not '
            'after it.',
        icon: Icons.assignment_ind_outlined,
        actionLabel: 'Open your profile',
        route: '/profile',
      ),
    );
  }

  // A gap can only be named once there is a score to have a gap.
  if (revealed && crs.total < crsDrawLow) {
    notices.add(
      AgentNotice(
        id: 'crs-gap',
        title: 'Your CRS score is ${crsDrawLow - crs.total} points below '
            'recent draws',
        detail: 'Recent general draws closed between $crsDrawLow and '
            '$crsDrawHigh. A sibling in Canada is worth 15 points, and a '
            'provincial nomination is worth 600.',
        icon: Icons.speed_rounded,
        actionLabel: 'See what moves it',
        route: '/immigration',
      ),
    );
  }

  final next = completion.next;
  if (next != null) {
    notices.add(
      AgentNotice(
        id: 'completion',
        title: '${next.title} is the next section to fill in',
        detail: '${next.summary}. Sections still open only make your score an '
            'underestimate.',
        icon: Icons.fact_check_outlined,
        actionLabel: 'Finish your profile',
        route: '/profile/complete',
      ),
    );
  }

  return notices;
});
