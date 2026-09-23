import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/routes.dart';
import '../../../../../app/theme/theme.dart';
import '../../../../../shared/shared.dart';
import '../../data/mock_verification.dart';
import '../widgets/auth_shake.dart';

/// Which flow the code belongs to — decides the copy and where a correct code
/// leads.
enum VerifyCodePurpose {
  /// Forgot password: a correct code leads to choosing a new password.
  passwordReset,

  /// Sign up: a correct code confirms the email and continues registration.
  emailVerification,
}

/// Enter the code WorkSettle emailed you.
///
/// One screen serves both flows, matching the web app: forgot password
/// (email → code → new password) and sign up (details → code → registration).
class VerifyCodeScreen extends StatefulWidget {
  const VerifyCodeScreen({
    required this.purpose,
    required this.email,
    super.key,
  });

  final VerifyCodePurpose purpose;
  final String email;

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final _code = TextEditingController();
  String? _error;
  String? _notice;
  bool _resending = false;
  int _rejections = 0;

  bool get _isReset => widget.purpose == VerifyCodePurpose.passwordReset;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _submit() {
    final code = _code.text.trim();
    setState(() {
      _notice = null;
      if (code.length != verificationCodeLength || int.tryParse(code) == null) {
        _error = 'Enter the $verificationCodeLength-digit code from the email';
      } else if (code != mockVerificationCode) {
        // TODO(backend): verify against Supabase Auth instead of the mock.
        _error = 'That code does not match. Check the latest email and '
            'try again, or send a new code';
      } else {
        _error = null;
      }
    });
    if (_error != null) {
      HapticFeedback.mediumImpact();
      setState(() => _rejections++);
      return;
    }

    if (_isReset) {
      context.push(Routes.resetNewPassword, extra: widget.email);
    } else {
      context.go(Routes.registration);
    }
  }

  Future<void> _resend() async {
    setState(() {
      _resending = true;
      _error = null;
      _notice = null;
    });
    // TODO(backend): request a fresh code. The mock code never changes.
    await Future<void>.delayed(WsMotion.medium);
    if (!mounted) return;
    setState(() {
      _resending = false;
      _notice = 'A new code is on its way to ${widget.email}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isReset ? 'Forgot Password' : 'Verify Your Email'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: WsSpacing.xl,
                  vertical: WsSpacing.xxl,
                ),
                children: [
                  const WsAppear(
                    alignment: Alignment.centerLeft,
                    fromScale: 0.6,
                    child: WsIconTile(icon: Icons.mark_email_read_outlined),
                  ),
                  const SizedBox(height: WsSpacing.lg),
                  WsAppear(
                    delay: 0.1,
                    child: Text(
                      'Check your email',
                      style: context.text.titleLarge,
                    ),
                  ),
                  const SizedBox(height: WsSpacing.sm),
                  WsAppear(
                    delay: 0.2,
                    child: Text(
                      'Enter the $verificationCodeLength-digit code sent to '
                      '${widget.email} to '
                      '${_isReset ? 'reset your password' : 'confirm your email'}.',
                      style: context.text.bodyMedium
                          ?.copyWith(color: context.colors.onSurfaceVariant),
                    ),
                  ),
                  const SizedBox(height: WsSpacing.xxl),
                  WsAppear(
                    delay: 0.3,
                    child: AuthShake(
                      trigger: _rejections,
                      child: WsField(
                        label: 'Verification Code',
                        required: true,
                        controller: _code,
                        hint: '6 digits',
                        error: _error,
                        helper: _notice,
                        keyboardType: TextInputType.number,
                        leadingIcon: Icons.key_outlined,
                      ),
                    ),
                  ),
                  const SizedBox(height: WsSpacing.sm),
                  WsAppear(
                    delay: 0.4,
                    child: _ResendRow(
                      resending: _resending,
                      onResend: _resend,
                    ),
                  ),
                  const SizedBox(height: WsSpacing.xl),
                  const WsAppear(delay: 0.5, child: _MockCodeBanner()),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                WsSpacing.xl,
                WsSpacing.md,
                WsSpacing.xl,
                WsSpacing.xl,
              ),
              child: WsPrimaryButton(label: 'Verify', onPressed: _submit),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dev-only stand-in for the email that has not been sent.
///
/// TODO(backend): remove with `mock_verification.dart`.
class _MockCodeBanner extends StatelessWidget {
  const _MockCodeBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(WsSpacing.lg),
      decoration: BoxDecoration(
        color: context.ws.moduleTint,
        borderRadius: BorderRadius.circular(WsRadii.field),
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: context.ws.caption),
          const SizedBox(width: WsSpacing.md),
          Expanded(
            child: Text(
              'Test mode: no email is sent. Use code $mockVerificationCode.',
              style: context.text.bodySmall
                  ?.copyWith(color: context.colors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResendRow extends StatelessWidget {
  const _ResendRow({
    required this.resending,
    required this.onResend,
  });

  final bool resending;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            "Didn't get the code?",
            style: context.text.bodyMedium
                ?.copyWith(color: context.colors.onSurfaceVariant),
          ),
        ),
        WsLink(
          label: resending ? 'Sending…' : 'Resend',
          onPressed: resending ? null : onResend,
        ),
      ],
    );
  }
}
