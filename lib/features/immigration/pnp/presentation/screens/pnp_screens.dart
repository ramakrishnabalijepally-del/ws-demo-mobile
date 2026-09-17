import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/routes.dart';
import '../../../../../app/theme/theme.dart';
import '../../../../../shared/shared.dart';
import '../../../../../shared/utils/pnp_matcher.dart';
import '../../../controllers/stream_matches.dart';
import '../../../data/mock_immigration.dart';

/// J10 — the province list.
///
/// The deck lays these out as a grid of full-colour flags. **The grid is
/// dropped, the flags are kept**: rows scale with text where a fixed grid cell
/// does not, and section 7 makes province marks the one full-colour imagery
/// allowed in an icon slot — in a 40 px rounded square with a hairline, never
/// recoloured and never cropped to a circle.
class PnpProvincesScreen extends ConsumerWidget {
  const PnpProvincesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = ref.watch(streamMatchesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Provincial Programs')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: WsSpacing.xxxl),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              WsSpacing.xl,
              WsSpacing.lg,
              WsSpacing.xl,
              WsSpacing.lg,
            ),
            child: Text(
              'Every province runs its own nominee program, and a nomination '
              'is worth 600 CRS points. These are the ones your profile '
              'reaches.',
              style: context.text.bodyMedium
                  ?.copyWith(color: context.colors.onSurfaceVariant),
            ),
          ),
          for (final province in mockProvinces) ...[
            WsListRow(
              leading: WsProvinceMark(
                code: province.abbreviation,
                label: province.name,
              ),
              title: province.name,
              subtitle: province.programName,
              trailing: matches.any(
                (m) =>
                    m.province.abbreviation == province.abbreviation &&
                    m.assessment.lines,
              )
                  ? const WsVerdictChip(
                      verdict: WsVerdict.eligible,
                      label: 'Match',
                    )
                  : const WsVerdictChip(
                      verdict: WsVerdict.explore,
                      label: 'Explore',
                    ),
              onTap: () => context.push(
                Routes.withId(Routes.pnpStreams, province.abbreviation),
              ),
            ),
            Divider(color: context.colors.outlineVariant, height: 1),
          ],
        ],
      ),
    );
  }
}

/// J11 — the streams within one province.
class PnpStreamsScreen extends ConsumerWidget {
  const PnpStreamsScreen({required this.provinceCode, super.key});

  final String provinceCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = ref.watch(streamMatchesProvider);
    final province =
        mockProvinces.where((p) => p.abbreviation == provinceCode).firstOrNull;

