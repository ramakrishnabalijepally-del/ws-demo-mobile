import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/routes.dart';
import '../../../../../app/theme/theme.dart';
import '../../../../../shared/data/mock_candidate.dart';
import '../../../../../shared/models/candidate.dart';
import '../../../../../shared/models/ws_module.dart';
import '../../../../../shared/shared.dart';
import '../../../../immigration/immigration.dart';
import '../../../data/mock_profile.dart';

/// M1, M3–M7 — the Profile tab and its five tabs.
///
/// Overview · Immigration · Jobs · Documents · Goals, with the active tab
/// marked by a 2.5 px red underline — **the underline is the only indicator, no
/// pill and no fill** (design system section 14).
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
          const WsThemeToggle(),
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
            Tab(text: 'Immigration'),
            Tab(text: 'Jobs'),
            Tab(text: 'Documents'),
            Tab(text: 'Goals'),
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
                _OverviewTab(candidate: candidate),
                const _ImmigrationTab(),
                const _JobsTab(),
                const _DocumentsTab(),
                _GoalsTab(candidate: candidate),
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

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.candidate});

  final Candidate candidate;

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
          child: Column(
            children: [
              _Fact(label: 'Email', value: candidate.email),
              _Fact(label: 'Phone', value: candidate.phone),
              _Fact(label: 'Date of birth', value: candidate.dateOfBirth),
              _Fact(
                label: 'Location',
                value: '${candidate.city}, ${candidate.province}',
              ),
              _Fact(label: 'From', value: candidate.countryOfOrigin),
              _Fact(
                label: 'You are a',
                value: candidate.profileType,
                last: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: WsSpacing.md),
        WsSecondaryButton(
          label: 'Edit profile',
          onPressed: () => context.push(Routes.profileEdit),
        ),
        const SizedBox(height: WsSpacing.xxl),
        Text('Your scores', style: context.text.titleLarge),
        const SizedBox(height: WsSpacing.md),
        WsScoreCard(
          icon: WsModule.crsPredictor.icon,
          title: 'CRS Predictor',
          supporting: 'Comprehensive Ranking System',
          value: mockCrsScore,
          maximum: mockCrsMaximum,
          verdict: WsVerdict.eligible,
          verdictLabel: 'Good Range',
          contextLine: mockRecentDraws,
          brandFill: true,
          showDisclaimer: true,
          onTap: () => context.go(Routes.crsResult),
        ),
      ],
    );
  }
}

class _ImmigrationTab extends StatelessWidget {
  const _ImmigrationTab();

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
        for (final program in mockFederalPrograms)
          Padding(
            padding: const EdgeInsets.only(bottom: WsSpacing.md),
            child: WsCard(
              child: Row(
                children: [
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

class _GoalsTab extends StatelessWidget {
  const _GoalsTab({required this.candidate});

  final Candidate candidate;

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
        Text('What you told us you want', style: context.text.titleLarge),
        const SizedBox(height: WsSpacing.md),
        WsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final goal in candidate.goals)
                Padding(
                  padding: const EdgeInsets.only(bottom: WsSpacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: WsIconSize.tick,
                        color: context.colors.onSurface,
                      ),
                      const SizedBox(width: WsSpacing.md),
                      Expanded(
                        child: Text(goal, style: context.text.bodyMedium),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: WsSpacing.xxl),
        Text('Job interests', style: context.text.titleLarge),
        const SizedBox(height: WsSpacing.md),
        Wrap(
          spacing: WsSpacing.sm,
          runSpacing: WsSpacing.sm,
          children: [
            for (final category in candidate.jobCategories)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: WsSpacing.lg,
                  vertical: WsSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: context.ws.verdictTintedSurface,
                  borderRadius: WsRadii.pillR,
                ),
                child: Text(category, style: context.text.labelLarge),
              ),
          ],
        ),
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value, this.last = false});

  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: context.text.bodyMedium
                    ?.copyWith(color: context.ws.caption),
              ),
            ),
            Flexible(
              child: Text(
                value,
                style: context.text.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.right,
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
