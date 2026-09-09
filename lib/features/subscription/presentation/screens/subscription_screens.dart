import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/theme.dart';
import '../../../../shared/shared.dart';
import '../../data/mock_plans.dart';

/// O1 — the locked-feature prompt.
///
/// Design system Pattern D: **the paywall is only ever reached by trying to use
/// a premium feature — it is not a screen in the navigation.** It states what
/// stays free before it states a price.
class PaywallScreen extends StatelessWidget {
  const PaywallScreen({this.lockedFeature, super.key});

  /// What the reader just tried to open, so the screen answers the question
  /// they actually asked.
  final String? lockedFeature;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upgrade')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          WsSpacing.xl,
          WsSpacing.xxl,
          WsSpacing.xl,
          WsSpacing.huge,
        ),
        children: [
          const Center(
            child: WsIconTile(
              icon: Icons.workspace_premium_rounded,
              size: WsTileSize.header,
            ),
          ),
          const SizedBox(height: WsSpacing.xl),
          Text(
            lockedFeature == null
                ? 'This one is on Pro'
                : '$lockedFeature is on Pro',
            style: context.text.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: WsSpacing.md),
          Text(
            'Your profile and job search stay free, always. Pro adds the AI '
            'tools — the score predictor, the eligibility checks, the '
            'assistant and your checklist.',
            style: context.text.bodyMedium
                ?.copyWith(color: context.colors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: WsSpacing.xxl),
          WsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('What Pro adds', style: context.text.titleMedium),
                const SizedBox(height: WsSpacing.md),
                for (final feature in mockPlans[1].features.skip(1))
                  Padding(
                    padding: const EdgeInsets.only(bottom: WsSpacing.sm),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_rounded,
                          size: WsIconSize.tick,
                          color: context.colors.primary,
                        ),
                        const SizedBox(width: WsSpacing.md),
                        Expanded(
                          child: Text(feature, style: context.text.bodyMedium),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
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
            children: [
              WsPrimaryButton(
                label: 'See the plans',
                onPressed: () => context.push(Routes.plans),
              ),
              WsLink(
                label: 'Not now',
                underline: false,
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// O2 — plan selection, with the monthly/yearly toggle.
class PlansScreen extends ConsumerStatefulWidget {
  const PlansScreen({super.key});

  @override
  ConsumerState<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends ConsumerState<PlansScreen> {
  int _period = 0; // 0 monthly, 1 yearly
  PlanTier _selected = PlanTier.pro;

  bool get _yearly => _period == 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose your plan')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          WsSpacing.xl,
          WsSpacing.lg,
          WsSpacing.xl,
          WsSpacing.huge,
        ),
        children: [
          WsSegmentedToggle(
            options: const ['Monthly', 'Yearly'],
            selectedIndex: _period,
            onChanged: (i) => setState(() => _period = i),
            trailing: const WsBadge.saving(label: 'Save 17%'),
          ),
          const SizedBox(height: WsSpacing.xl),
          for (final plan in mockPlans) ...[
            _PlanCard(
              plan: plan,
              yearly: _yearly,
              selected: _selected == plan.tier,
              onTap: () => setState(() => _selected = plan.tier),
            ),
            const SizedBox(height: WsSpacing.md),
          ],
          const SizedBox(height: WsSpacing.sm),
          WsSecondaryButton(
            label: 'Compare everything',
            onPressed: () => context.push(Routes.planComparison),
          ),
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
            label: _selected == PlanTier.free
                ? 'Stay on Free'
                : 'Continue to payment',
            onPressed: () => _selected == PlanTier.free
                ? context.pop()
                : context.push(Routes.payment, extra: _selected),
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.yearly,
    required this.selected,
    required this.onTap,
  });

  final Plan plan;
  final bool yearly;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final price = yearly ? plan.yearly : plan.monthly;
    final period = yearly ? '/year' : '/month';

    return WsSelectionCard(
      selected: selected,
      onTap: onTap,
      semanticLabel: '${plan.name} plan',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(plan.name, style: context.text.titleLarge),
              const SizedBox(width: WsSpacing.md),
              if (plan.mostPopular) const WsBadge.mostPopular(),
            ],
          ),
          const SizedBox(height: WsSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                price == 0 ? 'Free' : '\$$price',
                style: context.text.displaySmall?.copyWith(fontSize: 30),
              ),
              if (price != 0) ...[
                const SizedBox(width: WsSpacing.xs),
                Text(
                  period,
                  style: WsTypography.denominator(context.ws.caption),
                ),
              ],
            ],
          ),
          const SizedBox(height: WsSpacing.sm),
          Text(
            plan.blurb,
            style: context.text.bodySmall?.copyWith(color: context.ws.caption),
          ),
          const SizedBox(height: WsSpacing.lg),
          for (final feature in plan.features)
            Padding(
              padding: const EdgeInsets.only(bottom: WsSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_rounded,
                    size: WsIconSize.tick,
                    color: context.colors.primary,
                  ),
                  const SizedBox(width: WsSpacing.md),
                  Expanded(
                    child: Text(feature, style: context.text.bodyMedium),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// O3 — the comparison matrix.
class PlanComparisonScreen extends StatelessWidget {
  const PlanComparisonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compare plans')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: WsSpacing.lg),
        children: [
          Padding(
            padding: WsSpacing.gutter,
            child: Text(
              'A dash means a plan does not include something. It is not a '
              'mark against it — the free plan does the thing most people came '
              'here for.',
              style:
                  context.text.bodySmall?.copyWith(color: context.ws.caption),
            ),
          ),
          const SizedBox(height: WsSpacing.lg),
          // The matrix scrolls inside its own container so the page body never
          // scrolls horizontally.
          const SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: WsSpacing.gutter,
            child: _Matrix(),
          ),
        ],
      ),
    );
  }
}

