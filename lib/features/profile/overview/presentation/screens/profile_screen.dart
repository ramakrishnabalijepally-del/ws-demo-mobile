import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/routes.dart';
import '../../../../../app/theme/theme.dart';
import '../../../../../shared/controllers/crs_controller.dart';
import '../../../../../shared/data/mock_candidate.dart';
import '../../../../../shared/models/candidate.dart';
import '../../../../../shared/models/immigration_details.dart';
import '../../../../../shared/shared.dart';
import '../../../../../shared/models/crs_profile.dart';
import '../../../../../shared/models/profile_section.dart';
import '../../../../../shared/utils/clb_conversion.dart';
import '../../../../../shared/utils/crs_calculator.dart';
import '../../../../immigration/immigration.dart';
import '../../../data/mock_profile.dart';

/// M1, M3–M7 — the Profile screen and its five tabs.
///
/// Overview · Immigration profile · Jobs · Documents.
///
/// Overview carries the basic profile in full and the immigration profile in
/// summary, each in its own card with its own Edit button. There is no
/// separate Basic profile tab: it would only repeat the Overview card. **Every field a tab shows is a field the edit screen edits**, so
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
  late final TabController _tabs = TabController(length: 4, vsync: this);

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
                  onOpenImmigration: () => _tabs.animateTo(1),
                ),
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
                // Profile strength is a readout here and nothing more. The
                // checklist is reached from the dashboard and from the agent's
                // notices; a second way in from the profile header only asked
                // the reader to decide which of two routes they had taken.
                Text(
                  '${candidate.profileStrength}% complete',
                  style: context.text.bodySmall
                      ?.copyWith(color: context.ws.caption),
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

/// Overview — both profiles as cards, each opening its own editor.
///
/// The basic profile is shown here in full, so it has no tab of its own. The
/// immigration card is a summary of the tab behind it; its link moves there.
class _OverviewTab extends StatelessWidget {
  const _OverviewTab({
    required this.candidate,
    required this.onOpenImmigration,
  });

  final Candidate candidate;
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
            onEdit: () => context.push(Routes.profileEdit),
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
    required this.onEdit,
    this.openLabel,
    this.onOpen,
  });

  final IconData icon;
  final String title;
  final List<Widget> facts;

  /// The link into the full tab, named so it says where it goes. Null for a
  /// card that is already the whole profile.
  final String? openLabel;

  final VoidCallback onEdit;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final openLabel = this.openLabel;
    final onOpen = this.onOpen;

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
          if (openLabel != null && onOpen != null) ...[
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
        ],
      ),
    );
  }
}

/// The Basic profile fields, in one list so the Overview card and the edit
/// form can never drift apart.
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

/// Passport, status in Canada and family, then the federal and PNP scores —
/// everything immigration in one place.
///
/// **The scores here are readouts, never generators.** Each is generated in
/// Immigration and nowhere else — one place to ask for it. Before it exists,
/// its slot says where to go; once it does, tapping it opens the breakdown.
///
/// The tab reads in one direction: the facts, then every answer the scores
/// are built from, then the scores themselves. A total placed before its own
/// inputs asks the reader to take it on trust.
class _ImmigrationProfileTab extends StatelessWidget {
  const _ImmigrationProfileTab({required this.candidate});

  final Candidate candidate;

  static const String _notAdded = 'Not added yet';