    if (province == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Provincial Programs')),
        body: WsEmptyState(
          icon: Icons.map_outlined,
          headline: 'We do not have that province yet',
          body: 'The provinces we cover are on the previous screen.',
          actionLabel: 'Back to provinces',
          onAction: () => context.pop(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(province.abbreviation)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          WsSpacing.xl,
          WsSpacing.lg,
          WsSpacing.xl,
          WsSpacing.xxxl,
        ),
        children: [
          Row(
            children: [
              WsProvinceMark(code: province.abbreviation, label: province.name),
              const SizedBox(width: WsSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(province.name, style: context.text.titleLarge),
                    Text(
                      province.programName,
                      style: context.text.bodySmall
                          ?.copyWith(color: context.ws.caption),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: WsSpacing.xxl),
          Text('Streams', style: context.text.titleLarge),
          const SizedBox(height: WsSpacing.md),
          for (final stream in province.streams)
            Padding(
              padding: const EdgeInsets.only(bottom: WsSpacing.md),
              child: WsCard(
                onTap: () => context.push(
                  '${Routes.withId(Routes.pnpStreams, province.abbreviation)}'
                  '/${Uri.encodeComponent(stream.name)}',
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            stream.name,
                            style: context.text.titleMedium,
                          ),
                        ),
                        const SizedBox(width: WsSpacing.md),
                        Builder(
                          builder: (context) {
                            final fit =
                                assessmentFor(matches, province, stream).fit;
                            return WsVerdictChip(
                              verdict: _verdictOf(fit),
                              label: fit.label,
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: WsSpacing.xs),
                    Text(
                      stream.summary,
                      style: context.text.bodySmall
                          ?.copyWith(color: context.ws.caption),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: WsSpacing.lg),
          const WsDisclaimer(authority: 'the province'),
        ],
      ),
    );
  }
}

/// J12–J13 — one stream: what it asks for, and where the candidate stands.
class PnpStreamDetailScreen extends ConsumerWidget {
  const PnpStreamDetailScreen({
    required this.provinceCode,
    required this.streamName,
    super.key,
  });

  final String provinceCode;
  final String streamName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = ref.watch(streamMatchesProvider);
    final province =
        mockProvinces.where((p) => p.abbreviation == provinceCode).firstOrNull;
    final stream = province?.streams
        .where((s) => s.name == Uri.decodeComponent(streamName))
        .firstOrNull;

    if (province == null || stream == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Stream')),
        body: WsEmptyState(
          icon: Icons.map_outlined,
          headline: 'We cannot find that stream',
          body: 'Programs change often. The current list is one screen back.',
          actionLabel: 'Back',
          onAction: () => context.pop(),
        ),
      );
    }

    final assessment = assessmentFor(matches, province, stream);

    return Scaffold(
      appBar: AppBar(title: Text(province.abbreviation)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          WsSpacing.xl,
          WsSpacing.lg,
          WsSpacing.xl,
          WsSpacing.huge,
        ),
        children: [
          Text(stream.name, style: context.text.headlineLarge),
          const SizedBox(height: WsSpacing.sm),
          Text(
            stream.summary,
            style: context.text.bodyMedium
                ?.copyWith(color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(height: WsSpacing.xl),
          WsCard(
            raised: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Where you stand',
                        style: context.text.titleMedium,
                      ),
                    ),
                    // The verdict lands a beat after the screen, so it reads
                    // as considered rather than stamped on.
                    WsAppear(
                      delay: 0.5,
                      duration: WsMotion.focal,
                      fromScale: 0.85,
                      distance: 0,
                      child: WsVerdictChip(
                        verdict: _verdictOf(assessment.fit),
                        label: assessment.fit.label,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: WsSpacing.md),
                Text(
                  _explain(assessment),
                  style: context.text.bodyMedium,
                ),
                const SizedBox(height: WsSpacing.md),
                const WsDisclaimer(authority: 'the province'),
              ],
            ),
          ),
          const SizedBox(height: WsSpacing.xxl),
          Text('What it asks for', style: context.text.titleLarge),
          const SizedBox(height: WsSpacing.md),
          for (final requirement in stream.requirements)
            Padding(
              padding: const EdgeInsets.only(bottom: WsSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: WsIconSize.tick,
                    color: context.colors.onSurface,
                  ),
                  const SizedBox(width: WsSpacing.md),
                  Expanded(
                    child: Text(requirement, style: context.text.bodyMedium),
                  ),
                ],
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            WsSpacing.xl,
            WsSpacing.md,
            WsSpacing.xl,
            WsSpacing.lg,
          ),
          child: WsPrimaryButton(
            label: 'Book a consultation',
            onPressed: () => context.go(Routes.appointments),
          ),
        ),
      ),
    );
  }
}

