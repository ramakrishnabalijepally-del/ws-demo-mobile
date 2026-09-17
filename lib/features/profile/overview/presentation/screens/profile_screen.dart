import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/routes.dart';
import '../../../../../app/theme/theme.dart';
import '../../../../../shared/controllers/crs_controller.dart';
import '../../../../../shared/data/mock_candidate.dart';
import '../../../../../shared/models/candidate.dart';
import '../../../../../shared/models/immigration_details.dart';
import '../../../../../shared/models/ws_module.dart';
import '../../../../../shared/shared.dart';
import '../../../../../shared/models/crs_profile.dart';
import '../../../../../shared/models/profile_section.dart';
import '../../../../../shared/utils/clb_conversion.dart';
import '../../../../../shared/utils/crs_calculator.dart';
import '../../../../immigration/immigration.dart';
import '../../../data/mock_profile.dart';

/// M1, M3–M7 — the Profile screen and its five tabs.
///
/// Overview · Basic profile · Immigration profile · Jobs · Documents.
///
/// Overview is the summary of the two profiles side by side, each in its own
/// card with its own Edit button; the two tabs after it are the same profiles
/// in full. **Every field a tab shows is a field the edit screen edits**, so
/// the reader never opens Edit and finds a different set of questions. The CRS
/// Predictor sits under Immigration profile, beside the passport and status it
/// belongs with. The active tab is marked by a 2.5 px red underline — **the
/// underline is the only indicator, no pill and no fill** (design system
/// section 14).
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 5, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final candidate = ref.watch(candidateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () => context.push(Routes.settings),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Basic profile'),
            Tab(text: 'Immigration profile'),
            Tab(text: 'Jobs'),
            Tab(text: 'Documents'),
          ],
        ),
      ),
      body: Column(
        children: [
          _ProfileHeader(candidate: candidate),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _OverviewTab(
                  candidate: candidate,
                  onOpenBasic: () => _tabs.animateTo(1),
                  onOpenImmigration: () => _tabs.animateTo(2),
                ),
                _BasicProfileTab(candidate: candidate),
                _ImmigrationProfileTab(candidate: candidate),
                const _JobsTab(),
                const _DocumentsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.candidate});

  final Candidate candidate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        WsSpacing.xl,
        WsSpacing.lg,
        WsSpacing.xl,
        WsSpacing.lg,
      ),
      child: Row(
        children: [
          _Avatar(candidate: candidate),
          const SizedBox(width: WsSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        candidate.fullName,
                        style: context.text.titleLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (candidate.verified) ...[
                      const SizedBox(width: WsSpacing.sm),
                      Icon(
                        Icons.verified_rounded,
                        size: 18,
                        color: context.colors.primary,
                        semanticLabel: 'Verified',
                      ),
                    ],
                  ],
                ),
                Text(
                  candidate.occupation,
                  style: context.text.bodySmall
                      ?.copyWith(color: context.ws.caption),
                ),
                const SizedBox(height: WsSpacing.sm),
                WsMeter(
                  value: candidate.profileStrength,
                  maximum: 100,
                  semanticLabel:
                      'Profile ${candidate.profileStrength} per cent complete',
                ),
                const SizedBox(height: WsSpacing.xs),
                // Profile strength leads to the checklist, because the
                // profile is what every score in the app is built from.
                // A Wrap, so the link drops under the figure when a small
                // phone or large text leaves no room beside it.
                Wrap(
                  spacing: WsSpacing.sm,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      '${candidate.profileStrength}% complete',
                      style: context.text.bodySmall
                          ?.copyWith(color: context.ws.caption),
                    ),
                    WsLink(
                      label: 'Complete profile',
                      underline: false,
                      onPressed: () => context.push(Routes.profileCompletion),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// M2 — the avatar, and the sheet that changes it.
class _Avatar extends StatelessWidget {
  const _Avatar({required this.candidate});

  final Candidate candidate;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 34,
          backgroundColor: context.ws.verdictTintedSurface,
          child: Text(candidate.initials, style: context.text.titleLarge),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Semantics(
            button: true,
            label: 'Change profile photo',
            child: InkWell(
              onTap: () => _showAvatarSheet(context),
              customBorder: const CircleBorder(),
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.colors.primary,
                  border: Border.all(color: context.colors.surface, width: 2),
                ),
                child: Icon(
                  Icons.edit_rounded,
                  size: 13,
                  color: context.colors.onPrimary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static void _showAvatarSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            WsSpacing.xl,
            WsSpacing.sm,
            WsSpacing.xl,
            WsSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Change your photo',
                style: context.text.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: WsSpacing.xl),
              // TODO(backend): no camera or gallery access in the mock.
              WsListRow(
                leading: const WsIconTile(icon: Icons.photo_camera_outlined),
                title: 'Take a photo',
                onTap: () => Navigator.of(context).pop(),
              ),
              WsListRow(
                leading: const WsIconTile(icon: Icons.photo_library_outlined),
                title: 'Choose from your library',
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const EdgeInsets _tabPadding = EdgeInsets.fromLTRB(
  WsSpacing.xl,
  WsSpacing.lg,
  WsSpacing.xl,
  WsSpacing.xxxl,
);

/// Overview — both profiles as summary cards, each opening its own editor.
///
/// The cards show the same fields as the two tabs behind them, so this is a
/// shortcut rather than a third version of the truth. Tapping a card body
/// moves to that tab; the Edit button goes straight to the form.
class _OverviewTab extends StatelessWidget {
  const _OverviewTab({
    required this.candidate,
    required this.onOpenBasic,
    required this.onOpenImmigration,
  });

  final Candidate candidate;
  final VoidCallback onOpenBasic;
  final VoidCallback onOpenImmigration;

  @override
  Widget build(BuildContext context) {
    final details = candidate.immigration;
    final family = candidate.crs.familyInCanada;

    return ListView(
      padding: _tabPadding,
      children: [
        WsAppear(
          child: _OverviewCard(
            icon: Icons.person_outline_rounded,
            title: 'Basic profile',
            openLabel: 'See the full basic profile',
            onEdit: () => context.push(Routes.profileEdit),
            onOpen: onOpenBasic,
            facts: basicProfileFacts(candidate),
          ),
        ),
        const SizedBox(height: WsSpacing.md),
        WsAppear(
          delay: 0.15,
          child: _OverviewCard(
            icon: Icons.flight_takeoff_rounded,
            title: 'Immigration profile',
            openLabel: 'See the full immigration profile',
            onEdit: () => context.push('${Routes.profileEdit}?tab=immigration'),
            onOpen: onOpenImmigration,
            facts: [
              _Fact(
                label: 'Passport',
                value: details.passportNumber.isEmpty
                    ? 'Not added yet'
                    : details.maskedPassportNumber,
              ),
              _Fact(
                label: 'Status in Canada',
                value: details.status?.label ?? 'No status yet',
              ),
              _Fact(
                label: 'Family in Canada',
                value: switch (family) {
                  null => 'Not added yet',
                  final f when f.isEmpty => 'None',
                  final f => f.map((m) => m.label).join(', '),
                },
                last: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// One profile as a card: a heading with an Edit button, its facts, and a row
/// that opens the full tab.
class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.icon,
    required this.title,
    required this.facts,
    required this.openLabel,
    required this.onEdit,
    required this.onOpen,
  });

  final IconData icon;
  final String title;
  final List<Widget> facts;

  /// The link into the full tab, named so it says where it goes.
  final String openLabel;

  final VoidCallback onEdit;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return WsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              WsIconTile(icon: icon, size: WsTileSize.compact),
              const SizedBox(width: WsSpacing.md),
              Expanded(child: Text(title, style: context.text.titleMedium)),
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: WsIconSize.field),
                label: const Text('Edit'),
              ),
            ],
          ),
          Divider(color: context.colors.outlineVariant, height: WsSpacing.xxl),
          ...facts,
          const SizedBox(height: WsSpacing.md),
          Align(
            alignment: Alignment.centerLeft,
            child: WsLink(
              label: openLabel,
              underline: false,
              onPressed: onOpen,
            ),
          ),
        ],
      ),
    );
  }
}

/// The Basic profile fields, in one list so the Overview card, the Basic
/// profile tab and the edit form can never drift apart.
List<Widget> basicProfileFacts(Candidate candidate) {
  final code = WsProvinceMark.countryCodeFor(candidate.countryOfOrigin);

  return [
    _Fact(label: 'Email', value: candidate.email),
    _Fact(label: 'Phone', value: candidate.phone),
    _Fact(label: 'Date of birth', value: candidate.dateOfBirth),
    _Fact(
      label: 'From',
      value: candidate.countryOfOrigin,
      mark: code == null
          ? null
          : WsProvinceMark.country(
              code: code,
              label: candidate.countryOfOrigin,
              size: 24,
            ),
    ),
    _Fact(label: 'You are a', value: candidate.profileType, last: true),
  ];
}

class _BasicProfileTab extends StatelessWidget {
  const _BasicProfileTab({required this.candidate});

  final Candidate candidate;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: _tabPadding,
      children: [
        _TabHeading(
          title: 'Basic profile',
          onEdit: () => context.push(Routes.profileEdit),
        ),
        const SizedBox(height: WsSpacing.md),
        WsCard(child: Column(children: basicProfileFacts(candidate))),
      ],
    );
  }
}