  @override
  Widget build(BuildContext context) {
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
        // The order the reader is asked to think in: who you are, what you
        // have done, then the documents and the people behind it. The CRS
        // answers and the immigration facts are one list, not two.
        _AboutYouCard(candidate: candidate),
        const SizedBox(height: WsSpacing.md),
        _EducationCard(crs: candidate.crs),
        const SizedBox(height: WsSpacing.md),
        _WorkCard(crs: candidate.crs),
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
        _LanguageCard(crs: candidate.crs),
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
        if (ProfileSection.spouse.appliesTo(candidate.crs)) ...[
          const SizedBox(height: WsSpacing.md),
          _SpouseCard(crs: candidate.crs),
        ],
        const SizedBox(height: WsSpacing.xxl),
        // The totals come after the answers they are made of, not before
        // them: the reader sees what they have given, then what it adds up
        // to. Both are readouts — generated in Immigration, never here.
        const _ScoreHeading(
          title: 'Federal score',
          subtitle: "Canada's Express Entry ranking score.",
          points: [
            (Icons.flag_outlined, 'Out of 1,200 points (the CRS).'),
            (
              Icons.fact_check_outlined,
              'Worked out from your answers above, using official IRCC '
                  'points.',
            ),
            (
              Icons.touch_app_outlined,
              'Get it in Immigration. Then tap the score to see how it adds '
                  'up.',
            ),
          ],
        ),
        const SizedBox(height: WsSpacing.md),
        const _CrsScoreTile(),
        const SizedBox(height: WsSpacing.xxl),
        const _ScoreHeading(
          title: 'PNP score',
          subtitle: 'Your points with each province.',
          points: [
            (
              Icons.location_city_outlined,
              'A province can nominate you for permanent residence.',
            ),
            (
              Icons.map_outlined,
              'Each province scores you on its own points system.',
            ),
            (
              Icons.touch_app_outlined,
              'Get each one in Immigration. Then tap a score to see how it '
                  'adds up.',
            ),
          ],
        ),
        const SizedBox(height: WsSpacing.md),
        const PnpProvinceGrid(canGenerate: false),
        const SizedBox(height: WsSpacing.xl),
        const WsDisclaimer(),
      ],
    );
  }
}

/// A score's heading: the title with a small ⓘ beside it, and one plain
/// line saying what the score is.
///
/// The ⓘ opens a short explanation — three points, not a paragraph — for the
/// reader who wants it, and stays out of the way for the one who does not.
class _ScoreHeading extends StatelessWidget {
  const _ScoreHeading({
    required this.title,
    required this.subtitle,
    required this.points,
  });

  final String title;
  final String subtitle;

  /// Each point is one short sentence with the icon that says what it is
  /// about.
  final List<(IconData, String)> points;

  void _showAbout(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            WsSpacing.xl,
            0,
            WsSpacing.xl,
            WsSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: context.text.titleLarge),
              const SizedBox(height: WsSpacing.xl),
              for (final (icon, text) in points)
                Padding(
                  padding: const EdgeInsets.only(bottom: WsSpacing.lg),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WsIconTile(icon: icon, size: WsTileSize.compact),
                      const SizedBox(width: WsSpacing.md),
                      Expanded(
                        child: Padding(
                          // Centres a one-line point on the 40 dp tile.
                          padding: const EdgeInsets.only(top: WsSpacing.sm),
                          child: Text(text, style: context.text.bodyMedium),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: WsSpacing.sm),
              WsSecondaryButton(
                label: 'Got it',
                onPressed: () => Navigator.of(sheetContext).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Semantics(
                header: true,
                child: Text(title, style: context.text.titleLarge),
              ),
            ),
            // Beside the title, not across the card from it: the symbol
            // belongs to the words it explains.
            IconButton(
              tooltip: 'About the ${title.toLowerCase()}',
              onPressed: () => _showAbout(context),
              icon: Icon(
                Icons.info_outline_rounded,
                size: 20,
                color: context.ws.caption,
              ),
            ),
          ],
        ),
        Text(
          subtitle,
          style: context.text.bodySmall?.copyWith(color: context.ws.caption),
        ),
      ],
    );
  }
}

/// The CRS score, small. It is never generated here: before it exists the
/// tile opens the CRS status screen in Immigration, where it is; once it
/// does, the tile opens the breakdown. Both open above Profile, so Back
/// returns here.
class _CrsScoreTile extends ConsumerWidget {
  const _CrsScoreTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final revealed = ref.watch(crsRevealedProvider);
    final crs = ref.watch(crsResultProvider);
    final verdict = crsVerdict(crs.total);

