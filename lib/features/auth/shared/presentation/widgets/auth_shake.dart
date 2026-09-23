import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../app/theme/theme.dart';

/// Shakes its child sideways each time [trigger] changes — the physical "no"
/// for a rejected code or password. Skipped when the OS asks for reduced
/// motion; the error text below the field carries the message either way.
class AuthShake extends StatefulWidget {
  const AuthShake({required this.trigger, required this.child, super.key});

  /// Bump this to play the shake once.
  final int trigger;
  final Widget child;

  @override
  State<AuthShake> createState() => _AuthShakeState();
}

class _AuthShakeState extends State<AuthShake>
    with SingleTickerProviderStateMixin {
  static const double _amplitude = 8;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: WsMotion.slow,
  );

  @override
  void didUpdateWidget(AuthShake oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger != oldWidget.trigger && !WsMotion.reduced(context)) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final t = _controller.value;
        // Three decaying swings, ending exactly at rest.
        final dx = math.sin(t * math.pi * 6) * _amplitude * (1 - t);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
    );
  }
}
