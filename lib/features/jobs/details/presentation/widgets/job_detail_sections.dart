import 'package:flutter/material.dart';

import '../../../../../app/theme/theme.dart';
import '../../../../../shared/shared.dart';
import '../../../models/job.dart';

/// The sections every job detail carries, in reading order: type, duties,
/// requirements, skills, benefits and immigration support.
///
/// Benefits and immigration support list **every** option, not only the ones
/// offered. A newcomer comparing two postings needs "no accommodation" to be
/// visible, and a missing row cannot say that. Absence is an em dash, never a
/// cross — the product does not punish the posting visually.

class JobDetailSection extends StatelessWidget {
  const JobDetailSection({
    required this.title,
    required this.child,
    this.supporting,
    super.key,
  });

  final String title;
  final String? supporting;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final supporting = this.supporting;
    return Padding(
      padding: const EdgeInsets.only(top: WsSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: context.text.titleLarge),
          if (supporting != null) ...[
            const SizedBox(height: WsSpacing.xs),
            Text(
              supporting,
              style:
                  context.text.bodySmall?.copyWith(color: context.ws.caption),
            ),
          ],
          const SizedBox(height: WsSpacing.md),
          child,
        ],
      ),
    );
  }
}

/// The posting's types, each with a check glyph.
class JobTypeChips extends StatelessWidget {
  const JobTypeChips({required this.types, super.key});

  final List<Employment> types;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: WsSpacing.sm,
      runSpacing: WsSpacing.sm,
      children: [
        for (final type in types)
          _TagPill(label: type.label, icon: Icons.check_rounded),
      ],
    );
  }
}

/// The summary as a bold lead, then the full description. Long descriptions
/// fold after the first paragraph so Tasks and Requirements stay close.
class JobDescription extends StatefulWidget {
  const JobDescription({required this.job, super.key});

  final Job job;

  @override
  State<JobDescription> createState() => _JobDescriptionState();
}

class _JobDescriptionState extends State<JobDescription> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final paragraphs = widget.job.description;
    final canFold = paragraphs.length > 1;
    final shown = _expanded || !canFold ? paragraphs : paragraphs.take(1);
    final body = context.text.bodyMedium
        ?.copyWith(color: context.colors.onSurfaceVariant);

    return WsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.job.summary,
            style: context.text.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: context.colors.onSurface,
            ),
          ),
          AnimatedSize(
            duration: WsMotion.duration(context, WsMotion.medium),
            curve: WsMotion.standard,
            alignment: Alignment.topCenter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final paragraph in shown)
                  Padding(
                    padding: const EdgeInsets.only(top: WsSpacing.md),
                    child: Text(paragraph, style: body),
                  ),
              ],
            ),
          ),
          if (canFold) ...[
            const SizedBox(height: WsSpacing.sm),
            WsLink(
              label: _expanded ? 'Show less' : 'Read full description',
              underline: false,
              onPressed: () => setState(() => _expanded = !_expanded),
            ),
          ],
        ],
      ),
    );
  }
}

/// Tasks and duties, numbered so a long list is easy to refer back to.
class JobDutiesList extends StatelessWidget {
  const JobDutiesList({required this.duties, super.key});

  final List<String> duties;

