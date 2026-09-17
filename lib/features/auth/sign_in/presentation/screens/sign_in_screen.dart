import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/providers.dart';
import '../../../../../app/router/routes.dart';
import '../../../../../app/theme/theme.dart';
import '../../../../../shared/shared.dart';
import '../../../shared/presentation/widgets/auth_scaffold.dart';
import '../widgets/social_sign_in_row.dart';

/// B1–B3 — sign in, and its two error states.
///
/// The deck's error copy reads "Invalid email" and "Password does not match
/// email". Both are rewritten per design system section 20: **name the fix, not
/// the failure**, and never leave the reader without a next move.
///
/// The validation here is deliberately shallow — it exists to show the error
/// states, not to guard anything. Any password signs you in.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen>
    with SingleTickerProviderStateMixin {
  final _email = TextEditingController();
  final _password = TextEditingController();

  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: WsMotion.focal,
  );

  bool _remember = false;
  bool _obscure = true;
  String? _emailError;
  String? _passwordError;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (WsMotion.reduced(context)) {
      _entrance.value = 1;
    } else if (_entrance.isDismissed) {
      _entrance.forward();
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _entrance.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _email.text.trim();
    final password = _password.text;

    setState(() {
      _emailError = switch (email) {
        '' => 'Enter the email address you signed up with',
        final e when !e.contains('@') || !e.contains('.') =>
          'Enter a complete email address, like name@example.com',
        _ => null,
      };
      _passwordError = password.isEmpty
          ? 'Enter your password'
          : password.length < 6
              // Names what would fix it rather than reporting a mismatch the
              // reader cannot act on.
              ? 'That password is too short. Passwords are at least 6 characters'
              : null;
    });

    if (_emailError == null && _passwordError == null) {
      // TODO(backend): no authentication happens — this signs the mock
      // candidate in and routes to the dashboard.
      ref.read(signedInProvider.notifier).signIn();
      context.go(Routes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      entrance: _entrance,
      child: _SignInForm(
        email: _email,
        password: _password,
        emailError: _emailError,
        passwordError: _passwordError,
        obscure: _obscure,
        remember: _remember,
        onToggleObscure: () => setState(() => _obscure = !_obscure),
        onRememberChanged: (v) => setState(() => _remember = v),
        onSubmit: _submit,
      ),
    );
  }
}

class _SignInForm extends StatelessWidget {
  const _SignInForm({
    required this.email,
    required this.password,
    required this.emailError,
    required this.passwordError,
    required this.obscure,
    required this.remember,
    required this.onToggleObscure,
    required this.onRememberChanged,
    required this.onSubmit,
  });

  final TextEditingController email;
  final TextEditingController password;
  final String? emailError;
  final String? passwordError;
  final bool obscure;
  final bool remember;
  final VoidCallback onToggleObscure;
  final ValueChanged<bool> onRememberChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Welcome back', style: context.text.headlineLarge),
        const SizedBox(height: WsSpacing.xs),
        Text(
          'Sign in to your account to pick up your journey.',
          style: context.text.bodyMedium
              ?.copyWith(color: context.colors.onSurfaceVariant),
        ),
        const SizedBox(height: WsSpacing.xxl),
        WsField(
          label: 'Email',
          required: true,
          controller: email,
          hint: 'name@example.com',
          error: emailError,
          keyboardType: TextInputType.emailAddress,
          trailingIcon: Icons.mail_outline_rounded,
        ),
        const SizedBox(height: WsSpacing.xl),
        WsField(
          label: 'Password',
          required: true,
          controller: password,
          hint: 'Your password',
          error: passwordError,
          obscure: obscure,
          trailingIcon: obscure
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          onTrailingTap: onToggleObscure,
        ),
        const SizedBox(height: WsSpacing.sm),
        // Both halves stay on one line at 360 dp only because the link is
        // "Forgot password?" rather than "Forgot your password?" — the
        // longer wording squeezed the checkbox label past its own width.
        // The Row stays bounded because WsCheckboxRow contains an
        // Expanded, which a Wrap would not give a width to.
        Row(
          children: [
            Expanded(
              child: WsCheckboxRow(
                label: 'Remember me',
                value: remember,
                onChanged: onRememberChanged,
              ),
            ),
            WsLink(
              label: 'Forgot password?',
              underline: false,
              onPressed: () => context.push(Routes.forgotPassword),
            ),
          ],
        ),
        const SizedBox(height: WsSpacing.xl),
        WsPrimaryButton(
          label: 'Sign In',
          forward: false,
          onPressed: onSubmit,
        ),
        const SizedBox(height: WsSpacing.xxl),
        const SocialSignInRow(),
        const SizedBox(height: WsSpacing.xxl),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                "Don't have an account?",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),
            WsLink(
              label: 'Register',
              onPressed: () => context.push(Routes.signUp),
            ),
          ],
        ),
      ],
    );
  }
}
