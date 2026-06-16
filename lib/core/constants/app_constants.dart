abstract final class AppConstants {
  static const Duration splashDuration = Duration(milliseconds: 2500);
  static const int onboardingPageCount = 2;
  static const String appName = 'Gozolt Partner';
  static const String appTagline = 'THE DRIVER APP';

  // ── OTP ────────────────────────────────────────────────
  static const int otpLength = 6;
  static const int otpResendSeconds = 30;

  // ── Stripe ────────────────────────────────────────────
  static const String stripePublishableKey = String.fromEnvironment(
    'STRIPE_PK',
    defaultValue: 'pk_test_51RhyquLppOyXcfaxgEhWZuhDAIPhz6H1bDh9u3hDVdGd1Fd7mboroU1VhXPL1mlSz2ZyPxp5ZLGoNWGGPLQJ2v7100oCnHbogY',
  );

  static const double defaultLat = 35.8989;
  static const double defaultLng = 14.5146;

  // ── Timeouts ───────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
