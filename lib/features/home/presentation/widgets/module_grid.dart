import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/theme.dart';
import '../../../../shared/models/ws_module.dart';
import '../../../../shared/shared.dart';

/// The hub grid, two tiles per row.
///
/// **Every tile is the same ink glyph on the same Grey 100 tile** — the seven
/// hues are retired and the glyph does the identifying. Job Matching alone
/// keeps the brand red.
///
/// A locked module routes to the paywall rather than the feature, which is the
/// only way the paywall is ever reached (design system Pattern D).
class ModuleGrid extends ConsumerWidget {
  const ModuleGrid({required this.modules, super.key});

  final List<WsModule> modules;

  static String _routeFor(WsModule module) => switch (module) {
        WsModule.jobMatching => Routes.jobs,
        WsModule.profileMatching => Routes.profile,
        WsModule.eligibility => Routes.programs,
        WsModule.crsPredictor => Routes.crsOverview,
        WsModule.assistant => Routes.assistant,
        WsModule.checklist => Routes.checklist,
        WsModule.appointments => Routes.appointments,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tier = ref.watch(planTierProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        const columns = 2;
        const gap = WsSpacing.md;
        final tileWidth = (constraints.maxWidth - gap) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final module in modules)
              SizedBox(
                width: tileWidth,
                child: _ModuleTile(
                  module: module,
                  locked: module.isPremium && tier == PlanTier.free,
                  onTap: () {
                    final locked = module.isPremium && tier == PlanTier.free;
                    context.push(
                      locked ? Routes.paywall : _routeFor(module),
                      extra: locked ? module.label : null,
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ModuleTile extends StatelessWidget {
  const _ModuleTile({
    required this.module,
    required this.locked,
    required this.onTap,
  });

  final WsModule module;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return WsCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              WsIconTile(icon: module.icon, brand: module.brand),
              const Spacer(),
              if (locked)
                Icon(
                  Icons.lock_outline_rounded,
                  size: 18,
                  color: context.ws.placeholder,
                  semanticLabel: 'Pro feature',
                ),
            ],
          ),
          const SizedBox(height: WsSpacing.md),
          Text(
            module.label,
            style: context.text.titleMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            module.blurb,
            style: context.text.bodySmall?.copyWith(color: context.ws.caption),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
