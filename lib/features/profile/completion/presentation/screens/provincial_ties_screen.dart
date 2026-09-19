import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/theme/theme.dart';
import '../../../../../shared/data/mock_candidate.dart';
import '../../../../../shared/models/crs_profile.dart';
import '../../../../../shared/shared.dart';
import '../widgets/form_controls.dart';

/// Provincial factors — the PNP counterpart of Additional factors.
///
/// Only what the four provincial grids score and the rest of the profile does
/// not ask: family, work and study in a province, and a job offer. Each
/// question offers only the provinces whose grid scores that answer, and a
/// follow-up appears only when its answer changes a score.
class ProvincialTiesScreen extends ConsumerStatefulWidget {
  const ProvincialTiesScreen({super.key});

  @override
  ConsumerState<ProvincialTiesScreen> createState() =>
      _ProvincialTiesScreenState();
}

class _ProvincialTiesScreenState extends ConsumerState<ProvincialTiesScreen> {
  late CrsProfile _profile = ref.read(candidateProvider).crs;
  late final TextEditingController _wage = TextEditingController(
    text: _profile.provincial.bcHourlyWage?.toStringAsFixed(2) ?? '',
  );
  String? _wageError;

  ProvincialFactors get _f => _profile.provincial;

  void _update(ProvincialFactors next) =>
      setState(() => _profile = _profile.copyWith(provincial: next));

  @override
  void dispose() {
    _wage.dispose();
    super.dispose();
  }

  void _onWage(String text) {
    final wage = double.tryParse(text.trim().replaceAll(r'$', ''));
    setState(() {
      _wageError = text.trim().isEmpty || (wage != null && wage > 0)
          ? null
          : 'Enter the hourly wage in dollars, like 32.50';
      _profile = _profile.copyWith(
        provincial:
            _f.copyWith(bcHourlyWage: wage != null && wage > 0 ? wage : null),
      );
    });
  }

