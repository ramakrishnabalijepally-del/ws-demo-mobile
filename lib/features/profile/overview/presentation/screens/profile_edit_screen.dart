import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/theme/theme.dart';
import '../../../../../shared/data/mock_candidate.dart';
import '../../../../../shared/models/candidate.dart';
import '../../../../../shared/models/crs_profile.dart';
import '../../../../../shared/models/immigration_details.dart';
import '../../../../../shared/shared.dart';
import '../../../completion/presentation/widgets/form_controls.dart';

/// Which half of the profile the edit screen opens on.
enum ProfileEditTab { basic, immigration }

/// Editing the profile, in two tabs: Basic and Immigration.
///
/// One Save covers both, so switching tabs never loses what was typed in the
/// other. Family in Canada is the same answer the CRS additional factors ask
/// for, so saving it here moves the CRS score too.
class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({this.initialTab = ProfileEditTab.basic, super.key});

  final ProfileEditTab initialTab;

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(
    length: ProfileEditTab.values.length,
    vsync: this,
    initialIndex: widget.initialTab.index,
  );

  // Basic
  late final TextEditingController _first;
  late final TextEditingController _last;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _dob;
  late final TextEditingController _occupation;
  late final TextEditingController _country;

  // Immigration
  late final TextEditingController _passportNumber;
  late final TextEditingController _passportIssue;
  late final TextEditingController _passportExpiry;
  late final TextEditingController _statusIssue;
  late final TextEditingController _statusExpiry;
  CanadianStatus? _status;
  Set<FamilyInCanada>? _family;
  late String _profileType;

  String? _emailError;
  final Map<TextEditingController, String> _dateErrors = {};

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
    _country = TextEditingController(text: c.countryOfOrigin);
    _profileType = c.profileType;

    final i = c.immigration;
    _passportNumber = TextEditingController(text: i.passportNumber);
    _passportIssue = TextEditingController(text: i.passportIssueDate);
    _passportExpiry = TextEditingController(text: i.passportExpiryDate);
    _statusIssue = TextEditingController(text: i.statusIssueDate);
    _statusExpiry = TextEditingController(text: i.statusExpiryDate);
    _status = i.status;
    _family = c.crs.familyInCanada;
  }

  @override
  void dispose() {
    for (final controller in [
      _first,
      _last,
      _email,
      _phone,
      _dob,
      _occupation,
      _country,
      _passportNumber,
      _passportIssue,
      _passportExpiry,
      _statusIssue,
      _statusExpiry,
    ]) {
      controller.dispose();
    }
    _tabs.dispose();
    super.dispose();
  }

  static final RegExp _datePattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  /// Empty is allowed — not every candidate has a status or a passport to
  /// hand. Anything typed must be a real date.
  String? _dateError(TextEditingController controller) {
    final text = controller.text.trim();
    if (text.isEmpty) return null;
    if (!_datePattern.hasMatch(text) || DateTime.tryParse(text) == null) {
      return 'Enter the date as YYYY-MM-DD';
    }
    return null;
  }

  String? _orderError(
    TextEditingController issue,
    TextEditingController expiry,
    String what,
  ) {
    final from = DateTime.tryParse(issue.text.trim());
    final to = DateTime.tryParse(expiry.text.trim());
    if (from == null || to == null || to.isAfter(from)) return null;
    return 'The expiry date must be after the $what issue date';
  }

  void _save() {
    final email = _email.text.trim();
    final dateFields = [
      _dob,
      _passportIssue,
      _passportExpiry,
      if (_status != null) ...[_statusIssue, _statusExpiry],
    ];

    setState(() {
      _emailError = email.contains('@') && email.contains('.')
          ? null
          : 'Enter a complete email address, like name@example.com';
      _dateErrors.clear();
      for (final field in dateFields) {
        final error = _dateError(field);
        if (error != null) _dateErrors[field] = error;
      }
      final passportOrder =
          _orderError(_passportIssue, _passportExpiry, 'passport');
      if (passportOrder != null) {
        _dateErrors.putIfAbsent(_passportExpiry, () => passportOrder);
      }
      if (_status != null) {
        final statusOrder = _orderError(_statusIssue, _statusExpiry, 'status');
        if (statusOrder != null) {
          _dateErrors.putIfAbsent(_statusExpiry, () => statusOrder);
        }
      }
    });

    final basicInvalid = _emailError != null || _dateErrors.containsKey(_dob);
    if (basicInvalid) {
      _tabs.animateTo(ProfileEditTab.basic.index);
      return;
    }
    if (_dateErrors.isNotEmpty) {
      _tabs.animateTo(ProfileEditTab.immigration.index);
      return;
    }

    final current = ref.read(candidateProvider);
    // TODO(backend): saved in memory only.
    ref.read(candidateProvider.notifier).update(
          current.copyWith(
            firstName: _first.text.trim(),
            lastName: _last.text.trim(),
            email: email,
            phone: _phone.text.trim(),
            dateOfBirth: _dob.text.trim(),
            occupation: _occupation.text.trim(),
            countryOfOrigin: _country.text.trim(),
            profileType: _profileType,
            immigration: ImmigrationDetails(
              passportNumber: _passportNumber.text.trim(),
              passportIssueDate: _passportIssue.text.trim(),
              passportExpiryDate: _passportExpiry.text.trim(),
              status: _status,
              statusIssueDate: _status == null ? '' : _statusIssue.text.trim(),
              statusExpiryDate:
                  _status == null ? '' : _statusExpiry.text.trim(),
            ),
            crs: current.crs.copyWith(familyInCanada: _family),
          ),
        );

    final messenger = ScaffoldMessenger.of(context);
    context.pop();
    messenger.showSnackBar(const SnackBar(content: Text('Profile saved')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit profile'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Basic profile'),
            Tab(text: 'Immigration profile'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _BasicForm(
            first: _first,
            last: _last,
            email: _email,
            emailError: _emailError,
            phone: _phone,
            dob: _dob,
            dobError: _dateErrors[_dob],
            occupation: _occupation,
            country: _country,
            profileType: _profileType,
            onProfileType: (value) => setState(() => _profileType = value),
          ),
          _ImmigrationForm(
            passportNumber: _passportNumber,
            passportIssue: _passportIssue,
            passportExpiry: _passportExpiry,
            status: _status,
            statusIssue: _statusIssue,
            statusExpiry: _statusExpiry,
            family: _family,
            errors: _dateErrors,
            onStatus: (status) => setState(() => _status = status),
            onFamily: (family) => setState(() => _family = family),
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

const EdgeInsets _formPadding = EdgeInsets.fromLTRB(
  WsSpacing.xl,
  WsSpacing.xl,
  WsSpacing.xl,
  WsSpacing.huge,
);

class _BasicForm extends StatelessWidget {
  const _BasicForm({
    required this.first,
    required this.last,
    required this.email,
    required this.emailError,
    required this.phone,
    required this.dob,
    required this.dobError,
    required this.occupation,
    required this.country,
    required this.profileType,
    required this.onProfileType,
  });

  final TextEditingController first;
  final TextEditingController last;
  final TextEditingController email;
  final String? emailError;
  final TextEditingController phone;
  final TextEditingController dob;
  final String? dobError;
  final TextEditingController occupation;
  final TextEditingController country;
  final String profileType;
  final ValueChanged<String> onProfileType;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: _formPadding,
      children: [
        WsField(
          label: 'First Name',
          required: true,
          controller: first,
          leadingIcon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: WsSpacing.xl),
        WsField(
          label: 'Last Name',
          required: true,
          controller: last,
          leadingIcon: Icons.person_outline_rounded,
        ),
        const SizedBox(height: WsSpacing.xl),
        WsField(
          label: 'Email',
          required: true,
          controller: email,
          error: emailError,
          keyboardType: TextInputType.emailAddress,
          leadingIcon: Icons.mail_outline_rounded,
        ),
        const SizedBox(height: WsSpacing.xl),
        WsField(
          label: 'Phone',
          controller: phone,
          keyboardType: TextInputType.phone,
          leadingIcon: Icons.phone_outlined,
        ),
        const SizedBox(height: WsSpacing.xl),
        WsField(
          label: 'Date of Birth',
          controller: dob,
          error: dobError,
          helper: 'YYYY-MM-DD. Also used for your CRS and PNP scores.',
          leadingIcon: Icons.calendar_today_outlined,
        ),
        const SizedBox(height: WsSpacing.xl),
        WsField(
          label: 'Occupation',
          controller: occupation,
          leadingIcon: Icons.work_outline_rounded,
        ),
        const SizedBox(height: WsSpacing.xl),
        WsField(
          label: 'Country you are from',
          controller: country,
          helper: 'Shown with its flag on your profile',
          leadingIcon: Icons.public_outlined,
        ),
        const SizedBox(height: WsSpacing.xxl),
        ChoiceGroup<String>(
          question: 'You are a',
          options: candidateProfileTypes,
          labelOf: (type) => type,
          selected: profileType.isEmpty ? null : profileType,
          onSelected: onProfileType,
        ),
      ],
    );
  }
}

class _ImmigrationForm extends StatelessWidget {
  const _ImmigrationForm({
    required this.passportNumber,
    required this.passportIssue,
    required this.passportExpiry,
    required this.status,
    required this.statusIssue,
    required this.statusExpiry,
    required this.family,
    required this.errors,
    required this.onStatus,
    required this.onFamily,
  });

  final TextEditingController passportNumber;
  final TextEditingController passportIssue;
  final TextEditingController passportExpiry;
  final CanadianStatus? status;
  final TextEditingController statusIssue;
  final TextEditingController statusExpiry;
  final Set<FamilyInCanada>? family;
  final Map<TextEditingController, String> errors;
  final ValueChanged<CanadianStatus?> onStatus;
  final ValueChanged<Set<FamilyInCanada>> onFamily;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: _formPadding,
      children: [
        const _FormHeading(
          icon: Icons.badge_outlined,
          title: 'Passport',
        ),
        const SizedBox(height: WsSpacing.lg),
        WsField(
          label: 'Passport number',
          controller: passportNumber,
          leadingIcon: Icons.numbers_rounded,
        ),
        const SizedBox(height: WsSpacing.xl),
        _DatePair(
          issue: passportIssue,
          expiry: passportExpiry,
          errors: errors,
        ),
        const SizedBox(height: WsSpacing.xxxl),
        const _FormHeading(
          icon: Icons.assignment_ind_outlined,
          title: 'Status in Canada',
        ),
        const SizedBox(height: WsSpacing.lg),
        ChoiceGroup<CanadianStatus?>(
          question: 'What is your current status?',
          options: const [...CanadianStatus.values, null],
          labelOf: (s) => s?.label ?? 'No status in Canada yet',
          selected: status,
          onSelected: onStatus,
        ),
        // Dates only mean something once there is a status to date.
        AnimatedSize(
          duration: WsMotion.duration(context, WsMotion.medium),
          curve: WsMotion.standard,
          alignment: Alignment.topCenter,
          child: status == null
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(top: WsSpacing.lg),
                  child: _DatePair(
                    issue: statusIssue,
                    expiry: statusExpiry,
                    errors: errors,
                  ),
                ),
        ),
        const SizedBox(height: WsSpacing.xxxl),
        const _FormHeading(
          icon: Icons.family_restroom_rounded,
          title: 'Family in Canada',
        ),
        const SizedBox(height: WsSpacing.lg),
        FamilyInCanadaQuestion(value: family, onChanged: onFamily),
        const SizedBox(height: WsSpacing.md),
        const WsSyncNote(
          message: 'The same answer as in your CRS profile — change it here '
              'and your CRS score updates too.',
        ),
      ],
    );
  }
}

class _FormHeading extends StatelessWidget {
  const _FormHeading({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        WsIconTile(icon: icon, size: WsTileSize.compact),
        const SizedBox(width: WsSpacing.md),
        Expanded(child: Text(title, style: context.text.titleLarge)),
      ],
    );
  }
}

/// Issue and expiry dates, stacked so both fit a 360 dp phone at any text
/// size.
class _DatePair extends StatelessWidget {
  const _DatePair({
    required this.issue,
    required this.expiry,
    required this.errors,
  });

  final TextEditingController issue;
  final TextEditingController expiry;
  final Map<TextEditingController, String> errors;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WsField(
          label: 'Issue date',
          controller: issue,
          error: errors[issue],
          helper: 'YYYY-MM-DD',
          keyboardType: TextInputType.datetime,
          leadingIcon: Icons.event_outlined,
        ),
        const SizedBox(height: WsSpacing.xl),
        WsField(
          label: 'Expiry date',
          controller: expiry,
          error: errors[expiry],
          helper: 'YYYY-MM-DD',
          keyboardType: TextInputType.datetime,
          leadingIcon: Icons.event_busy_outlined,
        ),
      ],
    );
  }
}
