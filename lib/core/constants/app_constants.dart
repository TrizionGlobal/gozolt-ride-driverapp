abstract final class AppConstants {
  static const Duration splashDuration = Duration(milliseconds: 1500);
  static const int onboardingPageCount = 2;
  static const String appName = 'Gozolt Partner';
  static const String appTagline = 'THE DRIVER APP';

  // ── OTP ────────────────────────────────────────────────
  static const int otpLength = 6;
  static const int otpResendSeconds = 30;

  // ── Stripe ────────────────────────────────────────────
  static const String stripePublishableKey = String.fromEnvironment(
    'STRIPE_PK',
    defaultValue: 'pk_test_51RYXLLPM5zo65HVyj5vNSB4z2awbPt8oemY8tgJQ7Kepb6SaR1XVd0a5tmbJuqhGgTYH0wnewoSqlcEJXzwhQQht00hpMFVH1g',
  );

  /// Set via --dart-define=DEV_BYPASS=true for dev builds.
  /// In release builds this is always false.
  static const bool kDevBypass =
      bool.fromEnvironment('DEV_BYPASS', defaultValue: false);

  static const bool isTestMode = false;
  static const double defaultLat = isTestMode ? 17.385 : 35.8989;
  static const double defaultLng = isTestMode ? 78.4867 : 14.5146;

  // ── Timeouts ───────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
