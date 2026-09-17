import 'package:flutter/material.dart';

import '../../app/theme/theme.dart';

/// The AI agent's mark.
///
/// **The client's logo has not been supplied.** This renders the placeholder
/// glyph at exactly the right size in the right frame, so the layout is
/// correct now and swapping the artwork in later is a one-file change.
///
// TODO(assets): replace the [Icon] with the supplied agent logo. Keep the
// frame — 999 radius, brand red fill, white glyph — and keep [navIcon] and
// [navIconActive] in step with it so the tab and the screen agree.
class WsAgentMark extends StatelessWidget {
  const WsAgentMark({this.size = 60, super.key});

  /// The tab bar's glyph while the tab is not selected.
  static const IconData navIcon = Icons.auto_awesome_outlined;

  /// The tab bar's glyph while the tab is selected.
  static const IconData navIconActive = Icons.auto_awesome_rounded;

  /// The header size is 60 (design system section 10); a row mark is 44.
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'WorkSettle AI agent',
      image: true,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          // The agent is the product's one AI surface, so it carries the brand
          // red the way Job Matching does.
          color: context.colors.primary,
          borderRadius: WsRadii.pillR,
          boxShadow: WsShadows.primaryButton,
        ),
        child: Icon(
          navIconActive,
          size: size * 0.47,
          color: context.colors.onPrimary,
        ),
      ),
    );
  }
}
