import 'package:flutter/material.dart';

import '../../../../../app/theme/theme.dart';

/// "or continue with" — the social sign-in row, shared by sign in and sign up.
///
/// The deck renders Facebook in its own brand blue and Google in a disabled
/// grey. **Neither survives**: no second hue enters this system (design system
/// section 2), so both are neutral outlined rows, told apart by their glyph and
/// their label. That also stops a brand colour reading as a state.
class SocialSignInRow extends StatelessWidget {
  const SocialSignInRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: context.colors.outlineVariant)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: WsSpacing.md),
              child: Text(
                'or continue with',
                style:
                    context.text.bodySmall?.copyWith(color: context.ws.caption),
              ),
            ),
            Expanded(child: Divider(color: context.colors.outlineVariant)),
          ],
        ),
        const SizedBox(height: WsSpacing.xl),
        const Row(
          children: [
            Expanded(
              child: _SocialButton(
                label: 'Google',
                icon: Icons.g_mobiledata_rounded,
              ),
            ),
            SizedBox(width: WsSpacing.md),
            Expanded(
              child: _SocialButton(
                label: 'Apple',
                icon: Icons.apple_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      // TODO(backend): no OAuth in the mock. The button is present so the
      // layout is real; wiring it is a backend task.
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        foregroundColor: context.colors.onSurface,
        side: BorderSide(color: context.colors.outlineVariant, width: 1.5),
        textStyle: WsTypography.button(context.colors.onSurface),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: WsSpacing.sm),
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
