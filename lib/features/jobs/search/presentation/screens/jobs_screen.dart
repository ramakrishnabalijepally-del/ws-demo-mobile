import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/routes.dart';
import '../../../../../app/theme/theme.dart';
import '../../../../../shared/shared.dart';
import '../../../controllers/jobs_controller.dart';
import '../../../data/mock_jobs.dart';
import '../../../widgets/job_card.dart';
import '../widgets/job_filter_sheet.dart';

/// E1–E2, E5–E6 — the Jobs tab: search, category chips, results, empty state.
///
/// Search and the results list are one screen rather than two. The deck splits
/// them, but on a phone that means a second screen whose only job is to hold a
/// keyboard — the list simply filters as you type.
class JobsScreen extends ConsumerStatefulWidget {
  const JobsScreen({super.key});

  @override
  ConsumerState<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends ConsumerState<JobsScreen> {
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _openFilters() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const JobFilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final jobs = ref.watch(filteredJobsProvider);
    final filters = ref.watch(jobFiltersProvider);
    final query = ref.watch(jobQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jobs'),
        actions: [
          const WsThemeToggle(),
          IconButton(
            tooltip: 'Saved jobs',
            onPressed: () => context.push(Routes.savedJobs),
            icon: const Icon(Icons.bookmark_border_rounded),
          ),
          IconButton(
            tooltip: 'Your applications',
            onPressed: () => context.push(Routes.applications),
            icon: const Icon(Icons.description_outlined),
          ),
          IconButton(
            tooltip: 'Messages',
            onPressed: () => context.push(Routes.chatList),
            icon: const Icon(Icons.chat_bubble_outline_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              WsSpacing.xl,
              WsSpacing.sm,
              WsSpacing.xl,
              WsSpacing.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _search,
                    onChanged: (v) =>
                        ref.read(jobQueryProvider.notifier).state = v,
                    style: context.text.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Search job titles or companies',
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        size: WsIconSize.field,
                      ),
                      suffixIcon: query.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Clear search',
                              icon: const Icon(Icons.close_rounded, size: 18),
                              onPressed: () {
                                _search.clear();
                                ref.read(jobQueryProvider.notifier).state = '';
                              },
                            ),
                    ),
                  ),
                ),
                const SizedBox(width: WsSpacing.md),
                _FilterButton(
                  activeCount: filters.activeCount,
                  onPressed: _openFilters,
                ),
              ],
            ),
          ),
          _CategoryChips(
            selected: filters.field,
            onSelected: (field) => ref
                .read(jobFiltersProvider.notifier)
                .set(filters.copyWith(field: field)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              WsSpacing.xl,
              WsSpacing.md,
              WsSpacing.xl,
              WsSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    query.isEmpty ? 'Recommended for you' : 'Results',
                    style: context.text.titleLarge,
                  ),
                ),
                Text(
                  '${jobs.length} found',
                  style: context.text.bodySmall
                      ?.copyWith(color: context.ws.caption),
                ),
              ],
            ),
          ),
          Expanded(
            child: jobs.isEmpty
                ? WsEmptyState(
                    icon: Icons.search_off_rounded,
                    headline: 'No jobs match that yet',
                    body: 'Try a broader search, or clear a filter or two — '
                        'there are ${mockJobs.length} roles on the board.',
                    actionLabel: 'Clear filters',
                    onAction: () {
                      _search.clear();
                      ref.read(jobQueryProvider.notifier).state = '';
                      ref.read(jobFiltersProvider.notifier).clear();
                    },
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      WsSpacing.xl,
                      WsSpacing.sm,
                      WsSpacing.xl,
                      WsSpacing.xxxl,
                    ),
                    itemCount: jobs.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: WsSpacing.md),
                    itemBuilder: (context, i) => JobCard(
                      job: jobs[i],
                      onTap: () => context.push(
                        Routes.withId(Routes.jobDetails, jobs[i].id),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.activeCount, required this.onPressed});

  final int activeCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final active = activeCount > 0;
    return Semantics(
      button: true,
      label: active ? '$activeCount filters active' : 'Filter jobs',
      child: InkWell(
        onTap: onPressed,
        borderRadius: WsRadii.fieldR,
        child: Container(
          width: WsTouch.minTarget,
          height: WsTouch.minTarget,
          decoration: BoxDecoration(
            color: active ? context.colors.primary : context.colors.surface,
            borderRadius: WsRadii.fieldR,
            border: Border.all(
              color: active
                  ? context.colors.primary
                  : context.colors.outlineVariant,
              width: 1.5,
            ),
          ),
          child: Icon(
            Icons.tune_rounded,
            size: 20,
            color: active ? context.colors.onPrimary : context.colors.onSurface,
          ),
        ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.selected, required this.onSelected});

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: WsSpacing.gutter,
        itemCount: mockFieldsOfWork.length,
        separatorBuilder: (_, __) => const SizedBox(width: WsSpacing.sm),
        itemBuilder: (context, i) {
          final field = mockFieldsOfWork[i];
          final isSelected = field == selected;
          return ChoiceChip(
            label: Text(field),
            selected: isSelected,
            onSelected: (_) => onSelected(field),
            labelStyle: WsTypography.chip(
              isSelected ? context.colors.onPrimary : context.colors.onSurface,
            ),
          );
        },
      ),
    );
  }
}
