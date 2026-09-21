import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/theme/theme.dart';
import '../../../../../shared/data/mock_candidate.dart';
import '../../../../../shared/models/crs_profile.dart';
import '../../../../../shared/shared.dart';
import '../widgets/form_controls.dart';

/// One province's factors — the PNP counterpart of Additional factors.
///
/// Each province is scored on its own, so each asks only what its own grid
/// reads: family, work and study there, and a job offer. Every question is a
/// plain yes or no about this province, and a follow-up appears only when its
/// answer changes this province's score.
///
/// The answers are stored once, across provinces, so a later answer about the
/// same fact — worked in Saskatchewan, say — updates every province that reads
/// it.
class ProvincialTiesScreen extends ConsumerStatefulWidget {
  const ProvincialTiesScreen({required this.provinceCode, super.key});

  /// Two-letter code: AB, BC, SK or MB.
  final String provinceCode;

  @override
  ConsumerState<ProvincialTiesScreen> createState() =>
      _ProvincialTiesScreenState();
}

class _ProvincialTiesScreenState extends ConsumerState<ProvincialTiesScreen> {
  late final ProvinceTie? _province = ProvinceTie.forCode(widget.provinceCode);
  late final CrsProfile _start = ref.read(candidateProvider).crs;
  late _Answers _a = _Answers.from(_start, _province);
  late final TextEditingController _wage = TextEditingController(
    text: _a.bcWage?.toStringAsFixed(2) ?? '',
  );
  String? _wageError;

  @override
  void dispose() {
    _wage.dispose();
    super.dispose();
  }

  void _set(_Answers next) => setState(() => _a = next);

  void _onWage(String text) {
    final wage = double.tryParse(text.trim().replaceAll(r'$', ''));
    final valid = wage != null && wage > 0;
    setState(() {
      _wageError = text.trim().isEmpty || valid
          ? null
          : 'Enter the hourly wage in dollars, like 32.50';
      _a = _a.copyWith(bcWage: valid ? wage : null, clearWage: !valid);
    });
  }

  void _save(ProvinceTie province) {
    // TODO(backend): saved in memory only.
    final candidate = ref.read(candidateProvider);
    final crs = candidate.crs;
    ref.read(candidateProvider.notifier).update(
          candidate.copyWith(
            crs: crs.copyWith(provincial: _a.applyTo(crs.provincial, province)),
          ),
        );
    final messenger = ScaffoldMessenger.of(context);
    context.pop();
    messenger.showSnackBar(
      SnackBar(content: Text('${province.label} answers saved.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final province = _province;
    if (province == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Provincial factors')),
        body: Padding(
          padding: WsSpacing.gutter,
          child: Text(
            'This province does not rank candidates on a points grid.',
            style: context.text.bodyMedium,
          ),
        ),
      );
    }

    final studied = _start.studiedInCanada;

    return Scaffold(
      appBar: AppBar(title: Text('${province.label} factors')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          WsSpacing.xl,
          WsSpacing.lg,
          WsSpacing.xl,
          WsSpacing.xxxl,
        ),
        children: [
          Text(
            '${province.label} gives points for ties to the province. These '
            'questions are only the ones its grid scores.',
            style: context.text.bodyMedium
                ?.copyWith(color: context.colors.onSurfaceVariant),
          ),
          _FamilyQuestions(province: province, a: _a, onChanged: _set),
          _WorkQuestions(province: province, a: _a, onChanged: _set),
          if (studied)
            _StudyQuestions(province: province, a: _a, onChanged: _set),
          _OfferQuestions(
            province: province,
            a: _a,
            onChanged: _set,
            wage: _wage,
            wageError: _wageError,
            onWage: _onWage,
          ),
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
            onPressed: _a.isComplete(province, studiedInCanada: studied)
                ? () => _save(province)
                : null,
          ),
        ),
      ),
    );
  }
}

/// This form's answers, each a yes or no about one province.
///
/// Null is unanswered. They start empty for a province that has not been
/// answered yet, even when another province's form already filled the shared
/// sets — "no" there is not an answer to this province's question.
class _Answers {
  const _Answers({
    this.family,
    this.extendedFamily,
    this.worked,
    this.workYear,
    this.workedElsewhere,
    this.studied,
    this.studyTwoYears,
    this.studiedElsewhere,
    this.offer,
    this.abOutsideCities,
    this.abRegulated,
    this.bcWage,
    this.bcArea,
    this.workingForEmployer,
  });

