import '../../../core/constants/asset_paths.dart';

class OnboardingPageData {
  final String imagePath;
  final String Function(dynamic l10n) getTitle;

  const OnboardingPageData({
    required this.imagePath,
    required this.getTitle,
  });
}

final onboardingPages = [
  OnboardingPageData(
    imagePath: AssetPaths.onboarding1Car,
    getTitle: (l10n) => l10n.onboardingTitle1,
  ),
  OnboardingPageData(
    imagePath: AssetPaths.onboarding2Car,
    getTitle: (l10n) => l10n.onboardingTitle2,
  ),
];
