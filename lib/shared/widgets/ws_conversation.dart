/// Conversation. `design/worksettle-design-system.md` section 15.
///
/// The only place in the product where a bubble inverts against the screen it
/// sits on. **The user's words are ink; the assistant's are on the neutral
/// ground — the assistant never speaks in brand red.** Both roles hold in
/// dark, where the user's bubble becomes near-white with dark text: the
/// relationship survives, the colours swap.
///
/// The same components carry the recruiter chat, which is the same shape with
/// different data.
library;

import 'package:flutter/material.dart';

import '../../app/theme/theme.dart';
import 'ws_buttons.dart';

enum WsSpeaker {
  /// Ink fill, surface-coloured text, right-aligned, 16/16/4/16.
  user,

  /// Neutral fill, ink text, left-aligned, 16/16/16/4.
  other,
}

class WsChatBubble extends StatelessWidget {
  const WsChatBubble({
    required this.speaker,
    required this.child,
    this.avatar,
    super.key,
  });

  // Not const: the child is built from a runtime string.
  WsChatBubble.text({
    required this.speaker,
    required String text,
    this.avatar,
    super.key,
  }) : child = _BubbleText(text);

  final WsSpeaker speaker;
  final Widget child;

  /// The robot avatar beside an assistant bubble.
  final Widget? avatar;

  static const double _maxWidthFraction = 0.78;

  @override
  Widget build(BuildContext context) {
    final isUser = speaker == WsSpeaker.user;

    final bubble = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width * _maxWidthFraction,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: WsSpacing.lg,
        vertical: WsSpacing.md,
      ),
      decoration: BoxDecoration(
        color: isUser
            ? context.colors.inverseSurface
            : context.colors.surfaceContainerHighest,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(WsRadii.card),
          topRight: const Radius.circular(WsRadii.card),
          bottomLeft: Radius.circular(isUser ? WsRadii.card : WsSpacing.xs),
          bottomRight: Radius.circular(isUser ? WsSpacing.xs : WsRadii.card),
        ),
      ),
      child: DefaultTextStyle(
        style: context.text.bodyMedium!.copyWith(
          color: isUser
              ? context.colors.onInverseSurface
              : context.colors.onSurface,
        ),
        child: child,
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: WsSpacing.md),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser && avatar != null) ...[
            avatar!,
            const SizedBox(width: WsSpacing.sm),
          ],
          Flexible(child: bubble),
        ],
      ),
    );
  }
}

class _BubbleText extends StatelessWidget {
  const _BubbleText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(text);
}

/// Three 7 px dots on a 1.2 s stagger. **Replaced by the processing timeline
/// for anything over about two seconds** — a wait long enough to notice
/// deserves to be told what is happening.
class WsTypingDots extends StatefulWidget {
  const WsTypingDots({super.key});

  @override
  State<WsTypingDots> createState() => _WsTypingDotsState();
}

class _WsTypingDotsState extends State<WsTypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: WsMotion.typingCycle,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (WsMotion.reduced(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'WorkSettle is typing',
      child: WsChatBubble(
        speaker: WsSpeaker.other,
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                final t = (_controller.value + i / 3) % 1;
                final opacity = 0.3 + 0.7 * (1 - (t * 2 - 1).abs());
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.ws.placeholder.withValues(alpha: opacity),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

/// A full-width suggested question. Six to eight on the empty state.
class WsSuggestionRow extends StatelessWidget {
  const WsSuggestionRow({
    required this.question,
    required this.onTap,
    super.key,
  });

  final String question;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: WsSpacing.sm),
      child: Material(
        color: context.colors.surface,
        borderRadius: WsRadii.fieldR,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: WsTouch.minTarget),
            padding: const EdgeInsets.symmetric(
              horizontal: WsSpacing.lg,
              vertical: WsSpacing.md,
            ),
            decoration: BoxDecoration(
              borderRadius: WsRadii.fieldR,
              border: Border.all(color: context.colors.outlineVariant),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    question,
                    style: context.text.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: WsSpacing.sm),
                Icon(
                  Icons.chevron_right_rounded,
                  size: WsIconSize.chevron + 4,
                  color: context.ws.placeholder,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Attach glyph, Grey 100 pill input, 44 px red circular send.
class WsComposer extends StatelessWidget {
  const WsComposer({
    required this.controller,
    required this.onSend,
    this.hint = 'Type message…',
    this.onAttach,
    this.onMic,
    super.key,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final String hint;
  final VoidCallback? onAttach;
  final VoidCallback? onMic;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        WsSpacing.lg,
        WsSpacing.md,
        WsSpacing.lg,
        WsSpacing.md,
      ),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(top: BorderSide(color: context.colors.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (onAttach != null)
              IconButton(
                onPressed: onAttach,
                icon: const Icon(Icons.attach_file_rounded),
                color: context.ws.placeholder,
                tooltip: 'Attach a file',
              ),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(minHeight: 44),
                padding: const EdgeInsets.symmetric(horizontal: WsSpacing.lg),
                decoration: BoxDecoration(
                  color: context.colors.surfaceContainerHighest,
                  borderRadius: WsRadii.pillR,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        style: context.text.bodyMedium,
                        minLines: 1,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: hint,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          hintStyle: context.text.bodyMedium
                              ?.copyWith(color: context.ws.placeholder),
                        ),
                      ),
                    ),
                    if (onMic != null)
                      IconButton(
                        onPressed: onMic,
                        icon: const Icon(Icons.mic_none_rounded, size: 20),
                        color: context.ws.placeholder,
                        tooltip: 'Voice mode',
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: WsSpacing.sm),
            WsSendButton(onPressed: onSend),
          ],
        ),
      ),
    );
  }
}

/// A 7 px ink dot plus "Online · Based on Your Profile" at 11.5/600.
class WsPresence extends StatelessWidget {
  const WsPresence({this.label = 'Online · Based on Your Profile', super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.colors.onSurface,
          ),
        ),
        const SizedBox(width: WsSpacing.sm),
        Text(label, style: WsTypography.micro(context.ws.caption)),
      ],
    );
  }
}
