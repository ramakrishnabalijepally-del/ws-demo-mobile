import '../../../shared/widgets/ws_hero_image.dart';

/// One onboarding slide. The headline is split so a single span can carry the
/// red — the emphasis is part of the sentence, not a free highlight.
class OnboardingSlide {
  const OnboardingSlide({
    required this.before,
    required this.emphasis,
    required this.hero,
    this.after = '',
  });

  final String before;
  final String emphasis;
  final String after;

  /// The client photograph behind this slide.
  final WsHero hero;
}

/// A2–A4. Three promises, in the order the deck sets them.
const List<OnboardingSlide> mockOnboardingSlides = [
  OnboardingSlide(
    before: 'Find Your ',
    emphasis: 'Dream',
    after: ' Job',
    hero: WsHero.jobs,
  ),
  OnboardingSlide(
    before: 'Match Jobs Based On Your ',
    emphasis: 'Profile',
    hero: WsHero.profile,
  ),
  OnboardingSlide(
    before: 'We Are Here To Help You ',
    emphasis: 'Achieve Your',
    after: ' Dreams',
    hero: WsHero.success,
  ),
];
