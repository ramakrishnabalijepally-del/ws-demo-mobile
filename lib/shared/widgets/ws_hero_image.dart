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
  success('assets/images/hero_success.jpg'),

  // TODO(assets): the four below are Unsplash demo stand-ins, not client
  // photography — replace before release.

  /// A traveller with a suitcase at an airport window, a plane taking off.
  /// Immigration — it echoes the onboarding flight-path animation.
  immigration('assets/images/hero_immigration.jpg'),

  /// A developer coding at two screens in an open office. The job portal —
  /// it pairs with the onboarding "Software Developer" match card.
  jobPortal('assets/images/hero_job_portal.jpg'),

  /// Someone at a desk with laptop and notebook, working on their phone. The
  /// candidate's own profile — it pairs with the onboarding checklist card.
  userProfile('assets/images/hero_user_profile.jpg'),

  /// A teacher and students with raised hands. Language support — a wide shot,
  /// so it serves the home banner directly.
  language('assets/images/hero_language.jpg'),

  // Wide crops for the home banners (about 2.8:1, glyph over the left third).
  // Deliberately different photographs from onboarding, and chosen so the
  // section reads at a glance with the subject centre-right.

  /// The Canadian flag before the Peace Tower on Parliament Hill. Immigration.
  tileImmigration('assets/images/tile_immigration.jpg'),

  /// A handshake across an interview desk, clipboard and laptop. Jobs.
  tileJobs('assets/images/tile_jobs.jpg');

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
