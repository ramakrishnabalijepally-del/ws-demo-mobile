import 'package:flutter/material.dart';

import '../../../../../app/theme/theme.dart';

/// A province mark in its correct frame.
///
/// Design system section 7: province and country marks are **the only
/// full-colour imagery allowed in an icon slot**. They sit in a 40 px rounded
/// square with a Grey 200 hairline, never recoloured and never cropped to a
/// circle.
///
/// The client's flag assets have not been supplied. This renders the frame at
/// exactly the right size with the abbreviation inside, so the layout is
/// correct now and only the fill changes when the artwork lands.
class ProvinceMark extends StatelessWidget {
  const ProvinceMark({required this.abbreviation, super.key});

  final String abbreviation;

  @override
  Widget build(BuildContext context) {
    // TODO(assets): swap the child for the supplied flag image. Keep the frame:
    // 40 px, 10 px radius, hairline border, never a circle.
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: context.ws.verdictTintedSurface,
        borderRadius: WsRadii.tileSmallR,
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Text(
        abbreviation,
        style: context.text.labelLarge,
        semanticsLabel: abbreviation,
      ),
    );
  }
}
