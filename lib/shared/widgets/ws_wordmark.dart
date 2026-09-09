import 'package:flutter/material.dart';

import '../../app/theme/theme.dart';

/// The WorkSettle lockup. `design/worksettle-design-system.md` section 1.
///
/// **The artwork is a fixed client asset: set it, scale it, but never redraw
/// it, re-letter it or re-colour it.** The files are `worksettle.svg` and
/// `worksettle-reverse.svg`.
///
/// Neither has been supplied yet, so this renders a clearly-marked text
/// placeholder in the meantime. That placeholder is **not** the logo and must
/// not survive to a release — it exists so screens can be laid out at the right
/// size before the vector arrives.
///
/// What the real mark carries, for whoever wires the asset up:
///
/// - Two-tone letters — **W** red, "ork" ink, **S** red, "ettle" ink. The split
///   falls inside each word, which is what makes the two capitals read as one
///   mark. It is *not* "Work" red and "Settle" black.
/// - A globe inside the **o** of "Work", part of the letterform.
/// - Three figures — one ink flanked by two red — in a break in the rule.
/// - A hairline rule the width of the wordmark.
/// - The tagline "Your Journey Starts Here" beneath, centred, bold, in ink.
///   **Never set in red.**
/// - Clear space of one cap height of the W on all four sides.
/// - Below 96 px wide: drop the tagline and the rule, set the wordmark alone.
class WsWordmark extends StatelessWidget {
  const WsWordmark({this.width = 160, this.reverse = false, super.key});

  /// Minimum on screen is 96. Below that the tagline and rule are dropped.
  final double width;

  /// The reversed lockup, for Grey 900 and darker grounds. Uses the supplied
  /// reversed file — never a filter over the primary one.
  final bool reverse;

  static const double _taglineThreshold = 96;

  @override
  Widget build(BuildContext context) {
    final showTagline = width >= _taglineThreshold;

    // TODO(assets): replace this whole subtree with the supplied SVG once
    // worksettle.svg / worksettle-reverse.svg land in assets/images/.
    final ink = reverse ? context.ws.voiceForeground : context.colors.onSurface;
    final red = reverse ? context.ws.redOnSurface : context.colors.primary;

    return Semantics(
      label: 'WorkSettle',
      image: true,
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: 'W', style: TextStyle(color: red)),
                    TextSpan(text: 'ork', style: TextStyle(color: ink)),
                    TextSpan(text: 'S', style: TextStyle(color: red)),
                    TextSpan(text: 'ettle', style: TextStyle(color: ink)),
                  ],
                ),
                style: context.text.headlineLarge?.copyWith(
                  fontSize: width * 0.19,
                  height: 1.1,
                ),
              ),
            ),
            if (showTagline) ...[
              const SizedBox(height: WsSpacing.xs),
              Row(
                children: [
                  Expanded(child: Divider(color: ink, height: 1)),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: WsSpacing.sm),
                    child: Icon(Icons.groups_rounded, size: 12, color: red),
                  ),
                  Expanded(child: Divider(color: ink, height: 1)),
                ],
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Your Journey Starts Here',
                  style: context.text.labelSmall?.copyWith(
                    color: ink,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The positioning line, with its fixed emphasis.
///
/// *"Canada's first AI platform for **Work & Immigration** settlement."* — only
/// those three words take the red, and **the emphasis is part of the sentence,
/// not a free highlight.** Never colour a whole line.
class WsPositioningLine extends StatelessWidget {
  const WsPositioningLine({this.textAlign = TextAlign.center, super.key});

  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: context.text.headlineLarge,
        children: [
          const TextSpan(text: "Canada's first AI platform for "),
          TextSpan(
            text: 'Work & Immigration',
            style: TextStyle(color: context.ws.redOnSurface),
          ),
          const TextSpan(text: ' settlement.'),
        ],
      ),
      textAlign: textAlign,
    );
  }
}

/// A headline where one span carries the red — the onboarding pattern
/// ("Find Your **Dream** Job").
class WsEmphasisHeadline extends StatelessWidget {
  const WsEmphasisHeadline({
    required this.before,
    required this.emphasis,
    this.after = '',
    this.textAlign = TextAlign.center,
    super.key,
  });

  final String before;
  final String emphasis;
  final String after;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: context.text.headlineLarge,
        children: [
          TextSpan(text: before),
          TextSpan(
            text: emphasis,
            style: TextStyle(color: context.ws.redOnSurface),
          ),
          TextSpan(text: after),
        ],
      ),
      textAlign: textAlign,
    );
  }
}