/// Passport, status in Canada and family, then the CRS score and the federal
/// programs — everything immigration in one place.
///
/// **The score card is a readout and nothing more, in both of its states.** It
/// does not open the CRS Predictor and it carries no tap target, because the
/// answers behind it are already on this tab — each in its own card, each
/// opening its own form. A number you can press implies somewhere else to go;
/// there isn't one.
///
/// The tab reads in one direction: the facts, then every answer the score is
/// built from, then the score itself. A total placed before its own inputs
/// asks the reader to take it on trust.
///
/// Before the score has been asked for, the slot says where it comes from
/// rather than offering to produce it. **The CRS score is generated in
/// Immigration and nowhere else** — one place to ask for it, so the reader
/// never has to work out which of two buttons they pressed last.
class _ImmigrationProfileTab extends ConsumerWidget {
  const _ImmigrationProfileTab({required this.candidate});

  final Candidate candidate;

  static const String _notAdded = 'Not added yet';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final crs = ref.watch(crsResultProvider);
    final verdict = crsVerdict(crs.total);
    final revealed = ref.watch(crsRevealedProvider);
    final details = candidate.immigration;
    final family = candidate.crs.familyInCanada;
    final today = DateTime.now();

    String? expiresLine(DateTime? expiry) {
      if (expiry == null) return null;
      final when = relativeToToday(expiry, today);
      return expiry.isBefore(today) ? 'Expired $when' : 'Expires $when';
    }

