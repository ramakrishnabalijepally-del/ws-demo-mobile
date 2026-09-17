import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/routes.dart';
import '../../../../../app/theme/theme.dart';
import '../../../../../shared/controllers/crs_controller.dart';
import '../../../../../shared/data/mock_candidate.dart';
import '../../../../../shared/shared.dart';
import '../../../controllers/agent_notices.dart';
import '../../../data/mock_agent.dart';

/// The AI Agent tab — the middle destination in the bottom bar.
///
/// **The agent is not a chat box with a new name.** A chat waits to be asked;
/// this reads the whole profile and opens with what it has already noticed —
/// a passport about to expire, three jobs that match, a CRS gap worth closing.
/// Asking it something is one of the things you can do here, not the only one.
///
/// Appointments live here too: the agent is what works out that you need a
/// human, so booking one is the last step of its own flow rather than a row
/// buried in Settlement.
class AiAgentScreen extends ConsumerStatefulWidget {
  const AiAgentScreen({super.key});

  @override
  ConsumerState<AiAgentScreen> createState() => _AiAgentScreenState();
}

class _AiAgentScreenState extends ConsumerState<AiAgentScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: WsMotion.entranceSequence,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (WsMotion.reduced(context)) {
      _entrance.value = 1;
    } else if (_entrance.isDismissed) {
      _entrance.forward();
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final candidate = ref.watch(candidateProvider);
    final completion = ref.watch(profileCompletionProvider);
    final notices = ref.watch(agentNoticesProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const WsProfileButton(),
        leadingWidth: WsTouch.minTarget + WsSpacing.md,
        title: const Text('AI Agent'),
        actions: [
          IconButton(
            tooltip: 'Saved answers',
            onPressed: () => context.push(Routes.assistantSaved),
            icon: const Icon(Icons.bookmark_border_rounded),
          ),
          const SizedBox(width: WsSpacing.sm),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          WsSpacing.xl,
          WsSpacing.lg,
          WsSpacing.xl,
          WsSpacing.xxxl,
        ),
        children: [
          WsRiseIn(
            entrance: _entrance,
            end: 0.5,
            fromScale: 0.96,
            child: _AgentHeader(
              name: candidate.firstName,
              profileComplete: completion.next == null,
            ),
          ),
          const SizedBox(height: WsSpacing.xxxl),
          WsRiseIn(
            entrance: _entrance,
            begin: 0.15,
            end: 0.55,
            child: _SectionHeader(
              title: 'What I noticed',
              supporting: notices.isEmpty
                  ? 'Nothing needs you today — this is read from your profile, '
                      'so it changes as your profile does'
                  : '${notices.length} '
                      '${notices.length == 1 ? 'thing' : 'things'} worth your '
                      'attention, from your profile',
            ),
          ),
          const SizedBox(height: WsSpacing.md),
          for (final (i, notice) in notices.indexed)
            WsAppear(
              delay: 0.2 + i * 0.08,
              duration: WsMotion.entranceSequence,
              child: Padding(
                padding: const EdgeInsets.only(bottom: WsSpacing.md),
                child: _NoticeCard(notice: notice),
              ),
            ),
          const SizedBox(height: WsSpacing.xxl),
          WsAppear(
            delay: 0.5,
            duration: WsMotion.entranceSequence,
            child: _AskCard(onTap: () => context.push(Routes.assistantChat)),
          ),
          const SizedBox(height: WsSpacing.xxl),
          const WsAppear(
            delay: 0.6,
            duration: WsMotion.entranceSequence,
            child: _SectionHeader(
              title: 'When you need a person',
              supporting: 'The agent is not a lawyer, and says so',
            ),
          ),
          const SizedBox(height: WsSpacing.md),
          WsAppear(
            delay: 0.68,
            duration: WsMotion.entranceSequence,
            child: WsCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  WsListRow(
                    leading:
                        const WsIconTile(icon: Icons.event_available_rounded),
                    title: 'Appointments',
                    subtitle: 'Consultations with licensed RCICs',
                    onTap: () => context.push(Routes.appointments),
                  ),
                  Divider(color: context.colors.outlineVariant, height: 1),
                  WsListRow(
                    leading: const WsIconTile(icon: Icons.graphic_eq_rounded),
                    title: 'Voice mode',
                    subtitle: 'Ask out loud, hands free',
                    onTap: () => context.push(Routes.assistantVoice),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: WsSpacing.xl),
          const WsDisclaimer(),
        ],
      ),
    );
  }
}

