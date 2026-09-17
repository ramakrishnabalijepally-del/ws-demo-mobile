import '../../../shared/widgets/ws_hero_image.dart';

/// Which product story a slide tells — each one assembles its own cards.
enum OnboardingScene { immigration, jobs, profile }

/// One onboarding slide. The headline is split so a single span can carry the
/// red — the emphasis is part of the sentence, not a free highlight.
class OnboardingSlide {
  const OnboardingSlide({
    required this.before,
    required this.emphasis,
    required this.supporting,
    required this.hero,
    required this.scene,
    this.after = '',
  });

  final String before;
  final String emphasis;
  final String after;

  /// One sentence under the headline saying what the product does here.
  final String supporting;

  /// The photograph at the centre of the stage.
  final WsHero hero;

  final OnboardingScene scene;
}

/// A2–A4. Three promises: immigration, the job portal, the user profile.
const List<OnboardingSlide> mockOnboardingSlides = [
  OnboardingSlide(
    before: 'Plan Your ',
    emphasis: 'Immigration',
    after: ' Journey',
    supporting:
        'See your CRS score and the programs that fit, based on what you tell WorkSettle.',
    hero: WsHero.immigration,
    scene: OnboardingScene.immigration,
  ),
  OnboardingSlide(
    before: 'Find Your ',
    emphasis: 'Dream',
    after: ' Job',
    supporting:
        'Verified, immigrant-friendly employers matched to your skills.',
    hero: WsHero.jobPortal,
    scene: OnboardingScene.jobs,
  ),
  OnboardingSlide(
    before: 'Match Jobs Based On Your ',
    emphasis: 'Profile',
    supporting: 'The more you add, the sharper your matches and estimates.',
    hero: WsHero.userProfile,
    scene: OnboardingScene.profile,
  ),
];

// Illustrative figures on the slide cards. Not the candidate's real data.

const int mockOnboardingCrsScore = 468;
const String mockOnboardingCrsVerdict = 'Good Range';
const String mockOnboardingRoutes = 'Express Entry · PNP';

const String mockOnboardingJobTitle = 'Software Developer';
const String mockOnboardingJobEmployer = 'Northwind Labs · Toronto, ON';
const String mockOnboardingJobVerdict = 'Good Match';

const int mockOnboardingProfileStrength = 72;

/// Checklist rows on the profile slide, and whether each is done.
const List<(String, bool)> mockOnboardingChecklist = [
  ('Work experience', true),
  ('Education', true),
  ('Language test', false),
];
