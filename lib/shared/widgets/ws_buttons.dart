/// Buttons. `design/worksettle-design-system.md` section 8.
///
/// **Every button is a full pill.** The product is a linear journey, so the
/// primary action is almost always full width, pinned to the bottom, with a
/// trailing arrow — **the arrow means "this moves you forward"** and is dropped
/// on actions that stay on the same screen.
///
/// **Two primary buttons never appear on one screen.**
library;

import 'package:flutter/material.dart';

import '../../app/theme/theme.dart';

/// The one forward action per screen. Settle Red fill, white label, and a red
/// shadow so it lifts off a white ground.
class WsPrimaryButton extends StatefulWidget {
  const WsPrimaryButton({
    required this.label,
    required this.onPressed,
    this.forward = true,
    this.isLoading = false,
    this.expand = true,
    this.icon,
    super.key,
  });

  final String label;

  /// Null disables the button — 45% opacity, not interactive.
  final VoidCallback? onPressed;

  /// Show the trailing arrow. Drop it when the action stays on this screen.
  final bool forward;

  /// The label swaps for a three-dot pulse and the width is held, so the
  /// layout does not jump.
  final bool isLoading;

  /// Full width in flows; inline in cards.
  final bool expand;

  /// An optional leading glyph.
  final IconData? icon;

  @override
  State<WsPrimaryButton> createState() => _WsPrimaryButtonState();
}

class _WsPrimaryButtonState extends State<WsPrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.isLoading;

    final button = FilledButton(
      onPressed: enabled ? widget.onPressed : null,
      child: widget.isLoading
          ? _PulsingDots(color: context.colors.onPrimary)
          : Row(
              mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, size: WsIconSize.buttonArrow),
                  const SizedBox(width: WsSpacing.sm),
                ],
                Flexible(
                  child: Text(
                    widget.label,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
                if (widget.forward) ...[
                  const SizedBox(width: WsSpacing.sm),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: WsIconSize.buttonArrow,
                  ),
                ],
              ],
            ),
    );

    // The shadow is the button's own, not the theme's — it drops on press.
    return Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: WsMotion.duration(context, WsMotion.fast),
        decoration: BoxDecoration(
          borderRadius: WsRadii.pillR,
          boxShadow: enabled && !_pressed
              ? WsShadows.primaryButton
              : const <BoxShadow>[],
        ),
        child: widget.expand
            ? SizedBox(width: double.infinity, child: button)
            : button,
      ),
    );
  }
}

/// The alternative route — voice instead of chat, detail instead of save.
/// Sits beneath a primary, never beside it as an equal.
class WsSecondaryButton extends StatelessWidget {
  const WsSecondaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final button = OutlinedButton(
      onPressed: onPressed,
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: WsIconSize.buttonArrow),
            const SizedBox(width: WsSpacing.sm),
          ],
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Back, Cancel. Never sits alone.
class WsGhostButton extends StatelessWidget {
  const WsGhostButton({
    required this.label,
    required this.onPressed,
    this.expand = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final button = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: context.colors.onSurface,
        side: BorderSide(color: context.colors.outlineVariant, width: 1.5),
        textStyle: WsTypography.button(context.colors.onSurface),
      ),
      child: Text(label),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Escape hatches — "Sign In", "Skip", "Go to Dashboard". Underlined red.
class WsLink extends StatelessWidget {
  const WsLink({
    required this.label,
    required this.onPressed,
    this.underline = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool underline;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: WsSpacing.sm),
        minimumSize: const Size(0, WsTouch.minTarget),
      ),
      child: Text(
        label,
        style: WsTypography.button(context.ws.redOnSurface).copyWith(
          fontSize: 14,
          decoration: underline ? TextDecoration.underline : null,
          decorationColor: context.ws.redOnSurface,
        ),
      ),
    );
  }
}

/// Chat send. **The only circular button in the system.**
class WsSendButton extends StatelessWidget {
  const WsSendButton({required this.onPressed, this.enabled = true, super.key});

  final VoidCallback? onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Send message',
      child: SizedBox(
        width: 44,
        height: 44,
        child: Material(
          color: enabled
              ? context.colors.primary
              : context.colors.primary.withValues(alpha: 0.45),
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            child: Icon(
              Icons.arrow_upward_rounded,
              size: 20,
              color: context.colors.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

/// The loading state: the label swaps for a three-dot pulse at held width.
class _PulsingDots extends StatefulWidget {
  const _PulsingDots({required this.color});

  final Color color;

  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: WsMotion.typingCycle,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // MediaQuery is not available in initState, and the reduced-motion setting
    // can change while the app is running.
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
      label: 'Loading',
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              final t = (_controller.value + i / 3) % 1;
              final opacity = 0.35 + 0.65 * (1 - (t * 2 - 1).abs());
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withValues(alpha: opacity),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
