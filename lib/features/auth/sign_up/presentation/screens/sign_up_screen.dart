import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/routes.dart';
import '../../../../../app/theme/theme.dart';
import '../../../../../shared/shared.dart';
import '../../../sign_in/presentation/widgets/social_sign_in_row.dart';

/// B4 — create an account.
///
/// Creating the account leads into the registration flow rather than straight
/// to the dashboard: design system Pattern A puts one decision per screen and
/// a review before anything is committed.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  bool _obscure = true;
  String? _passwordError;
  String? _confirmError;

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() {
      _passwordError = _password.text.length < 6
          ? 'Choose a password of at least 6 characters'
          : null;
      _confirmError = _confirm.text == _password.text
          ? null
          : 'Both password fields need to match. Re-type it to confirm';
    });

    if (_passwordError == null && _confirmError == null) {
      context.go(Routes.registration);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: WsSpacing.xl,
            vertical: WsSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(child: WsWordmark(width: 170)),
              const SizedBox(height: WsSpacing.xxl),
              Text(
                'Create your account',
                style: context.text.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: WsSpacing.sm),
              Text(
                'Basic profile and job search are always free.',
                style: context.text.bodyMedium
                    ?.copyWith(color: context.colors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: WsSpacing.xxl),
              WsField(
                label: 'First Name',
                required: true,
                controller: _first,
                hint: 'Adam',
                leadingIcon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: WsSpacing.lg),
              WsField(
                label: 'Last Name',
                required: true,
                controller: _last,
                hint: 'Smith',
                leadingIcon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: WsSpacing.lg),
              WsPhoneField(
                label: 'Phone Number',
                required: true,
                controller: _phone,
              ),
              const SizedBox(height: WsSpacing.lg),
              WsField(
                label: 'Password',
                required: true,
                controller: _password,
                obscure: _obscure,
                error: _passwordError,
                helper: 'At least 6 characters',
                leadingIcon: Icons.lock_outline_rounded,
                trailingIcon: _obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                onTrailingTap: () => setState(() => _obscure = !_obscure),
              ),
              const SizedBox(height: WsSpacing.lg),
              WsField(
                label: 'Confirm Password',
                required: true,
                controller: _confirm,
                obscure: _obscure,
                error: _confirmError,
                leadingIcon: Icons.lock_outline_rounded,
              ),
              const SizedBox(height: WsSpacing.xxl),
              WsPrimaryButton(label: 'Create Account', onPressed: _submit),
              const SizedBox(height: WsSpacing.xxl),
              const SocialSignInRow(),
              const SizedBox(height: WsSpacing.xl),
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
          ),
        ),
      ),
    );
  }
}