  factory _Answers.from(CrsProfile crs, ProvinceTie? province) {
    final f = crs.provincial;
    if (province == null || !f.isAnsweredFor(province)) {
      return const _Answers();
    }
    bool has(Set<ProvinceTie>? set) => set?.contains(province) ?? false;
    bool outside(Set<ProvinceTie>? set) =>
        set?.any((t) => t != province && t != ProvinceTie.none) ?? false;
    final offer = f.jobOffer == province;

    return _Answers(
      family: has(f.immediateFamily),
      extendedFamily: has(f.extendedFamily),
      worked: has(f.workedIn),
      workYear: f.saskatchewanWorkYear,
      workedElsewhere: outside(f.workedIn),
      studied: has(f.studiedIn),
      studyTwoYears: f.manitobaStudyTwoYears,
      studiedElsewhere: outside(f.studiedIn),
      offer: offer,
      abOutsideCities: offer ? f.albertaJobOutsideCities : null,
      abRegulated: offer ? f.albertaJobRegulated : null,
      bcWage: offer ? f.bcHourlyWage : null,
      bcArea: offer ? f.bcArea : null,
      workingForEmployer: offer ? f.workingForEmployer : null,
    );
  }

  final bool? family;
  final bool? extendedFamily;
  final bool? worked;

  /// Saskatchewan only: 12 months or more in the last five years.
  final bool? workYear;

  /// Manitoba only: it counts work elsewhere in Canada against you.
  final bool? workedElsewhere;
  final bool? studied;

  /// Manitoba only: a program of two years or more.
  final bool? studyTwoYears;

  /// Manitoba only, as for work.
  final bool? studiedElsewhere;
  final bool? offer;
  final bool? abOutsideCities;
  final bool? abRegulated;
  final double? bcWage;
  final BcArea? bcArea;
  final bool? workingForEmployer;

  static const _ab = ProvinceTie.alberta;
  static const _bc = ProvinceTie.britishColumbia;
  static const _sk = ProvinceTie.saskatchewan;
  static const _mb = ProvinceTie.manitoba;

  /// Which questions each grid reads.
  static bool asksFamily(ProvinceTie p) => p != _bc;
  static bool asksExtendedFamily(ProvinceTie p) => p == _sk || p == _mb;
  static bool asksWork(ProvinceTie p) => p != _bc;

  bool isComplete(ProvinceTie p, {required bool studiedInCanada}) {
    if (asksFamily(p) && family == null) return false;
    if (asksExtendedFamily(p) && extendedFamily == null) return false;
    if (asksWork(p) && worked == null) return false;
    if (p == _sk && worked == true && workYear == null) return false;
    if (p == _mb && workedElsewhere == null) return false;
    if (studiedInCanada) {
      if (studied == null) return false;
      if (p == _mb && studied == true && studyTwoYears == null) return false;
      if (p == _mb && studiedElsewhere == null) return false;
    }
    if (offer == null) return false;
    if (offer == true) {
      if (p == _ab && (abOutsideCities == null || abRegulated == null)) {
        return false;
      }
      if (p == _bc &&
          (bcWage == null || bcArea == null || workingForEmployer == null)) {
        return false;
      }
      if (p == _mb && workingForEmployer == null) return false;
    }
    return true;
  }

  /// Writes these answers into the shared sets, touching only [p] — and, for
  /// Manitoba's "anywhere else" questions, the other provinces.
  ProvincialFactors applyTo(ProvincialFactors f, ProvinceTie p) {
    Set<ProvinceTie>? toggle(Set<ProvinceTie>? set, bool? yes) {
      if (yes == null) return set;
      final next = {...?set}..remove(ProvinceTie.none);
      return yes ? (next..add(p)) : (next..remove(p));
    }

    Set<ProvinceTie>? elsewhere(Set<ProvinceTie>? set, bool? yes) {
      if (p != _mb || yes == null) return set;
      final next = {...?set}..remove(ProvinceTie.none);
      if (!yes) return next..removeWhere((t) => t != _mb);
      // Already placed somewhere else — Alberta, say — so nothing to add.
      if (next.any((t) => t != _mb)) return next;
      return next..add(ProvinceTie.elsewhere);
    }

    final workedSet = elsewhere(toggle(f.workedIn, worked), workedElsewhere);
    final studiedSet =
        elsewhere(toggle(f.studiedIn, studied), studiedElsewhere);

    // One job offer is counted at a time: yes here replaces an offer in
    // another province; no clears it only if it was this province's.
    final ProvinceTie? jobOffer = switch (offer) {
      true => p,
      false =>
        f.jobOffer == p || f.jobOffer == null ? ProvinceTie.none : f.jobOffer,
      null => f.jobOffer,
    };
    final offerChanged = jobOffer != f.jobOffer;

    return f.copyWith(
      immediateFamily: toggle(f.immediateFamily, family),
      extendedFamily: toggle(f.extendedFamily, extendedFamily),
      workedIn: workedSet,
      saskatchewanWorkYear: workedSet?.contains(_sk) ?? false
          ? (p == _sk ? workYear : f.saskatchewanWorkYear)
          : null,
      studiedIn: studiedSet,
      manitobaStudyTwoYears: studiedSet?.contains(_mb) ?? false
          ? (p == _mb ? studyTwoYears : f.manitobaStudyTwoYears)
          : null,
      jobOffer: jobOffer,
      albertaJobOutsideCities: p == _ab && offer == true
          ? abOutsideCities
          : (offerChanged ? null : f.albertaJobOutsideCities),
      albertaJobRegulated: p == _ab && offer == true
          ? abRegulated
          : (offerChanged ? null : f.albertaJobRegulated),
      bcHourlyWage: p == _bc && offer == true
          ? bcWage
          : (offerChanged ? null : f.bcHourlyWage),
      bcArea:
          p == _bc && offer == true ? bcArea : (offerChanged ? null : f.bcArea),
      workingForEmployer: (p == _bc || p == _mb) && offer == true
          ? workingForEmployer
          : (offerChanged ? null : f.workingForEmployer),
      answeredFor: {...f.answeredFor, p},
    );
  }

