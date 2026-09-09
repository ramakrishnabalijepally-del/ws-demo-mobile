import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/theme/theme.dart';
import '../../../../../shared/data/mock_candidate.dart';
import '../../../../../shared/shared.dart';

/// Editing the profile.
///
/// The design deck shows this as the profile screen with its fields already
/// editable. Splitting it out means the read view stays scannable and the edit
/// view can hold a save action, which is the pattern the rest of the app uses.
class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  late final TextEditingController _first;
  late final TextEditingController _last;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _dob;
  late final TextEditingController _occupation;
  late final TextEditingController _city;

  String? _emailError;

  @override
  void initState() {
    super.initState();
    final c = ref.read(candidateProvider);
    _first = TextEditingController(text: c.firstName);
    _last = TextEditingController(text: c.lastName);
    _email = TextEditingController(text: c.email);
    _phone = TextEditingController(text: c.phone);
    _dob = TextEditingController(text: c.dateOfBirth);
    _occupation = TextEditingController(text: c.occupation);
    _city = TextEditingController(text: c.city);
  }

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _email.dispose();
    _phone.dispose();
    _dob.dispose();
    _occupation.dispose();
    _city.dispose();
    super.dispose();
  }

  void _save() {
    final email = _email.text.trim();
    setState(() {
      _emailError = email.contains('@') && email.contains('.')
          ? null
          : 'Enter a complete email address, like name@example.com';
    });
    if (_emailError != null) return;

    ref.read(candidateProvider.notifier).update(
          ref.read(candidateProvider).copyWith(
                firstName: _first.text.trim(),
                lastName: _last.text.trim(),
                email: email,
                phone: _phone.text.trim(),
                dateOfBirth: _dob.text.trim(),
                occupation: _occupation.text.trim(),
                city: _city.text.trim(),
              ),
        );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          WsSpacing.xl,
          WsSpacing.lg,
          WsSpacing.xl,
          WsSpacing.huge,
        ),
        children: [
          WsField(
            label: 'First Name',
            required: true,
            controller: _first,
            leadingIcon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: WsSpacing.xl),
          WsField(
            label: 'Last Name',
            required: true,
            controller: _last,
            leadingIcon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: WsSpacing.xl),
          WsField(
            label: 'Email',
            required: true,
            controller: _email,
            error: _emailError,
            keyboardType: TextInputType.emailAddress,
            leadingIcon: Icons.mail_outline_rounded,
          ),
          const SizedBox(height: WsSpacing.xl),
          WsField(
            label: 'Phone',
            controller: _phone,
            keyboardType: TextInputType.phone,
            leadingIcon: Icons.phone_outlined,
          ),
          const SizedBox(height: WsSpacing.xl),
          WsField(
            label: 'Date of Birth',
            controller: _dob,
            helper: 'Four-digit year, month, day',
            leadingIcon: Icons.calendar_today_outlined,
          ),
          const SizedBox(height: WsSpacing.xl),
          WsField(
            label: 'Occupation',
            controller: _occupation,
            leadingIcon: Icons.work_outline_rounded,
          ),
          const SizedBox(height: WsSpacing.xl),
          WsField(
            label: 'City',
            controller: _city,
            leadingIcon: Icons.location_city_outlined,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            WsSpacing.xl,
            WsSpacing.md,
            WsSpacing.xl,
            WsSpacing.lg,
          ),
          child: WsPrimaryButton(
            label: 'Save changes',
            forward: false,
            onPressed: _save,
          ),
        ),
      ),
    );
  }
}
