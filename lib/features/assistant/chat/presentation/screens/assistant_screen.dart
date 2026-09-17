import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/routes.dart';
import '../../../../../app/theme/theme.dart';
import '../../../../../shared/controllers/crs_controller.dart';
import '../../../../../shared/models/ws_module.dart';
import '../../../../../shared/shared.dart';
import '../../../../../shared/utils/crs_calculator.dart';
import '../../../../immigration/immigration.dart';
import '../../../data/mock_assistant.dart';

/// L1–L5 — the assistant.
///
/// Design system Pattern C: **empty state with suggestions → question →
/// processing timeline → structured answer → related questions → save.**
///
/// The timeline is the piece that matters. It replaces a spinner with the
/// actual work being done, one line at a time, which is what makes the wait
/// read as diligence rather than lag.
class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

/// One entry in the visible thread.
sealed class _Turn {
  const _Turn();
}

class _UserTurn extends _Turn {
  const _UserTurn(this.text);
  final String text;
}

class _AnswerTurn extends _Turn {
  const _AnswerTurn(this.exchange);
  final AssistantExchange exchange;
}

class _ThinkingTurn extends _Turn {
  const _ThinkingTurn(this.exchange, this.completed);
  final AssistantExchange exchange;
  final int completed;
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final TextEditingController _composer = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<_Turn> _turns = [];

  bool _busy = false;

  @override
  void dispose() {
    _composer.dispose();
    _scroll.dispose();
    super.dispose();
  }

  AssistantExchange _exchangeFor(String question) {
    final lower = question.toLowerCase();
    final exchange = mockExchanges.firstWhere(
      (e) => e.question.toLowerCase() == lower,
      // Anything unscripted gets the CRS answer, which is the one every
      // newcomer asks first anyway.
      orElse: () => mockExchanges.first,
    );

    // The score is not shown until it has been asked for, and it is asked for
    // in Immigration. Since every unscripted question lands on the CRS answer,
    // without this the assistant would hand over the number to anyone who
    // typed anything at all.
    if (exchange.scoreCard && !ref.read(crsRevealedProvider)) {
      return mockCrsNotAskedExchange;
    }
    return exchange;
  }

  Future<void> _ask(String question) async {
    if (_busy || question.trim().isEmpty) return;
    final exchange = _exchangeFor(question);

    setState(() {
      _busy = true;
      _turns
        ..add(_UserTurn(question))
        ..add(_ThinkingTurn(exchange, 0));
      _composer.clear();
    });
    _scrollToEnd();

    // Each timeline row resolves in order.
    for (var i = 1; i <= exchange.timeline.length; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      setState(() {
        _turns[_turns.length - 1] = _ThinkingTurn(exchange, i);
      });
      _scrollToEnd();
    }

    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() {
      _turns[_turns.length - 1] = _AnswerTurn(exchange);
      _busy = false;
    });
    _scrollToEnd();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: WsMotion.duration(context, WsMotion.medium),
        curve: WsMotion.standard,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // The app bar title slot is narrow once two actions are in place,
        // so the presence line is the short form here. The full
        // "Online · Based on Your Profile" belongs on the empty state, which
        // has the width for it.
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('WorkSettle AI', style: context.text.titleMedium),
            const WsPresence(label: 'Online'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Voice mode',
            onPressed: () => context.push(Routes.assistantVoice),
            icon: const Icon(Icons.graphic_eq_rounded),
          ),
          IconButton(
            tooltip: 'Saved conversations',
            onPressed: () => context.push(Routes.assistantSaved),
            icon: const Icon(Icons.bookmark_border_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _turns.isEmpty
                ? _EmptyState(onAsk: _ask)
                : ListView(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(
                      WsSpacing.xl,
                      WsSpacing.lg,
                      WsSpacing.xl,
                      WsSpacing.lg,
                    ),
                    children: [
                      for (final turn in _turns)
                        _TurnView(turn: turn, onAsk: _ask),
                    ],
                  ),
          ),
          WsComposer(
            controller: _composer,
            hint: 'Ask about jobs, immigration or settling in',
            onSend: () => _ask(_composer.text),
            onMic: () => context.push(Routes.assistantVoice),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAsk});