/// The agent's mark, a plain statement of what it does, and what it can see.
class _AgentHeader extends StatelessWidget {
  const _AgentHeader({required this.name, required this.profileComplete});

  final String name;
  final bool profileComplete;

  @override
  Widget build(BuildContext context) {
    return WsCard(
      raised: true,
      padding: const EdgeInsets.all(WsSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const WsAgentMark(),
              const SizedBox(width: WsSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Working on it, $name',
                      style: context.text.titleLarge,
                    ),
                    const SizedBox(height: WsSpacing.xs),
                    const WsPresence(label: 'Watching your profile'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: WsSpacing.lg),
          Text(
            profileComplete
                ? 'Your profile is complete, so everything below is based on '
                    'the full picture.'
                : 'The more of your profile you fill in, the more I can spot '
                    'before it becomes a problem.',
            style: context.text.bodySmall?.copyWith(color: context.ws.caption),
          ),
          const SizedBox(height: WsSpacing.lg),
          // Rows rather than a Wrap of pills: a pill sizes to its own text, so
          // "Matches jobs to your skills" runs off a 360 dp phone long before
          // 200% text scaling gets near it.
          for (final (i, capability) in mockAgentCapabilities.indexed)
            Padding(
              padding: EdgeInsets.only(
                bottom:
                    i == mockAgentCapabilities.length - 1 ? 0 : WsSpacing.sm,
              ),
              child: _CapabilityRow(
                icon: capability.icon,
                label: capability.label,
              ),
            ),
        ],
      ),
    );
  }
}

class _CapabilityRow extends StatelessWidget {
  const _CapabilityRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: WsIconSize.field, color: context.ws.caption),
        const SizedBox(width: WsSpacing.md),
        Expanded(
          child: Text(
            label,
            style: context.text.bodySmall?.copyWith(color: context.ws.caption),
          ),
        ),
      ],
    );
  }
}

/// One thing the agent noticed. The urgent one is the single selected card on
/// the screen — a 2 px red border says "start here" without adding a colour.
class _NoticeCard extends StatelessWidget {
  const _NoticeCard({required this.notice});

  final AgentNotice notice;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WsIconTile(icon: notice.icon, brand: notice.urgent),
            const SizedBox(width: WsSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (notice.urgent)
                    Text(
                      'Worth doing first',
                      style: context.text.labelLarge
                          ?.copyWith(color: context.ws.redOnSurface),
                    ),
                  Text(notice.title, style: context.text.titleMedium),
                  const SizedBox(height: 2),
                  Text(
                    notice.detail,
                    style: context.text.bodySmall
                        ?.copyWith(color: context.ws.caption),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: WsSpacing.md),
        Align(
          alignment: Alignment.centerLeft,
          child: WsLink(
            label: notice.actionLabel,
            underline: false,
            onPressed: () => context.push(notice.route),
          ),
        ),
      ],
    );

    return notice.urgent
        ? WsSelectionCard(
            selected: true,
            semanticLabel: 'Worth doing first: ${notice.title}',
            onTap: () => context.push(notice.route),
            child: content,
          )
        : WsCard(onTap: () => context.push(notice.route), child: content);
  }
}

/// The way into the conversation. Not a live composer — a second text field
/// for one question would be two sources of truth for the same thread.
class _AskCard extends StatelessWidget {
  const _AskCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return WsBanner(
      padding: const EdgeInsets.all(WsSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Ask me anything', style: context.text.titleLarge),
          const SizedBox(height: WsSpacing.xs),
          Text(
            'Jobs, immigration, settling in. Answers use your profile, so they '
            'are about your situation rather than the general case.',
            style: context.text.bodySmall
                ?.copyWith(color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(height: WsSpacing.lg),
          WsPrimaryButton(label: 'Start a conversation', onPressed: onTap),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.supporting});

  final String title;
  final String? supporting;

  @override
  Widget build(BuildContext context) {
    final supporting = this.supporting;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: context.text.titleLarge),
        if (supporting != null) ...[
          const SizedBox(height: WsSpacing.xs),
          Text(
            supporting,
            style: context.text.bodySmall?.copyWith(color: context.ws.caption),
          ),
        ],
      ],
    );
  }
}