  @override
  Widget build(BuildContext context) {
    return WsCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (i, duty) in duties.indexed)
            Padding(
              padding: EdgeInsets.only(
                bottom: i == duties.length - 1 ? 0 : WsSpacing.md,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: WsSpacing.xxl,
                    child: Text(
                      '${i + 1}.',
                      style: context.text.labelLarge?.copyWith(
                        color: context.ws.caption,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  Expanded(child: Text(duty, style: context.text.bodyMedium)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Experience, education and certifications, each under its own label.
class JobRequirementsCard extends StatelessWidget {
  const JobRequirementsCard({required this.job, super.key});

  final Job job;

  @override
  Widget build(BuildContext context) {
    return WsCard(
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RequirementRow(
            icon: Icons.work_history_outlined,
            label: 'Experience',
            lines: [job.experience],
          ),
          Divider(height: 1, color: context.colors.outlineVariant),
          _RequirementRow(
            icon: Icons.school_outlined,
            label: 'Education',
            lines: [job.education],
          ),
          Divider(height: 1, color: context.colors.outlineVariant),
          _RequirementRow(
            icon: Icons.workspace_premium_outlined,
            label: 'Certifications',
            lines: job.certifications.isEmpty
                ? const ['None required']
                : job.certifications,
          ),
        ],
      ),
    );
  }
}

class _RequirementRow extends StatelessWidget {
  const _RequirementRow({
    required this.icon,
    required this.label,
    required this.lines,
  });

  final IconData icon;
  final String label;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(WsSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WsIconTile(icon: icon, size: WsTileSize.compact),
          const SizedBox(width: WsSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: context.text.labelLarge
                      ?.copyWith(color: context.ws.caption),
                ),
                const SizedBox(height: WsSpacing.xs),
                for (final line in lines)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      lines.length > 1 ? '• $line' : line,
                      style: context.text.bodyMedium,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The skills the posting asks for.
class JobSkillChips extends StatelessWidget {
  const JobSkillChips({required this.skills, super.key});

  final List<String> skills;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: WsSpacing.sm,
      runSpacing: WsSpacing.sm,
      children: [
        for (final skill in skills) _TagPill(label: skill),
      ],
    );
  }
}

/// A quiet Grey 100 tag. Not pressable, so no border and no chevron.
class _TagPill extends StatelessWidget {
  const _TagPill({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final icon = this.icon;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: WsSpacing.md,
        vertical: WsSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: context.ws.verdictTintedSurface,
        borderRadius: WsRadii.pillR,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: WsIconSize.chevron,
              color: context.colors.onSurface,
            ),
            const SizedBox(width: WsSpacing.xs),
          ],
          Flexible(
            child: Text(
              label,
              style: context.text.labelLarge
                  ?.copyWith(color: context.colors.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

/// All five benefits, each marked offered or not.
class JobBenefitsCard extends StatelessWidget {
  const JobBenefitsCard({required this.benefits, super.key});

  final Set<JobBenefit> benefits;

  @override
  Widget build(BuildContext context) {
    return WsCard(
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (i, benefit) in JobBenefit.values.indexed) ...[
            if (i > 0) Divider(height: 1, color: context.colors.outlineVariant),
            _OfferRow(
              icon: benefit.icon,
              title: benefit.label,
              offered: benefits.contains(benefit),
              offeredLabel: 'Included',
            ),
          ],
        ],
      ),
    );
  }
}

/// PNP, LMIA and job offer, each marked supported or not.
class JobImmigrationSupportCard extends StatelessWidget {
  const JobImmigrationSupportCard({required this.support, super.key});

  final Set<ImmigrationSupport> support;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        WsCard(
          padding: EdgeInsets.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (i, kind) in ImmigrationSupport.values.indexed) ...[
                if (i > 0)
                  Divider(height: 1, color: context.colors.outlineVariant),
                _OfferRow(
                  icon: switch (kind) {
                    ImmigrationSupport.pnp => Icons.account_balance_outlined,
                    ImmigrationSupport.lmia => Icons.assignment_outlined,
                    ImmigrationSupport.jobOffer => Icons.handshake_outlined,
                  },
                  title: kind.label,
                  detail: kind.detail,
                  offered: support.contains(kind),
                  offeredLabel: 'Supported',
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: WsSpacing.md),
        // Employer support is not an outcome: the legal line belongs here, next
        // to the claim, not in a footer nobody reaches.
        const WsDisclaimer(
          authority: 'IRCC or the province',
          message: 'Support is as stated by the employer and is not a '
              'guarantee of immigration.',
        ),
      ],
    );
  }
}

/// A benefit or support row. Offered is a check and a word; not offered is an
/// em dash, which the screen reader hears as "Not offered".
class _OfferRow extends StatelessWidget {
  const _OfferRow({
    required this.icon,
    required this.title,
    required this.offered,
    required this.offeredLabel,
    this.detail,
  });

  final IconData icon;
  final String title;
  final String? detail;
  final bool offered;
  final String offeredLabel;

  @override
  Widget build(BuildContext context) {
    final detail = this.detail;
    final muted = context.ws.caption;

    return Semantics(
      label: '$title: ${offered ? offeredLabel : 'Not offered'}',
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minHeight: WsTouch.minTarget),
        padding: const EdgeInsets.symmetric(
          horizontal: WsSpacing.lg,
          vertical: WsSpacing.md,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: WsIconSize.field,
              color: offered ? context.colors.onSurface : muted,
            ),
            const SizedBox(width: WsSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: context.text.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: offered ? context.colors.onSurface : muted,
                    ),
                  ),
                  if (detail != null)
                    Text(
                      detail,
                      style: context.text.bodySmall?.copyWith(color: muted),
                    ),
                ],
              ),
            ),
            const SizedBox(width: WsSpacing.md),
            if (offered)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_rounded,
                    size: WsIconSize.tick,
                    color: context.colors.onSurface,
                  ),
                  const SizedBox(width: WsSpacing.xs),
                  Text(offeredLabel, style: context.text.labelLarge),
                ],
              )
            else
              Text(
                '—',
                style: context.text.titleMedium?.copyWith(color: muted),
              ),
          ],
        ),
      ),
    );
  }
}