    return WsCard(
      onTap: () =>
          context.push(revealed ? Routes.crsBreakdown : Routes.crsOverview),
      child: Row(
        children: [
          // The CRS is Canada's federal score, so it carries the flag.
          const WsProvinceMark.canada(),
          const SizedBox(width: WsSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('CRS score', style: context.text.bodySmall),
                if (revealed) ...[
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${crs.total}',
                          style: context.text.headlineLarge?.copyWith(
                            fontFeatures: const [
                              FontFeature.tabularFigures(),
                            ],
                          ),
                        ),
                        TextSpan(
                          text: ' / $crsMaximum',
                          style: WsTypography.denominator(context.ws.caption),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: WsSpacing.xs),
                  // Under the number, not beside it: a verdict and a chevron
                  // beside the score do not fit on a 360 dp phone.
                  WsVerdictChip(verdict: verdict.verdict, label: verdict.label),
                ] else ...[
                  Text('Not generated yet', style: context.text.titleMedium),
                  Text(
                    'Tap to get it in Immigration.',
                    style: context.text.bodySmall
                        ?.copyWith(color: context.ws.caption),
                  ),
                ],
              ],
            ),
          ),
          // Centred on the row in both states: the whole card is the target,
          // and the chevron says it opens something.
          const SizedBox(width: WsSpacing.sm),
          Icon(
            Icons.chevron_right_rounded,
            size: WsIconSize.chevron + 4,
            color: context.ws.placeholder,
          ),
        ],
      ),
    );
  }
}

/// Shared wording and formatting for the CRS answer cards below.
///
/// **Additional factors is deliberately not among them**: a provincial
/// nomination belongs with the provinces, not the federal profile.
abstract final class _CrsAnswers {
  static const String notAnswered = 'Not answered yet';

  static String years(int? years) => switch (years) {
        null => notAnswered,
        0 => 'None',
        1 => '1 year',
        final y => '$y years',
      };

  static String yesNo(bool? value) =>
      value == null ? notAnswered : (value ? 'Yes' : 'No');

  /// "CLB 8 in all four" — the lowest ability is the one every CRS combination
  /// is measured against, so it is the number worth showing.
  static String? levelLine(LanguageResult? result) {
    if (result == null) return null;
    final levels = clbFor(result).all.reduce((a, b) => a < b ? a : b);
    return '${result.test.french ? 'NCLC' : 'CLB'} $levels in all four';
  }

  /// Every card opens [ProfileSection]'s own form, so an answer changed here is
  /// the same answer the CRS Predictor reads — the score updates as soon as the
  /// form saves.
  static void edit(BuildContext context, ProfileSection section) =>
      context.push(Routes.withId(Routes.profileSection, section.name));
}

/// Date of birth and marital status, and who is coming.
class _AboutYouCard extends StatelessWidget {
  const _AboutYouCard({required this.candidate});

  final Candidate candidate;

  @override
  Widget build(BuildContext context) {
    final crs = candidate.crs;
    final partner = crs.maritalStatus?.hasPartner ?? false;
    final birth = candidate.birthDate;
    final age = birth == null ? null : ageOn(birth, DateTime.now());

    return _FactCard(
      icon: ProfileSection.aboutYou.icon,
      title: ProfileSection.aboutYou.title,
      onOpen: () => _CrsAnswers.edit(context, ProfileSection.aboutYou),
      facts: [
        _Fact(
          label: 'Date of birth',
          value: candidate.dateOfBirth.isEmpty
              ? _CrsAnswers.notAnswered
              : candidate.dateOfBirth,
          caption: age == null ? null : 'Age $age',
        ),
        _Fact(
          label: 'Marital status',
          value: crs.maritalStatus?.label ?? _CrsAnswers.notAnswered,
          stacked: true,
          last: !partner,
        ),
        if (partner) ...[
          _Fact(
            label: 'Partner coming with you',
            value: _CrsAnswers.yesNo(crs.spouseAccompanying),
          ),
          _Fact(
            label: 'Partner is a citizen or PR',
            value: _CrsAnswers.yesNo(crs.spouseCanadianOrPr),
            last: true,
          ),
        ],
      ],
    );
  }
}

