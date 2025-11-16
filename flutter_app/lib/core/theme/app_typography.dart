import 'package:flutter/material.dart';

/// TekTech Typography - Modern & Readable
/// 
/// Material 3 compliant typography system
class AppTypography {
  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'System',
    fontWeight: FontWeight.w700, // Bold
    fontSize: 57,
    height: 64 / 57, // lineHeight / fontSize
    letterSpacing: -0.25,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: 'System',
    fontWeight: FontWeight.w700, // Bold
    fontSize: 45,
    height: 52 / 45,
    letterSpacing: 0,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: 'System',
    fontWeight: FontWeight.w600, // SemiBold
    fontSize: 36,
    height: 44 / 36,
    letterSpacing: 0,
  );

  // Headline - For section titles
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: 'System',
    fontWeight: FontWeight.w700, // Bold
    fontSize: 32,
    height: 40 / 32,
    letterSpacing: 0,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: 'System',
    fontWeight: FontWeight.w600, // SemiBold
    fontSize: 28,
    height: 36 / 28,
    letterSpacing: 0,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: 'System',
    fontWeight: FontWeight.w600, // SemiBold
    fontSize: 24,
    height: 32 / 24,
    letterSpacing: 0,
  );

  // Title - For card titles
  static const TextStyle titleLarge = TextStyle(
    fontFamily: 'System',
    fontWeight: FontWeight.w600, // SemiBold
    fontSize: 22,
    height: 28 / 22,
    letterSpacing: 0,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: 'System',
    fontWeight: FontWeight.w500, // Medium
    fontSize: 16,
    height: 24 / 16,
    letterSpacing: 0.15,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: 'System',
    fontWeight: FontWeight.w500, // Medium
    fontSize: 14,
    height: 20 / 14,
    letterSpacing: 0.1,
  );

  // Body - For main content
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'System',
    fontWeight: FontWeight.w400, // Normal
    fontSize: 16,
    height: 24 / 16,
    letterSpacing: 0.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'System',
    fontWeight: FontWeight.w400, // Normal
    fontSize: 14,
    height: 20 / 14,
    letterSpacing: 0.25,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'System',
    fontWeight: FontWeight.w400, // Normal
    fontSize: 12,
    height: 16 / 12,
    letterSpacing: 0.4,
  );

  // Label - For buttons and chips
  static const TextStyle labelLarge = TextStyle(
    fontFamily: 'System',
    fontWeight: FontWeight.w500, // Medium
    fontSize: 14,
    height: 20 / 14,
    letterSpacing: 0.1,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: 'System',
    fontWeight: FontWeight.w500, // Medium
    fontSize: 12,
    height: 16 / 12,
    letterSpacing: 0.5,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: 'System',
    fontWeight: FontWeight.w500, // Medium
    fontSize: 11,
    height: 16 / 11,
    letterSpacing: 0.5,
  );

  /// Get Material 3 compatible TextTheme
  static TextTheme get textTheme {
    return const TextTheme(
      displayLarge: displayLarge,
      displayMedium: displayMedium,
      displaySmall: displaySmall,
      headlineLarge: headlineLarge,
      headlineMedium: headlineMedium,
      headlineSmall: headlineSmall,
      titleLarge: titleLarge,
      titleMedium: titleMedium,
      titleSmall: titleSmall,
      bodyLarge: bodyLarge,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelLarge: labelLarge,
      labelMedium: labelMedium,
      labelSmall: labelSmall,
    );
  }
}
