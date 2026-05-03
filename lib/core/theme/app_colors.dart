import 'package:flutter/material.dart';

abstract final class AppColors {
  // Primary brand colors
  static const Color primaryGold = Color(0xFFF5C518);
  static const Color brandYellow = Color(0xFFF5C518);

  // Background colors - dark navy palette
  static const Color backgroundPrimary = Color(0xFF1B2838);
  static const Color backgroundSecondary = Color(0xFF152233);
  static const Color backgroundDarker = Color(0xFF0F1923);

  // Surface colors
  static const Color surfaceDark = Color(0xFF223344);
  static const Color surfaceCard = Color(0xFF2A3A4A);
  static const Color surfaceInput = Color(0xFF243447);

  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color textAccent = Color(0xFFF5C518);
  static const Color textMuted = Color(0xFF78909C);

  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Utility
  static const Color transparent = Colors.transparent;
  static const Color white = Colors.white;
  static const Color black = Colors.black;
}
