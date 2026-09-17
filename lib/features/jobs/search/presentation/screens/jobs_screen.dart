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
import '../widgets/top_jobs_bar.dart';

/// E1–E2, E5–E6 — the Jobs tab: search, the jobs bar, top jobs, results and
/// the empty state.
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
  /// How many result rows play the entrance stagger.
  static const int _staggeredRows = 6;

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

  void _clearAll() {
    _search.clear();
    ref.read(jobQueryProvider.notifier).state = '';
    ref.read(jobFiltersProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final jobs = ref.watch(filteredJobsProvider);
    final filters = ref.watch(jobFiltersProvider);
    final query = ref.watch(jobQueryProvider);
    final setFilters = ref.read(jobFiltersProvider.notifier).set;

    // Top jobs is a starting point, so it steps aside once the reader has
    // started narrowing the list themselves.
    final browsing = query.isEmpty && filters.isDefault;

    return Scaffold(
      appBar: AppBar(
        leading: const WsProfileButton(),
        leadingWidth: WsTouch.minTarget + WsSpacing.md,
        title: const Text('Jobs'),
        actions: [
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
          _JobsBar(
            selectedField: filters.field,
            newOnly: filters.newOnly,
            newCount: ref.watch(newJobsCountProvider),
            onField: (field) => setFilters(filters.copyWith(field: field)),
            onNew: () =>
                setFilters(filters.copyWith(newOnly: !filters.newOnly)),
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                if (browsing) ...[
                  const SliverToBoxAdapter(
                    child: SizedBox(height: WsSpacing.lg),
                  ),
                  SliverToBoxAdapter(
                    child: TopJobsBar(jobs: ref.watch(topSearchedJobsProvider)),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: WsSpacing.lg),
                  ),
                ],
                SliverToBoxAdapter(
                  child: Padding(
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
                            _heading(query: query, newOnly: filters.newOnly),
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
                ),
                if (jobs.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: WsEmptyState(
                      icon: Icons.search_off_rounded,
                      headline: 'No jobs match that yet',
                      body: 'Try a broader search, or clear a filter or two — '
                          'there are ${mockJobs.length} roles on the board.',
                      actionLabel: 'Clear filters',
                      onAction: _clearAll,
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      WsSpacing.xl,
                      WsSpacing.sm,
                      WsSpacing.xl,
                      WsSpacing.xxxl,
                    ),
                    sliver: SliverList.separated(
                      itemCount: jobs.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: WsSpacing.md),
                      itemBuilder: (context, i) {
                        final card = JobCard(
                          job: jobs[i],
                          onTap: () => context.push(
                            Routes.withId(Routes.jobDetails, jobs[i].id),
                          ),
                        );
                        // Only the first screenful rises in, keyed by job so a
                        // new search or filter visibly refreshes the list.
                        // Rows scrolled to later are simply there.
                        return i < _staggeredRows
                            ? WsAppear(
                                key: ValueKey(jobs[i].id),
                                delay: i * 0.1,
                                duration: WsMotion.focal,
                                child: card,
                              )
                            : card;
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _heading({required String query, required bool newOnly}) {
    if (query.isNotEmpty) return 'Results';
    if (newOnly) return 'New in the last 48 hours';
    return 'Recommended for you';
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

/// The jobs bar: the New button first, then the fields of work.
class _JobsBar extends StatelessWidget {
  const _JobsBar({
    required this.selectedField,
    required this.newOnly,
    required this.newCount,
    required this.onField,
    required this.onNew,
  });

  final String selectedField;
  final bool newOnly;
  final int newCount;
  final ValueChanged<String> onField;
  final VoidCallback onNew;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: WsSpacing.gutter,
        itemCount: mockFieldsOfWork.length + 1,
        // New toggles on top of a field rather than replacing it, so a hairline
        // sets it apart from the fields, which pick one at a time.
        separatorBuilder: (_, i) => i == 0
            ? Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: WsSpacing.md,
                  vertical: WsSpacing.md,
                ),
                child: VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: context.colors.outlineVariant,
                ),
              )
            : const SizedBox(width: WsSpacing.sm),
        itemBuilder: (context, i) {
          if (i == 0) {
            return _NewButton(count: newCount, selected: newOnly, onTap: onNew);
          }
          final field = mockFieldsOfWork[i - 1];
          final isSelected = field == selectedField;
          return ChoiceChip(
            label: Text(field),
            selected: isSelected,
            onSelected: (_) => onField(field),
            labelStyle: WsTypography.chip(
              isSelected ? context.colors.onPrimary : context.colors.onSurface,
            ),
          );
        },
      ),
    );
  }
}

/// Postings from the last 48 hours. Unlike the field chips it toggles, so it
/// combines with whichever field is picked.
class _NewButton extends StatelessWidget {
  const _NewButton({
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final label = selected ? colors.onPrimary : colors.onSurface;

    return Semantics(
      button: true,
      selected: selected,
      label: '$count new jobs in the last 48 hours',
      excludeSemantics: true,
      child: Center(
        child: Material(
          color: selected ? colors.primary : colors.surface,
          shape: StadiumBorder(
            side: BorderSide(
              color: selected ? colors.primary : colors.outlineVariant,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                WsSpacing.md,
                WsSpacing.xs + 2,
                WsSpacing.xs + 2,
                WsSpacing.xs + 2,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.bolt_rounded,
                    size: WsIconSize.chevron,
                    color: selected ? colors.onPrimary : colors.primary,
                  ),
                  const SizedBox(width: WsSpacing.xs),
                  Text('New', style: WsTypography.chip(label)),
                  const SizedBox(width: WsSpacing.sm),
                  // The count sits in its own capsule so it reads as a number
                  // of jobs, not as part of the word.
                  Container(
                    constraints: const BoxConstraints(minWidth: 22),
                    padding: const EdgeInsets.symmetric(
                      horizontal: WsSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? colors.onPrimary
                          : context.ws.verdictTintedSurface,
                      borderRadius: WsRadii.pillR,
                    ),
                    child: Text(
                      '$count',
                      textAlign: TextAlign.center,
                      style: WsTypography.chip(
                        selected ? colors.primary : colors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
