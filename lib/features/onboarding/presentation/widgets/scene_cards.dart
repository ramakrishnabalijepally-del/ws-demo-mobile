import 'package:flutter/material.dart';

import '../../../../app/theme/theme.dart';
import '../../../../shared/shared.dart';
import '../../animations/onboarding_motion.dart';
import '../../data/mock_onboarding.dart';

/// The small product cards that float over each slide's photograph. Every one
/// is built from the shared inventory — WsCard, WsIconTile, WsVerdictChip,
/// WsRing — so the promise on the slide looks like the product it leads to.

/// Immigration — the CRS score counting up to its verdict.
class CrsScoreCard extends StatelessWidget {
  const CrsScoreCard({required this.entrance, super.key});

  final Animation<double> entrance;

  @override
  Widget build(BuildContext context) {
    return WsCard(
      raised: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const WsIconTile(icon: Icons.speed_rounded),
              const SizedBox(width: WsSpacing.md),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'CRS score',
                      style: context.text.bodySmall
                          ?.copyWith(color: context.ws.caption),
                    ),
                    AnimatedBuilder(
                      animation: entrance,
                      builder: (context, _) => Text(
                        '${(mockOnboardingCrsScore * staggered(entrance.value, 0.2, 0.85)).round()}',
                        style: context.text.displaySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: WsSpacing.sm),
          const WsVerdictChip(
            verdict: WsVerdict.eligible,
            label: mockOnboardingCrsVerdict,
          ),
        ],
      ),
    );
  }
}

/// Immigration — the routes the score is measured against.
class RoutesCard extends StatelessWidget {
  const RoutesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return WsCard(
      raised: true,
      padding: const EdgeInsets.symmetric(
        horizontal: WsSpacing.lg,
        vertical: WsSpacing.md,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.flight_takeoff_rounded,
            size: WsIconSize.field,
            color: context.colors.onSurface,
          ),
          const SizedBox(width: WsSpacing.sm),
          Flexible(
            child: Text(mockOnboardingRoutes, style: context.text.labelLarge),
          ),
        ],
      ),
    );
  }
}

/// Jobs — a matched role, carrying the one brand-red tile.
class JobMatchCard extends StatelessWidget {
  const JobMatchCard({super.key});

  @override
  Widget build(BuildContext context) {
    return WsCard(
      raised: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const WsIconTile(icon: Icons.work_rounded, brand: true),
              const SizedBox(width: WsSpacing.md),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      mockOnboardingJobTitle,
                      style: context.text.titleMedium,
                    ),
                    Text(
                      mockOnboardingJobEmployer,
                      style: context.text.bodySmall
                          ?.copyWith(color: context.ws.caption),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: WsSpacing.sm),
          const WsVerdictChip(
            verdict: WsVerdict.eligible,
            label: mockOnboardingJobVerdict,
          ),
        ],
      ),
    );
  }
}

/// Jobs — the trust signal on every listing.
class VerifiedEmployerCard extends StatelessWidget {
  const VerifiedEmployerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return WsCard(
      raised: true,
      padding: const EdgeInsets.symmetric(
        horizontal: WsSpacing.lg,
        vertical: WsSpacing.md,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_rounded,
            size: WsIconSize.field,
            color: context.colors.onSurface,
          ),
          const SizedBox(width: WsSpacing.sm),
          Flexible(
            child: Text('Verified employer', style: context.text.labelLarge),
          ),
        ],
      ),
    );
  }
}

/// Profile — the strength ring filling. The only ring in the product.
class ProfileStrengthCard extends StatelessWidget {
  const ProfileStrengthCard({required this.entrance, super.key});

  final Animation<double> entrance;

  @override
  Widget build(BuildContext context) {
    return WsCard(
      raised: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: entrance,
            builder: (context, _) => WsRing(
              percent: (mockOnboardingProfileStrength *
                      staggered(entrance.value, 0.2, 0.9))
                  .round(),
              diameter: 60,
            ),
          ),
          const SizedBox(width: WsSpacing.md),
          Flexible(
            child: Text('Profile\nstrength', style: context.text.labelLarge),
          ),
        ],
      ),
    );
  }
}

/// Profile — checklist rows ticking in one after another.
class ChecklistCard extends StatelessWidget {
  const ChecklistCard({required this.entrance, super.key});

  final Animation<double> entrance;

  @override
  Widget build(BuildContext context) {
    return WsCard(
      raised: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (index, (label, done)) in mockOnboardingChecklist.indexed)
            Padding(
              padding: EdgeInsets.only(
                bottom: index == mockOnboardingChecklist.length - 1
                    ? 0
                    : WsSpacing.sm,
              ),
              child: _ChecklistRow(
                label: label,
                done: done,
                entrance: entrance,
                begin: 0.45 + index * 0.12,
              ),
            ),
        ],
      ),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({
    required this.label,
    required this.done,
    required this.entrance,
    required this.begin,
  });

  final String label;
  final bool done;
  final Animation<double> entrance;
  final double begin;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox.square(
          dimension: WsIconSize.tick,
          child: done
              ? AnimatedBuilder(
                  animation: entrance,
                  builder: (context, child) => Transform.scale(
                    scale: staggered(entrance.value, begin, begin + 0.3),
                    child: child,
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: WsIconSize.tick,
                    color: context.colors.onSurface,
                  ),
                )
              : Icon(
                  Icons.radio_button_unchecked_rounded,
                  size: WsIconSize.tick,
                  color: context.ws.placeholder,
                ),
        ),
        const SizedBox(width: WsSpacing.sm),
        Flexible(
          child: Text(
            label,
            style: context.text.bodySmall?.copyWith(
              color: done ? context.colors.onSurface : context.ws.caption,
            ),
          ),
        ),
      ],
    );
  }
}