class _Matrix extends StatelessWidget {
  const _Matrix();

  @override
  Widget build(BuildContext context) {
    const double featureWidth = 200;
    const double columnWidth = 84;

    Widget cell(bool included, Color? background) => Container(
          width: columnWidth,
          height: 44,
          color: background,
          alignment: Alignment.center,
          child: included
              ? Icon(
                  Icons.check_rounded,
                  size: WsIconSize.tick,
                  color: context.colors.primary,
                  semanticLabel: 'Included',
                )
              : Text(
                  // An em dash, never a cross.
                  '—',
                  style: context.text.bodyMedium
                      ?.copyWith(color: context.ws.placeholder),
                  semanticsLabel: 'Not included',
                ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SizedBox(width: featureWidth),
            for (final (name, background) in [
              ('Free', null),
              ('Pro', context.ws.planProColumn),
              ('Pro+', context.ws.planProPlusColumn),
            ])
              Container(
                width: columnWidth,
                height: 44,
                color: background,
                alignment: Alignment.center,
                child: Text(name, style: context.text.titleMedium),
              ),
          ],
        ),
        Divider(color: context.colors.outlineVariant, height: 1),
        for (final row in mockComparison)
          Row(
            children: [
              SizedBox(
                width: featureWidth,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: WsSpacing.md,
                    horizontal: WsSpacing.sm,
                  ),
                  child: Text(row.feature, style: context.text.bodyMedium),
                ),
              ),
              cell(row.free, null),
              cell(row.pro, context.ws.planProColumn),
              cell(row.proPlus, context.ws.planProPlusColumn),
            ],
          ),
      ],
    );
  }
}

/// O4 — payment method.
class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({required this.tier, super.key});

  final PlanTier tier;

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  int _method = 0;
  bool _processing = false;

  Future<void> _pay() async {
    setState(() => _processing = true);
    // TODO(backend): no payment is taken. The delay stands in for the round
    // trip so the loading state on the button is visible.
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;
    ref.read(planTierProvider.notifier).upgradeTo(widget.tier);
    context.go(Routes.subscriptionActive);
  }

  @override
  Widget build(BuildContext context) {
    final plan = mockPlans.firstWhere((p) => p.tier == widget.tier);

    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          WsSpacing.xl,
          WsSpacing.lg,
          WsSpacing.xl,
          WsSpacing.huge,
        ),
        children: [
          WsCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(plan.name, style: context.text.titleLarge),
                      Text(
                        plan.blurb,
                        style: context.text.bodySmall
                            ?.copyWith(color: context.ws.caption),
                      ),
                    ],
                  ),
                ),
                Text(
                  '\$${plan.monthly}/mo',
                  style: context.text.titleMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: WsSpacing.xxl),
          Text('How would you like to pay?', style: context.text.titleLarge),
          const SizedBox(height: WsSpacing.md),
          for (var i = 0; i < mockPaymentMethods.length; i++) ...[
            WsSelectionCard(
              selected: _method == i,
              onTap: () => setState(() => _method = i),
              semanticLabel: mockPaymentMethods[i].label,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          mockPaymentMethods[i].label,
                          style: context.text.titleMedium,
                        ),
                        Text(
                          mockPaymentMethods[i].detail,
                          style: context.text.bodySmall
                              ?.copyWith(color: context.ws.caption),
                        ),
                      ],
                    ),
                  ),
                  if (_method == i)
                    Icon(
                      Icons.check_circle_rounded,
                      color: context.colors.primary,
                    ),
                ],
              ),
            ),
            const SizedBox(height: WsSpacing.md),
          ],
          const SizedBox(height: WsSpacing.sm),
          Text(
            'You can cancel any time. Cancelling stops the next renewal and you '
            'keep access until the end of the period you have paid for.',
            style: context.text.bodySmall?.copyWith(color: context.ws.caption),
          ),
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
            label: 'Pay \$${plan.monthly} and start',
            forward: false,
            isLoading: _processing,
            onPressed: _processing ? null : _pay,
          ),
        ),
      ),
    );
  }
}

/// O5 — activated.
class SubscriptionActiveScreen extends StatelessWidget {
  const SubscriptionActiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WsSuccessScreen(
      // Money settled: the filled ink disc, not the open red ring.
      milestone: WsMilestone.settled,
      headline: 'You are on Pro',
      body: 'Every AI tool is unlocked. Your CRS score and eligibility are '
          'waiting on the Immigration tab.',
      primaryLabel: 'See my score',
      confetti: true,
      onPrimary: () => context.go(Routes.crsResult),
      secondaryLabel: 'Back to Home',
      onSecondary: () => context.go(Routes.home),
    );
  }
}
