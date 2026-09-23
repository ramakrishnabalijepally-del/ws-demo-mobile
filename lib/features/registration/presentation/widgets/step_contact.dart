import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/theme.dart';
import '../../../../shared/shared.dart';
import '../../controllers/registration_controller.dart';
import '../screens/registration_screen.dart';

/// C3 — Contact Information.
class StepContact extends ConsumerStatefulWidget {
  const StepContact({super.key});

  @override
  ConsumerState<StepContact> createState() => _StepContactState();
}

class _StepContactState extends ConsumerState<StepContact> {
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _city;

  String? _province;
  String? _emailError;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(registrationProvider).draft;
    _email = TextEditingController(text: draft.email);
    _phone = TextEditingController(text: draft.phone);
    _city = TextEditingController(text: draft.city);
    _province = draft.province.isEmpty ? null : draft.province;
  }

  @override
  void dispose() {
    _email.dispose();
    _phone.dispose();
    _city.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _email.text.trim();
    setState(() {
      _emailError = email.contains('@') && email.contains('.')
          ? null
          : 'Enter a complete email address, like name@example.com';
    });
    if (_emailError != null) return;

    final controller = ref.read(registrationProvider.notifier);
    controller.update(
      ref.read(registrationProvider).draft.copyWith(
            email: email,
            phone: _phone.text.trim(),
            city: _city.text.trim(),
            province: _province ?? '',
          ),
    );
    controller.next();
  }

  @override
  Widget build(BuildContext context) {
    return RegistrationStepScaffold(
      headline: 'How can we reach you?',
      supporting: 'Where you live decides which provincial programs you can '
          'apply to, so it is worth getting right.',
      primaryLabel: 'Continue',
      onPrimary: _submit,
      children: [
        WsField(
          label: 'Email',
          required: true,
          controller: _email,
          hint: 'name@example.com',
          error: _emailError,
          keyboardType: TextInputType.emailAddress,
          leadingIcon: Icons.mail_outline_rounded,
        ),
        const SizedBox(height: WsSpacing.xl),
        WsPhoneField(label: 'Phone Number', required: true, controller: _phone),
        const SizedBox(height: WsSpacing.xl),
        WsLocationFields(
          city: _city,
          province: _province,
          required: true,
          onProvinceChanged: (p) => setState(() => _province = p),
        ),
      ],
    );
  }
}
