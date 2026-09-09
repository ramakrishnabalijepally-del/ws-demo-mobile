import 'package:flutter/material.dart';

import '../../app/theme/theme.dart';

/// The client's three supplied photographs, in one place.
///
/// They are portrait crops, so every use site must say how to fit them into a
/// landscape slot. [WsHeroImage] always uses `BoxFit.cover` with an alignment
/// biased toward the upper third — these are photographs of people, and a
/// centred crop of a portrait cuts their head off in a wide banner.
enum WsHero {
  /// A man with a tablet, city skyline behind him. Looking outward — job search.
  jobs('assets/images/hero_jobs.jpg'),

  /// A woman working at a laptop. Heads-down — profile and paperwork.
  profile('assets/images/hero_profile.jpg'),

  /// A man holding a signed contract, thumbs up. The outcome.
  success('assets/images/hero_success.jpg');

  const WsHero(this.path);

  final String path;
}

class WsHeroImage extends StatelessWidget {
  const WsHeroImage({
    required this.hero,
    this.height,
    this.alignment = const Alignment(0, -0.35),
    this.semanticLabel,
    super.key,
  });

  final WsHero hero;

  /// Null fills the parent — used by the onboarding slides, which give the
  /// photo whatever vertical space is left.
  final double? height;

  /// Upper-third by default so faces survive a landscape crop.
  final Alignment alignment;

  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      hero.path,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      alignment: alignment,
      semanticLabel: semanticLabel,
      // A missing or corrupt asset should degrade to the placeholder panel it
      // replaced, not to a grey exception box in the middle of the screen.
      errorBuilder: (context, _, __) => ColoredBox(
        color: context.ws.moduleTint,
        child: Center(
          child: Icon(
            Icons.image_outlined,
            size: 40,
            color: context.ws.placeholder,
          ),
        ),
      ),
    );
  }
}