  void _save() {
    // TODO(backend): saved in memory only.
    final candidate = ref.read(candidateProvider);
    ref
        .read(candidateProvider.notifier)
        .update(candidate.copyWith(crs: _profile));
    final messenger = ScaffoldMessenger.of(context);
    context.pop();
    messenger.showSnackBar(
      const SnackBar(content: Text('Saved to your profile.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final f = _f;
    final worked = f.workedIn ?? const <ProvinceTie>{};
    final studied = f.studiedIn ?? const <ProvinceTie>{};

    return Scaffold(
      appBar: AppBar(title: const Text('Provincial factors')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          WsSpacing.xl,
          WsSpacing.lg,
          WsSpacing.xl,
          WsSpacing.xxxl,
        ),
        children: [
          Text(
            'Alberta, British Columbia, Saskatchewan and Manitoba give points '
            'for family, work, study or a job offer in the province. Each '
            'question lists only the provinces that score it.',
            style: context.text.bodyMedium
                ?.copyWith(color: context.colors.onSurfaceVariant),
          ),
          const _Heading('Family'),
          MultiChoiceGroup<ProvinceTie>(
            question: 'Where does a parent, brother, sister or child live?',
            helper: '18 or older, and a Canadian citizen or permanent '
                'resident.',
            options: const [
              ProvinceTie.alberta,
              ProvinceTie.saskatchewan,
              ProvinceTie.manitoba,
            ],
            labelOf: (tie) => tie.label,
            selected: f.immediateFamily,
            noneLabel: 'None of these',
            onChanged: (set) => _update(f.copyWith(immediateFamily: set)),
          ),
          const SizedBox(height: WsSpacing.xxl),
          MultiChoiceGroup<ProvinceTie>(
            question: 'Where does a grandparent, aunt, uncle, niece, nephew '
                'or cousin live?',
            helper: 'Saskatchewan and Manitoba count these relatives too; '
                'Alberta does not.',
            options: const [ProvinceTie.saskatchewan, ProvinceTie.manitoba],
            labelOf: (tie) => tie.label,
            selected: f.extendedFamily,
            noneLabel: 'None of these',
            onChanged: (set) => _update(f.copyWith(extendedFamily: set)),
          ),
          const _Heading('Work in Canada'),
          MultiChoiceGroup<ProvinceTie>(
            question: 'Where have you worked full time for six months or '
                'more?',
            helper: 'On a valid work permit. Choose every province that '
                'applies — Manitoba counts work elsewhere against you.',
            options: const [
              ProvinceTie.alberta,
              ProvinceTie.saskatchewan,
              ProvinceTie.manitoba,
              ProvinceTie.elsewhere,
            ],
            labelOf: (tie) => tie.label,
            selected: f.workedIn,
            noneLabel: 'I have not worked in Canada',
            onChanged: (set) => _update(
              f.copyWith(
                workedIn: set,
                saskatchewanWorkYear: set.contains(ProvinceTie.saskatchewan)
                    ? f.saskatchewanWorkYear
                    : null,
              ),
            ),
          ),
          if (worked.contains(ProvinceTie.saskatchewan)) ...[
            const SizedBox(height: WsSpacing.xxl),
            YesNoQuestion(
              question: 'Was your Saskatchewan work 12 months or more, in '
                  'the last five years?',
              helper: 'Saskatchewan counts past work only at a year or more.',
              value: f.saskatchewanWorkYear,
              onChanged: (value) =>
                  _update(f.copyWith(saskatchewanWorkYear: value)),
            ),
          ],
          // No Canadian post-secondary study in the profile means there is
          // nothing to place, so the question is not asked.
          if (_profile.studiedInCanada) ...[
            const _Heading('Study in Canada'),
            MultiChoiceGroup<ProvinceTie>(
              question: 'Where did you complete your Canadian post-secondary '
                  'program?',
              helper: 'At least one academic year, full time. Choose every '
                  'province that applies.',
              options: const [
                ProvinceTie.alberta,
                ProvinceTie.britishColumbia,
                ProvinceTie.saskatchewan,
                ProvinceTie.manitoba,
                ProvinceTie.elsewhere,
              ],
              labelOf: (tie) => tie.label,
              selected: f.studiedIn,
              onChanged: (set) => _update(
                f.copyWith(
                  studiedIn: set,
                  manitobaStudyTwoYears: set.contains(ProvinceTie.manitoba)
                      ? f.manitobaStudyTwoYears
                      : null,
                ),
              ),
            ),
            if (studied.contains(ProvinceTie.manitoba)) ...[
              const SizedBox(height: WsSpacing.xxl),
              YesNoQuestion(
                question: 'Was the Manitoba program two years or longer?',
                helper: 'Manitoba gives 100 points for two years or more, 50 '
                    'for one.',
                value: f.manitobaStudyTwoYears,
                onChanged: (value) =>
                    _update(f.copyWith(manitobaStudyTwoYears: value)),
              ),
            ],
          ],
          const _Heading('Job offer'),
          ChoiceGroup<ProvinceTie>(
            question: 'Do you have a full-time, permanent job offer in one of '
                'these provinces?',
            helper: 'Job offers no longer count for the CRS, but every '
                'provincial grid scores one.',
            options: const [
              ProvinceTie.alberta,
              ProvinceTie.britishColumbia,
              ProvinceTie.saskatchewan,
              ProvinceTie.manitoba,
              ProvinceTie.none,
            ],
            labelOf: (tie) =>
                tie == ProvinceTie.none ? 'No, or somewhere else' : tie.label,
            selected: f.jobOffer,
            // A different province's follow-ups do not carry over.
            onSelected: (tie) => _update(
              f.copyWith(
                jobOffer: tie,
                albertaJobOutsideCities: null,
                albertaJobRegulated: null,
                bcArea: null,
                workingForEmployer: null,
              ),
            ),
          ),
          ...switch (f.jobOffer) {
            ProvinceTie.alberta => [
                const SizedBox(height: WsSpacing.xxl),
                YesNoQuestion(
                  question: 'Is the job outside the Calgary and Edmonton '
                      'areas?',
                  value: f.albertaJobOutsideCities,
                  onChanged: (value) =>
                      _update(f.copyWith(albertaJobOutsideCities: value)),
                ),
                const SizedBox(height: WsSpacing.xxl),
                YesNoQuestion(
                  question: 'Is it a regulated occupation or designated '
                      'trade you are licensed or certified for in Alberta?',
                  value: f.albertaJobRegulated,
                  onChanged: (value) =>
                      _update(f.copyWith(albertaJobRegulated: value)),
                ),
              ],
            ProvinceTie.britishColumbia => [
                const SizedBox(height: WsSpacing.xxl),
                WsField(
                  label: 'Hourly wage of the job offer (CAD)',
                  controller: _wage,
                  hint: '32.50',
                  helper: 'One point per dollar from \$16, up to 55 at '
                      '\$70 or more.',
                  error: _wageError,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: _onWage,
                ),
                const SizedBox(height: WsSpacing.xxl),
                ChoiceGroup<BcArea>(
                  question: 'Where in British Columbia is the job?',
                  options: BcArea.values,
                  labelOf: (area) => area.label,
                  selected: f.bcArea,
                  onSelected: (area) => _update(f.copyWith(bcArea: area)),
                ),
                const SizedBox(height: WsSpacing.xxl),
                YesNoQuestion(
                  question: 'Are you working full time for this employer in '
                      'British Columbia now?',
                  value: f.workingForEmployer,
                  onChanged: (value) =>
                      _update(f.copyWith(workingForEmployer: value)),
                ),
              ],
            ProvinceTie.manitoba => [
                const SizedBox(height: WsSpacing.xxl),
                YesNoQuestion(
                  question: 'Have you worked for this employer in Manitoba '
                      'for six months or more?',
                  helper: 'Six months with a Manitoba employer offering you a '
                      'job is worth 500 points.',
                  value: f.workingForEmployer,
                  onChanged: (value) =>
                      _update(f.copyWith(workingForEmployer: value)),
                ),
              ],
            _ => const <Widget>[],
          },
          const SizedBox(height: WsSpacing.xxl),
          const WsDisclaimer(authority: 'the province'),
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
            label: 'Save',
            forward: false,
            onPressed: _profile.provincialFactorsAnswered ? _save : null,
          ),
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: WsSpacing.xxxl,
        bottom: WsSpacing.lg,
      ),
      child: Text(title, style: context.text.titleLarge),
    );
  }
}
