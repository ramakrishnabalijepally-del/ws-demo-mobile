import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/theme.dart';
import '../../../../shared/shared.dart';
import '../../data/mock_onboarding.dart';

/// A2–A4 — the three onboarding slides.
///
/// One promise per screen, a dot rail beneath, and a headline where a single
/// span carries the red. **Never colour a whole line** (design system section
/// 4) — the emphasis picks out the word the slide is actually about.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isLast => _page == mockOnboardingSlides.length - 1;

  void _next() {
    if (_isLast) {
      context.go(Routes.signIn);
      return;
    }
    _controller.nextPage(
      duration: WsMotion.duration(context, WsMotion.medium),
      curve: WsMotion.standard,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: WsSpacing.md),
                child: WsLink(
                  label: 'Skip',
                  underline: false,
                  onPressed: () => context.go(Routes.signIn),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: mockOnboardingSlides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) => _Slide(
                  slide: mockOnboardingSlides[i],
                ),
              ),
            ),
            const SizedBox(height: WsSpacing.xl),
            WsDotRail(total: mockOnboardingSlides.length, active: _page),
            const SizedBox(height: WsSpacing.xxxl),
            Padding(
              padding: WsSpacing.gutter,
              child: WsPrimaryButton(
                label: _isLast ? 'Get Started' : 'Next',
                onPressed: _next,
              ),
            ),
            const SizedBox(height: WsSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  const _Slide({required this.slide});

  final OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: WsSpacing.gutter,
      child: Column(
        children: [
          const SizedBox(height: WsSpacing.xxl),
          WsEmphasisHeadline(
            before: slide.before,
            emphasis: slide.emphasis,
            after: slide.after,
          ),
          const SizedBox(height: WsSpacing.xxl),
          Expanded(
            child: ClipRRect(
              borderRadius: WsRadii.cardR,
              child: WsHeroImage(
                hero: slide.hero,
                semanticLabel: '${slide.before}${slide.emphasis}${slide.after}',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
