import 'package:flutter/material.dart';

import '../../../../app/theme/theme.dart';
import '../../../../shared/shared.dart';
import '../../animations/onboarding_motion.dart';
import '../../data/mock_onboarding.dart';
import 'flight_arc.dart';
import 'scene_cards.dart';

/// The visual half of a slide: a tilted plate, the photograph, and two product
/// cards floating over it.
///
/// Three depths move at three speeds while the page is dragged — the plate
/// turns, the photo lags behind the finger, the cards run ahead of it — so a
/// swipe reads as moving through a scene rather than sliding a flat image.
class SlideStage extends StatelessWidget {
  const SlideStage({
    required this.slide,
    required this.pageOffset,
    required this.entrance,
    required this.float,
    super.key,
  });

  final OnboardingSlide slide;

  /// −1…1: how far this page sits from the centre of the viewport.
  final double pageOffset;

  final Animation<double> entrance;
  final Animation<double> float;

  /// The route across the immigration photo: from the lower left, arcing up
  /// and landing on the upper right.
  static const _route = FlightPoints(
    start: Offset(0.14, 0.82),
    control1: Offset(0.18, 0.28),
    control2: Offset(0.62, 0.02),
    end: Offset(0.84, 0.3),
  );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final offset = pageOffset.clamp(-1.0, 1.0);
        final cardWidth = width * 0.62;
        const photoInsets = EdgeInsets.fromLTRB(
          WsSpacing.xxxl,
          WsSpacing.md,
          WsSpacing.xxxl,
          WsSpacing.xxxl,
        );

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Back plate: gives the photo a second layer to turn against.
            Positioned.fill(
              child: Padding(
                padding: photoInsets,
                child: Transform.rotate(
                  angle: -0.07 + offset * 0.1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: context.ws.moduleTint,
                      borderRadius: WsRadii.cardR,
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: photoInsets,
                child: Transform.translate(
                  offset: Offset(offset * width * 0.3, 0),
                  child: Transform.scale(
                    scale: 1 - offset.abs() * 0.06,
                    child: ClipRRect(
                      borderRadius: WsRadii.cardR,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          WsHeroImage(
                            hero: slide.hero,
                            alignment: Alignment.center,
                            semanticLabel:
                                '${slide.before}${slide.emphasis}${slide.after}',
                          ),
                          if (slide.scene == OnboardingScene.immigration)
                            AnimatedBuilder(
                              animation: entrance,
                              builder: (context, _) => FlightArc(
                                points: _route,
                                progress: staggered(entrance.value, 0.05, 0.75),
                                pathColor: context.colors.onPrimary,
                                planeColor: context.colors.onPrimary,
                                destinationColor: context.colors.primary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: WsSpacing.huge,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: cardWidth),
                child: WsRiseIn(
                  entrance: entrance,
                  begin: 0.2,
                  end: 0.7,
                  fromScale: 0.92,
                  float: float,
                  drift: -offset * width * 0.2,
                  child: _LeadCard(scene: slide.scene, entrance: entrance),
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: cardWidth),
                child: WsRiseIn(
                  entrance: entrance,
                  begin: 0.35,
                  end: 0.85,
                  fromScale: 0.92,
                  float: float,
                  floatPhase: -1,
                  drift: -offset * width * 0.12,
                  child: _SupportCard(scene: slide.scene, entrance: entrance),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LeadCard extends StatelessWidget {
  const _LeadCard({required this.scene, required this.entrance});

  final OnboardingScene scene;
  final Animation<double> entrance;

  @override
  Widget build(BuildContext context) {
    return switch (scene) {
      OnboardingScene.immigration => CrsScoreCard(entrance: entrance),
      OnboardingScene.jobs => const VerifiedEmployerCard(),
      OnboardingScene.profile => ProfileStrengthCard(entrance: entrance),
    };
  }
}

class _SupportCard extends StatelessWidget {
  const _SupportCard({required this.scene, required this.entrance});

  final OnboardingScene scene;
  final Animation<double> entrance;

  @override
  Widget build(BuildContext context) {
    return switch (scene) {
      OnboardingScene.immigration => const RoutesCard(),
      OnboardingScene.jobs => const JobMatchCard(),
      OnboardingScene.profile => ChecklistCard(entrance: entrance),
    };
  }
}