    String orNotAdded(String value) => value.isEmpty ? _notAdded : value;

    return ListView(
      padding: _tabPadding,
      children: [
        _TabHeading(
          title: 'Immigration profile',
          onEdit: () => context.push('${Routes.profileEdit}?tab=immigration'),
        ),
        const SizedBox(height: WsSpacing.md),
        _FactCard(
          icon: Icons.badge_outlined,
          title: 'Passport',
          facts: [
            _Fact(
              label: 'Number',
              value: orNotAdded(details.maskedPassportNumber),
            ),
            _Fact(
              label: 'Issued',
              value: orNotAdded(details.passportIssueDate),
            ),
            _Fact(
              label: 'Expires',
              value: orNotAdded(details.passportExpiryDate),
              caption: expiresLine(details.passportExpiry),
              last: true,
            ),
          ],
        ),
        const SizedBox(height: WsSpacing.md),
        _FactCard(
          icon: Icons.assignment_ind_outlined,
          title: 'Status in Canada',
          facts: [
            _Fact(
              label: 'Status',
              value: details.status?.label ?? 'No status yet',
              last: details.status == null,
            ),
            if (details.status != null) ...[
              _Fact(
                label: 'Issued',
                value: orNotAdded(details.statusIssueDate),
              ),
              _Fact(
                label: 'Expires',
                value: orNotAdded(details.statusExpiryDate),
                caption: expiresLine(details.statusExpiry),
                last: true,
              ),
            ],
          ],
        ),
        const SizedBox(height: WsSpacing.md),
        _FactCard(
          icon: Icons.family_restroom_rounded,
          title: 'Family in Canada',
          facts: [
            _Fact(
              label: 'Living in Canada',
              value: switch (family) {
                null => _notAdded,
                final f when f.isEmpty => 'None',
                final f => f.map((m) => m.label).join(', '),
              },
              last: true,
            ),
          ],
        ),
        const SizedBox(height: WsSpacing.md),
        // The answers carry straight on from the facts above — passport,
        // status and family, then about you, education, language tests and
        // work. They are one list of what the reader has told WorkSettle, so
        // nothing is allowed to interrupt it.
        _CrsAnswerCards(candidate: candidate),
        const SizedBox(height: WsSpacing.xxl),
        // The total comes after the answers it is made of, not before them:
        // the reader sees what they have given, then what it adds up to.
        Text('CRS score', style: context.text.titleLarge),
        const SizedBox(height: WsSpacing.md),
        // Same card shell either way, so nothing jumps when the score arrives.
        if (revealed)
          WsScoreCard(
            icon: WsModule.crsPredictor.icon,
            title: 'Your CRS score',
            supporting: 'Comprehensive Ranking System',
            value: crs.total,
            maximum: crsMaximum,
            verdict: verdict.verdict,
            verdictLabel: verdict.label,
            contextLine: mockRecentDraws,
            brandFill: true,
            showDisclaimer: true,
          )
        else
          WsScorePrompt(
            icon: WsModule.crsPredictor.icon,
            title: 'Your CRS score',
            supporting: 'Comprehensive Ranking System',
            body: 'WorkSettle works it out in Immigration, from the answers '
                'above and the points IRCC publishes.',
            note: 'The more of this tab you fill in, the closer it is when '
                'you ask for it.',
          ),
        const SizedBox(height: WsSpacing.xxl),
        Text('Federal programs', style: context.text.titleLarge),
        const SizedBox(height: WsSpacing.md),
        for (final program in mockFederalPrograms)
          Padding(
            padding: const EdgeInsets.only(bottom: WsSpacing.md),
            child: WsCard(
              child: Row(
                children: [
                  const WsProvinceMark.canada(),
                  const SizedBox(width: WsSpacing.md),
                  Expanded(
                    child: Text(program.name, style: context.text.titleMedium),
                  ),
                  const SizedBox(width: WsSpacing.md),
                  WsVerdictChip(
                    verdict: program.eligible
                        ? WsVerdict.eligible
                        : WsVerdict.explore,
                    label: program.eligible ? 'Eligible' : 'Explore',
                  ),
                ],
              ),
            ),
          ),
        const WsDisclaimer(),
      ],
    );
  }
}

