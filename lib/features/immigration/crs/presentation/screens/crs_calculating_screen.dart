import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/routes.dart';
import '../../../../../app/theme/theme.dart';
import '../../../../../shared/controllers/crs_controller.dart';
import '../../../../../shared/models/ws_module.dart';
import '../../../../../shared/shared.dart';

/// Ask for the CRS score, and calculate it.
///
/// The score is only worked out from a complete profile. Until then the
/// candidate lands on the status screen, which says what is filled in, what is
/// not, and opens each missing section where it is answered.
///
/// [toResult] opens the full result screen afterwards. The Immigration tab
/// does; the profile does not, because the score there is a readout and the
/// candidate asked to see it where they were standing.
Future<void> getMyCrsScore(
  BuildContext context,
  WidgetRef ref, {
  bool toResult = true,
}) async {
  final complete = ref.read(profileCompletionProvider).isComplete;
  await context.push<void>(
    complete ? '${Routes.crsCalculating}?result=$toResult' : Routes.crsOverview,
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
      // Replace this screen rather than `go`: the result takes the
      // calculating screen's place with the status screen behind it, and
      // whatever opened that — the Immigration tab or Profile — behind that.
      // `go` would rebuild the stack from the Immigration tab and lose Profile.
      context.pushReplacement(Routes.crsResult);
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
