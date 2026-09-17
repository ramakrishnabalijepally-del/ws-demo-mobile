import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/theme/theme.dart';
import '../../../../../shared/data/mock_candidate.dart';
import '../../../../../shared/models/crs_profile.dart';
import '../../../../../shared/shared.dart';
import 'section_forms.dart';

/// The last two questions before a score can be calculated, asked in a sheet
/// rather than a screen.
///
/// Additional factors is the one section worth stopping for: a provincial
/// nomination is 600 points, so a score calculated without knowing about one
/// can be wrong by half the scale. Every other gap only makes the score an
/// underestimate the result screen already labels as an estimate.
///
/// **It is the same form the Additional factors section uses**, not a second
/// copy of the questions, so an answer given here is the profile's answer.
///
/// Returns true when the answers were saved and the score should be
/// calculated, and null or false when the candidate backed out.
Future<bool?> showAdditionalFactorsSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => const _AdditionalFactorsSheet(),
  );
}

class _AdditionalFactorsSheet extends ConsumerStatefulWidget {
  const _AdditionalFactorsSheet();

  @override
  ConsumerState<_AdditionalFactorsSheet> createState() =>
      _AdditionalFactorsSheetState();
}

class _AdditionalFactorsSheetState
    extends ConsumerState<_AdditionalFactorsSheet> {
  late CrsProfile _draft = ref.read(candidateProvider).crs;

  void _save() {
    // TODO(backend): saved in memory only.
    ref.read(candidateProvider.notifier).update(
          ref.read(candidateProvider).copyWith(crs: _draft),
        );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    // The sheet sizes to its content up to most of the screen, so the two
    // questions are not trapped in a fixed-height box at 200% text scale.
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // The drag handle comes from the bottom-sheet theme.
          Padding(
            padding: const EdgeInsets.fromLTRB(
              WsSpacing.xl,
              WsSpacing.sm,
              WsSpacing.xl,
              WsSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Two questions first', style: context.text.titleLarge),
                const SizedBox(height: WsSpacing.xs),
                Text(
                  'A provincial nomination is worth 600 points, so your score '
                  'is not meaningful until WorkSettle knows about one.',
                  style: context.text.bodyMedium
                      ?.copyWith(color: context.colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                WsSpacing.xl,
                WsSpacing.md,
                WsSpacing.xl,
                WsSpacing.lg,
              ),
              child: AdditionalFactorsForm(
                draft: _draft,
                onChanged: (profile) => setState(() => _draft = profile),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                WsSpacing.xl,
                WsSpacing.md,
                WsSpacing.xl,
                WsSpacing.lg,
              ),
              child: WsPrimaryButton(
                label: 'Get my CRS score',
                onPressed: _save,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
