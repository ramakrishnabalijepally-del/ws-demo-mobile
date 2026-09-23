import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/routes.dart';
import '../../../../../app/theme/theme.dart';
import '../../../../../shared/shared.dart';

/// B6 — choose SMS or email.
///
/// Two selection cards, the product's most-used selection state: a 2 px red
/// border plus the selected tint, **with the padding reduced by 1 px so the
/// card does not shift when it is chosen** (design system section 11).
///
/// The contact details are masked, which is the one place partial information
/// is the right answer — it confirms *which* address without exposing it.
class ResetMethodScreen extends StatefulWidget {
  const ResetMethodScreen({required this.email, super.key});

  final String email;

  @override
  State<ResetMethodScreen> createState() => _ResetMethodScreenState();
}

class _ResetMethodScreenState extends State<ResetMethodScreen> {
  // Email first: it is the channel the code is actually sent on.
  int _selected = 0;

  late final List<({IconData icon, String via, String detail})> _methods = [
    (
      icon: Icons.mail_outline_rounded,
      via: 'via Email',
      detail: _mask(widget.email),
    ),
    (icon: Icons.sms_outlined, via: 'via SMS', detail: '+1 416 ••• ••42'),
  ];

  static String _mask(String email) {
    final at = email.indexOf('@');
    if (at < 1) return email;
    final visible = at < 3 ? 1 : 2;
    return '${email.substring(0, visible)}••••••${email.substring(at)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: WsSpacing.xl,
            vertical: WsSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Where should we send it?',
                style: context.text.titleLarge,
              ),
              const SizedBox(height: WsSpacing.sm),
              Text(
                'Choose which contact detail to use for your reset code.',
                style: context.text.bodyMedium
                    ?.copyWith(color: context.colors.onSurfaceVariant),
              ),
              const SizedBox(height: WsSpacing.xxl),
              for (var i = 0; i < _methods.length; i++) ...[
                WsSelectionCard(
                  selected: _selected == i,
                  onTap: () => setState(() => _selected = i),
                  semanticLabel: '${_methods[i].via}, ${_methods[i].detail}',
                  child: Row(
                    children: [
                      WsIconTile(icon: _methods[i].icon),
                      const SizedBox(width: WsSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _methods[i].via,
                              style: context.text.bodySmall
                                  ?.copyWith(color: context.ws.caption),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _methods[i].detail,
                              style: context.text.titleMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: WsSpacing.md),
              ],
              const Spacer(),
              WsPrimaryButton(
                label: 'Continue',
                // TODO(backend): send the code on the chosen channel. SMS
                // lands on the same mock email-code screen for now.
                onPressed: () =>
                    context.push(Routes.resetVerifyCode, extra: widget.email),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
