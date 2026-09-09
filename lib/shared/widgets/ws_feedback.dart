import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/theme.dart';
import 'ws_buttons.dart';

/// Milestone screens. `design/worksettle-design-system.md` section 17.
///
/// Three moments get a full screen to themselves: account created, eligibility
/// confirmed, and subscription activated. Each is a centred glyph in a ring or
/// disc, a headline, one or two sentences, and a single forward action.
///
/// **A red ring marks a step completed; a solid ink circle marks a transaction
/// settled.** That is the whole rule — account creation and profile milestones
/// get the open red ring; money and eligibility outcomes get the filled ink
/// disc with a white check. **Open versus filled is the signal, not hue.**
enum WsMilestone {
  /// A step completed — account created, profile milestone.
  step,

  /// A transaction settled — payment taken, eligibility confirmed.
  settled,
}

class WsSuccessScreen extends StatelessWidget {
  const WsSuccessScreen({
    required this.milestone,
    required this.headline,
    required this.body,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.confetti = false,
    this.icon = Icons.check_rounded,
    super.key,
  });

  final WsMilestone milestone;
  final String headline;
  final String body;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  /// Scattered maple leaves and dots. **These three screens only**, and it
  /// respects reduced motion.
  final bool confetti;

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            if (confetti) const Positioned.fill(child: WsConfetti()),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: WsSpacing.xl,
                vertical: WsSpacing.xxl,
              ),
              child: Column(
                children: [
                  const Spacer(),
                  _Glyph(milestone: milestone, icon: icon),
                  const SizedBox(height: WsSpacing.xxl),
                  // Centred body copy is allowed here and on only two other
                  // screens in the product.
                  Text(
                    headline,
                    style: context.text.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: WsSpacing.md),
                  Text(
                    body,
                    style: context.text.bodyMedium
                        ?.copyWith(color: context.colors.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  WsPrimaryButton(label: primaryLabel, onPressed: onPrimary),
                  if (secondaryLabel != null) ...[
                    const SizedBox(height: WsSpacing.md),
                    WsSecondaryButton(
                      label: secondaryLabel!,
                      onPressed: onSecondary,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Glyph extends StatelessWidget {
  const _Glyph({required this.milestone, required this.icon});

  final WsMilestone milestone;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    const double size = 96;

    if (milestone == WsMilestone.settled) {
      // Filled ink disc, white check.
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.ws.verdictFilledSurface,
        ),
        child: Icon(icon, size: 44, color: context.ws.verdictFilledLabel),
      );
    }

    // Open red ring.
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.ws.redTint,
        border: Border.all(color: context.colors.primary, width: 3),
      ),
      child: Icon(icon, size: 44, color: context.colors.primary),
    );
  }
}

/// Scattered maple leaves and dots at 6–10 px.
///
/// Appears on three screens only — account created, eligibility confirmed,
/// subscription activated — and **respects reduced motion**: with motion
/// disabled the pieces are painted in their settled positions rather than
/// animated.
class WsConfetti extends StatefulWidget {
  const WsConfetti({this.pieceCount = 28, super.key});

  final int pieceCount;

  @override
  State<WsConfetti> createState() => _WsConfettiState();
}

class _WsConfettiState extends State<WsConfetti>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );

  late final List<_Piece> _pieces = _buildPieces(widget.pieceCount);

  static List<_Piece> _buildPieces(int count) {
    // A fixed seed: the celebration looks the same every time, which makes it
    // reviewable and keeps screenshot tests stable.
    final random = math.Random(20260908);
    return List.generate(count, (i) {
      return _Piece(
        x: random.nextDouble(),
        delay: random.nextDouble() * 0.4,
        size: 6 + random.nextDouble() * 4,
        drift: (random.nextDouble() - 0.5) * 0.2,
        spin: random.nextDouble() * math.pi * 2,
        isLeaf: i.isEven,
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (WsMotion.reduced(context)) {
      _controller.value = 1;
    } else if (!_controller.isAnimating && _controller.value == 0) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            painter: _ConfettiPainter(
              pieces: _pieces,
              progress: _controller.value,
              red: context.colors.primary,
              ink: context.colors.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _Piece {
  const _Piece({
    required this.x,
    required this.delay,
    required this.size,
    required this.drift,
    required this.spin,
    required this.isLeaf,
  });

  final double x;
  final double delay;
  final double size;
  final double drift;
  final double spin;
  final bool isLeaf;
}

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter({
    required this.pieces,
    required this.progress,
    required this.red,
    required this.ink,
  });

  final List<_Piece> pieces;
  final double progress;
  final Color red;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    for (final piece in pieces) {
      final t = ((progress - piece.delay) / (1 - piece.delay)).clamp(0.0, 1.0);
      if (t <= 0) continue;

      final dx = (piece.x + piece.drift * t) * size.width;
      final dy = t * size.height * 0.9;
      final paint = Paint()
        ..color =
            (piece.isLeaf ? red : ink).withValues(alpha: 0.85 * (1 - t * 0.4));

      canvas.save();
      canvas.translate(dx, dy);
      canvas.rotate(piece.spin + t * math.pi * 2);
      if (piece.isLeaf) {
        // A maple leaf reads as a leaf at 10 px only as a silhouette; a
        // rounded diamond is the honest simplification at this size.
        final path = Path()
          ..moveTo(0, -piece.size / 2)
          ..lineTo(piece.size / 2, 0)
          ..lineTo(0, piece.size / 2)
          ..lineTo(-piece.size / 2, 0)
          ..close();
        canvas.drawPath(path, paint);
      } else {
        canvas.drawCircle(Offset.zero, piece.size / 3, paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}

/// The empty state. Section 23 lists these as not yet defined by the client, so
/// this is a conservative build: a quiet glyph, a headline, a sentence, and an
/// optional way out. **Never styled as a failure** — nothing here is the
/// reader's fault.
class WsEmptyState extends StatelessWidget {
  const WsEmptyState({
    required this.icon,
    required this.headline,
    required this.body,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final IconData icon;
  final String headline;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(WsSpacing.huge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.ws.verdictTintedSurface,
              ),
              child: Icon(icon, size: 28, color: context.ws.caption),
            ),
            const SizedBox(height: WsSpacing.xl),
            Text(
              headline,
              style: context.text.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: WsSpacing.sm),
            Text(
              body,
              style: context.text.bodyMedium
                  ?.copyWith(color: context.colors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: WsSpacing.xl),
              WsSecondaryButton(
                label: actionLabel!,
                onPressed: onAction,
                expand: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