/// The CRS answers, in the same sections the CRS questions ask them in, each
/// editable where it is shown.
///
/// Every card opens [ProfileSection]'s own form, so an answer changed here is
/// the same answer the CRS Predictor reads — the score below updates as soon
/// as the form saves.
///
/// **Additional factors is deliberately not here**: a provincial nomination
/// belongs with the provinces, not the federal profile.
class _CrsAnswerCards extends StatelessWidget {
  const _CrsAnswerCards({required this.candidate});

  final Candidate candidate;

  static const String _notAnswered = 'Not answered yet';

  static String _years(int? years) => switch (years) {
        null => _notAnswered,
        0 => 'None',
        1 => '1 year',
        final y => '$y years',
      };

  static String _yesNo(bool? value) =>
      value == null ? _notAnswered : (value ? 'Yes' : 'No');

  /// "CLB 8 in all four" — the lowest ability is the one every CRS combination
  /// is measured against, so it is the number worth showing.
  static String? _levelLine(LanguageResult? result) {
    if (result == null) return null;
    final levels = clbFor(result).all.reduce((a, b) => a < b ? a : b);
    return '${result.test.french ? 'NCLC' : 'CLB'} $levels in all four';
  }

  @override
  Widget build(BuildContext context) {
    final crs = candidate.crs;
    final partner = crs.maritalStatus?.hasPartner ?? false;
    final birth = candidate.birthDate;
    final age = birth == null ? null : ageOn(birth, DateTime.now());

    void edit(ProfileSection section) => context.push(
          Routes.withId(Routes.profileSection, section.name),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FactCard(
          icon: ProfileSection.aboutYou.icon,
          title: ProfileSection.aboutYou.title,
          onOpen: () => edit(ProfileSection.aboutYou),
          facts: [
            _Fact(
              label: 'Date of birth',
              value: candidate.dateOfBirth.isEmpty
                  ? _notAnswered
                  : candidate.dateOfBirth,
              caption: age == null ? null : 'Age $age',
            ),
            _Fact(
              label: 'Marital status',
              value: crs.maritalStatus?.label ?? _notAnswered,
              stacked: true,
              last: !partner,
            ),
            if (partner) ...[
              _Fact(
                label: 'Partner coming with you',
                value: _yesNo(crs.spouseAccompanying),
              ),
              _Fact(
                label: 'Partner is a citizen or PR',
                value: _yesNo(crs.spouseCanadianOrPr),
                last: true,
              ),
            ],
          ],
        ),
        const SizedBox(height: WsSpacing.md),
        _FactCard(
          icon: ProfileSection.education.icon,
          title: ProfileSection.education.title,
          onOpen: () => edit(ProfileSection.education),
          facts: [
            _Fact(
              label: 'Highest qualification',
              value: crs.education?.label ?? _notAnswered,
              stacked: true,
            ),
            _Fact(
              label: 'Studied in Canada',
              value: crs.canadianEducation?.label ?? _notAnswered,
              stacked: true,
              last: true,
            ),
          ],
        ),
        const SizedBox(height: WsSpacing.md),
        _FactCard(
          icon: ProfileSection.language.icon,
          title: ProfileSection.language.title,
          onOpen: () => edit(ProfileSection.language),
          facts: [
            _Fact(
              label: 'English',
              value: crs.englishTest?.test.label ?? _notAnswered,
              caption: _levelLine(crs.englishTest),
            ),
            _Fact(
              label: 'French',
              value: crs.frenchTest?.test.label ?? _notAnswered,
              caption: _levelLine(crs.frenchTest),
              last: true,
            ),
          ],
        ),
        const SizedBox(height: WsSpacing.md),
        _FactCard(
          icon: ProfileSection.work.icon,
          title: ProfileSection.work.title,
          onOpen: () => edit(ProfileSection.work),
          facts: [
            _Fact(
              label: 'Skilled work in Canada',
              value: _years(crs.canadianWorkYears),
            ),
            _Fact(
              label: 'Skilled work abroad',
              value: _years(crs.foreignWorkYears),
            ),
            _Fact(
              label: 'Trade certificate',
              value: _yesNo(crs.certificateOfQualification),
              last: true,
            ),
          ],
        ),
        // IRCC scores a spouse only when one is coming and is not already a
        // citizen or PR, so the card appears on exactly the same condition the
        // CRS questions do.
        if (ProfileSection.spouse.appliesTo(crs)) ...[
          const SizedBox(height: WsSpacing.md),
          _FactCard(
            icon: ProfileSection.spouse.icon,
            title: ProfileSection.spouse.title,
            onOpen: () => edit(ProfileSection.spouse),
            facts: [
              _Fact(
                label: 'Their education',
                value: crs.spouseEducation?.label ?? _notAnswered,
                stacked: true,
              ),
              _Fact(
                label: 'Their language test',
                value: crs.spouseLanguageTest?.test.label ?? _notAnswered,
                caption: _levelLine(crs.spouseLanguageTest),
              ),
              _Fact(
                label: 'Their work in Canada',
                value: _years(crs.spouseCanadianWorkYears),
                last: true,
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// A tab's title with its Edit button on the right.
class _TabHeading extends StatelessWidget {
  const _TabHeading({required this.title, required this.onEdit});

  final String title;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: context.text.titleLarge)),
        TextButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined, size: WsIconSize.field),
          label: const Text('Edit'),
        ),
      ],
    );
  }
}