  _Answers copyWith({
    bool? family,
    bool? extendedFamily,
    bool? worked,
    bool? workYear,
    bool? workedElsewhere,
    bool? studied,
    bool? studyTwoYears,
    bool? studiedElsewhere,
    bool? offer,
    bool? abOutsideCities,
    bool? abRegulated,
    double? bcWage,
    bool clearWage = false,
    BcArea? bcArea,
    bool? workingForEmployer,
  }) {
    final offerNow = offer ?? this.offer;
    // A "no" drops the follow-ups that only a "yes" asks.
    final keepFollowUps = offerNow == true;
    return _Answers(
      family: family ?? this.family,
      extendedFamily: extendedFamily ?? this.extendedFamily,
      worked: worked ?? this.worked,
      workYear:
          (worked ?? this.worked) == true ? workYear ?? this.workYear : null,
      workedElsewhere: workedElsewhere ?? this.workedElsewhere,
      studied: studied ?? this.studied,
      studyTwoYears: (studied ?? this.studied) == true
          ? studyTwoYears ?? this.studyTwoYears
          : null,
      studiedElsewhere: studiedElsewhere ?? this.studiedElsewhere,
      offer: offerNow,
      abOutsideCities:
          keepFollowUps ? abOutsideCities ?? this.abOutsideCities : null,
      abRegulated: keepFollowUps ? abRegulated ?? this.abRegulated : null,
      bcWage: keepFollowUps && !clearWage ? bcWage ?? this.bcWage : null,
      bcArea: keepFollowUps ? bcArea ?? this.bcArea : null,
      workingForEmployer:
          keepFollowUps ? workingForEmployer ?? this.workingForEmployer : null,
    );
  }
}

class _FamilyQuestions extends StatelessWidget {
  const _FamilyQuestions({
    required this.province,
    required this.a,
    required this.onChanged,
  });

  final ProvinceTie province;
  final _Answers a;
  final ValueChanged<_Answers> onChanged;

  @override
  Widget build(BuildContext context) {
    if (!_Answers.asksFamily(province)) return const SizedBox.shrink();
    final name = province.label;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Heading('Family'),
        YesNoQuestion(
          question: 'Does a parent, brother, sister or child live in $name?',
          helper: '18 or older, and a Canadian citizen or permanent resident.',
          value: a.family,
          onChanged: (v) => onChanged(a.copyWith(family: v)),
        ),
        if (_Answers.asksExtendedFamily(province)) ...[
          const SizedBox(height: WsSpacing.xxl),
          YesNoQuestion(
            question: 'Does a grandparent, aunt, uncle, niece, nephew or '
                'cousin live in $name?',
            value: a.extendedFamily,
            onChanged: (v) => onChanged(a.copyWith(extendedFamily: v)),
          ),
        ],
      ],
    );
  }
}

class _WorkQuestions extends StatelessWidget {
  const _WorkQuestions({
    required this.province,
    required this.a,
    required this.onChanged,
  });

  final ProvinceTie province;
  final _Answers a;
  final ValueChanged<_Answers> onChanged;

  @override
  Widget build(BuildContext context) {
    if (!_Answers.asksWork(province)) return const SizedBox.shrink();
    final name = province.label;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Heading('Work in Canada'),
        YesNoQuestion(
          question: 'Have you worked full time in $name for six months or '
              'more?',
          helper: 'On a valid work permit.',
          value: a.worked,
          onChanged: (v) => onChanged(a.copyWith(worked: v)),
        ),
        if (province == ProvinceTie.saskatchewan && a.worked == true) ...[
          const SizedBox(height: WsSpacing.xxl),
          YesNoQuestion(
            question: 'Was it 12 months or more, in the last five years?',
            helper: 'Saskatchewan counts past work only at a year or more.',
            value: a.workYear,
            onChanged: (v) => onChanged(a.copyWith(workYear: v)),
          ),
        ],
        if (province == ProvinceTie.manitoba) ...[
          const SizedBox(height: WsSpacing.xxl),
          YesNoQuestion(
            question: 'Have you worked full time anywhere else in Canada?',
            helper: 'Manitoba counts work in another province against you.',
            value: a.workedElsewhere,
            onChanged: (v) => onChanged(a.copyWith(workedElsewhere: v)),
          ),
        ],
      ],
    );
  }
}

