import 'package:flutter/material.dart';

import '../../../../../app/theme/theme.dart';
import '../../../../../shared/models/crs_profile.dart';
import '../../../../../shared/models/profile_section.dart';
import '../../../../../shared/shared.dart';
import 'form_controls.dart';
import 'language_test_editor.dart';

/// The questions for one profile section. Every question maps to a CRS factor
/// on IRCC's grid; the helper lines say what each one is worth.
class SectionForm extends StatelessWidget {
  const SectionForm({
    required this.section,
    required this.draft,
    required this.dateOfBirth,
    required this.dateOfBirthError,
    required this.onChanged,
    required this.onDateOfBirthChanged,
    super.key,
  });

  final ProfileSection section;
  final CrsProfile draft;
  final TextEditingController dateOfBirth;
  final String? dateOfBirthError;
  final ValueChanged<CrsProfile> onChanged;
  final VoidCallback onDateOfBirthChanged;

  @override
  Widget build(BuildContext context) {
    return switch (section) {
      ProfileSection.aboutYou => _AboutYouForm(
          draft: draft,
          dateOfBirth: dateOfBirth,
          dateOfBirthError: dateOfBirthError,
          onChanged: onChanged,
          onDateOfBirthChanged: onDateOfBirthChanged,
        ),
      ProfileSection.education =>
        _EducationForm(draft: draft, onChanged: onChanged),
      ProfileSection.language =>
        _LanguageForm(draft: draft, onChanged: onChanged),
      ProfileSection.work => _WorkForm(draft: draft, onChanged: onChanged),
      ProfileSection.spouse => _SpouseForm(draft: draft, onChanged: onChanged),
      ProfileSection.additional =>
        AdditionalFactorsForm(draft: draft, onChanged: onChanged),
    };
  }
}

const Widget _gap = SizedBox(height: WsSpacing.xxxl);

class _AboutYouForm extends StatelessWidget {
  const _AboutYouForm({
    required this.draft,
    required this.dateOfBirth,
    required this.dateOfBirthError,
    required this.onChanged,
    required this.onDateOfBirthChanged,
  });

  final CrsProfile draft;
  final TextEditingController dateOfBirth;
  final String? dateOfBirthError;
  final ValueChanged<CrsProfile> onChanged;
  final VoidCallback onDateOfBirthChanged;

  @override
  Widget build(BuildContext context) {
    final hasPartner = draft.maritalStatus?.hasPartner ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WsField(
          label: 'Date of birth',
          required: true,
          controller: dateOfBirth,
          hint: 'YYYY-MM-DD',
          helper: 'Age is worth up to 110 points, most between 20 and 29.',
          error: dateOfBirthError,
          keyboardType: TextInputType.datetime,
          leadingIcon: Icons.calendar_today_outlined,
          onChanged: (_) => onDateOfBirthChanged(),
        ),
        _gap,
        ChoiceGroup<MaritalStatus>(
          question: 'What is your marital status?',
          options: MaritalStatus.values,
          labelOf: (status) => status.label,
          selected: draft.maritalStatus,
          onSelected: (status) => onChanged(
            draft.copyWith(
              maritalStatus: status,
              spouseAccompanying:
                  status.hasPartner ? draft.spouseAccompanying : null,
              spouseCanadianOrPr:
                  status.hasPartner ? draft.spouseCanadianOrPr : null,
            ),
          ),
        ),
        if (hasPartner) ...[
          _gap,
          YesNoQuestion(
            question: 'Will your spouse or partner come with you to Canada?',
            value: draft.spouseAccompanying,
            onChanged: (coming) => onChanged(
              draft.copyWith(
                spouseAccompanying: coming,
                spouseCanadianOrPr: coming ? draft.spouseCanadianOrPr : null,
              ),
            ),
          ),
        ],
        if (hasPartner && draft.spouseAccompanying == true) ...[
          _gap,
          YesNoQuestion(
            question: 'Are they a Canadian citizen or permanent resident?',
            helper: 'If they are, you are scored as a single applicant.',
            value: draft.spouseCanadianOrPr,
            onChanged: (value) =>
                onChanged(draft.copyWith(spouseCanadianOrPr: value)),
          ),
        ],
      ],
    );
  }
}

class _EducationForm extends StatelessWidget {
  const _EducationForm({required this.draft, required this.onChanged});

  final CrsProfile draft;
  final ValueChanged<CrsProfile> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ChoiceGroup<EducationLevel>(
          question: 'What is your highest level of education?',
          helper: 'Education completed outside Canada needs an Educational '
              'Credential Assessment (ECA) to count.',
          options: EducationLevel.values,
          labelOf: (level) => level.label,
          selected: draft.education,
          onSelected: (level) => onChanged(draft.copyWith(education: level)),
        ),
        _gap,
        ChoiceGroup<CanadianEducation>(
          question: 'Have you studied in Canada?',
          helper: 'A Canadian post-secondary credential adds up to 30 points.',
          options: CanadianEducation.values,
          labelOf: (education) => education.label,
          selected: draft.canadianEducation,
          onSelected: (education) =>
              onChanged(draft.copyWith(canadianEducation: education)),
        ),
      ],
    );
  }
}

