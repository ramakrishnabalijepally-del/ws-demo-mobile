import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/routes.dart';
import '../../../../../app/theme/theme.dart';
import '../../../../../shared/shared.dart';
import '../../../data/mock_chat.dart';

/// I1–I3 — the message list, with swipe-to-archive.
class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  static const List<String> _filters = ['All', 'Unread', 'Archived'];
  String _filter = 'All';

  /// Archiving is in-memory: the fixture's own flag plus whatever the reader
  /// does in this session.
  final Set<String> _archived = {
    for (final t in mockChatThreads)
      if (t.archived) t.id,
  };

  List<ChatThread> get _threads => mockChatThreads.where((t) {
        final isArchived = _archived.contains(t.id);
        return switch (_filter) {
          'Unread' => !isArchived && t.unread > 0,
          'Archived' => isArchived,
          _ => !isArchived,
        };
      }).toList();

  @override
  Widget build(BuildContext context) {
    final threads = _threads;

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: Column(
        children: [
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: WsSpacing.gutter,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: WsSpacing.sm),
              itemBuilder: (context, i) => ChoiceChip(
                label: Text(_filters[i]),
                selected: _filter == _filters[i],
                onSelected: (_) => setState(() => _filter = _filters[i]),
                labelStyle: WsTypography.chip(
                  _filter == _filters[i]
                      ? context.colors.onPrimary
                      : context.colors.onSurface,
                ),
              ),
            ),
          ),
          Expanded(
            child: threads.isEmpty
                ? WsEmptyState(
                    icon: Icons.chat_bubble_outline_rounded,
                    headline: _filter == 'Archived'
                        ? 'Nothing archived'
                        : 'No messages yet',
                    body: 'When an employer replies to an application, the '
                        'conversation starts here.',
                    actionLabel: 'See applications',
                    onAction: () => context.push(Routes.applications),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(top: WsSpacing.sm),
                    itemCount: threads.length,
                    separatorBuilder: (_, __) => Divider(
                      color: context.colors.outlineVariant,
                      height: 1,
                    ),
                    itemBuilder: (context, i) {
                      final thread = threads[i];
                      return Dismissible(
                        key: ValueKey(thread.id),
                        direction: DismissDirection.endToStart,
                        background: const _ArchiveBackground(),
                        confirmDismiss: (_) => _confirmArchive(context, thread),
                        onDismissed: (_) =>
                            setState(() => _archived.add(thread.id)),
                        child: WsListRow(
                          leading: WsIconTile(
                            icon: Icons.business_rounded,
                            brand: thread.unread > 0,
                          ),
                          title: thread.company,
                          subtitle: thread.preview,
                          trailing: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                thread.time,
                                style: context.text.bodySmall
                                    ?.copyWith(color: context.ws.caption),
                              ),
                              if (thread.unread > 0) ...[
                                const SizedBox(height: WsSpacing.xs),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: context.colors.primary,
                                    borderRadius: WsRadii.pillR,
                                  ),
                                  child: Text(
                                    '${thread.unread}',
                                    style: WsTypography.chip(
                                      context.colors.onPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          onTap: () => context.push(
                            Routes.withId(Routes.chatThread, thread.id),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  static Future<bool> _confirmArchive(
    BuildContext context,
    ChatThread thread,
  ) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            WsSpacing.xl,
            WsSpacing.sm,
            WsSpacing.xl,
            WsSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Archive this conversation?',
                style: context.text.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: WsSpacing.sm),
              Text(
                'Your thread with ${thread.company} moves to Archived. Nothing '
                'is deleted and you can open it again from the filter.',
                style: context.text.bodyMedium
                    ?.copyWith(color: context.colors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: WsSpacing.xxl),
              WsPrimaryButton(
                label: 'Archive',
                forward: false,
                onPressed: () => Navigator.of(context).pop(true),
              ),
              const SizedBox(height: WsSpacing.md),
              WsGhostButton(
                label: 'Cancel',
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        ),
      ),
    );
    return confirmed ?? false;
  }
}

class _ArchiveBackground extends StatelessWidget {
  const _ArchiveBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: WsSpacing.xl),
      color: context.ws.verdictTintedSurface,
      child: Icon(
        Icons.archive_outlined,
        color: context.colors.onSurface,
        semanticLabel: 'Archive',
      ),
    );
  }
}

/// I4–I5 — one thread.
///
/// Same bubble components as the AI assistant, different data: user bubbles are
/// ink and right-aligned, the recruiter's are neutral and left-aligned
/// (design system section 15).
class ChatThreadScreen extends StatefulWidget {
  const ChatThreadScreen({required this.threadId, super.key});

