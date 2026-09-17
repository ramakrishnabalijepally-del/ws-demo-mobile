import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/routes.dart';
import '../../../../../app/theme/theme.dart';
import '../../../../../shared/controllers/crs_controller.dart';
import '../../../../../shared/data/mock_candidate.dart';
import '../../../../../shared/models/profile_section.dart';
import '../../../../../shared/models/ws_module.dart';
import '../../../../../shared/shared.dart';
import '../../../../profile/profile.dart';

/// Ask for the CRS score, and calculate it.
///
/// Additional factors is asked first when it is still open, because a
/// provincial nomination is 600 points and a score that does not know about
/// one is not worth showing. Every other missing section only makes the score
/// an underestimate, which the result screen already labels as an estimate —
/// so nothing else blocks the question.
///
/// [toResult] opens the full result screen afterwards. The Immigration tab
/// does; the profile does not, because the score there is a readout and the
/// candidate asked to see it where they were standing.
Future<void> getMyCrsScore(
  BuildContext context,
  WidgetRef ref, {
  bool toResult = true,
}) async {
  final candidate = ref.read(candidateProvider);
  final needsAdditional = !ProfileSection.additional.isComplete(
    candidate.crs,
    hasDateOfBirth: candidate.birthDate != null,
  );

  if (needsAdditional) {
    final answered = await showAdditionalFactorsSheet(context);
    if (answered != true || !context.mounted) return;
  }

  await context.push<void>(
    '${Routes.crsCalculating}?result=$toResult',
  );
}

/// The moment between asking for the score and seeing it.
///
/// The design system's processing timeline, not a spinner: it names the work
/// being done, which is what makes the wait read as diligence. The score
/// itself is already calculated — this is the reveal, and the honesty rule is
/// that it must be *short*. Nothing is being faked for longer than the
/// animation needs.
class CrsCalculatingScreen extends ConsumerStatefulWidget {
  const CrsCalculatingScreen({this.toResult = true, super.key});

  final bool toResult;

  @override
  ConsumerState<CrsCalculatingScreen> createState() =>
      _CrsCalculatingScreenState();
}

class _CrsCalculatingScreenState extends ConsumerState<CrsCalculatingScreen> {
  static const List<String> _steps = [
    'Reading your profile',
    "Applying IRCC's points grid",
    'Comparing with recent draws',
  ];

  /// How long each line holds before the next resolves.
  static const Duration _perStep = Duration(milliseconds: 520);

  int _done = 0;
  Timer? _timer;
  bool _left = false;

  @override
  void initState() {
    super.initState();
    // Scheduled rather than run in initState so the first frame paints with
    // nothing done — otherwise the sequence is over before it is seen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _run();
    });
  }

  void _run() {
    // Reduced motion gets the same ending, immediately: the score is the
    // point, the sequence is the flourish.
    if (WsMotion.reduced(context)) {
      _finish();
      return;
    }
    _timer = Timer.periodic(_perStep, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _done++);
      if (_done >= _steps.length) {
        timer.cancel();
        _finish();
      }
    });
  }

  void _finish() {
    if (_left || !mounted) return;
    _left = true;
    ref.read(crsRevealedProvider.notifier).reveal();

    if (widget.toResult) {
      // go, not push: the result belongs in the Immigration tab's own stack,
      // with the overview behind it, so Back lands somewhere that makes sense.
      context.go(Routes.crsResult);
    } else {
      context.pop();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your CRS score')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(WsSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: WsSpacing.huge),
              WsIconTile(
                icon: WsModule.crsPredictor.icon,
                size: WsTileSize.header,
              ),
              const SizedBox(height: WsSpacing.xl),
              Text(
                'Working out your score',
                style: context.text.headlineLarge,
              ),
              const SizedBox(height: WsSpacing.sm),
              Text(
                'From the answers in your profile, using the points IRCC '
                'publishes.',
                style: context.text.bodyMedium
                    ?.copyWith(color: context.colors.onSurfaceVariant),
              ),
              const SizedBox(height: WsSpacing.xxxl),
              Semantics(
                liveRegion: true,
                label: 'Calculating your CRS score',
                child: WsProcessingTimeline(
                  steps: [
                    for (final (i, step) in _steps.indexed)
                      WsTimelineStep(step, done: i < _done),
                  ],
                ),
              ),
              const Spacer(),
              const WsDisclaimer(),
            ],
          ),
        ),
      ),
    );
  }
}