class _LanguageForm extends StatelessWidget {
  const _LanguageForm({required this.draft, required this.onChanged});

  final CrsProfile draft;
  final ValueChanged<CrsProfile> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Enter the scores exactly as they appear on your report. Results '
          'must be less than two years old when you apply.',
          style: context.text.bodySmall?.copyWith(color: context.ws.caption),
        ),
        const SizedBox(height: WsSpacing.xl),
        LanguageTestEditor(
          title: 'English test',
          tests: const [
            LanguageTest.ielts,
            LanguageTest.celpip,
            LanguageTest.pteCore,
          ],
          result: draft.englishTest,
          onChanged: (result) => onChanged(draft.copyWith(englishTest: result)),
        ),
        _gap,
        LanguageTestEditor(
          title: 'French test',
          helper: 'Optional. French at NCLC 7 or higher adds up to 50 points.',
          tests: const [LanguageTest.tef, LanguageTest.tcf],
          result: draft.frenchTest,
          onChanged: (result) => onChanged(draft.copyWith(frenchTest: result)),
        ),
      ],
    );
  }
}

class _WorkForm extends StatelessWidget {
  const _WorkForm({required this.draft, required this.onChanged});

  final CrsProfile draft;
  final ValueChanged<CrsProfile> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        YearsStepper(
          question: 'Skilled work experience in Canada',
          helper: 'Paid, full-time (or the same hours part-time), in a TEER '
              '0, 1, 2 or 3 occupation, in the last 10 years.',
          value: draft.canadianWorkYears,
          max: 5,
          onChanged: (years) =>
              onChanged(draft.copyWith(canadianWorkYears: years)),
        ),
        _gap,
        YearsStepper(
          question: 'Skilled work experience outside Canada',
          helper: 'In the last 10 years. It scores alongside your language '
              'results and Canadian experience.',
          value: draft.foreignWorkYears,
          max: 3,
          onChanged: (years) =>
              onChanged(draft.copyWith(foreignWorkYears: years)),
        ),
        _gap,
        YesNoQuestion(
          question: 'Do you hold a certificate of qualification in a skilled '
              'trade?',
          helper: 'Issued by a Canadian province, territory or federal body.',
          value: draft.certificateOfQualification,
          onChanged: (value) =>
              onChanged(draft.copyWith(certificateOfQualification: value)),
        ),
      ],
    );
  }
}

class _SpouseForm extends StatelessWidget {
  const _SpouseForm({required this.draft, required this.onChanged});

  final CrsProfile draft;
  final ValueChanged<CrsProfile> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ChoiceGroup<EducationLevel>(
          question: "Your spouse or partner's highest level of education",
          helper: 'Worth up to 10 points.',
          options: EducationLevel.values,
          labelOf: (level) => level.label,
          selected: draft.spouseEducation,
          onSelected: (level) =>
              onChanged(draft.copyWith(spouseEducation: level)),
        ),
        _gap,
        LanguageTestEditor(
          title: 'Their language test',
          helper: 'Optional. Their first official language adds up to 20 '
              'points.',
          tests: LanguageTest.values,
          result: draft.spouseLanguageTest,
          onChanged: (result) =>
              onChanged(draft.copyWith(spouseLanguageTest: result)),
        ),
        _gap,
        YearsStepper(
          question: 'Their skilled work experience in Canada',
          helper: 'Worth up to 10 points.',
          value: draft.spouseCanadianWorkYears,
          max: 5,
          onChanged: (years) =>
              onChanged(draft.copyWith(spouseCanadianWorkYears: years)),
        ),
      ],
    );
  }
}

/// The Additional factors questions.
///
/// Public because the CRS score flow asks them in a sheet before calculating,
/// and must ask *these* questions rather than a second copy of them.
class AdditionalFactorsForm extends StatelessWidget {
  const AdditionalFactorsForm({
    required this.draft,
    required this.onChanged,
    super.key,
  });

  final CrsProfile draft;
  final ValueChanged<CrsProfile> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        YesNoQuestion(
          question: 'Do you have a provincial or territorial nomination?',
          helper: 'A nomination certificate adds 600 points.',
          value: draft.provincialNomination,
          onChanged: (value) =>
              onChanged(draft.copyWith(provincialNomination: value)),
        ),
        _gap,
        FamilyInCanadaQuestion(
          value: draft.familyInCanada,
          onChanged: (value) =>
              onChanged(draft.copyWith(familyInCanada: value)),
        ),
        _gap,
        WsCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: WsIconSize.field,
                color: context.ws.caption,
              ),
              const SizedBox(width: WsSpacing.md),
              Expanded(
                child: Text(
                  'Job offers no longer add CRS points. IRCC removed them on '
                  '25 March 2025, though some programs still need one to be '
                  'eligible.',
                  style: context.text.bodySmall
                      ?.copyWith(color: context.ws.caption),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
