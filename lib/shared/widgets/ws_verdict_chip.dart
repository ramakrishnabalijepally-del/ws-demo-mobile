import 'package:flutter/material.dart';

import '../../app/theme/theme.dart';

/// The three-rung state ladder.
/// `design/worksettle-design-system.md` sections 2 and 9.
///
/// **Filled outranks outlined outranks tinted.** The more certain the state,
/// the more solid the shape. No pill carries a hue — with colour removed as a
/// channel, the glyph is the second channel, so **the glyph is not optional**:
/// a chip without its icon is a bug. That is why [WsVerdict] pairs each rung
/// with its glyph and [WsVerdictChip] has no way to omit it.
///
/// **A chip never says "Ineligible."** Where a user does not qualify, show the
/// neutral verdict plus the specific gap and what closes it.
enum WsVerdict {
  /// The user meets the published threshold on the data they have given.
  /// Eligible · Good Range · High Potential · Good Match.
  eligible(Icons.check_rounded),

  /// Possible, but depends on information not yet entered or a factor outside
  /// their profile. Potential Match · Potential Options.
  potential(Icons.contrast_rounded),

  /// Not assessed. **Never styled as a negative.** Explore Further.
  explore(Icons.circle_rounded);

  const WsVerdict(this.glyph);

  /// Load-bearing, not decoration.
  final IconData glyph;
}

/// A verdict pill. Eligibility is the product's core information and this is
/// how it is reported.
class WsVerdictChip extends StatelessWidget {
  const WsVerdictChip({
    required this.verdict,
    required this.label,
    super.key,
  });

  final WsVerdict verdict;

  /// The pill always carries text — colour alone never reports a state.
  final String label;

  @override
  Widget build(BuildContext context) {
    final ws = context.ws;

    final (Color background, Color foreground, Color? border) =
        switch (verdict) {
      WsVerdict.eligible => (
          ws.verdictFilledSurface,
          ws.verdictFilledLabel,
          null,
        ),
      WsVerdict.potential => (
          Colors.transparent,
          ws.verdictOutlinedLabel,
          ws.verdictOutlinedBorder,
        ),
      WsVerdict.explore => (
          ws.verdictTintedSurface,
          ws.verdictTintedLabel,
          null,
        ),
    };

    return Semantics(
      label: label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: background,
          borderRadius: WsRadii.pillR,
          border: Border.all(
            color: border ?? Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              verdict.glyph,
              size: verdict == WsVerdict.explore
                  ? WsIconSize.chipGlyph - 4
                  : WsIconSize.chipGlyph,
              color: foreground,
            ),
            const SizedBox(width: 5),
            Text(label, style: WsTypography.chip(foreground)),
          ],
        ),
      ),
    );
  }
}

/// Commercial and pricing emphasis — deliberately **not** a verdict.
///
/// "Most Popular" takes the brand red because it is the plan the product
/// pushes. "Save 17%" is quiet Grey 100, because a pricing incentive is not a
/// judgement about the reader.
class WsBadge extends StatelessWidget {
  const WsBadge.mostPopular({super.key})
      : label = 'Most Popular',
        _red = true;

  const WsBadge.saving({required this.label, super.key}) : _red = false;

  final String label;
  final bool _red;

  @override
  Widget build(BuildContext context) {
    final background =
        _red ? context.colors.primary : context.ws.verdictTintedSurface;
    final foreground =
        _red ? context.colors.onPrimary : context.ws.verdictTintedLabel;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: WsRadii.pillR,
      ),
      child: Text(label, style: WsTypography.chip(foreground)),
    );
  }
}
