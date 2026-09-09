import 'package:flutter/material.dart';

import '../../../../app/theme/theme.dart';
import '../../../../shared/shared.dart';
import '../../models/tip.dart';

/// A tip card.
///
/// The deck gives each card its own saturated gradient — blue, amber, pink.
/// **All three are dropped**: no second accent hue enters this system, so the
/// card is the standard shell and the article is told apart by its title
/// (design system section 2).
class TipCard extends StatelessWidget {
  const TipCard({required this.tip, required this.onTap, super.key});

  final Tip tip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return WsCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(tip.title, style: context.text.titleMedium),
          const SizedBox(height: WsSpacing.sm),
          Text(
            '${tip.authorName} · ${tip.authorRole}',
            style: context.text.bodySmall?.copyWith(color: context.ws.caption),
          ),
          const SizedBox(height: WsSpacing.md),
          Row(
            children: [
              Icon(
                Icons.schedule_outlined,
                size: 14,
                color: context.ws.placeholder,
              ),
              const SizedBox(width: WsSpacing.xs + 2),
              Text(
                '${tip.readMinutes} min read',
                style:
                    context.text.bodySmall?.copyWith(color: context.ws.caption),
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right_rounded,
                size: WsIconSize.chevron + 4,
                color: context.ws.placeholder,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
