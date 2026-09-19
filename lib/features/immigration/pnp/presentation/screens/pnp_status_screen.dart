import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/routes.dart';
import '../../../../../app/theme/theme.dart';
import '../../../../../shared/shared.dart';
import '../../../controllers/pnp_status.dart';
import '../../../widgets/score_status_list.dart';

/// What the PNP scores need, and what is still missing.
///
/// The provincial counterpart of the CRS status screen: each section the
/// points grids read, filled in or not, each opening the profile's own form.
/// Once nothing is missing, the button reveals the scores on the Immigration
/// tab.
class PnpStatusScreen extends ConsumerWidget {
  const PnpStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completion = ref.watch(pnpCompletionProvider);
    final tiesAnswered = ref.watch(pnpTiesAnsweredProvider);
    final ready = completion.isComplete && tiesAnswered;
    final missing = completion.sections.length -
        completion.done.length +
        (tiesAnswered ? 0 : 1);

    return Scaffold(
      appBar: AppBar(title: const Text('Your PNP scores')),
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
                : 'Fill these in to get your PNP scores',
            style: context.text.headlineLarge,
          ),
          const SizedBox(height: WsSpacing.md),
          Text(
            'Alberta, British Columbia, Saskatchewan and Manitoba each rank '
            'candidates on their own points grid. WorkSettle scores you on '
            'each from your profile, and anything you save there shows here '
            'straight away.',
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
                title: 'Provincial factors',
                icon: Icons.location_on_outlined,
                done: tiesAnswered,
                whereToFill: 'Asked here — family, work, study or a job offer '
                    'in a province',
                onTap: () => context.push(Routes.pnpTies),
              ),
            ],
          ),
          const SizedBox(height: WsSpacing.xl),
          Text(
            'A few smaller factors — sector endorsements, regional bonuses — '
            'are not asked yet. Each province lists them under "Not counted '
            'yet", so your scores are a floor.',
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
                label: 'Get my PNP scores',
                onPressed: ready
                    ? () {
                        ref.read(pnpRevealedProvider.notifier).reveal();
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
