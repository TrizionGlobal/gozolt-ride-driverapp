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
    defaultValue: 'pk_live_51RhyquLppOyXcfaxlpBULfNGVCeGeWJcBptsxFG9MXtMY2m1RFCQBL83Do6KPLLcNFqRcFlDg6od7FQ52pK0uJCm00EVV3XnHO',
  );

  static const double defaultLat = 35.8989;
  static const double defaultLng = 14.5146;

  // ── Timeouts ───────────────────────────────────────────
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
