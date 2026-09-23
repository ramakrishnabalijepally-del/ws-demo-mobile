import 'package:flutter/material.dart';

import '../../app/theme/theme.dart';
import '../data/countries.dart';

/// A province, territory or country mark in its correct frame.
///
/// Design system section 7: province and country marks are **the only
/// full-colour imagery allowed in an icon slot**. They sit in a 40 px rounded
/// square with a Grey 200 hairline, **never recoloured and never cropped to a
/// circle** — which is why the flag is fitted whole inside the frame rather
/// than filled to its edges, whatever its proportions.
///
/// Provinces and countries are keyed in separate folders on purpose: several
/// two-letter codes mean one thing in each set (NL is both Newfoundland and
/// Labrador and the Netherlands, SK both Saskatchewan and Slovakia).
///
// TODO(assets): these are the official flags from Wikimedia Commons and
// flagcdn.com, standing in until the client supplies its own marks. The frame
// does not change when they do.
class WsProvinceMark extends StatelessWidget {
  const WsProvinceMark({
    required this.code,
    required this.label,
    this.size = 40,
    super.key,
  }) : _folder = 'provinces';

  /// The Canadian flag, for federal programs and anything nationwide.
  const WsProvinceMark.canada({this.size = 40, super.key})
      : code = 'CA',
        label = 'Canada',
        _folder = 'provinces';

  /// A country of origin, keyed by its ISO 3166-1 alpha-2 code.
  const WsProvinceMark.country({
    required this.code,
    required this.label,
    this.size = 40,
    super.key,
  }) : _folder = 'countries';

  /// Two letters: a provincial or territorial abbreviation, `CA`, or an ISO
  /// country code.
  final String code;

  /// Read out by a screen reader — the flag itself carries no text.
  final String label;

  final double size;

  final String _folder;

  /// Full names to the codes the assets are keyed by, so a stored province
  /// name can find its mark.
  static const Map<String, String> codes = {
    'Alberta': 'AB',
    'British Columbia': 'BC',
    'Manitoba': 'MB',
    'New Brunswick': 'NB',
    'Newfoundland and Labrador': 'NL',
    'Northwest Territories': 'NT',
    'Nova Scotia': 'NS',
    'Nunavut': 'NU',
    'Ontario': 'ON',
    'Prince Edward Island': 'PE',
    'Quebec': 'QC',
    'Saskatchewan': 'SK',
    'Yukon': 'YT',
  };

  /// Country of origin names to ISO codes. Lower-case keys, because the name
  /// is typed by hand in registration and in the profile form. Common
  /// alternative names point at the same flag.
  static const Map<String, String> countryCodes = {
    'afghanistan': 'af',
    'algeria': 'dz',
    'argentina': 'ar',
    'australia': 'au',
    'bangladesh': 'bd',
    'brazil': 'br',
    'cameroon': 'cm',
    'canada': 'ca',
    'chile': 'cl',
    'china': 'cn',
    'colombia': 'co',
    'egypt': 'eg',
    'england': 'gb',
    'eritrea': 'er',
    'ethiopia': 'et',
    'france': 'fr',
    'germany': 'de',
    'ghana': 'gh',
    'great britain': 'gb',
    'india': 'in',
    'iran': 'ir',
    'iraq': 'iq',
    'ireland': 'ie',
    'italy': 'it',
    'jamaica': 'jm',
    'japan': 'jp',
    'kenya': 'ke',
    'korea': 'kr',
    'lebanon': 'lb',
    'mexico': 'mx',
    'morocco': 'ma',
    'nepal': 'np',
    'netherlands': 'nl',
    'new zealand': 'nz',
    'nigeria': 'ng',
    'pakistan': 'pk',
    'peru': 'pe',
    'philippines': 'ph',
    'poland': 'pl',
    'portugal': 'pt',
    'romania': 'ro',
    'russia': 'ru',
    'saudi arabia': 'sa',
    'south africa': 'za',
    'south korea': 'kr',
    'spain': 'es',
    'sri lanka': 'lk',
    'syria': 'sy',
    'tunisia': 'tn',
    'turkey': 'tr',
    'türkiye': 'tr',
    'uae': 'ae',
    'uk': 'gb',
    'ukraine': 'ua',
    'united arab emirates': 'ae',
    'united kingdom': 'gb',
    'united states': 'us',
    'united states of america': 'us',
    'usa': 'us',
    'venezuela': 've',
    'vietnam': 'vn',
    'zimbabwe': 'zw',
  };

  /// Null when the name is not a province or territory — nothing is drawn
  /// rather than a wrong flag.
  static String? codeFor(String name) => codes[name.trim()];

  /// Null when the country is not one we hold a flag for. The caller draws
  /// nothing rather than the wrong flag.
  static String? countryCodeFor(String name) {
    final key = name.trim().toLowerCase();
    final alias = countryCodes[key];
    if (alias != null) return alias;
    for (final (country, code) in countries) {
      if (country.toLowerCase() == key) return code;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      image: true,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: context.ws.verdictTintedSurface,
          borderRadius: WsRadii.tileSmallR,
          border: Border.all(color: context.colors.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(WsSpacing.xs),
          child: Image.asset(
            'assets/images/$_folder/${code.toLowerCase()}.png',
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
            excludeFromSemantics: true,
            // A missing mark falls back to the abbreviation in the same frame,
            // so the layout never moves.
            errorBuilder: (context, _, __) => Center(
              child: Text(
                code.toUpperCase(),
                style: context.text.labelLarge,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
