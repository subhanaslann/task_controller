import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  // Legacy color constants (for backward compatibility)
  static const Color primaryColor = AppColors.primary;
  static const Color primaryLightColor = AppColors.indigo500;
  static const Color primaryDarkColor = AppColors.indigo700;

  static const Color secondaryColor = AppColors.secondary;
  static const Color errorColor = AppColors.error;
  static const Color warningColor = AppColors.warning;
  static const Color infoColor = AppColors.info;

  static const Color surfaceColor = AppColors.surface;
  static const Color backgroundColor = AppColors.background;
  static const Color cardColor = AppColors.surfaceContainer;

  // Text colors
  static const Color textPrimaryColor = AppColors.onSurface;
  static const Color textSecondaryColor = AppColors.onSurfaceVariant;
  static const Color textDisabledColor = AppColors.outline;

  // Priority colors
  static const Color priorityLowColor = AppColors.priorityLow;
  static const Color priorityNormalColor = AppColors.priorityNormal;
  static const Color priorityHighColor = AppColors.priorityHigh;

  // Status colors
  static const Color statusTodoColor = AppColors.statusTodo;
  static const Color statusInProgressColor = AppColors.statusInProgress;
  static const Color statusDoneColor = AppColors.statusDone;

  // Spacing
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;

  // Border radius
  static const double radius4 = 4.0;
  static const double radius8 = 8.0;
  static const double radius12 = 12.0;
  static const double radius16 = 16.0;
  static const double radius20 = 20.0;
  static const double radius24 = 24.0;
  static const double radius28 = 28.0;
  static const double radiusFull = 999.0;

  // Elevation
  static const double elevation0 = 0.0;
  static const double elevation1 = 1.0;
  static const double elevation2 = 2.0;
  static const double elevation3 = 3.0;
  static const double elevation4 = 4.0;
  static const double elevation6 = 6.0;
  static const double elevation8 = 8.0;

  // Sizes
  static const double minTouchTarget = 48.0;

  // Icon sizes
  static const double iconXs = 16.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;

  // Button heights
  static const double buttonSmall = 40.0;
  static const double buttonMedium = 48.0;
  static const double buttonLarge = 56.0;

  // Avatar sizes
  static const double avatarSmall = 24.0;
  static const double avatarMedium = 32.0;
  static const double avatarLarge = 40.0;
  static const double avatarXl = 56.0;

  // Border widths
  static const double borderThin = 1.0;
  static const double borderMedium = 2.0;
  static const double borderThick = 3.0;

  // Animation durations (milliseconds)
  static const int durationInstant = 0;
  static const int durationFast = 120;
  static const int durationNormal = 180;
  static const int durationSlow = 220;
  static const int durationVerySlow = 300;
  static const int durationLoading = 600;

  // Semantic durations
  static const int durationStateChange = durationFast;
  static const int durationEnterExit = durationNormal;
  static const int durationPageTransition = durationSlow;
  static const int durationShimmer = durationLoading;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,

        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,

        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: AppColors.onTertiaryContainer,

        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onErrorContainer,

        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        surfaceContainerHighest: AppColors.surfaceContainerHighest,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        surfaceContainerHigh: AppColors.surfaceContainerHigh,
        surfaceContainer: AppColors.surfaceContainer,
        surfaceContainerLow: AppColors.surfaceContainerLow,
        surfaceContainerLowest: AppColors.surfaceContainerLowest,

        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
        scrim: Colors.black.withOpacity(0.32),
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceContainer,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainer,
        elevation: 1,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius12),
          borderSide: BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius12),
          borderSide: BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius12),
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius12),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        filled: true,
        fillColor: AppColors.surfaceContainer,
      ),
      textTheme: AppTypography.textTheme,

      // Material 3 Shapes - Using default theme shapes
    );
  }

  // Legacy dark theme colors (for backward compatibility)
  static const Color darkPrimaryColor = AppColors.darkPrimary;
  static const Color darkPrimaryContainerColor = AppColors.darkPrimaryContainer;
  static const Color darkSecondaryColor = AppColors.darkSecondary;
  static const Color darkSecondaryContainerColor =
      AppColors.darkSecondaryContainer;
  static const Color darkErrorColor = AppColors.darkError;
  static const Color darkErrorContainerColor = AppColors.darkErrorContainer;

  static const Color darkBackgroundColor = AppColors.darkBackground;
  static const Color darkSurfaceColor = AppColors.darkSurface;
  static const Color darkSurfaceVariantColor = AppColors.darkSurfaceVariant;
  static const Color darkOutlineColor = AppColors.darkOutline;

  static const Color darkTextPrimaryColor = AppColors.darkOnSurface;
  static const Color darkTextSecondaryColor = AppColors.darkOnSurfaceVariant;

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.darkPrimary,
        onPrimary: AppColors.darkOnPrimary,
        primaryContainer: AppColors.darkPrimaryContainer,
        onPrimaryContainer: AppColors.darkOnPrimaryContainer,

        secondary: AppColors.darkSecondary,
        onSecondary: AppColors.darkOnSecondary,
        secondaryContainer: AppColors.darkSecondaryContainer,
        onSecondaryContainer: AppColors.darkOnSecondaryContainer,

        tertiary: AppColors.darkTertiary,
        onTertiary: AppColors.darkOnTertiary,
        tertiaryContainer: AppColors.darkTertiaryContainer,
        onTertiaryContainer: AppColors.darkOnTertiaryContainer,

        error: AppColors.darkError,
        onError: AppColors.darkOnError,
        errorContainer: AppColors.darkErrorContainer,
        onErrorContainer: AppColors.darkOnErrorContainer,

        background: AppColors.darkBackground,
        onBackground: AppColors.darkOnBackground,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkOnSurface,
        surfaceVariant: AppColors.darkSurfaceVariant,
        onSurfaceVariant: AppColors.darkOnSurfaceVariant,
        surfaceContainerHighest: AppColors.darkSurfaceContainerHighest,
        surfaceContainerHigh: AppColors.darkSurfaceContainerHigh,
        surfaceContainer: AppColors.darkSurfaceContainer,
        surfaceContainerLow: AppColors.darkSurfaceContainerLow,
        surfaceContainerLowest: AppColors.darkSurfaceContainerLowest,

        outline: AppColors.darkOutline,
        outlineVariant: AppColors.darkOutlineVariant,
        scrim: Colors.black.withOpacity(0.32),
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurfaceContainer,
        foregroundColor: AppColors.darkOnSurface,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurfaceContainer,
        elevation: 2,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: AppColors.darkOnPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius12),
          borderSide: BorderSide(color: AppColors.darkOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius12),
          borderSide: BorderSide(color: AppColors.darkOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius12),
          borderSide: BorderSide(color: AppColors.darkPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius12),
          borderSide: BorderSide(color: AppColors.darkError),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius12),
          borderSide: BorderSide(color: AppColors.darkError, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        filled: true,
        fillColor: AppColors.darkSurfaceVariant,
      ),
      textTheme: AppTypography.textTheme.apply(
        bodyColor: AppColors.darkOnSurface,
        displayColor: AppColors.darkOnSurface,
      ),

      // Material 3 Shapes - Using default theme shapes
    );
  }
}
