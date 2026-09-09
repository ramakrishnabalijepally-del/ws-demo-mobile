import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/routes.dart';
import '../../../../../app/theme/theme.dart';
import '../../../../../shared/shared.dart';

/// B5 — where should we send the reset?
///
/// The deck gives this screen a solid red app bar. That is dropped: red is
/// brand and action, and a screen-wide red header on a "something went wrong"
/// flow reads as an alarm (design system section 2). The standard app bar plus
/// a red primary button says the same thing more calmly.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _email.text.trim();
    setState(() {
      _error = email.contains('@') && email.contains('.')
          ? null
          : 'Enter the email address on your account, like name@example.com';
    });
    if (_error == null) context.push(Routes.resetMethod);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: WsSpacing.xl,
            vertical: WsSpacing.xxl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Forgot your password?', style: context.text.titleLarge),
              const SizedBox(height: WsSpacing.sm),
              Text(
                'Tell us the email address on your account and we will send you '
                'a link to set a new password.',
                style: context.text.bodyMedium
                    ?.copyWith(color: context.colors.onSurfaceVariant),
              ),
              const SizedBox(height: WsSpacing.xxl),
              WsField(
                label: 'Email',
                required: true,
                controller: _email,
                hint: 'name@example.com',
                error: _error,
                keyboardType: TextInputType.emailAddress,
                trailingIcon: Icons.mail_outline_rounded,
              ),
              const Spacer(),
              WsPrimaryButton(label: 'Continue', onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
