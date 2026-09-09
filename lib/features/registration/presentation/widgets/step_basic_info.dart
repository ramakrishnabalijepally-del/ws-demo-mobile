import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/theme.dart';
import '../../../../shared/shared.dart';
import '../../controllers/registration_controller.dart';
import '../screens/registration_screen.dart';

/// C2 — Basic Information.
///
/// The date field asks for its format in the label's helper rather than
/// correcting the reader afterwards: *"Enter your date of birth as
/// YYYY-MM-DD"*, which is the design system's own example of naming the fix
/// (section 20).
class StepBasicInfo extends ConsumerStatefulWidget {
  const StepBasicInfo({super.key});

  @override
  ConsumerState<StepBasicInfo> createState() => _StepBasicInfoState();
}

class _StepBasicInfoState extends ConsumerState<StepBasicInfo> {
  late final TextEditingController _first;
  late final TextEditingController _last;
  late final TextEditingController _dob;
  late final TextEditingController _country;

  String? _dobError;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(registrationProvider).draft;
    _first = TextEditingController(text: draft.firstName);
    _last = TextEditingController(text: draft.lastName);
    _dob = TextEditingController(text: draft.dateOfBirth);
    _country = TextEditingController(text: draft.countryOfOrigin);
  }

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _dob.dispose();
    _country.dispose();
    super.dispose();
  }

  static final RegExp _isoDate = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  void _submit() {
    setState(() {
      _dobError = _isoDate.hasMatch(_dob.text.trim())
          ? null
          : 'Enter your date of birth as YYYY-MM-DD';
    });
    if (_dobError != null) return;

    final controller = ref.read(registrationProvider.notifier);
    controller.update(
      ref.read(registrationProvider).draft.copyWith(
            firstName: _first.text.trim(),
            lastName: _last.text.trim(),
            dateOfBirth: _dob.text.trim(),
            countryOfOrigin: _country.text.trim(),
          ),
    );
    controller.next();
  }

  @override
  Widget build(BuildContext context) {
    return RegistrationStepScaffold(
      headline: "Let's get you started",
      supporting: 'Use the spelling exactly as it appears on your passport — '
          'immigration programs match on it.',
      primaryLabel: 'Continue',
      onPrimary: _submit,
      children: [
        WsField(
          label: 'First Name',
          required: true,
          controller: _first,
          hint: 'Adam',
          leadingIcon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: WsSpacing.xl),
        WsField(
          label: 'Last Name',
          required: true,
          controller: _last,
          hint: 'Smith',
          leadingIcon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: WsSpacing.xl),
        WsField(
          label: 'Date of Birth',
          required: true,
          controller: _dob,
          hint: '1995-12-27',
          helper: 'Four-digit year, month, day',
          error: _dobError,
          leadingIcon: Icons.calendar_today_outlined,
        ),
        const SizedBox(height: WsSpacing.xl),
        WsField(
          label: 'Country of Origin',
          required: true,
          controller: _country,
          hint: 'United Kingdom',
          leadingIcon: Icons.public_outlined,
        ),
      ],
    );
  }
}
