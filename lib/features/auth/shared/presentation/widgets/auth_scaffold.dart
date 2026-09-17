import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../app/theme/theme.dart';
import '../../../../../shared/shared.dart';
import 'auth_pattern.dart';

/// The shape every auth screen shares: a branded header — the logo on the red
/// tint, a halftone of Settle Red diamonds rippling in from the corner — with
/// the form on a white sheet that rises over it.
///
/// The whole thing scrolls as one, so the keyboard, a small phone or 200% text
/// never trap a field. Sign in and sign up both use it, which is why it lives
/// in `auth/shared/` rather than in either flow.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    required this.entrance,
    required this.child,
    this.onBack,
    super.key,
  });

  /// The screen's entrance timeline. The pattern, the logo and the sheet all
  /// take their windows from it.
  final Animation<double> entrance;

  /// The form, on the sheet.
  final Widget child;

  /// Null draws no back control — sign in is the root of the flow.
  final VoidCallback? onBack;

  /// The header never shrinks below this, even on a short phone.
  static const double _minHeader = 200;

  @override
  Widget build(BuildContext context) {
    final statusBar = MediaQuery.paddingOf(context).top;
    final onBack = this.onBack;

    return Scaffold(
      backgroundColor: context.ws.redTint,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final header = math.max(_minHeader, constraints.maxHeight * 0.3);

          return Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: header + WsRadii.card * 2,
                child: AuthPattern(reveal: entrance),
              ),
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: header,
                      child: Padding(
                        padding: EdgeInsets.only(top: statusBar),
                        child: Center(
                          child: WsRiseIn(
                            entrance: entrance,
                            end: 0.55,
                            fromScale: 0.9,
                            child: const WsWordmark(width: 200),
                          ),
                        ),
                      ),
                    ),
                    WsRiseIn(
                      entrance: entrance,
                      begin: 0.1,
                      end: 0.7,
                      child: _FormSheet(
                        minHeight: math.max(0, constraints.maxHeight - header),
                        reveal: entrance,
                        child: WsRiseIn(
                          entrance: entrance,
                          begin: 0.25,
                          end: 0.9,
                          child: child,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (onBack != null)
                Positioned(
                  left: WsSpacing.sm,
                  top: statusBar + WsSpacing.xs,
                  child: IconButton(
                    tooltip: 'Back',
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// The white sheet the form sits on: rounded top corners, lifted off the
/// header, filling to the bottom of the screen, with a faint echo of the
/// header's pattern in its lower corner.
class _FormSheet extends StatelessWidget {
  const _FormSheet({
    required this.minHeight,
    required this.reveal,
    required this.child,
  });

  final double minHeight;
  final Animation<double> reveal;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(WsRadii.card),
          ),
          boxShadow: WsShadows.floating,
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: WsSpacing.huge * 2,
              child: ClipRect(
                child: AuthPattern(
                  reveal: reveal,
                  corner: Alignment.bottomLeft,
                  spread: 0.35,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                WsSpacing.xl,
                WsSpacing.xxxl,
                WsSpacing.xl,
                WsSpacing.huge + bottomInset,
              ),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
