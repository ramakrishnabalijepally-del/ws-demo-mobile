import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/routes.dart';
import '../../../../../app/theme/theme.dart';
import '../../../../../shared/shared.dart';
import '../../../data/mock_immigration.dart';
import '../widgets/province_mark.dart';

/// J10 — the province list.
///
/// The deck lays these out as a grid of full-colour flags. **The grid is
/// dropped, the flags are kept**: rows scale with text where a fixed grid cell
/// does not, and section 7 makes province marks the one full-colour imagery
/// allowed in an icon slot — in a 40 px rounded square with a hairline, never
/// recoloured and never cropped to a circle.
class PnpProvincesScreen extends StatelessWidget {
  const PnpProvincesScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              leading: ProvinceMark(abbreviation: province.abbreviation),
              title: province.name,
              subtitle: province.programName,
              trailing: province.streams.any((s) => s.matched)
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
class PnpStreamsScreen extends StatelessWidget {
  const PnpStreamsScreen({required this.provinceCode, super.key});

  final String provinceCode;

  @override
  Widget build(BuildContext context) {
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
              ProvinceMark(abbreviation: province.abbreviation),
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
                        WsVerdictChip(
                          verdict: stream.matched
                              ? WsVerdict.eligible
                              : WsVerdict.potential,
                          label: stream.matched ? 'Good Match' : 'Potential',
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
class PnpStreamDetailScreen extends StatelessWidget {
  const PnpStreamDetailScreen({
    required this.provinceCode,
    required this.streamName,
    super.key,
  });

  final String provinceCode;
  final String streamName;

  @override
  Widget build(BuildContext context) {
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
                    WsVerdictChip(
                      verdict: stream.matched
                          ? WsVerdict.eligible
                          : WsVerdict.potential,
                      label: stream.matched ? 'Good Match' : 'Potential Match',
                    ),
                  ],
                ),
                const SizedBox(height: WsSpacing.md),
                Text(
                  stream.matched
                      ? 'On the information you have given, your profile meets '
                          'the published criteria for this stream.'
                      : 'This one depends on something not yet in your profile '
                          '— usually a job offer or Canadian experience. It is '
                          'not closed to you.',
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
class ProgramsScreen extends StatelessWidget {
  const ProgramsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
class CompareScreen extends StatelessWidget {
  const CompareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final matchedStreams = [
      for (final province in mockProvinces)
        for (final stream in province.streams)
          if (stream.matched) (province: province, stream: stream),
    ];

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
                    ProvinceMark(abbreviation: match.province.abbreviation),
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
