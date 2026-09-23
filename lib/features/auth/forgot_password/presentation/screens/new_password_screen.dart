import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/routes.dart';
import '../../../../../app/theme/theme.dart';
import '../../../../../shared/shared.dart';
import '../../../shared/presentation/widgets/auth_shake.dart';

/// Forgot password, last step — choose the new password, typed twice.
///
/// Saving it does **not** sign the candidate in: they land on a confirmation
/// and sign in again with the new password, the same as the web app.
class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({required this.email, super.key});

  final String email;

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  static const int _minLength = 6;

  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;
  String? _passwordError;
  String? _confirmError;
  int _rejections = 0;

  @override
  void initState() {
    super.initState();
    // The rule checklist ticks live as the candidate types.
    _password.addListener(_refresh);
    _confirm.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  bool get _longEnough => _password.text.length >= _minLength;
  bool get _hasNumber => _password.text.contains(RegExp(r'\d'));
  bool get _matches =>
      _confirm.text.isNotEmpty && _confirm.text == _password.text;

  void _submit() {
    setState(() {
      _passwordError = !_longEnough
          ? 'Choose a password of at least $_minLength characters'
          : (!_hasNumber ? 'Add at least one number to your password' : null);
      _confirmError = _matches
          ? null
          : 'Both password fields need to match. Re-type it to confirm';
    });
    if (_passwordError != null || _confirmError != null) {
      HapticFeedback.mediumImpact();
      setState(() => _rejections++);
      return;
    }
    // TODO(backend): save the new password through Supabase Auth.
    context.go(Routes.resetSuccess);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
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
                    child: WsIconTile(icon: Icons.lock_reset_rounded),
                  ),
                  const SizedBox(height: WsSpacing.lg),
                  WsAppear(
                    delay: 0.1,
                    child: Text(
                      'Set a new password',
                      style: context.text.titleLarge,
                    ),
                  ),
                  const SizedBox(height: WsSpacing.sm),
                  WsAppear(
                    delay: 0.2,
                    child: Text(
                      'For ${widget.email}. You will sign in with it next.',
                      style: context.text.bodyMedium
                          ?.copyWith(color: context.colors.onSurfaceVariant),
                    ),
                  ),
                  const SizedBox(height: WsSpacing.xxl),
                  WsAppear(
                    delay: 0.3,
                    child: AuthShake(
                      trigger: _rejections,
                      child: _PasswordFields(
                        password: _password,
                        confirm: _confirm,
                        obscure: _obscure,
                        passwordError: _passwordError,
                        confirmError: _confirmError,
                        onToggleObscure: () =>
                            setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),
                  const SizedBox(height: WsSpacing.lg),
                  WsAppear(
                    delay: 0.4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Rule(
                          met: _longEnough,
                          label: 'At least $_minLength characters',
                        ),
                        _Rule(met: _hasNumber, label: 'Contains a number'),
                        _Rule(met: _matches, label: 'Both passwords match'),
                      ],
                    ),
                  ),
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
              child: WsPrimaryButton(
                label: 'Save Password',
                onPressed: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PasswordFields extends StatelessWidget {
  const _PasswordFields({
    required this.password,
    required this.confirm,
    required this.obscure,
    required this.passwordError,
    required this.confirmError,
    required this.onToggleObscure,
  });

  final TextEditingController password;
  final TextEditingController confirm;
  final bool obscure;
  final String? passwordError;
  final String? confirmError;
  final VoidCallback onToggleObscure;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        WsField(
          label: 'New Password',
          required: true,
          controller: password,
          obscure: obscure,
          error: passwordError,
          leadingIcon: Icons.lock_outline_rounded,
          trailingIcon: obscure
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          onTrailingTap: onToggleObscure,
        ),
        const SizedBox(height: WsSpacing.xl),
        WsField(
          label: 'Confirm New Password',
          required: true,
          controller: confirm,
          obscure: obscure,
          error: confirmError,
          leadingIcon: Icons.lock_outline_rounded,
        ),
      ],
    );
  }
}

/// One password rule, ticking over as it is met. Weight and glyph carry the
/// state, not hue (design system: red is never a state colour).
class _Rule extends StatelessWidget {
  const _Rule({required this.met, required this.label});

  final bool met;
  final String label;

  @override
  Widget build(BuildContext context) {
    final duration = WsMotion.duration(context, WsMotion.medium);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: WsSpacing.xs),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: duration,
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Icon(
              met ? Icons.check_circle_rounded : Icons.circle_outlined,
              key: ValueKey(met),
              size: 18,
              color: met ? context.colors.onSurface : context.ws.caption,
            ),
          ),
          const SizedBox(width: WsSpacing.sm),
          Expanded(
            child: AnimatedDefaultTextStyle(
              duration: duration,
              style: (context.text.bodySmall ?? const TextStyle()).copyWith(
                color: met ? context.colors.onSurface : context.ws.caption,
                fontWeight: met ? FontWeight.w700 : FontWeight.w500,
              ),
              child: Text(label),
            ),
          ),
        ],
      ),
    );
  }
}
