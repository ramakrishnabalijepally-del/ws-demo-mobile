import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/routes.dart';
import '../../../../../app/theme/theme.dart';
import '../../../../../shared/shared.dart';
import '../../../shared/data/mock_verification.dart';
import '../../../shared/presentation/widgets/auth_scaffold.dart';
import '../../../sign_in/presentation/widgets/social_sign_in_row.dart';

/// B4 — create an account.
///
/// The same branded shape as sign in — logo on the red tint with the halftone
/// behind it, the form on a sheet that rises over it — because these two
/// screens are one moment in the product, seen a minute apart.
///
/// Creating the account leads into the registration flow rather than straight
/// to the dashboard: design system Pattern A puts one decision per screen and
/// a review before anything is committed.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: WsMotion.focal,
  );

  bool _obscure = true;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;

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
    _first.dispose();
    _last.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    _entrance.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _email.text.trim();
    setState(() {
      _emailError = email.isEmpty
          ? 'Enter the email address WorkSettle should write to'
          : (email.contains('@') && email.contains('.')
              ? null
              : 'Enter a complete email address, like name@example.com');
      _passwordError = _password.text.length < 6
          ? 'Choose a password of at least 6 characters'
          : null;
      _confirmError = _confirm.text == _password.text
          ? null
          : 'Both password fields need to match. Re-type it to confirm';
    });

    if (_emailError == null &&
        _passwordError == null &&
        _confirmError == null) {
      context.push(Routes.signUpVerifyEmail, extra: email);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      entrance: _entrance,
      onBack: () => context.go(Routes.signIn),
      child: _SignUpForm(
        first: _first,
        last: _last,
        email: _email,
        phone: _phone,
        password: _password,
        confirm: _confirm,
        obscure: _obscure,
        emailError: _emailError,
        passwordError: _passwordError,
        confirmError: _confirmError,
        onToggleObscure: () => setState(() => _obscure = !_obscure),
        onSubmit: _submit,
      ),
    );
  }
}

class _SignUpForm extends StatelessWidget {
  const _SignUpForm({
    required this.first,
    required this.last,
    required this.email,
    required this.phone,
    required this.password,
    required this.confirm,
    required this.obscure,
    required this.emailError,
    required this.passwordError,
    required this.confirmError,
    required this.onToggleObscure,
    required this.onSubmit,
  });

  final TextEditingController first;
  final TextEditingController last;
  final TextEditingController email;
  final TextEditingController phone;
  final TextEditingController password;
  final TextEditingController confirm;
  final bool obscure;
  final String? emailError;
  final String? passwordError;
  final String? confirmError;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Create your account', style: context.text.headlineLarge),
        const SizedBox(height: WsSpacing.xs),
        Text(
          'Basic profile and job search are always free.',
          style: context.text.bodyMedium
              ?.copyWith(color: context.colors.onSurfaceVariant),
        ),
        const SizedBox(height: WsSpacing.xxl),
        WsField(
          label: 'First Name',
          required: true,
          controller: first,
          hint: mockCandidate.firstName,
          leadingIcon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: WsSpacing.xl),
        WsField(
          label: 'Last Name',
          required: true,
          controller: last,
          hint: mockCandidate.lastName,
          leadingIcon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: WsSpacing.xl),
        WsField(
          label: 'Email',
          required: true,
          controller: email,
          // TODO(backend): back to 'name@example.com' with the mock.
          hint: mockCandidate.email,
          error: emailError,
          keyboardType: TextInputType.emailAddress,
          leadingIcon: Icons.mail_outline_rounded,
        ),
        const SizedBox(height: WsSpacing.xl),
        WsPhoneField(
          label: 'Phone Number',
          required: true,
          controller: phone,
        ),
        const SizedBox(height: WsSpacing.xl),
        WsField(
          label: 'Password',
          required: true,
          controller: password,
          obscure: obscure,
          error: passwordError,
          helper: 'At least 6 characters',
          leadingIcon: Icons.lock_outline_rounded,
          trailingIcon: obscure
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          onTrailingTap: onToggleObscure,
        ),
        const SizedBox(height: WsSpacing.xl),
        WsField(
          label: 'Confirm Password',
          required: true,
          controller: confirm,
          obscure: obscure,
          error: confirmError,
          leadingIcon: Icons.lock_outline_rounded,
        ),
        const SizedBox(height: WsSpacing.xxl),
        WsPrimaryButton(label: 'Create Account', onPressed: onSubmit),
        const SizedBox(height: WsSpacing.xxl),
        const SocialSignInRow(),
        const SizedBox(height: WsSpacing.xxl),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                'Already have an account?',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.bodyMedium
                    ?.copyWith(color: context.colors.onSurfaceVariant),
              ),
            ),
            WsLink(
              label: 'Sign In',
              onPressed: () => context.go(Routes.signIn),
            ),
          ],
        ),
      ],
    );
  }
}
