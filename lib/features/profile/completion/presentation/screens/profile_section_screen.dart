import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/theme/theme.dart';
import '../../../../../shared/data/mock_candidate.dart';
import '../../../../../shared/models/crs_profile.dart';
import '../../../../../shared/models/profile_section.dart';
import '../../../../../shared/shared.dart';
import '../../../../../shared/utils/crs_calculator.dart';
import '../widgets/section_forms.dart';

/// One profile section's form.
///
/// Answers are held as a draft until Save, and the bar at the bottom shows the
/// CRS score those answers would give — so the reader sees what each answer is
/// worth before committing it.
///
/// **The same screen serves the profile and the CRS Predictor.** Both write to
/// the one candidate profile, and the score is calculated from it, so an answer
/// given in either place is already in the other. Only the wording changes, to
/// say where the answers are going.
class ProfileSectionScreen extends ConsumerStatefulWidget {
  const ProfileSectionScreen({
    required this.sectionId,
    this.fromCrs = false,
    super.key,
  });

  /// A [ProfileSection] name, from the route.
  final String sectionId;

  /// Opened from the CRS Predictor in Immigration rather than from Profile.
  final bool fromCrs;

  @override
  ConsumerState<ProfileSectionScreen> createState() =>
      _ProfileSectionScreenState();
}

class _ProfileSectionScreenState extends ConsumerState<ProfileSectionScreen> {
  late CrsProfile _draft = ref.read(candidateProvider).crs;

  late final TextEditingController _dateOfBirth =
      TextEditingController(text: ref.read(candidateProvider).dateOfBirth);

  String? _dateOfBirthError;

  ProfileSection? get _section => ProfileSection.values
      .where((section) => section.name == widget.sectionId)
      .firstOrNull;

  @override
  void dispose() {
    _dateOfBirth.dispose();
    super.dispose();
  }

  static int? _ageFrom(String dateOfBirth) {
    final birth = DateTime.tryParse(dateOfBirth.trim());
    return birth == null ? null : ageOn(birth, DateTime.now());
  }

  void _save() {
    var next = ref.read(candidateProvider).copyWith(crs: _draft);

    if (_section == ProfileSection.aboutYou) {
      final dateOfBirth = _dateOfBirth.text.trim();
      final valid = RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dateOfBirth) &&
          DateTime.tryParse(dateOfBirth) != null;
      if (!valid) {
        setState(
          () => _dateOfBirthError = 'Enter your date of birth as YYYY-MM-DD',
        );
        return;
      }
      next = next.copyWith(dateOfBirth: dateOfBirth);
    }

    // TODO(backend): saved in memory only.
    ref.read(candidateProvider.notifier).update(next);

    final score = calculateCrs(next.crs, age: _ageFrom(next.dateOfBirth)).total;
    final messenger = ScaffoldMessenger.of(context);
    context.pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          widget.fromCrs
              ? 'Saved to your profile. Your CRS score is $score.'
              : 'Saved. Your CRS score in Immigration is now $score.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final section = _section;
    if (section == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: WsEmptyState(
          icon: Icons.person_search_outlined,
          headline: 'That section does not exist',
          body: 'Your profile sections are one screen back.',
          actionLabel: 'Back',
          onAction: () => context.pop(),
        ),
      );
    }

    final candidate = ref.watch(candidateProvider);
    final savedAge = _ageFrom(candidate.dateOfBirth);
    final draftAge = section == ProfileSection.aboutYou
        ? _ageFrom(_dateOfBirth.text)
        : savedAge;

    return Scaffold(
      appBar: AppBar(title: Text(section.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          WsSpacing.xl,
          WsSpacing.lg,
          WsSpacing.xl,
          WsSpacing.xxxl,
        ),
        children: [
          Text(
            section.summary,
            style: context.text.bodyMedium
                ?.copyWith(color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(height: WsSpacing.lg),
          WsSyncNote(
            message: widget.fromCrs
                ? 'These answers are saved to your profile, so you only enter '
                    'them once.'
                : 'These answers also calculate your CRS score in '
                    'Immigration.',
          ),
          const SizedBox(height: WsSpacing.xxl),
          SectionForm(
            section: section,
            draft: _draft,
            dateOfBirth: _dateOfBirth,
            dateOfBirthError: _dateOfBirthError,
            onChanged: (profile) => setState(() => _draft = profile),
            onDateOfBirthChanged: () =>
                setState(() => _dateOfBirthError = null),
          ),
          const SizedBox(height: WsSpacing.xxl),
          const WsDisclaimer(),
        ],
      ),
      bottomNavigationBar: _SaveBar(
        before: calculateCrs(candidate.crs, age: savedAge).total,
        after: calculateCrs(_draft, age: draftAge).total,
        onSave: _save,
      ),
    );
  }
}

class _SaveBar extends StatelessWidget {
  const _SaveBar({
    required this.before,
    required this.after,
    required this.onSave,
  });

  final int before;
  final int after;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final delta = after - before;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(top: BorderSide(color: context.colors.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            WsSpacing.xl,
            WsSpacing.md,
            WsSpacing.xl,
            WsSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'CRS score with these answers',
                          style: context.text.bodySmall
                              ?.copyWith(color: context.ws.caption),
                        ),
                        Semantics(
                          label: '$after',
                          liveRegion: true,
                          excludeSemantics: true,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(
                              begin: before.toDouble(),
                              end: after.toDouble(),
                            ),
                            duration:
                                WsMotion.duration(context, WsMotion.focal),
                            curve: WsMotion.entrance,
                            builder: (context, value, _) => Text(
                              '${value.round()}',
                              style: context.text.displaySmall,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (delta != 0) _Delta(delta: delta),
                ],
              ),
              const SizedBox(height: WsSpacing.md),
              WsPrimaryButton(label: 'Save', forward: false, onPressed: onSave),
            ],
          ),
        ),
      ),
    );
  }
}

/// The change from the saved score. Ink, with a direction glyph — a lower
/// number is information, never a warning.
class _Delta extends StatelessWidget {
  const _Delta({required this.delta});

  final int delta;

  @override
  Widget build(BuildContext context) {
    final up = delta > 0;
    return Semantics(
      label: '${up ? 'Up' : 'Down'} ${delta.abs()} points from your saved '
          'score',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            up ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            size: WsIconSize.field,
            color: context.colors.onSurface,
          ),
          const SizedBox(width: WsSpacing.xs),
          Text(
            '${up ? '+' : '−'}${delta.abs()}',
            style: context.text.titleMedium,
          ),
        ],
      ),
    );
  }
}