/// J14 — federal programs, and the comparison.
class ProgramsScreen extends ConsumerWidget {
  const ProgramsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Federal Programs')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          WsSpacing.xl,
          WsSpacing.lg,
          WsSpacing.xl,
          WsSpacing.xxxl,
        ),
        children: [
          for (final program in mockFederalPrograms)
            Padding(
              padding: const EdgeInsets.only(bottom: WsSpacing.md),
              child: WsCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Federal programs carry the country mark, the way a
                        // provincial stream carries its province's.
                        const WsProvinceMark.canada(),
                        const SizedBox(width: WsSpacing.md),
                        Expanded(
                          child: Text(
                            program.name,
                            style: context.text.titleMedium,
                          ),
                        ),
                        const SizedBox(width: WsSpacing.md),
                        WsVerdictChip(
                          verdict: program.eligible
                              ? WsVerdict.eligible
                              : WsVerdict.explore,
                          // Never "Ineligible": the neutral verdict plus the
                          // gap and what closes it (design system section 9).
                          label: program.eligible ? 'Eligible' : 'Explore',
                        ),
                      ],
                    ),
                    const SizedBox(height: WsSpacing.xs),
                    Text(
                      program.summary,
                      style: context.text.bodySmall
                          ?.copyWith(color: context.ws.caption),
                    ),
                    const SizedBox(height: WsSpacing.md),
                    Text(program.note, style: context.text.bodyMedium),
                  ],
                ),
              ),
            ),
          const SizedBox(height: WsSpacing.sm),
          const WsDisclaimer(),
        ],
      ),
    );
  }
}

/// The compare screen — the same programs, read across rather than down.
class CompareScreen extends ConsumerWidget {
  const CompareScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchedStreams = ref.watch(liningUpStreamsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Compare options')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          WsSpacing.xl,
          WsSpacing.lg,
          WsSpacing.xl,
          WsSpacing.xxxl,
        ),
        children: [
          Text(
            'On the profile you have entered',
            style: context.text.titleLarge,
          ),
          const SizedBox(height: WsSpacing.sm),
          Text(
            '${matchedStreams.length} provincial streams and '
            '${mockFederalPrograms.where((p) => p.eligible).length} federal '
            'program currently line up with your answers.',
            style: context.text.bodyMedium
                ?.copyWith(color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(height: WsSpacing.xl),
          for (final match in matchedStreams)
            Padding(
              padding: const EdgeInsets.only(bottom: WsSpacing.md),
              child: WsCard(
                onTap: () => context.push(
                  '${Routes.withId(
                    Routes.pnpStreams,
                    match.province.abbreviation,
                  )}/${Uri.encodeComponent(match.stream.name)}',
                ),
                child: Row(
                  children: [
                    WsProvinceMark(
                      code: match.province.abbreviation,
                      label: match.province.name,
                    ),
                    const SizedBox(width: WsSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            match.stream.name,
                            style: context.text.titleMedium,
                          ),
                          Text(
                            match.province.name,
                            style: context.text.bodySmall
                                ?.copyWith(color: context.ws.caption),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: WsSpacing.md),
                    const WsVerdictChip(
                      verdict: WsVerdict.eligible,
                      label: 'Good Match',
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: WsSpacing.sm),
          const WsDisclaimer(),
        ],
      ),
    );
  }
}

/// The verdict chip for a fit. The ladder is filled → outlined → tinted, and
/// there is no fourth rung.
WsVerdict _verdictOf(StreamFit fit) => switch (fit) {
      StreamFit.good => WsVerdict.eligible,
      StreamFit.potential => WsVerdict.potential,
      StreamFit.explore => WsVerdict.explore,
    };

/// What the verdict means, in the candidate's own terms.
///
/// **Never a refusal.** Where something is missing it is named as the thing
/// that would close it, and where the profile simply cannot answer, that is
/// said plainly rather than held against the reader.
String _explain(StreamAssessment assessment) {
  final unknowns = assessment.unknowns.map((u) => u.description).toList();
  return switch (assessment.fit) {
    StreamFit.good =>
      'On the information you have given, your profile meets every published '
          'criterion for this stream that WorkSettle can check.',
    StreamFit.potential =>
      'Everything WorkSettle can check from your profile is met. This stream '
          'also asks for ${_join(unknowns)}, which is not something a profile '
          'can answer — so it stays open rather than confirmed.',
    StreamFit.explore => 'This one is not closed to you. What would move it: '
        '${_join(assessment.gaps)}.',
  };
}

String _join(List<String> parts) {
  if (parts.isEmpty) return 'something outside your profile';
  if (parts.length == 1) return parts.single;
  return '${parts.sublist(0, parts.length - 1).join(', ')} and ${parts.last}';
}
