import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/controllers/crs_controller.dart';
import '../../../shared/data/mock_candidate.dart';
import '../../../shared/utils/pnp_matcher.dart';
import '../data/mock_immigration.dart';

/// One provincial stream, and how it sits against the profile as it stands.
typedef StreamMatch = ({
  Province province,
  PnpStream stream,
  StreamAssessment assessment,
});

/// Every stream in every province, assessed against the candidate's profile.
///
/// **This is the one place a stream verdict comes from.** The PNP screens, the
/// Immigration tab and the assistant all read it, so they cannot tell the
/// reader three different things — and because it watches the profile, the CRS
/// result and the provincial grids, adding a language test or a year of work
/// moves every one of them at once.
final streamMatchesProvider = Provider<List<StreamMatch>>((ref) {
  final candidate = ref.watch(candidateProvider);
  final grids = ref.watch(pnpScoresProvider);
  final crs = ref.watch(crsResultProvider);

  return <StreamMatch>[
    for (final province in mockProvinces)
      for (final stream in province.streams)
        (
          province: province,
          stream: stream,
          assessment: assessStream(
            candidate,
            stream.criteria,
            grids: grids,
            crsTotal: crs.total,
          ),
        ),
  ];
});

/// The streams that line up — everything checkable met, whether or not
/// something unverifiable remains.
final liningUpStreamsProvider = Provider<List<StreamMatch>>(
  (ref) => ref
      .watch(streamMatchesProvider)
      .where((m) => m.assessment.lines)
      .toList(),
);

/// The streams where nothing at all is left hanging.
final confirmedStreamsProvider = Provider<List<StreamMatch>>(
  (ref) => ref
      .watch(streamMatchesProvider)
      .where((m) => m.assessment.fit == StreamFit.good)
      .toList(),
);

/// The streams waiting only on something a profile cannot answer.
final openStreamsProvider = Provider<List<StreamMatch>>(
  (ref) => ref
      .watch(streamMatchesProvider)
      .where((m) => m.assessment.fit == StreamFit.potential)
      .toList(),
);

/// How one stream sits, out of an already-computed list.
StreamAssessment assessmentFor(
  List<StreamMatch> matches,
  Province province,
  PnpStream stream,
) =>
    matches
        .firstWhere(
          (m) =>
              m.province.abbreviation == province.abbreviation &&
              m.stream.name == stream.name,
        )
        .assessment;

/// Those streams as the assistant says them: "Ontario Human Capital
/// Priorities, British Columbia Tech and two Saskatchewan streams".
///
/// Provinces with more than one collapse to a count, because a sentence that
/// lists six stream names in full stops being readable.
String liningUpSentence(List<StreamMatch> matches) {
  final byProvince = <String, List<String>>{};
  for (final match in matches) {
    byProvince
        .putIfAbsent(match.province.name, () => <String>[])
        .add(match.stream.name);
  }

  final parts = <String>[
    for (final entry in byProvince.entries)
      if (entry.value.length == 1)
        _qualify(entry.key, entry.value.single)
      else
        '${countWord(entry.value.length)} ${entry.key} streams',
  ];

  if (parts.isEmpty) return '';
  if (parts.length == 1) return parts.single;
  return '${parts.sublist(0, parts.length - 1).join(', ')} and ${parts.last}';
}

/// The same streams with their count, as an answer opens on them.
String liningUpOpening(List<StreamMatch> matches) {
  if (matches.isEmpty) {
    return 'Nothing in your profile lines up with a provincial stream yet — '
        'the sections still open are what would change that.';
  }
  final provinces = matches.map((m) => m.province.name).toSet().length;
  final count = countWord(matches.length);
  final where = provinces == 1
      ? 'in ${matches.first.province.name}'
      : 'across ${countWord(provinces)} provinces';
  final one = matches.length == 1;
  return '${count[0].toUpperCase()}${count.substring(1)} '
      '${one ? 'stream' : 'streams'} $where '
      '${one ? 'lines' : 'line'} up with what you have entered: '
      '${liningUpSentence(matches)}.';
}

/// "Alberta" + "Alberta Express Entry" is not a name anyone says out loud, so
/// a stream that already carries its province keeps its own name.
String _qualify(String province, String stream) =>
    stream.startsWith(province) ? stream : '$province $stream';

/// Small numbers are words in prose, per the design system's voice rules.
String countWord(int n) => switch (n) {
      1 => 'one',
      2 => 'two',
      3 => 'three',
      4 => 'four',
      5 => 'five',
      6 => 'six',
      7 => 'seven',
      8 => 'eight',
      9 => 'nine',
      10 => 'ten',
      final other => '$other',
    };
