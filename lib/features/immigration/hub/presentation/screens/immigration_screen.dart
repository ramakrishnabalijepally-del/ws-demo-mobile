import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/routes.dart';
import '../../../../../app/theme/theme.dart';
import '../../../../../shared/models/ws_module.dart';
import '../../../../../shared/shared.dart';
import '../../../data/mock_immigration.dart';

/// J1 — the Immigration tab.
///
/// Design system Pattern B — *assess, then disclose*. The hub is the tool
/// overview; each row leads into its own numbered flow, and every result closes
/// with the provisional disclaimer.
class ImmigrationScreen extends StatelessWidget {
  const ImmigrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Immigration'),
        actions: const [WsThemeToggle()],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          WsSpacing.xl,
          WsSpacing.lg,
          WsSpacing.xl,
          WsSpacing.xxxl,
        ),
        children: [
          WsScoreCard(
            icon: WsModule.crsPredictor.icon,
            title: 'Your CRS score',
            supporting: 'Comprehensive Ranking System',
            value: mockCrsScore,
            maximum: mockCrsMaximum,
            verdict: WsVerdict.eligible,
            verdictLabel: 'Good Range',
            contextLine: mockRecentDraws,
            brandFill: true,
            showDisclaimer: true,
            onTap: () => context.push(Routes.crsResult),
          ),
          const SizedBox(height: WsSpacing.xxl),
          Text('Tools', style: context.text.titleLarge),
          const SizedBox(height: WsSpacing.md),
          WsCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                WsListRow(
                  leading: const WsIconTile(icon: Icons.speed_rounded),
                  title: 'CRS Calculator',
                  subtitle: 'Five questions, then a score and a breakdown',
                  onTap: () => context.push(Routes.crsOverview),
                ),
                Divider(color: context.colors.outlineVariant, height: 1),
                WsListRow(
                  leading: const WsIconTile(icon: Icons.map_rounded),
                  title: 'Provincial Nominee Programs',
                  subtitle: 'Pick a province, then a stream',
                  onTap: () => context.push(Routes.pnpProvinces),
                ),
                Divider(color: context.colors.outlineVariant, height: 1),
                WsListRow(
                  leading:
                      const WsIconTile(icon: Icons.account_balance_rounded),
                  title: 'Federal Programs',
                  subtitle: 'Express Entry streams and the pilots',
                  onTap: () => context.push(Routes.programs),
                ),
                Divider(color: context.colors.outlineVariant, height: 1),
                WsListRow(
                  leading: const WsIconTile(icon: Icons.compare_arrows_rounded),
                  title: 'Compare Your Options',
                  subtitle: 'Side by side, on the profile you have entered',
                  onTap: () => context.push(Routes.compare),
                ),
              ],
            ),
          ),
          const SizedBox(height: WsSpacing.xxl),
          Text('Where you stand', style: context.text.titleLarge),
          const SizedBox(height: WsSpacing.md),
          for (final program in mockFederalPrograms.take(3))
            Padding(
              padding: const EdgeInsets.only(bottom: WsSpacing.md),
              child: WsCard(
                onTap: () => context.push(Routes.programs),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(program.name, style: context.text.titleMedium),
                          const SizedBox(height: 2),
                          Text(
                            program.summary,
                            style: context.text.bodySmall
                                ?.copyWith(color: context.ws.caption),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: WsSpacing.md),
                    WsVerdictChip(
                      verdict: program.eligible
                          ? WsVerdict.eligible
                          : WsVerdict.potential,
                      label: program.eligible ? 'Eligible' : 'Potential',
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
