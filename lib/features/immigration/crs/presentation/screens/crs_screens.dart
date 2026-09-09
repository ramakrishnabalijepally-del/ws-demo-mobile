import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/routes.dart';
import '../../../../../app/theme/theme.dart';
import '../../../../../shared/models/ws_module.dart';
import '../../../../../shared/shared.dart';
import '../../../data/mock_immigration.dart';

/// J2 — the tool overview, the first beat of Pattern B.
class CrsOverviewScreen extends StatelessWidget {
  const CrsOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CRS Predictor')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          WsSpacing.xl,
          WsSpacing.lg,
          WsSpacing.xl,
          WsSpacing.huge,
        ),
        children: [
          const Center(
            child: WsIconTile(
              icon: Icons.speed_rounded,
              size: WsTileSize.header,
            ),
          ),
          const SizedBox(height: WsSpacing.xl),
          Text(
            'Predict your CRS score',
            style: context.text.headlineLarge,
          ),
          const SizedBox(height: WsSpacing.md),
          Text(
            'The Comprehensive Ranking System is how Express Entry ranks '
            'candidates. Five questions gets you an estimate you can compare '
            'against the scores that recent draws actually invited.',
            style: context.text.bodyMedium
                ?.copyWith(color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(height: WsSpacing.xxl),
          WsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('What we will ask', style: context.text.titleMedium),
                const SizedBox(height: WsSpacing.md),
                for (final step in mockCrsSteps)
                  Padding(
                    padding: const EdgeInsets.only(bottom: WsSpacing.sm),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          size: WsIconSize.tick,
                          color: context.colors.onSurface,
                        ),
                        const SizedBox(width: WsSpacing.md),
                        Text(step.title, style: context.text.bodyMedium),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: WsSpacing.lg),
          const WsDisclaimer(),
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
            label: 'Start',
            onPressed: () => context.push(Routes.crsCalculator),
          ),
        ),
      ),
    );
  }
}

/// J3–J7 — the five steps, on a numbered stepper.
class CrsCalculatorScreen extends StatefulWidget {
  const CrsCalculatorScreen({super.key});

  @override
  State<CrsCalculatorScreen> createState() => _CrsCalculatorScreenState();
}

class _CrsCalculatorScreenState extends State<CrsCalculatorScreen> {
  int _step = 0;

  /// Pre-filled with the mock candidate's answers so the wizard is walkable
  /// and the total matches the score the rest of the app reports.
  late final List<int> _answers = [
    for (final step in mockCrsSteps) step.answerIndex,
  ];

  bool get _isLast => _step == mockCrsSteps.length - 1;

  void _next() {
    if (_isLast) {
      context.go(Routes.crsResult);
      return;
    }
    setState(() => _step++);
  }

