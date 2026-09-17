import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/theme/theme.dart';
import '../../../../../shared/shared.dart';
import '../../../controllers/jobs_controller.dart';
import '../../../data/mock_jobs.dart';
import '../../../models/job.dart';

/// E3–E4 — the filter sheet.
///
/// Laid out as a stack of titled sections, each holding the control that suits
/// its question: a field for where, a range slider for how much, and an
/// even-column grid for picking one of a list. Every section has a dropdown.
/// The short ones start open; Field of work, the long list, starts closed.
class JobFilterSheet extends ConsumerStatefulWidget {
  const JobFilterSheet({super.key});

  @override
  ConsumerState<JobFilterSheet> createState() => _JobFilterSheetState();
}

class _JobFilterSheetState extends ConsumerState<JobFilterSheet> {
  late JobFilters _draft = ref.read(jobFiltersProvider);
  late final TextEditingController _location =
      TextEditingController(text: _draft.location);

  @override
  void dispose() {
    _location.dispose();
    super.dispose();
  }

  void _update(JobFilters next) => setState(() => _draft = next);

  void _pickLocation(String pick) {
    // Tapping the pick that is already chosen clears it.
    final next = _draft.location == pick ? '' : pick;
    _location.text = next;
    _update(_draft.copyWith(location: next));
  }

  @override
  Widget build(BuildContext context) {
    final matches = applyJobFilters(
      ref.watch(allJobsProvider),
      ref.watch(jobQueryProvider),
      _draft,
    ).length;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
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
                WsSpacing.sm,
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
                      onPressed: () {
                        _location.clear();
                        _update(const JobFilters());
                      },
                    ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: WsSpacing.gutter,
                children: [
                  _Section(
                    title: 'Location',
                    value: _draft.location.trim().isEmpty
                        ? 'Anywhere'
                        : _draft.location.trim(),
                    child: _LocationPicker(
                      controller: _location,
                      selected: _draft.location,
                      onTyped: (v) => _update(_draft.copyWith(location: v)),
                      onPicked: _pickLocation,
                    ),
                  ),
                  _Section(
                    title: 'Salary range',
                    value: _salaryLabel(_draft),
                    child: _SalaryRange(
                      filters: _draft,
                      onChanged: (min, max) => _update(
                        _draft.copyWith(salaryMin: min, salaryMax: max),
                      ),
                    ),
                  ),
                  _Section(
                    title: 'Job type',
                    value: _draft.employment?.label ?? 'Any',
                    child: _OptionGrid(
                      columns: 3,
                      options: [
                        'Any',
                        ...Employment.values.map((e) => e.label),
                      ],
                      selected: _draft.employment?.label ?? 'Any',
                      onSelected: (v) => _update(
                        v == 'Any'
                            ? _draft.copyWith(clearEmployment: true)
                            : _draft.copyWith(
                                employment: Employment.values
                                    .firstWhere((e) => e.label == v),
                              ),
                      ),
                    ),
                  ),
                  _Section(
                    title: 'Field of work',
                    value: _draft.field,
                    initiallyExpanded: false,
                    child: _OptionGrid(
                      columns: 2,
                      options: mockFieldsOfWork,
                      selected: _draft.field,
                      onSelected: (v) => _update(_draft.copyWith(field: v)),
                    ),
                  ),
                  const SizedBox(height: WsSpacing.sm),
                  WsCheckboxRow(
                    label: 'Only employers who hire on work permits',
                    subtitle: 'Verified as having sponsored or hired '
                        'newcomers before',
                    value: _draft.permitFriendlyOnly,
                    onChanged: (v) =>
                        _update(_draft.copyWith(permitFriendlyOnly: v)),
                  ),
                  const SizedBox(height: WsSpacing.xl),
                ],
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: context.colors.outlineVariant),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  WsSpacing.xl,
                  WsSpacing.md,
                  WsSpacing.xl,
                  WsSpacing.xl,
                ),
                child: SafeArea(
                  top: false,
                  child: WsPrimaryButton(
                    // The count answers "is this too narrow?" before the
                    // sheet closes on an empty list.
                    label: matches == 1 ? 'Show 1 job' : 'Show $matches jobs',
                    forward: false,
                    onPressed: () {
                      ref.read(jobFiltersProvider.notifier).set(_draft);
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

String _k(int amount) => '\$${amount ~/ 1000}k';

String _salaryLabel(JobFilters f) {
  if (f.salaryIsAny) return 'Any';
  final top = f.salaryMax == mockSalaryCeiling ? '+' : '–${_k(f.salaryMax)}';
  return '${_k(f.salaryMin)}$top';
}

/// One titled section with a dropdown. The chosen value sits on the right of
/// the title, so a closed section still says what it is set to.
class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.value,
    required this.child,
    this.initiallyExpanded = true,
  });

  final String title;
  final String value;
  final Widget child;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          // Empty borders: the section divider below is the only rule.
          shape: const Border(),
          collapsedShape: const Border(),
          expansionAnimationStyle: WsMotion.reduced(context)
              ? AnimationStyle.noAnimation
              : const AnimationStyle(
                  duration: WsMotion.medium,
                  curve: WsMotion.entrance,
                ),
          tilePadding: EdgeInsets.zero,
          minTileHeight: WsTouch.minTarget + WsSpacing.sm,
          childrenPadding: const EdgeInsets.only(bottom: WsSpacing.lg),
          expandedAlignment: Alignment.centerLeft,
          expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
          iconColor: context.colors.primary,
          collapsedIconColor: context.ws.placeholder,
          title: Row(
            children: [
              Text(title, style: context.text.titleMedium),
              const SizedBox(width: WsSpacing.md),
              // The value takes the rest of the row and hugs the chevron.
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.labelLarge
                      ?.copyWith(color: context.colors.onSurface),
                ),
              ),
            ],
          ),
          children: [child],
        ),
        Divider(height: 1, color: context.colors.outlineVariant),
      ],
    );
  }
}

