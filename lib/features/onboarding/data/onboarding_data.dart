import '../../../core/constants/asset_paths.dart';

class OnboardingPageData {
  final String imagePath;
  final String titlePre;
  final String titleHighlight;
  final String titlePost;

  const OnboardingPageData({
    required this.imagePath,
    required this.titlePre,
    required this.titleHighlight,
    required this.titlePost,
  });
}

final onboardingPages = [
  OnboardingPageData(
    imagePath: AssetPaths.onboarding2Car,
    titlePre: '"Let\'s get you on the ',
    titleHighlight: 'ROAD',
    titlePost: '"',
  ),
  OnboardingPageData(
    imagePath: AssetPaths.onboarding1Car,
    titlePre: '"Start ',
    titleHighlight: 'EARNING',
    titlePost: ' now"',
  ),
];
