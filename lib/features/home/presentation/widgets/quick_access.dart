import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/theme.dart';
import '../../../../shared/shared.dart';

/// The three routes the client wants a newcomer to see the moment they land:
/// **Jobs · Immigration Guidance · French Classes.**
///
/// The client's own screen puts these as full-bleed illustrated banners under a
/// search bar. The layout is kept; the artwork is not, because it was never
/// supplied — each banner carries a tinted placeholder panel at the exact size
/// the illustration will occupy, so dropping the real image in later changes
/// nothing about the layout.
///
/// The blue of the client's Immigration and French panels does not survive:
/// no second hue enters this system (design system section 2), so Jobs takes
/// the brand red as the entry point to the product and the other two are ink
/// on Grey 100, told apart by their glyph.
class QuickAccess extends ConsumerWidget {
  const QuickAccess({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // French language support is a Pro+ add-on, so the banner is honest about
    // being locked rather than failing after the tap.
    final frenchLocked = ref.watch(planTierProvider) != PlanTier.proPlus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SearchEntry(onTap: () => context.go(Routes.jobs)),
        const SizedBox(height: WsSpacing.lg),
        _Banner(
          icon: Icons.work_rounded,
          hero: WsHero.jobs,
          label: 'Jobs',
          blurb: 'Verified, immigrant-friendly employers',
          brand: true,
          onTap: () => context.go(Routes.jobs),
        ),
        const SizedBox(height: WsSpacing.md),
        _Banner(
          icon: Icons.flight_takeoff_rounded,
          hero: WsHero.success,
          label: 'Immigration Guidance',
          blurb: 'CRS score, provincial programs, eligibility',
          onTap: () => context.go(Routes.immigration),
        ),
        const SizedBox(height: WsSpacing.md),
        _Banner(
          icon: Icons.record_voice_over_rounded,
          hero: WsHero.profile,
          label: 'French Classes',
          blurb: 'Live small-group classes, beginner upward',
          locked: frenchLocked,
          onTap: () => frenchLocked
              ? context.push(Routes.paywall, extra: 'French Classes')
              : context.go(Routes.resources),
        ),
      ],
    );
  }
}

/// Not a real text field — tapping it opens the Jobs tab, which owns search.
/// A second live search box here would be two sources of truth for one query.
class _SearchEntry extends StatelessWidget {
  const _SearchEntry({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Search jobs',
      child: Material(
        color: context.colors.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: WsRadii.pillR,
          side: BorderSide(color: context.colors.outlineVariant, width: 1.5),
        ),
        child: InkWell(
          onTap: onTap,
          child: Container(
            constraints: const BoxConstraints(minHeight: WsTouch.minTarget),
            padding: const EdgeInsets.symmetric(horizontal: WsSpacing.lg),
            child: Row(
              children: [
                Icon(
                  Icons.search_rounded,
                  size: WsIconSize.field,
                  color: context.ws.placeholder,
                ),
                const SizedBox(width: WsSpacing.md),
                Expanded(
                  child: Text(
                    'What are you looking for?',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodyMedium
                        ?.copyWith(color: context.ws.placeholder),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
    this.locked = false,
  });

  final IconData icon;
  final WsHero hero;
  final String label;
  final String blurb;
  final VoidCallback onTap;

  /// Jobs alone carries the brand red.
  final bool brand;

  final bool locked;

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
                if (locked)
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 18,
                    color: ws.placeholder,
                    semanticLabel: 'Pro+ feature',
                  )
                else
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
