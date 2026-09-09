/// Cards and surfaces. `design/worksettle-design-system.md` sections 6 and 11.
///
/// Four card types carry nearly every screen and they share one shell: the
/// surface colour of the current theme, 16 px radius, hairline border, 16 px
/// padding. **The border is the boundary; the shadow only says how far off the
/// ground the surface sits.**
library;

import 'package:flutter/material.dart';

import '../../app/theme/theme.dart';

/// The shared card shell.
class WsCard extends StatelessWidget {
  const WsCard({
    required this.child,
    this.padding = WsSpacing.card,
    this.onTap,
    this.raised = false,
    this.color,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  /// Score cards and plan cards sit slightly off the ground. Everything else
  /// is border-only.
  final bool raised;

  /// Overrides the surface — for the tinted comparison columns and the score
  /// breakdown, which are still cards.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    // The card is a Material, not a decorated Container, so that anything
    // inside it that paints ink — ListTile, SwitchListTile, ExpansionTile —
    // finds a Material ancestor and its splashes stay visible. A DecoratedBox
    // holding the background between the two hides them, and Flutter asserts
    // on exactly that.
    Widget card = Material(
      color: color ?? context.colors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: WsRadii.cardR,
        side: BorderSide(color: context.colors.outlineVariant),
      ),
      child: onTap == null
          ? Padding(padding: padding, child: child)
          : InkWell(
              onTap: onTap,
              child: Padding(padding: padding, child: child),
            ),
    );

    if (raised) {
      // Shadow behind the Material, carrying no colour of its own, so it does
      // not become the "background" the ListTile assert complains about.
      card = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: WsRadii.cardR,
          boxShadow: context.isDark ? WsShadows.darkRaised : WsShadows.raised,
        ),
        child: card,
      );
    }

    return card;
  }
}

/// The single most-used selection state in the product — profile type, goals,
/// plan and payment method all use it.
///
/// Selected is a 2 px red border plus the selected-surface tint, **with the
/// padding reduced by 1 px so the card does not shift when it is chosen.**
class WsSelectionCard extends StatelessWidget {
  const WsSelectionCard({
    required this.selected,
    required this.onTap,
    required this.child,
    this.semanticLabel,
    super.key,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      label: semanticLabel,
      child: Material(
        color: Colors.transparent,
        borderRadius: WsRadii.cardR,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: AnimatedContainer(
            duration: WsMotion.duration(context, WsMotion.fast),
            // 16 at rest, 15 when selected: the extra border width is taken
            // out of the padding so nothing moves.
            padding: EdgeInsets.all(selected ? WsSpacing.lg - 1 : WsSpacing.lg),
            decoration: BoxDecoration(
              color: selected
                  ? context.ws.selectedSurface
                  : context.colors.surface,
              borderRadius: WsRadii.cardR,
              border: Border.all(
                color: selected
                    ? context.colors.primary
                    : context.colors.outlineVariant,
                width: selected ? 2 : 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// The only surface in the product allowed a gradient, and only this one: a
/// 103° sweep. It carries good news at the top of a results screen, and has no
/// border and no shadow.
class WsBanner extends StatelessWidget {
  const WsBanner({
    required this.child,
    this.padding = WsSpacing.card,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: WsRadii.cardR,
        gradient: LinearGradient(
          // 103° measured from the x-axis, expressed as begin/end alignments.
          begin: const Alignment(-1, -0.9),
          end: const Alignment(1, 0.9),
          colors: [context.ws.bannerStart, context.ws.bannerEnd],
        ),
      ),
      child: child,
    );
  }
}

/// The product's most repeated object: a rounded square filled with a module
/// tint, holding that module's glyph in its base colour.
///
/// Three sizes, per section 10. The 60 px circle marks a **full screen**, not
/// a row.
enum WsTileSize {
  /// Score cards, list rows, hub tiles.
  standard(44, WsRadii.tileSmall + 2, WsIconSize.moduleGlyph),

  /// Quick actions, compact rows.
  compact(40, WsRadii.tileSmall, 20),

  /// Module screen header.
  header(60, WsRadii.pill, 28);

  const WsTileSize(this.box, this.radius, this.glyph);

  final double box;
  final double radius;
  final double glyph;
}

class WsIconTile extends StatelessWidget {
  const WsIconTile({
    required this.icon,
    this.size = WsTileSize.standard,
    this.brand = false,
    super.key,
  });

  final IconData icon;
  final WsTileSize size;

  /// Job Matching alone keeps the brand red — it is the entry point to the
  /// product and the place the brand should appear. Every other module is ink
  /// on Grey 100, told apart by its glyph.
  final bool brand;

  @override
  Widget build(BuildContext context) {
    final ws = context.ws;
    return Container(
      width: size.box,
      height: size.box,
      decoration: BoxDecoration(
        color: brand ? ws.jobModuleTint : ws.moduleTint,
        borderRadius: BorderRadius.circular(size.radius),
      ),
      child: Icon(
        icon,
        size: size.glyph,
        color: brand ? ws.jobModuleBase : ws.moduleBase,
      ),
    );
  }
}

/// White row, leading tile or flag, title and supporting line, optional
/// verdict pill, chevron last.
///
/// **The chevron means the row opens a screen. A row without one is not
/// tappable** — so [onTap] and [chevron] travel together.
class WsListRow extends StatelessWidget {
  const WsListRow({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.chevron = true,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;

  /// A verdict pill, a price, a switch. Sits before the chevron.
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool chevron;

  @override
  Widget build(BuildContext context) {
    final showChevron = chevron && onTap != null;

    final row = Container(
      constraints: const BoxConstraints(minHeight: WsTouch.minTarget),
      padding: const EdgeInsets.symmetric(
        horizontal: WsSpacing.lg,
        vertical: WsSpacing.md,
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: WsSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: context.text.titleMedium),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: context.text.bodySmall
                        ?.copyWith(color: context.ws.caption),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: WsSpacing.md),
            trailing!,
          ],
          if (showChevron) ...[
            const SizedBox(width: WsSpacing.sm),
            Icon(
              Icons.chevron_right_rounded,
              size: WsIconSize.chevron + 4,
              color: context.ws.placeholder,
            ),
          ],
        ],
      ),
    );

    if (onTap == null) return row;

    return Material(
      color: Colors.transparent,
      borderRadius: WsRadii.rowR,
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: row),
    );
  }
}
