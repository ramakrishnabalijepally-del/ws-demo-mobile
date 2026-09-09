import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/theme/theme.dart';
import '../../../../../shared/shared.dart';
import '../../../controllers/jobs_controller.dart';
import '../../../data/mock_jobs.dart';
import '../../../models/job.dart';

/// E3–E4 — the filter sheet.
///
/// The deck splits "field of work" onto its own full screen because its chip
/// list is long. Here the sheet scrolls instead: a second screen to change one
/// filter is a step the reader did not ask for.
class JobFilterSheet extends ConsumerStatefulWidget {
  const JobFilterSheet({super.key});

  @override
  ConsumerState<JobFilterSheet> createState() => _JobFilterSheetState();
}

class _JobFilterSheetState extends ConsumerState<JobFilterSheet> {
  late JobFilters _draft = ref.read(jobFiltersProvider);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
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
                    child: Text('Filter jobs', style: context.text.titleLarge),
                  ),
                  if (!_draft.isDefault)
                    WsLink(
                      label: 'Clear all',
                      underline: false,
                      onPressed: () =>
                          setState(() => _draft = const JobFilters()),
                    ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: WsSpacing.gutter,
                children: [
                  _Group(
                    title: 'Field of work',
                    options: mockFieldsOfWork,
                    selected: _draft.field,
                    onSelected: (v) =>
                        setState(() => _draft = _draft.copyWith(field: v)),
                  ),
                  _Group(
                    title: 'Salary',
                    options: mockSalaryBands,
                    selected: _draft.salaryBand,
                    onSelected: (v) =>
                        setState(() => _draft = _draft.copyWith(salaryBand: v)),
                  ),
                  _Group(
                    title: 'Type',
                    options: ['Any', ...Employment.values.map((e) => e.label)],
                    selected: _draft.employment?.label ?? 'Any',
                    onSelected: (v) => setState(() {
                      _draft = v == 'Any'
                          ? _draft.copyWith(clearEmployment: true)
                          : _draft.copyWith(
                              employment: Employment.values
                                  .firstWhere((e) => e.label == v),
                            );
                    }),
                  ),
                  _Group(
                    title: 'Location',
                    options: mockLocations,
                    selected: _draft.location,
                    onSelected: (v) =>
                        setState(() => _draft = _draft.copyWith(location: v)),
                  ),
                  const SizedBox(height: WsSpacing.sm),
                  WsCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: WsSpacing.lg,
                      vertical: WsSpacing.xs,
                    ),
                    child: WsCheckboxRow(
                      label: 'Only employers who hire on work permits',
                      subtitle: 'Verified as having sponsored or hired '
                          'newcomers before',
                      value: _draft.permitFriendlyOnly,
                      onChanged: (v) => setState(
                        () => _draft = _draft.copyWith(permitFriendlyOnly: v),
                      ),
                    ),
                  ),
                  const SizedBox(height: WsSpacing.xxl),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                WsSpacing.xl,
                WsSpacing.md,
                WsSpacing.xl,
                WsSpacing.xl,
              ),
              child: SafeArea(
                top: false,
                child: WsPrimaryButton(
                  label: 'Show results',
                  forward: false,
                  onPressed: () {
                    ref.read(jobFiltersProvider.notifier).set(_draft);
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final String title;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: WsSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: context.text.titleMedium),
          const SizedBox(height: WsSpacing.md),
          Wrap(
            spacing: WsSpacing.sm,
            runSpacing: WsSpacing.sm,
            children: [
              for (final option in options)
                ChoiceChip(
                  label: Text(option),
                  selected: option == selected,
                  onSelected: (_) => onSelected(option),
                  labelStyle: WsTypography.chip(
                    option == selected
                        ? context.colors.onPrimary
                        : context.colors.onSurface,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
