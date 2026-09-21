import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/theme.dart';
import '../../../../shared/shared.dart';

/// The three tools under "Your tools" on the dashboard:
/// **Immigration · Jobs · Settlement.**
///
/// Each is a photo banner. The photos are demo stand-ins until client
/// photography arrives; the layout does not change when they are swapped.
///
/// No second hue enters this system (design system section 2), so Jobs takes
/// the brand red as the entry point to the product and the other two are ink
/// on Grey 100, told apart by their glyph.
class QuickAccess extends StatelessWidget {
  const QuickAccess({this.entrance, super.key});

  /// The screen's entrance timeline. Null shows every banner at rest;
  /// otherwise they rise in one after another.
  final Animation<double>? entrance;

  @override
  Widget build(BuildContext context) {
    final entrance = this.entrance ?? kAlwaysCompleteAnimation;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WsRiseIn(
          entrance: entrance,
          begin: 0.46,
          end: 0.84,
          fromScale: 0.96,
          child: _Banner(
            icon: Icons.flight_takeoff_rounded,
            hero: WsHero.tileImmigration,
            label: 'Immigration',
            blurb: 'CRS score, provincial programs, eligibility',
            onTap: () => context.go(Routes.immigration),
          ),
        ),
        const SizedBox(height: WsSpacing.md),
        WsRiseIn(
          entrance: entrance,
          begin: 0.53,
          end: 0.91,
          fromScale: 0.96,
          child: _Banner(
            icon: Icons.work_rounded,
            hero: WsHero.tileJobs,
            label: 'Jobs',
            blurb: 'Verified, immigrant-friendly employers',
            brand: true,
            onTap: () => context.go(Routes.jobs),
          ),
        ),
        const SizedBox(height: WsSpacing.md),
        WsRiseIn(
          entrance: entrance,
          begin: 0.6,
          end: 0.98,
          fromScale: 0.96,
          child: _Banner(
            icon: Icons.home_rounded,
            hero: WsHero.tileSettlement,
            label: 'Settlement',
            blurb: 'Arrival checklist, consultations and local resources',
            onTap: () => context.go(Routes.settlement),
          ),
        ),
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({
    required this.icon,
    required this.hero,
    required this.label,
    required this.blurb,
    required this.onTap,
    this.brand = false,
  });

  final IconData icon;
  final WsHero hero;
  final String label;
  final String blurb;
  final VoidCallback onTap;

  /// Jobs alone carries the brand red.
  final bool brand;

  @override
  Widget build(BuildContext context) {
    final ws = context.ws;

    return WsCard(
      onTap: onTap,
      raised: true,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // The client's photograph, cropped to the banner. A scrim under the
          // glyph keeps the icon legible whatever the photo is doing behind it.
          SizedBox(
            height: 132,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                WsHeroImage(hero: hero, semanticLabel: label),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        context.colors.scrim.withValues(alpha: 0.55),
                        context.colors.scrim.withValues(alpha: 0.10),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: WsSpacing.lg),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color:
                            brand ? ws.jobModuleBase : context.colors.surface,
                        borderRadius: WsRadii.fieldR,
                      ),
                      child: Icon(
                        icon,
                        size: 28,
                        color: brand
                            ? context.colors.onPrimary
                            : context.colors.onSurface,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(WsSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(label, style: context.text.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        blurb,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style:
                            context.text.bodySmall?.copyWith(color: ws.caption),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: WsSpacing.md),
                Icon(
                  Icons.chevron_right_rounded,
                  size: WsIconSize.chevron + 4,
                  color: ws.placeholder,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
