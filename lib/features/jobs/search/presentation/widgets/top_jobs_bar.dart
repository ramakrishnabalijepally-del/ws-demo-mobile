import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/routes.dart';
import '../../../../../app/theme/theme.dart';
import '../../../../../shared/shared.dart';
import '../../../data/mock_jobs.dart';
import '../../../models/job.dart';

/// Top jobs — the most searched roles, ranked, five to a swipe.
///
/// Three swipes of five rather than one long list of fifteen: the bar is a
/// glance at what other people are looking for, and it should not push the
/// results the reader actually searched for off the first screen.
class TopJobsBar extends StatefulWidget {
  const TopJobsBar({required this.jobs, super.key});

  /// Already ranked, highest first.
  final List<Job> jobs;

  @override
  State<TopJobsBar> createState() => _TopJobsBarState();
}

class _TopJobsBarState extends State<TopJobsBar> {
  final ScrollController _scroll = ScrollController();
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    final width = _scroll.position.viewportDimension;
    if (width == 0) return;
    final page = (_scroll.offset / width).round();
    if (page != _page) setState(() => _page = page);
  }

  @override
  Widget build(BuildContext context) {
    final jobs = widget.jobs;
    final pages = (jobs.length / mockTopJobsPerPage).ceil();
    final pageWidth = MediaQuery.sizeOf(context).width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: WsSpacing.gutter,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text('Top jobs', style: context.text.titleLarge),
              ),
              Text(
                'Most searched this month',
                style:
                    context.text.bodySmall?.copyWith(color: context.ws.caption),
              ),
            ],
          ),
        ),
        const SizedBox(height: WsSpacing.md),
        // A page is exactly one viewport wide, so the page physics snap one
        // group of five at a time. A PageView would need a fixed height, which
        // clips the rows once text is scaled up.
        SingleChildScrollView(
          controller: _scroll,
          scrollDirection: Axis.horizontal,
          physics: const PageScrollPhysics(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var p = 0; p < pages; p++)
                SizedBox(
                  width: pageWidth,
                  child: Padding(
                    padding: WsSpacing.gutter,
                    child: _TopJobsPage(
                      jobs: jobs
                          .skip(p * mockTopJobsPerPage)
                          .take(mockTopJobsPerPage)
                          .toList(),
                      firstRank: p * mockTopJobsPerPage + 1,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (pages > 1) ...[
          const SizedBox(height: WsSpacing.md),
          WsDotRail(total: pages, active: _page.clamp(0, pages - 1)),
        ],
      ],
    );
  }
}

class _TopJobsPage extends StatelessWidget {
  const _TopJobsPage({required this.jobs, required this.firstRank});

  final List<Job> jobs;
  final int firstRank;

  @override
  Widget build(BuildContext context) {
    return WsCard(
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (i, job) in jobs.indexed) ...[
            if (i > 0) Divider(height: 1, color: context.colors.outlineVariant),
            WsListRow(
              leading: _Rank(firstRank + i),
              title: job.title,
              subtitle: '${job.company} · ${_searches(job.searchCount)}',
              trailing: job.isNew ? const WsBadge.fresh() : null,
              onTap: () =>
                  context.push(Routes.withId(Routes.jobDetails, job.id)),
            ),
          ],
        ],
      ),
    );
  }

  static String _searches(int count) => count >= 1000
      ? '${(count / 1000).toStringAsFixed(1)}k searches'
      : '$count searches';
}

class _Rank extends StatelessWidget {
  const _Rank(this.rank);

  final int rank;

  static const double _box = 32;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _box,
      height: _box,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.ws.moduleTint,
        borderRadius: WsRadii.tileSmallR,
      ),
      child: Text(
        '$rank',
        style: context.text.labelLarge?.copyWith(
          color: context.ws.moduleBase,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