class _StudyQuestions extends StatelessWidget {
  const _StudyQuestions({
    required this.province,
    required this.a,
    required this.onChanged,
  });

  final ProvinceTie province;
  final _Answers a;
  final ValueChanged<_Answers> onChanged;

  @override
  Widget build(BuildContext context) {
    final manitoba = province == ProvinceTie.manitoba;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Heading('Study in Canada'),
        YesNoQuestion(
          question: 'Did you complete your post-secondary program in '
              '${province.label}?',
          helper: 'At least one academic year, full time.',
          value: a.studied,
          onChanged: (v) => onChanged(a.copyWith(studied: v)),
        ),
        if (manitoba && a.studied == true) ...[
          const SizedBox(height: WsSpacing.xxl),
          YesNoQuestion(
            question: 'Was the program two years or longer?',
            helper: 'Manitoba gives 100 points for two years or more, 50 for '
                'one.',
            value: a.studyTwoYears,
            onChanged: (v) => onChanged(a.copyWith(studyTwoYears: v)),
          ),
        ],
        if (manitoba) ...[
          const SizedBox(height: WsSpacing.xxl),
          YesNoQuestion(
            question: 'Did you also study in another province?',
            helper: 'Manitoba counts study elsewhere against you.',
            value: a.studiedElsewhere,
            onChanged: (v) => onChanged(a.copyWith(studiedElsewhere: v)),
          ),
        ],
      ],
    );
  }
}

class _OfferQuestions extends StatelessWidget {
  const _OfferQuestions({
    required this.province,
    required this.a,
    required this.onChanged,
    required this.wage,
    required this.wageError,
    required this.onWage,
  });

  final ProvinceTie province;
  final _Answers a;
  final ValueChanged<_Answers> onChanged;
  final TextEditingController wage;
  final String? wageError;
  final ValueChanged<String> onWage;

  @override
  Widget build(BuildContext context) {
    final yes = a.offer == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _Heading('Job offer'),
        YesNoQuestion(
          question: 'Do you have a full-time, permanent job offer in '
              '${province.label}?',
          helper: 'One offer counts at a time — yes here replaces an offer '
              'saved for another province.',
          value: a.offer,
          onChanged: (v) => onChanged(a.copyWith(offer: v)),
        ),
        if (yes && province == ProvinceTie.alberta) ...[
          const SizedBox(height: WsSpacing.xxl),
          YesNoQuestion(
            question: 'Is the job outside the Calgary and Edmonton areas?',
            value: a.abOutsideCities,
            onChanged: (v) => onChanged(a.copyWith(abOutsideCities: v)),
          ),
          const SizedBox(height: WsSpacing.xxl),
          YesNoQuestion(
            question: 'Is it a regulated occupation or designated trade you '
                'are licensed or certified for in Alberta?',
            value: a.abRegulated,
            onChanged: (v) => onChanged(a.copyWith(abRegulated: v)),
          ),
        ],
        if (yes && province == ProvinceTie.britishColumbia) ...[
          const SizedBox(height: WsSpacing.xxl),
          WsField(
            label: 'Hourly wage of the job offer (CAD)',
            controller: wage,
            hint: '32.50',
            helper: r'One point per dollar from $16, up to 55 at $70 or more.',
            error: wageError,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: onWage,
          ),
          const SizedBox(height: WsSpacing.xxl),
          ChoiceGroup<BcArea>(
            question: 'Where in British Columbia is the job?',
            options: BcArea.values,
            labelOf: (area) => area.label,
            selected: a.bcArea,
            onSelected: (area) => onChanged(a.copyWith(bcArea: area)),
          ),
        ],
        if (yes &&
            (province == ProvinceTie.britishColumbia ||
                province == ProvinceTie.manitoba)) ...[
          const SizedBox(height: WsSpacing.xxl),
          YesNoQuestion(
            question: province == ProvinceTie.manitoba
                ? 'Have you worked for this employer in Manitoba for six '
                    'months or more?'
                : 'Are you working full time for this employer in British '
                    'Columbia now?',
            value: a.workingForEmployer,
            onChanged: (v) => onChanged(a.copyWith(workingForEmployer: v)),
          ),
        ],
      ],
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
