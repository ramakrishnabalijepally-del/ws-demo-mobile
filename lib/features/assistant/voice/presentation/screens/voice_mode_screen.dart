import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../app/theme/theme.dart';
import '../../../../../shared/shared.dart';
import '../../../data/mock_assistant.dart';

/// L6–L7 — voice mode.
///
/// **The screen inverts to Grey 950 in both themes.** It is the one place the
/// light and dark themes converge rather than invert, and the only dark screen
/// after onboarding (design system section 15).
///
/// Because the ground is fixed rather than themed, every colour on this screen
/// comes from the voice tokens — not from `colorScheme`, which would flip.
class VoiceModeScreen extends StatefulWidget {
  const VoiceModeScreen({super.key});

  @override
  State<VoiceModeScreen> createState() => _VoiceModeScreenState();
}

class _VoiceModeScreenState extends State<VoiceModeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveform = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  bool _listening = false;
  bool _answered = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (WsMotion.reduced(context)) {
      _waveform.stop();
    } else if (_listening && !_waveform.isAnimating) {
      _waveform.repeat();
    }
  }

  @override
  void dispose() {
    _waveform.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_listening) {
      setState(() {
        _listening = false;
        _answered = true;
      });
      _waveform.stop();
      return;
    }

    setState(() {
      _listening = true;
      _answered = false;
    });
    if (!WsMotion.reduced(context)) _waveform.repeat();

    // TODO(backend): no speech recognition. The listen resolves on its own so
    // the answered state is reachable.
    await Future<void>.delayed(const Duration(milliseconds: 3200));
    if (!mounted || !_listening) return;
    setState(() {
      _listening = false;
      _answered = true;
    });
    _waveform.stop();
  }

  @override
  Widget build(BuildContext context) {
    final ws = context.ws;
    final exchange = mockExchanges.first;

    // The status bar has to invert with the screen, and this is one of the few
    // places brightness may legitimately be read directly.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: ws.voiceGround,
        appBar: AppBar(
          backgroundColor: ws.voiceGround,
          foregroundColor: ws.voiceForeground,
          title: Text(
            'Voice mode',
            style: context.text.titleMedium?.copyWith(
              color: ws.voiceForeground,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: WsSpacing.gutter,
            child: Column(
              children: [
                const Spacer(),
                if (_answered)
                  Text(
                    exchange.answer.first,
                    style: context.text.bodyMedium
                        ?.copyWith(color: ws.voiceForeground),
                    textAlign: TextAlign.center,
                  )
                else
                  Text(
                    _listening ? 'Listening…' : 'Tap to speak',
                    style: context.text.headlineLarge
                        ?.copyWith(color: ws.voiceForeground),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: WsSpacing.huge),
                SizedBox(
                  height: 96,
                  child: RepaintBoundary(
                    child: AnimatedBuilder(
                      animation: _waveform,
                      builder: (context, _) => CustomPaint(
                        size: const Size(double.infinity, 96),
                        painter: _WaveformPainter(
                          phase: _waveform.value,
                          active: _listening,
                          color: context.colors.primary,
                          idle: ws.voiceForeground.withValues(alpha: 0.25),
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Semantics(
                  button: true,
                  label: _listening ? 'Stop listening' : 'Start speaking',
                  child: InkWell(
                    onTap: _toggle,
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.colors.primary,
                      ),
                      child: Icon(
                        _listening ? Icons.stop_rounded : Icons.mic_rounded,
                        size: 32,
                        color: context.colors.onPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: WsSpacing.xl),
                Text(
                  'Voice answers are the same as chat answers — based on your '
                  'profile, and initial rather than final.',
                  style: context.text.bodySmall?.copyWith(
                    color: ws.voiceForeground.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: WsSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  const _WaveformPainter({
    required this.phase,
    required this.active,
    required this.color,
    required this.idle,
  });

  final double phase;
  final bool active;
  final Color color;
  final Color idle;

  static const int _bars = 42;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = active ? color : idle
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3;

    final spacing = size.width / _bars;
    final centreY = size.height / 2;

    for (var i = 0; i < _bars; i++) {
      final x = spacing * (i + 0.5);
      // A settled bar height when idle, so the shape reads as a waveform even
      // with motion disabled.
      final wave = active
          ? math.sin((i / _bars * 4 * math.pi) + phase * 2 * math.pi)
          : math.sin(i / _bars * 3 * math.pi);
      final envelope = math.sin(i / _bars * math.pi);
      final height = (8 + wave.abs() * 34 * envelope).clamp(4.0, 46.0);

      canvas.drawLine(
        Offset(x, centreY - height / 2),
        Offset(x, centreY + height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter old) =>
      old.phase != phase || old.active != active;
}

/// L8 — saved conversations.
class SavedConversationsScreen extends StatelessWidget {
  const SavedConversationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved conversations')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          WsSpacing.xl,
          WsSpacing.lg,
          WsSpacing.xl,
          WsSpacing.xxxl,
        ),
        children: [
          for (final exchange in mockExchanges)
            Padding(
              padding: const EdgeInsets.only(bottom: WsSpacing.md),
              child: WsCard(
                onTap: () {},
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(exchange.question, style: context.text.titleMedium),
                    const SizedBox(height: WsSpacing.xs),
                    Text(
                      exchange.answer.first,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodySmall
                          ?.copyWith(color: context.ws.caption),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