  @override
  Widget build(BuildContext context) {
    final step = mockCrsSteps[_step];

    return PopScope(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _step--);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('CRS Calculator'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            tooltip: 'Back',
            onPressed: () =>
                _step == 0 ? context.pop() : setState(() => _step--),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: WsSpacing.sm),
              WsNumberedStepper(
                steps: [for (final s in mockCrsSteps) s.title],
                current: _step,
                onStepTapped: (i) => setState(() => _step = i),
              ),
              const SizedBox(height: WsSpacing.xl),
              Expanded(
                child: ListView(
                  padding: WsSpacing.gutter,
                  children: [
                    Text(step.question, style: context.text.headlineLarge),
                    const SizedBox(height: WsSpacing.xxl),
                    for (var i = 0; i < step.options.length; i++) ...[
                      WsSelectionCard(
                        selected: _answers[_step] == i,
                        semanticLabel: step.options[i].label,
                        onTap: () => setState(() => _answers[_step] = i),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                step.options[i].label,
                                style: context.text.bodyMedium,
                              ),
                            ),
                            const SizedBox(width: WsSpacing.md),
                            Text(
                              '${step.options[i].points} pts',
                              style: context.text.bodySmall
                                  ?.copyWith(color: context.ws.caption),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: WsSpacing.md),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  WsSpacing.xl,
                  WsSpacing.md,
                  WsSpacing.xl,
                  WsSpacing.xl,
                ),
                child: WsPrimaryButton(
                  label: _isLast ? 'See my score' : 'Continue',
                  onPressed: _next,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// J8 — the result.
///
/// Pattern B fixes the order: **the number, the verdict pill, and the sentence
/// that puts it in context.** The breakdown is one tap away, never on the
/// result screen itself.
class CrsResultScreen extends StatelessWidget {
  const CrsResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your CRS score')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          WsSpacing.xl,
          WsSpacing.lg,
          WsSpacing.xl,
          WsSpacing.huge,
        ),
        children: [
          WsBanner(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'You are in a competitive range',
                  style: context.text.titleMedium,
                ),
                const SizedBox(height: WsSpacing.xs),
                Text(
                  'Recent Express Entry draws have invited candidates scoring '
                  '435 to 470.',
                  style: context.text.bodySmall
                      ?.copyWith(color: context.colors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(height: WsSpacing.lg),
          WsScoreCard(
            icon: WsModule.crsPredictor.icon,
            title: 'Comprehensive Ranking System',
            supporting: 'Based on the five answers you gave',
            value: mockCrsScore,
            maximum: mockCrsMaximum,
            verdict: WsVerdict.eligible,
            verdictLabel: 'Good Range',
            contextLine: '$mockCrsScore — competitive for $mockRecentDraws',
            brandFill: true,
            showDisclaimer: true,
          ),
          const SizedBox(height: WsSpacing.xxl),
          Text('What would move it', style: context.text.titleLarge),
          const SizedBox(height: WsSpacing.md),
          const _Lever(
            title: 'A provincial nomination',
            worth: '+600',
            body: 'The single largest factor. Three provinces have streams '
                'your profile already matches.',
          ),
          const _Lever(
            title: 'CLB 10 in English',
            worth: '+20',
            body: 'One more test sitting, and the skill transferability '
                'combinations move with it.',
          ),
          const _Lever(
            title: 'French at CLB 7',
            worth: '+50',
            body: 'Several draws have been French-only. It counts even when '
                'English is your stronger language.',
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
            label: 'See the breakdown',
            onPressed: () => context.push(Routes.crsBreakdown),
          ),
        ),
      ),
    );
  }
}

class _Lever extends StatelessWidget {
  const _Lever({required this.title, required this.worth, required this.body});

  final String title;
  final String worth;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: WsSpacing.md),
      child: WsCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: context.text.titleMedium)),
                Text(
                  worth,
                  style: context.text.titleMedium
                      ?.copyWith(color: context.ws.redOnSurface),
                ),
              ],
            ),
            const SizedBox(height: WsSpacing.xs),
            Text(
              body,
              style:
                  context.text.bodySmall?.copyWith(color: context.ws.caption),
            ),
          ],
        ),
      ),
    );
  }
}

/// J9 — the breakdown table.
class CrsBreakdownScreen extends StatelessWidget {
  const CrsBreakdownScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Score breakdown')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          WsSpacing.xl,
          WsSpacing.lg,
          WsSpacing.xl,
          WsSpacing.huge,
        ),
        children: [
          Text(
            'How $mockCrsScore adds up',
            style: context.text.titleLarge,
          ),
          const SizedBox(height: WsSpacing.md),
          Text(
            'Core factors first, then the points the system awards for how '
            'they combine.',
            style: context.text.bodyMedium
                ?.copyWith(color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(height: WsSpacing.xl),
          const WsScoreBreakdown(
            rows: mockCrsBreakdown,
            totalLabel: 'Total CRS score',
            total: mockCrsScore,
          ),
          const SizedBox(height: WsSpacing.xl),
          const WsDisclaimer(),
        ],
      ),
    );
  }
}
