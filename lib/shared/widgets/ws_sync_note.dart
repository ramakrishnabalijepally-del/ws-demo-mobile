import 'package:flutter/material.dart';

import '../../app/theme/theme.dart';

/// Says that what is on screen is shared with another part of the app.
///
/// The profile and the CRS calculator read and write the same answers. Without
/// a note, a candidate who fills in their education in one place has no reason
/// to trust it is already done in the other, and types it twice.
class WsSyncNote extends StatelessWidget {
  const WsSyncNote({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: WsSpacing.md,
        vertical: WsSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: context.ws.verdictTintedSurface,
        borderRadius: WsRadii.fieldR,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.sync_rounded,
            size: WsIconSize.field,
            color: context.colors.onSurface,
          ),
          const SizedBox(width: WsSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: context.text.bodySmall
                  ?.copyWith(color: context.colors.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}
