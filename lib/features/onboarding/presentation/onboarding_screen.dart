import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../core/providers/storage_provider.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/gozolt_logo.dart';
import '../data/onboarding_data.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _onSkipPressed() async {
    await ref.read(secureStorageProvider).setOnboardingSeen();
    if (mounted) {
      context.go(RouteNames.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Static background painter (Navy blue curved road at the bottom)
          Positioned.fill(
            child: CustomPaint(
              painter: OnboardingBackgroundPainter(),
            ),
          ),

          // PageView for swiping illustrations and text
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              itemCount: onboardingPages.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                final page = onboardingPages[index];
                return Stack(
                  children: [
                    // Illustration sitting exactly on the curve
                    Positioned(
                      bottom: size.height * 0.35, // grounds the wheels on the convex curve peak
                      left: 24,
                      right: 24,
                      height: size.height * 0.30,
                      child: Center(
                        child: Image.asset(
                          page.imagePath,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 280,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.directions_car_rounded,
                                size: 80,
                                color: AppColors.primaryGold,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    // Title Text inside the navy blue section
                    Positioned(
                      top: size.height * 0.70,
                      left: 20,
                      right: 20,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: const TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.35,
                              ),
                              children: [
                                TextSpan(text: page.titlePre),
                                TextSpan(
                                  text: page.titleHighlight,
                                  style: const TextStyle(
                                    color: Color(0xFFF5C518),
                                  ),
                                ),
                                TextSpan(text: page.titlePost),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Static Hexagonal Logo centered at top
          Positioned(
            top: topPadding + 20,
            left: 0,
            right: 0,
            child: const Center(
              child: GozoltLogo(size: 80),
            ),
          ),

          // Static "Skip" Button at top right
          Positioned(
            top: topPadding + 15,
            right: 24,
            child: GestureDetector(
              onTap: _onSkipPressed,
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: Color(0xFF1B2838),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),

          // Static Page Indicator centered at bottom
          Positioned(
            bottom: bottomPadding + 32,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: onboardingPages.length,
                effect: const WormEffect(
                  dotWidth: 10,
                  dotHeight: 10,
                  activeDotColor: Color(0xFFF5C518),
                  dotColor: Colors.white54,
                  spacing: 8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0C1B30)
      ..style = PaintingStyle.fill;

    final double startHeight = size.height * 0.56; // Starts lower at the edges
    final double peakHeight = size.height * 0.44;  // Peaks higher in the center (convex)

    final path = Path();
    path.moveTo(0, startHeight);
    path.quadraticBezierTo(
      size.width / 2,
      peakHeight,
      size.width,
      startHeight,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
