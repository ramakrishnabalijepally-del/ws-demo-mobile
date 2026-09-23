import 'package:flutter/material.dart';

import '../../app/theme/theme.dart';
import '../data/canadian_places.dart';
import 'ws_country_field.dart';
import 'ws_forms.dart';
import 'ws_province_mark.dart';
import 'ws_search_sheet.dart';

/// City and province, kept consistent with each other.
///
/// A listed city fills its province in; a chosen province narrows the city
/// list to its own cities; and moving to another province clears a listed
/// city that is not in it — a city in the wrong province is false
/// information. A town typed by hand cannot be checked and is left alone.
class WsLocationFields extends StatelessWidget {
  const WsLocationFields({
    required this.city,
    required this.province,
    required this.onProvinceChanged,
    this.required = false,
    super.key,
  });

  final TextEditingController city;
  final String? province;
  final ValueChanged<String?> onProvinceChanged;
  final bool required;

  void _provinceChanged(String? next) {
    final listed = provinceOfCity(city.text.trim());
    if (listed != null && listed != next) city.clear();
    onProvinceChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _CitySelect(
          controller: city,
          province: province,
          required: required,
          onPicked: (listedProvince) {
            if (listedProvince != null) onProvinceChanged(listedProvince);
          },
        ),
        const SizedBox(height: WsSpacing.xl),
        _ProvinceSelect(
          // Rebuilt when a city fills the province in, since the dropdown only
          // reads its value once.
          key: ValueKey(province),
          value: province,
          onChanged: _provinceChanged,
        ),
      ],
    );
  }
}

class _CitySelect extends StatelessWidget {
  const _CitySelect({
    required this.controller,
    required this.province,
    required this.required,
    required this.onPicked,
  });

  final TextEditingController controller;
  final String? province;
  final bool required;

  /// The picked city's province, or null for a town typed in by hand.
  final ValueChanged<String?> onPicked;

  List<WsSearchOption> _options() => [
        for (final (name, cityProvince) in canadianCities)
          if (province == null || cityProvince == province)
            WsSearchOption(
              value: name,
              subtitle: cityProvince,
              mark: WsProvinceMark(
                code: WsProvinceMark.codeFor(cityProvince) ?? 'CA',
                label: cityProvince,
              ),
            ),
      ];

  Future<void> _pick(BuildContext context) async {
    final picked = await showWsSearchSheet(
      context,
      title: province == null ? 'City' : 'City in $province',
      options: _options(),
      selected: controller.text.trim(),
      searchHint: province == null ? 'City or province' : 'City name',
      allowTyped: true,
    );
    if (picked == null) return;
    controller.text = picked;
    onPicked(provinceOfCity(picked));
  }

  @override
  Widget build(BuildContext context) {
    final province = this.province;
    final code = province == null ? null : WsProvinceMark.codeFor(province);
    return WsField(
      label: 'City',
      required: required,
      controller: controller,
      hint: 'Choose a city',
      readOnly: true,
      leading: code == null || province == null
          ? null
          : WsProvinceMark(
              code: code,
              label: province,
              size: WsCountryField.fieldMark,
            ),
      leadingIcon: Icons.location_city_outlined,
      trailingIcon: Icons.expand_more_rounded,
      onTrailingTap: () => _pick(context),
      onTap: () => _pick(context),
    );
  }
}

/// A province select built from the shared field shell, so the label sits above
/// and the radius still says "you type into this".
class _ProvinceSelect extends StatelessWidget {
  const _ProvinceSelect({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Province or Territory',
          style:
              context.text.labelLarge?.copyWith(color: context.ws.fieldLabel),
        ),
        const SizedBox(height: WsSpacing.sm),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          icon: Icon(
            Icons.expand_more_rounded,
            color: context.ws.placeholder,
          ),
          style: context.text.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Choose a province',
            prefixIcon: const Icon(
              Icons.map_outlined,
              size: WsIconSize.field,
            ),
            hintStyle: context.text.bodyMedium
                ?.copyWith(color: context.ws.placeholder),
          ),
          items: [
            for (final p in canadianProvinces)
              DropdownMenuItem(
                value: p,
                child: Row(
                  children: [
                    WsProvinceMark(
                      code: WsProvinceMark.codeFor(p) ?? 'CA',
                      label: p,
                      size: WsCountryField.fieldMark,
                    ),
                    const SizedBox(width: WsSpacing.md),
                    Expanded(
                      child: Text(p, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}