/// Options laid out in equal columns, so every row lines up with the next
/// however long each label is.
class _OptionGrid extends StatelessWidget {
  const _OptionGrid({
    required this.columns,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final int columns;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final rows = (options.length / columns).ceil();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var r = 0; r < rows; r++)
          Padding(
            padding: EdgeInsets.only(top: r == 0 ? 0 : WsSpacing.sm),
            // Equal height across a row: a label that wraps to two lines at
            // large text sizes does not leave its neighbours short.
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var c = 0; c < columns; c++) ...[
                    if (c > 0) const SizedBox(width: WsSpacing.sm),
                    Expanded(
                      child: r * columns + c < options.length
                          ? _OptionTile(
                              label: options[r * columns + c],
                              selected: options[r * columns + c] == selected,
                              onTap: () => onSelected(options[r * columns + c]),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// A pressable option. Rest is a quiet Grey 100 pill; selected takes the
/// selection treatment — 2 px red border on the tint — so the border is the
/// signal and the label never changes colour.
class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fill = selected
        ? context.ws.selectedSurface
        : context.colors.surfaceContainerHighest;

    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: fill,
        borderRadius: WsRadii.pillR,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: AnimatedContainer(
            duration: WsMotion.reduced(context) ? Duration.zero : WsMotion.fast,
            curve: WsMotion.standard,
            constraints: const BoxConstraints(minHeight: WsTouch.minTarget),
            padding: const EdgeInsets.symmetric(
              horizontal: WsSpacing.sm,
              vertical: WsSpacing.sm,
            ),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: WsRadii.pillR,
              // Same width at rest, in the fill colour, so selecting never
              // shifts the label.
              border: Border.all(
                color: selected ? context.colors.primary : fill,
                width: 2,
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: context.text.labelLarge?.copyWith(
                color: context.colors.onSurface,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LocationPicker extends StatelessWidget {
  const _LocationPicker({
    required this.controller,
    required this.selected,
    required this.onTyped,
    required this.onPicked,
  });

  final TextEditingController controller;
  final String selected;
  final ValueChanged<String> onTyped;
  final ValueChanged<String> onPicked;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: controller,
          onChanged: onTyped,
          style: context.text.bodyMedium,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            hintText: 'Type a city or province',
            prefixIcon:
                Icon(Icons.location_on_outlined, size: WsIconSize.field),
          ),
        ),
        const SizedBox(height: WsSpacing.md),
        _OptionGrid(
          columns: 2,
          options: mockLocations,
          selected: selected,
          onSelected: onPicked,
        ),
      ],
    );
  }
}

class _SalaryRange extends StatelessWidget {
  const _SalaryRange({required this.filters, required this.onChanged});

  final JobFilters filters;
  final void Function(int min, int max) onChanged;

  @override
  Widget build(BuildContext context) {
    final caption = context.text.bodySmall?.copyWith(color: context.ws.caption);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        RangeSlider(
          values: RangeValues(
            filters.salaryMin.toDouble(),
            filters.salaryMax.toDouble(),
          ),
          min: mockSalaryFloor.toDouble(),
          max: mockSalaryCeiling.toDouble(),
          divisions: (mockSalaryCeiling - mockSalaryFloor) ~/ mockSalaryStep,
          semanticFormatterCallback: (v) => _k(v.round()),
          onChanged: (v) => onChanged(v.start.round(), v.end.round()),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: WsSpacing.sm),
          child: Row(
            children: [
              Expanded(child: Text(_k(mockSalaryFloor), style: caption)),
              Text('${_k(mockSalaryCeiling)}+', style: caption),
            ],
          ),
        ),
      ],
    );
  }
}