class _FactCard extends StatelessWidget {
  const _FactCard({
    required this.icon,
    required this.title,
    required this.facts,
    this.onOpen,
  });

  final IconData icon;
  final String title;
  final List<Widget> facts;

  /// Opens this card's own form. A button inside the header would sit on its
  /// own padding and break the right edge the values below line up on, so the
  /// whole card is the target and a chevron says so — the system's own rule
  /// that a chevron means the row opens a screen.
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final onOpen = this.onOpen;

    return WsCard(
      onTap: onOpen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              WsIconTile(icon: icon, size: WsTileSize.compact),
              const SizedBox(width: WsSpacing.md),
              Expanded(child: Text(title, style: context.text.titleMedium)),
              if (onOpen != null) ...[
                const SizedBox(width: WsSpacing.sm),
                Icon(
                  Icons.chevron_right_rounded,
                  size: WsIconSize.chevron + 4,
                  color: context.ws.placeholder,
                ),
              ],
            ],
          ),
          Divider(color: context.colors.outlineVariant, height: WsSpacing.xxl),
          ...facts,
        ],
      ),
    );
  }
}

class _JobsTab extends StatelessWidget {
  const _JobsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        WsSpacing.xl,
        WsSpacing.lg,
        WsSpacing.xl,
        WsSpacing.xxxl,
      ),
      children: [
        WsCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              WsListRow(
                leading: const WsIconTile(icon: Icons.description_outlined),
                title: 'Your applications',
                subtitle: 'Everything you have sent',
                onTap: () => context.push(Routes.applications),
              ),
              Divider(color: context.colors.outlineVariant, height: 1),
              WsListRow(
                leading: const WsIconTile(icon: Icons.bookmark_border_rounded),
                title: 'Saved jobs',
                onTap: () => context.push(Routes.savedJobs),
              ),
              Divider(color: context.colors.outlineVariant, height: 1),
              WsListRow(
                leading:
                    const WsIconTile(icon: Icons.chat_bubble_outline_rounded),
                title: 'Messages',
                onTap: () => context.push(Routes.chatList),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// M8 — documents.
///
/// The design system lists the document-upload component under "not yet
/// defined" (section 23), so this is deliberately minimal: the list is real,
/// the upload is not.
class _DocumentsTab extends StatelessWidget {
  const _DocumentsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        WsSpacing.xl,
        WsSpacing.lg,
        WsSpacing.xl,
        WsSpacing.xxxl,
      ),
      children: [
        for (final document in mockDocuments)
          Padding(
            padding: const EdgeInsets.only(bottom: WsSpacing.md),
            child: WsCard(
              child: Row(
                children: [
                  WsIconTile(
                    icon: document.uploaded
                        ? Icons.description_rounded
                        : Icons.upload_file_outlined,
                  ),
                  const SizedBox(width: WsSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(document.name, style: context.text.titleMedium),
                        Text(
                          document.uploaded
                              ? document.detail
                              : 'Not uploaded yet',
                          style: context.text.bodySmall
                              ?.copyWith(color: context.ws.caption),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: WsSpacing.md),
                  WsVerdictChip(
                    verdict: document.uploaded
                        ? WsVerdict.eligible
                        : WsVerdict.explore,
                    label: document.uploaded ? 'On file' : 'Needed',
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: WsSpacing.sm),
        // TODO(backend): no file picker, and the upload component itself is
        // listed as undefined in the design system.
        WsSecondaryButton(label: 'Upload a document', onPressed: () {}),
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({
    required this.label,
    required this.value,
    this.mark,
    this.caption,
    this.stacked = false,
    this.last = false,
  });

  final String label;
  final String value;

  /// A quieter line under the value, such as "in 4 months".
  final String? caption;

  /// A flag, drawn before the value. Null draws nothing rather than the wrong
  /// flag — the caller decides whether it has one.
  final Widget? mark;

  /// Puts the value on its own line under the label, both left-aligned.
  ///
  /// For a value that is a full sentence — an education level, say — the
  /// side-by-side row leaves a narrow right-aligned column that wraps into a
  /// ragged block. Stacked, it reads as a paragraph and the card stays tidy.
  final bool stacked;

  final bool last;

  @override
  Widget build(BuildContext context) {
    final mark = this.mark;
    final labelStyle =
        context.text.bodyMedium?.copyWith(color: context.ws.caption);
    final valueStyle =
        context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w700);
    final captionStyle =
        context.text.bodySmall?.copyWith(color: context.ws.caption);

    if (stacked) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: labelStyle),
          const SizedBox(height: WsSpacing.xs),
          Text(value, style: valueStyle),
          if (caption != null) Text(caption!, style: captionStyle),
          if (!last)
            Divider(
              color: context.colors.outlineVariant,
              height: WsSpacing.xxl,
            ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          // spaceBetween is load-bearing, not decoration. The label is
          // Flexible so a long one wraps instead of overflowing, but a
          // Flexible and an Expanded both carry flex 1, so the value is
          // *sized* to half the row while being *placed* directly after the
          // label's much narrower actual width. The unused half then collapses
          // at the far right and every value stops short of the card edge the
          // dividers run to. spaceBetween hands that slack to the gap between
          // the two, so the value ends flush right in every card.
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Flexible, not a plain Text: the label takes only the width its
            // own text needs, and still wraps rather than overflowing when the
            // text scale grows.
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(right: WsSpacing.lg),
                child: Text(label, style: labelStyle),
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (mark != null) ...[
                    mark,
                    const SizedBox(width: WsSpacing.sm),
                  ],
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          value,
                          style: valueStyle,
                          textAlign: TextAlign.right,
                        ),
                        if (caption != null)
                          Text(
                            caption!,
                            style: captionStyle,
                            textAlign: TextAlign.right,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!last)
          Divider(color: context.colors.outlineVariant, height: WsSpacing.xxl),
      ],
    );
  }
}
