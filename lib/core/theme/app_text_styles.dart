import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTextStyles {

  // Display styles
  static const TextStyle displayLarge = TextStyle(
    
    fontSize: 48,
    fontWeight: FontWeight.w900,
    letterSpacing: 2.0,
  );

  static const TextStyle displayMedium = TextStyle(
    
    fontSize: 36,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.5,
  );

  // Headline styles
  static const TextStyle headlineLarge = TextStyle(
    
    fontSize: 32,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle headlineMedium = TextStyle(
    
    fontSize: 24,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle headlineSmall = TextStyle(
    
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  // Title styles
  static const TextStyle titleLarge = TextStyle(
    
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle titleMedium = TextStyle(
    
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle titleSmall = TextStyle(
    
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  // Body styles
  static const TextStyle bodyLarge = TextStyle(
    
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodyMedium = TextStyle(
    
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodySmall = TextStyle(
    
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  // Label styles
  static const TextStyle labelLarge = TextStyle(
    
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  static const TextStyle labelMedium = TextStyle(
    
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmall = TextStyle(
    
    fontSize: 10,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  // Splash screen specific styles
  static const TextStyle splashTitle = TextStyle(
    
    fontSize: 84,
    fontWeight: FontWeight.w900,
    letterSpacing: 3.0,
  );

  static const TextStyle splashSubtitle = TextStyle(
    
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 5.0,
  );

  // Onboarding styles
  static const TextStyle onboardingTitle = TextStyle(
    
    fontSize: 22,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.italic,
  );

  // Footer styles
  static const TextStyle footerText = TextStyle(
    
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle footerAccent = TextStyle(
    
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.brandYellow,
  );
}