  final String threadId;

  @override
  State<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends State<ChatThreadScreen> {
  final TextEditingController _composer = TextEditingController();
  final List<ChatMessage> _sent = [];

  @override
  void dispose() {
    _composer.dispose();
    super.dispose();
  }

  void _send() {
    final text = _composer.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _sent.add(ChatMessage(text: text, fromMe: true, time: 'Now'));
      _composer.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final thread =
        mockChatThreads.where((t) => t.id == widget.threadId).firstOrNull;

    if (thread == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Messages')),
        body: WsEmptyState(
          icon: Icons.chat_bubble_outline_rounded,
          headline: 'That conversation has gone',
          body: 'It may have been archived or removed.',
          actionLabel: 'Back to messages',
          onAction: () => context.pop(),
        ),
      );
    }

    final messages = [...thread.messages, ..._sent];

    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(thread.company, style: context.text.titleMedium),
            if (thread.online)
              WsPresence(label: '${thread.contactName} · Online'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Video call',
            onPressed: () =>
                context.push(Routes.withId(Routes.call, thread.id)),
            icon: const Icon(Icons.videocam_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                WsSpacing.xl,
                WsSpacing.lg,
                WsSpacing.xl,
                WsSpacing.lg,
              ),
              children: [
                for (final message in messages) ...[
                  WsChatBubble.text(
                    speaker: message.fromMe ? WsSpeaker.user : WsSpeaker.other,
                    text: message.text,
                    avatar: message.fromMe
                        ? null
                        : const WsIconTile(
                            icon: Icons.business_rounded,
                            size: WsTileSize.compact,
                          ),
                  ),
                  if (message.action != null)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 48,
                        bottom: WsSpacing.lg,
                      ),
                      child: WsSecondaryButton(
                        label: message.action!,
                        icon: Icons.videocam_rounded,
                        expand: false,
                        onPressed: () => context.push(
                          Routes.withId(Routes.call, thread.id),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
          WsComposer(
            controller: _composer,
            onSend: _send,
            onAttach: () {},
          ),
        ],
      ),
    );
  }
}

/// I6–I7 — the call screen: connecting, then in progress.
class CallScreen extends StatefulWidget {
  const CallScreen({required this.threadId, super.key});

  final String threadId;

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  bool _connected = false;
  bool _speaker = true;

  /// Held so it can be cancelled: a `Future.delayed` guarded by `mounted`
  /// still leaves a live timer behind when the screen is popped early.
  Timer? _connectTimer;

  @override
  void initState() {
    super.initState();
    // TODO(backend): there is no call. This resolves so the connected state is
    // reachable without a real signalling stack.
    _connectTimer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) setState(() => _connected = true);
    });
  }

  @override
  void dispose() {
    _connectTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final thread =
        mockChatThreads.where((t) => t.id == widget.threadId).firstOrNull;
    final title = thread?.company ?? 'Interview';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            const WsIconTile(
              icon: Icons.business_rounded,
              size: WsTileSize.header,
            ),
            const SizedBox(height: WsSpacing.xl),
            Text(title, style: context.text.titleLarge),
            const SizedBox(height: WsSpacing.sm),
            Text(
              _connected ? '04:37' : 'Connecting…',
              style: _connected
                  ? context.text.displaySmall
                  : context.text.bodyMedium
                      ?.copyWith(color: context.colors.onSurfaceVariant),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _CallButton(
                  icon: Icons.call_end_rounded,
                  label: 'End call',
                  destructive: true,
                  onTap: () => context.pop(),
                ),
                const SizedBox(width: WsSpacing.xxl),
                _CallButton(
                  icon: _speaker
                      ? Icons.volume_up_rounded
                      : Icons.volume_off_rounded,
                  label: _speaker ? 'Speaker on' : 'Speaker off',
                  onTap: () => setState(() => _speaker = !_speaker),
                ),
              ],
            ),
            const SizedBox(height: WsSpacing.huge),
          ],
        ),
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  const _CallButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// Ending a call is the one action in the product that is genuinely
  /// destructive-adjacent, and it takes the brand red because it is also the
  /// primary action on this screen.
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: destructive
                ? context.colors.primary
                : context.ws.verdictTintedSurface,
          ),
          child: Icon(
            icon,
            size: 26,
            color: destructive
                ? context.colors.onPrimary
                : context.colors.onSurface,
          ),
        ),
      ),
    );
  }
}
