import 'package:flutter/material.dart';

import '../../app/theme/theme.dart';
import 'ws_forms.dart';

/// One row in a [showWsSearchSheet] list.
class WsSearchOption {
  const WsSearchOption({
    required this.value,
    required this.mark,
    this.subtitle,
  });

  /// Shown as the row's title, searched, and returned when picked.
  final String value;

  /// Searched too, so "ontario" finds every Ontario city.
  final String? subtitle;

  /// A flag or other mark in the 40 px frame.
  final Widget mark;
}

/// A bottom sheet that lists [options] under a search box and resolves to the
/// picked value, or null if dismissed.
///
/// With [allowTyped], a search with no match offers the typed text itself, for
/// answers no list can hold (a small town, say).
Future<String?> showWsSearchSheet(
  BuildContext context, {
  required String title,
  required List<WsSearchOption> options,
  String selected = '',
  String searchHint = 'Search',
  bool allowTyped = false,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    sheetAnimationStyle: WsMotion.reduced(context)
        ? AnimationStyle.noAnimation
        : const AnimationStyle(
            duration: WsMotion.slow,
            curve: WsMotion.emphasized,
            reverseDuration: WsMotion.medium,
          ),
    builder: (_) => _SearchSheet(
      title: title,
      options: options,
      selected: selected,
      searchHint: searchHint,
      allowTyped: allowTyped,
    ),
  );
}

class _SearchSheet extends StatefulWidget {
  const _SearchSheet({
    required this.title,
    required this.options,
    required this.selected,
    required this.searchHint,
    required this.allowTyped,
  });

  final String title;
  final List<WsSearchOption> options;
  final String selected;
  final String searchHint;
  final bool allowTyped;

  @override
  State<_SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<_SearchSheet> {
  static const double _rowHeight = 64;

  final TextEditingController _query = TextEditingController();

  /// Opens with the current answer in view rather than at the top.
  late final ScrollController _scroll = ScrollController(
    initialScrollOffset: _startOffset(),
  );

  double _startOffset() {
    final index = widget.options.indexWhere((o) => o.value == widget.selected);
    return index <= 2 ? 0 : (index - 2) * _rowHeight;
  }

  @override
  void dispose() {
    _query.dispose();
    _scroll.dispose();
    super.dispose();
  }

  List<WsSearchOption> _matches(String q) {
    if (q.isEmpty) return widget.options;
    return [
      for (final o in widget.options)
        if (o.value.toLowerCase().contains(q) ||
            (o.subtitle?.toLowerCase().contains(q) ?? false))
          o,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final typed = _query.text.trim();
    final matches = _matches(typed.toLowerCase());
    final height = MediaQuery.sizeOf(context).height * 0.85;

    return SizedBox(
      height: height,
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                WsSpacing.xl,
                0,
                WsSpacing.xl,
                WsSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(widget.title, style: context.text.titleLarge),
                  const SizedBox(height: WsSpacing.lg),
                  WsField(
                    label: 'Search',
                    controller: _query,
                    hint: widget.searchHint,
                    leadingIcon: Icons.search_rounded,
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: WsMotion.duration(context, WsMotion.fast),
                child: matches.isEmpty
                    ? _NoMatch(
                        query: typed,
                        onUseTyped: widget.allowTyped
                            ? () => Navigator.of(context).pop(typed)
                            : null,
                      )
                    : ListView.builder(
                        key: const ValueKey('options'),
                        controller: _scroll,
                        itemExtent: _rowHeight,
                        itemCount: matches.length,
                        itemBuilder: (context, i) {
                          final option = matches[i];
                          return _OptionRow(
                            option: option,
                            selected: option.value == widget.selected,
                            onTap: () =>
                                Navigator.of(context).pop(option.value),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final WsSearchOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final subtitle = option.subtitle;
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: WsSpacing.xl),
          child: Row(
            children: [
              option.mark,
              const SizedBox(width: WsSpacing.md),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: selected
                          ? context.text.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w700)
                          : context.text.bodyMedium,
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodySmall
                            ?.copyWith(color: context.ws.caption),
                      ),
                  ],
                ),
              ),
              if (selected)
                Icon(
                  Icons.check_rounded,
                  size: WsIconSize.tick,
                  color: context.ws.redOnSurface,
                  semanticLabel: 'Selected',
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoMatch extends StatelessWidget {
  const _NoMatch({required this.query, this.onUseTyped});

  final String query;
  final VoidCallback? onUseTyped;

  @override
  Widget build(BuildContext context) {
    final useTyped = onUseTyped;
    return Padding(
      key: const ValueKey('none'),
      padding: const EdgeInsets.all(WsSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            useTyped == null
                ? 'Nothing matches "$query". Check the spelling.'
                : 'Nothing in the list matches "$query".',
            style: context.text.bodyMedium?.copyWith(color: context.ws.caption),
          ),
          if (useTyped != null) ...[
            const SizedBox(height: WsSpacing.md),
            TextButton(
              onPressed: useTyped,
              child: Text('Use "$query"'),
            ),
          ],
        ],
      ),
    );
  }
}
