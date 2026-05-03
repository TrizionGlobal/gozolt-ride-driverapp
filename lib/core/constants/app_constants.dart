abstract final class AppConstants {
  static const Duration splashDuration = Duration(seconds: 3);
  static const int onboardingPageCount = 2;
  static const String appName = 'Gozolt Driver';

  /// Set via --dart-define=DEV_BYPASS=true for dev builds.
  /// In release builds this is always false.
  static const bool kDevBypass =
      bool.fromEnvironment('DEV_BYPASS', defaultValue: false);

  static const bool isTestMode = false;
  static const double defaultLat = isTestMode ? 17.385 : 35.8989;
  static const double defaultLng = isTestMode ? 78.4867 : 14.5146;
}
