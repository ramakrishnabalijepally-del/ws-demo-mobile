import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/theme.dart';
import '../../../../shared/shared.dart';
import '../../data/mock_onboarding.dart';
import '../widgets/slide_stage.dart';

/// A2–A4 — the three onboarding slides.
///
/// Each slide is a small scene: a photograph with two product cards floating
/// over it, and a headline where a single span carries the red. **Never colour
/// a whole line** (design system section 4).
///
/// Motion does two jobs here. The swipe is continuous — the scene's layers move
/// at different speeds under the finger. And when a slide settles it assembles:
/// cards rise in, the CRS score counts up, the plane flies its route, the
/// checklist ticks. Under reduced motion every slide arrives already assembled.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _controller = PageController();

  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: WsMotion.focal,
  );

  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: WsMotion.ambientFloat,
  );

  int _page = 0;

  /// The slide just left keeps its assembled state while it slides away, so it
  /// does not empty out under the finger.
  int _previous = 0;

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (WsMotion.reduced(context)) {
      _entrance.value = 1;
      _float.stop();
      return;
    }
    if (!_started) {
      _started = true;
      _entrance.forward();
    }
    if (!_float.isAnimating) _float.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _entrance.dispose();
    _float.dispose();
    super.dispose();
  }

  bool get _isLast => _page == mockOnboardingSlides.length - 1;

  void _onPageChanged(int index) {
    setState(() {
      _previous = _page;
      _page = index;
    });
    if (WsMotion.reduced(context)) {
      _entrance.value = 1;
    } else {
      _entrance.forward(from: 0);
    }
  }

  void _next() {
    if (_isLast) {
      context.go(Routes.signIn);
      return;
    }
    _controller.nextPage(
      duration: WsMotion.duration(context, WsMotion.slow),
      curve: WsMotion.standard,
    );
  }

  Animation<double> _entranceFor(int index) {
    if (WsMotion.reduced(context)) return kAlwaysCompleteAnimation;
    if (index == _page) return _entrance;
    if (index == _previous) return kAlwaysCompleteAnimation;
    return kAlwaysDismissedAnimation;
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
                onPageChanged: _onPageChanged,
                itemBuilder: (context, i) => AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    final position = _controller.hasClients &&
                            _controller.position.haveDimensions
                        ? _controller.page ?? _page.toDouble()
                        : _page.toDouble();
                    return _Slide(
                      slide: mockOnboardingSlides[i],
                      pageOffset: i - position,
                      entrance: _entranceFor(i),
                      float: _float,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: WsSpacing.xl),
            WsDotRail(total: mockOnboardingSlides.length, active: _page),
            const SizedBox(height: WsSpacing.xxl),
            Padding(
              padding: WsSpacing.gutter,
              child: AnimatedSwitcher(
                duration: WsMotion.duration(context, WsMotion.medium),
                child: WsPrimaryButton(
                  key: ValueKey(_isLast),
                  label: _isLast ? 'Get Started' : 'Next',
                  onPressed: _next,
                ),
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
  const _Slide({
    required this.slide,
    required this.pageOffset,
    required this.entrance,
    required this.float,
  });

  final OnboardingSlide slide;
  final double pageOffset;
  final Animation<double> entrance;
  final Animation<double> float;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: WsSpacing.gutter,
      child: LayoutBuilder(
        builder: (context, constraints) => Column(
          children: [
            const SizedBox(height: WsSpacing.md),
            Expanded(
              child: RepaintBoundary(
                child: SlideStage(
                  slide: slide,
                  pageOffset: pageOffset,
                  entrance: entrance,
                  float: float,
                ),
              ),
            ),
            const SizedBox(height: WsSpacing.xxl),
            // Capped and scrollable so 200% text never pushes the stage to
            // nothing or overflows the page.
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: constraints.maxHeight * 0.42,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    WsRiseIn(
                      entrance: entrance,
                      end: 0.55,
                      child: WsEmphasisHeadline(
                        before: slide.before,
                        emphasis: slide.emphasis,
                        after: slide.after,
                      ),
                    ),
                    const SizedBox(height: WsSpacing.sm),
                    WsRiseIn(
                      entrance: entrance,
                      begin: 0.12,
                      end: 0.67,
                      child: Text(
                        slide.supporting,
                        textAlign: TextAlign.center,
                        style: context.text.bodyMedium
                            ?.copyWith(color: context.ws.caption),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