/// Highest qualification, and any study in Canada.
class _EducationCard extends StatelessWidget {
  const _EducationCard({required this.crs});

  final CrsProfile crs;

  @override
  Widget build(BuildContext context) {
    return _FactCard(
      icon: ProfileSection.education.icon,
      title: ProfileSection.education.title,
      onOpen: () => _CrsAnswers.edit(context, ProfileSection.education),
      facts: [
        _Fact(
          label: 'Highest qualification',
          value: crs.education?.label ?? _CrsAnswers.notAnswered,
          stacked: true,
        ),
        _Fact(
          label: 'Studied in Canada',
          value: crs.canadianEducation?.label ?? _CrsAnswers.notAnswered,
          stacked: true,
          last: true,
        ),
      ],
    );
  }
}

/// Skilled work in Canada and abroad, and a trade certificate.
class _WorkCard extends StatelessWidget {
  const _WorkCard({required this.crs});

  final CrsProfile crs;

  @override
  Widget build(BuildContext context) {
    return _FactCard(
      icon: ProfileSection.work.icon,
      title: ProfileSection.work.title,
      onOpen: () => _CrsAnswers.edit(context, ProfileSection.work),
      facts: [
        _Fact(
          label: 'Skilled work in Canada',
          value: _CrsAnswers.years(crs.canadianWorkYears),
        ),
        _Fact(
          label: 'Skilled work abroad',
          value: _CrsAnswers.years(crs.foreignWorkYears),
        ),
        _Fact(
          label: 'Trade certificate',
          value: _CrsAnswers.yesNo(crs.certificateOfQualification),
          last: true,
        ),
      ],
    );
  }
}

/// English and French results.
class _LanguageCard extends StatelessWidget {
  const _LanguageCard({required this.crs});

  final CrsProfile crs;

  @override
  Widget build(BuildContext context) {
    return _FactCard(
      icon: ProfileSection.language.icon,
      title: ProfileSection.language.title,
      onOpen: () => _CrsAnswers.edit(context, ProfileSection.language),
      facts: [
        _Fact(
          label: 'English',
          value: crs.englishTest?.test.label ?? _CrsAnswers.notAnswered,
          caption: _CrsAnswers.levelLine(crs.englishTest),
        ),
        _Fact(
          label: 'French',
          value: crs.frenchTest?.test.label ?? _CrsAnswers.notAnswered,
          caption: _CrsAnswers.levelLine(crs.frenchTest),
          last: true,
        ),
      ],
    );
  }
}

/// The partner's own education, language and Canadian work.
///
/// IRCC scores a spouse only when one is coming and is not already a citizen
/// or PR, so this card appears on exactly the same condition the CRS questions
/// do — see [ProfileSection.spouse].
class _SpouseCard extends StatelessWidget {
  const _SpouseCard({required this.crs});

  final CrsProfile crs;

  @override
  Widget build(BuildContext context) {
    return _FactCard(
      icon: ProfileSection.spouse.icon,
      title: ProfileSection.spouse.title,
      onOpen: () => _CrsAnswers.edit(context, ProfileSection.spouse),
      facts: [
        _Fact(
          label: 'Their education',
          value: crs.spouseEducation?.label ?? _CrsAnswers.notAnswered,
          stacked: true,
        ),
        _Fact(
          label: 'Their language test',
          value: crs.spouseLanguageTest?.test.label ?? _CrsAnswers.notAnswered,
          caption: _CrsAnswers.levelLine(crs.spouseLanguageTest),
        ),
        _Fact(
          label: 'Their work in Canada',
          value: _CrsAnswers.years(crs.spouseCanadianWorkYears),
          last: true,
        ),
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