  final ValueChanged<String> onAsk;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        WsSpacing.xl,
        WsSpacing.xxl,
        WsSpacing.xl,
        WsSpacing.xl,
      ),
      children: [
        const Center(
          child: WsIconTile(
            icon: Icons.forum_rounded,
            size: WsTileSize.header,
          ),
        ),
        const SizedBox(height: WsSpacing.xl),
        Text(
          'Ask WorkSettle anything',
          style: context.text.headlineLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: WsSpacing.sm),
        Text(
          'Answers are based on your profile, so they are about your situation '
          'rather than the general case.',
          style: context.text.bodyMedium
              ?.copyWith(color: context.colors.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: WsSpacing.xxl),
        // The suggestions cascade in under the heading.
        for (final (i, question) in mockSuggestedQuestions.indexed)
          WsAppear(
            delay: i * 0.07,
            duration: WsMotion.entranceSequence,
            child: WsSuggestionRow(
              question: question,
              onTap: () => onAsk(question),
            ),
          ),
      ],
    );
  }
}

class _TurnView extends StatelessWidget {
  const _TurnView({required this.turn, required this.onAsk});

  final _Turn turn;
  final ValueChanged<String> onAsk;

  @override
  Widget build(BuildContext context) {
    return switch (turn) {
      _UserTurn(:final text) =>
        WsChatBubble.text(speaker: WsSpeaker.user, text: text),
      _ThinkingTurn(:final exchange, :final completed) => WsChatBubble(
          speaker: WsSpeaker.other,
          avatar: const WsIconTile(
            icon: Icons.forum_rounded,
            size: WsTileSize.compact,
          ),
          child: WsProcessingTimeline(
            steps: [
              for (var i = 0; i < exchange.timeline.length; i++)
                WsTimelineStep(exchange.timeline[i], done: i < completed),
            ],
          ),
        ),
      _AnswerTurn(:final exchange) => _Answer(exchange: exchange, onAsk: onAsk),
    };
  }
}

class _Answer extends ConsumerWidget {
  const _Answer({required this.exchange, required this.onAsk});

  final AssistantExchange exchange;
  final ValueChanged<String> onAsk;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The same score the profile calculates — the assistant never quotes a
    // different number from the rest of the app, which is why the opening line
    // is built from this total rather than written into the fixture.
    final crs = ref.watch(crsResultProvider);
    final verdict = crsVerdict(crs.total);
    final revealed = ref.watch(crsRevealedProvider);
    final showScore = exchange.scoreCard && revealed;
    final lines =
        answerLines(exchange, crs.total, ref.watch(liningUpStreamsProvider));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WsChatBubble(
          speaker: WsSpeaker.other,
          avatar: const WsIconTile(
            icon: Icons.forum_rounded,
            size: WsTileSize.compact,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < lines.length; i++) ...[
                Text(lines[i]),
                if (i != lines.length - 1) const SizedBox(height: WsSpacing.md),
              ],
            ],
          ),
        ),
        // A score inside an answer renders as the real card, not as text —
        // once the candidate has asked for it.
        if (showScore) ...[
          WsScoreCard(
            icon: WsModule.crsPredictor.icon,
            title: 'Your CRS score',
            supporting: 'Comprehensive Ranking System',
            value: crs.total,
            maximum: crsMaximum,
            verdict: verdict.verdict,
            verdictLabel: verdict.label,
            contextLine: mockRecentDraws,
            brandFill: true,
            showDisclaimer: true,
          ),
          const SizedBox(height: WsSpacing.md),
        ],
        Padding(
          padding: const EdgeInsets.only(bottom: WsSpacing.sm),
          child: Text(
            'What next',
            style: context.text.labelLarge?.copyWith(color: context.ws.caption),
          ),
        ),
        // Follow-ups arrive after the answer and its score card have landed.
        for (final (i, followUp) in exchange.followUps.indexed)
          WsAppear(
            delay: 0.35 + i * 0.1,
            duration: WsMotion.entranceSequence,
            child: WsSuggestionRow(
              question: followUp,
              onTap: () => onAsk(followUp),
            ),
          ),
        const SizedBox(height: WsSpacing.sm),
        WsSecondaryButton(
          label: 'Save this to my profile',
          icon: Icons.bookmark_border_rounded,
          expand: false,
          // TODO(backend): nothing is saved; the saved list is a fixture.
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Saved to your profile')),
          ),
        ),
        const SizedBox(height: WsSpacing.xl),
      ],
    );
  }
}
