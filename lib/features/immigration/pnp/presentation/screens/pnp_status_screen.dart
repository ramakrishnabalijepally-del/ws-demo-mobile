import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/routes.dart';
import '../../../../../app/theme/theme.dart';
import '../../../../../shared/models/provincial_factors.dart';
import '../../../../../shared/shared.dart';
import '../../../controllers/pnp_status.dart';
import '../../../widgets/score_status_list.dart';

/// What one province's PNP score needs, and what is still missing.
///
/// The provincial counterpart of the CRS status screen, one province at a
/// time: each profile section the grid reads, plus that province's own
/// questions, each opening its form. Once nothing is missing, the button
/// reveals this province's score — and no other.
class PnpStatusScreen extends ConsumerWidget {
  const PnpStatusScreen({required this.provinceCode, super.key});

  /// Two-letter code: AB, BC, SK or MB.
  final String provinceCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final province = ProvinceTie.forCode(provinceCode);
    if (province == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('PNP score')),
        body: Padding(
          padding: WsSpacing.gutter,
          child: Text(
            'This province does not rank candidates on a points grid.',
            style: context.text.bodyMedium,
          ),
        ),
      );
    }
    final code = province.code!;
    final completion = ref.watch(pnpCompletionProvider);
    final tiesAnswered = ref.watch(pnpFactorsAnsweredProvider(code));
    final ready = completion.isComplete && tiesAnswered;
    final missing = completion.sections.length -
        completion.done.length +
        (tiesAnswered ? 0 : 1);

    return Scaffold(
      appBar: AppBar(title: Text('${province.label} score')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          WsSpacing.xl,
          WsSpacing.lg,
          WsSpacing.xl,
          WsSpacing.huge,
        ),
        children: [
          Text(
            ready
                ? 'Everything is filled in'
                : 'Fill these in to get your ${province.label} score',
            style: context.text.headlineLarge,
          ),
          const SizedBox(height: WsSpacing.md),
          Text(
            '${province.label} ranks candidates on its own points grid. '
            'WorkSettle scores you on it from your profile, and anything you '
            'save there shows here straight away.',
            style: context.text.bodyMedium
                ?.copyWith(color: context.colors.onSurfaceVariant),
          ),
          const SizedBox(height: WsSpacing.xxl),
          ScoreStatusList(
            items: [
              for (final section in completion.sections)
                ScoreStatusItem(
                  title: section.title,
                  icon: section.icon,
                  done: completion.done.contains(section),
                  whereToFill: 'Fill in on your profile',
                  onTap: () => context.push(
                    Routes.withId(Routes.profileSection, section.name),
                  ),
                ),
              // Not a CRS factor, so not a profile section: asked here.
              ScoreStatusItem(
                title: '${province.label} factors',
                icon: Icons.location_on_outlined,
                done: tiesAnswered,
                whereToFill: 'Asked here — family, work, study or a job offer '
                    'in ${province.label}',
                onTap: () => context.push(Routes.withId(Routes.pnpTies, code)),
              ),
            ],
          ),
          const SizedBox(height: WsSpacing.xl),
          Text(
            'A few smaller factors — sector endorsements, regional bonuses — '
            'are not asked yet. The breakdown lists them under "Not counted '
            'yet", so your score is a floor.',
            style: context.text.bodySmall?.copyWith(color: context.ws.caption),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!ready) ...[
                Text(
                  missing == 1
                      ? 'Fill in 1 more section to get your scores.'
                      : 'Fill in $missing more sections to get your scores.',
                  textAlign: TextAlign.center,
                  style: context.text.bodySmall
                      ?.copyWith(color: context.ws.caption),
                ),
                const SizedBox(height: WsSpacing.sm),
              ],
              WsPrimaryButton(
                label: 'Get my ${province.label} score',
                onPressed: ready
                    ? () {
                        ref.read(pnpRevealedProvider.notifier).reveal(code);
                        context.pop();
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
