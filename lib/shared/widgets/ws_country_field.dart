import 'package:flutter/material.dart';

import '../data/countries.dart';
import 'ws_forms.dart';
import 'ws_province_mark.dart';
import 'ws_search_sheet.dart';

/// A country field that opens a searchable list of flags instead of the
/// keyboard. The controller holds the country's name, as typed values did.
class WsCountryField extends StatelessWidget {
  const WsCountryField({
    required this.label,
    required this.controller,
    this.helper,
    this.error,
    this.required = false,
    this.onChanged,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final String? helper;
  final String? error;
  final bool required;
  final VoidCallback? onChanged;

  /// Smaller than the 40 px list mark so it sits inside the field's height.
  static const double fieldMark = 28;

  static final List<WsSearchOption> _options = [
    for (final (name, code) in countries)
      WsSearchOption(
        value: name,
        mark: WsProvinceMark.country(code: code, label: name),
      ),
  ];

  Future<void> _pick(BuildContext context) async {
    final picked = await showWsSearchSheet(
      context,
      title: label,
      options: _options,
      selected: controller.text.trim(),
      searchHint: 'Country name',
    );
    if (picked == null) return;
    controller.text = picked;
    onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final name = value.text.trim();
        final code = WsProvinceMark.countryCodeFor(name);
        return WsField(
          label: label,
          required: required,
          controller: controller,
          hint: 'Choose a country',
          helper: helper,
          error: error,
          readOnly: true,
          leading: code == null
              ? null
              : WsProvinceMark.country(
                  code: code,
                  label: name,
                  size: fieldMark,
                ),
          leadingIcon: Icons.public_outlined,
          trailingIcon: Icons.expand_more_rounded,
          onTrailingTap: () => _pick(context),
          onTap: () => _pick(context),
        );
      },
    );
  }
}
