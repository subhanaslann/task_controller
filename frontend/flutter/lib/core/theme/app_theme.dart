import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'design_tokens.dart';
import 'theme_extensions.dart';

/// TekTech App Theme - WhatsApp Inspired Dark Theme
///
/// Default theme is dark mode with WhatsApp-inspired colors
/// Light theme available as optional toggle
class AppTheme {
  // ========== LEGACY CONSTANTS (BACKWARD COMPATIBILITY) ==========

  // WhatsApp Theme Primary Colors
  static const Color primaryColor = AppColors.primary;  // Teal
  static const Color primaryLightColor = AppColors.teal300;
  static const Color primaryDarkColor = AppColors.teal700;

  static const Color secondaryColor = AppColors.secondary;  // WhatsApp Green
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

  // Spacing (use AppSpacing for new code)
  static const double spacing4 = AppSpacing.xs;
  static const double spacing8 = AppSpacing.sm;
  static const double spacing12 = 12.0;
  static const double spacing16 = AppSpacing.md;
  static const double spacing20 = 20.0;
  static const double spacing24 = AppSpacing.lg;
  static const double spacing32 = AppSpacing.xl;

  // Border radius (use AppRadius for new code)
  static const double radius4 = AppRadius.xs;
  static const double radius8 = AppRadius.sm;
  static const double radius12 = AppRadius.md;
  static const double radius16 = AppRadius.lg;
  static const double radius20 = 20.0;
  static const double radius24 = AppRadius.xl;
  static const double radius28 = 28.0;
  static const double radiusFull = AppRadius.full;

  // Elevation (use AppElevation for new code)
  static const double elevation0 = AppElevation.none;
  static const double elevation1 = AppElevation.xs;
  static const double elevation2 = AppElevation.sm;
  static const double elevation3 = 3.0;
  static const double elevation4 = AppElevation.md;
  static const double elevation6 = 6.0;
  static const double elevation8 = AppElevation.lg;

  // Sizes
  static const double minTouchTarget = 48.0;

  // Icon sizes (use AppIconSize for new code)
  static const double iconXs = AppIconSize.xs;
  static const double iconSm = AppIconSize.sm;
  static const double iconMd = AppIconSize.md;
  static const double iconLg = AppIconSize.lg;
  static const double iconXl = AppIconSize.xl;

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
  static const double borderThin = AppBorderWidth.thin;
  static const double borderMedium = AppBorderWidth.normal;
  static const double borderThick = AppBorderWidth.thick;

  // Animation durations (use AppDuration for new code)
  static const int durationInstant = 0;
  static const int durationFast = 150;
  static const int durationNormal = 300;
  static const int durationSlow = 500;
  static const int durationVerySlow = 700;
  static const int durationLoading = 1000;

  // Semantic durations
  static const int durationStateChange = durationFast;
  static const int durationEnterExit = durationNormal;
  static const int durationPageTransition = durationNormal;
  static const int durationShimmer = durationLoading;

  // ========== DARK THEME (DEFAULT - WHATSAPP INSPIRED) ==========

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme - WhatsApp Dark Theme
      colorScheme: ColorScheme.dark(
        // Primary - Teal
        primary: AppColors.primary,  // #00A884
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,

        // Secondary - WhatsApp Green
        secondary: AppColors.secondary,  // #25D366
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,

        // Tertiary - Blue
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: AppColors.onTertiaryContainer,

        // Error
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onErrorContainer,

        // Surface - WhatsApp Dark Surfaces
        surface: AppColors.darkSurface,  // #202C33
        onSurface: AppColors.textPrimaryDark,
        onSurfaceVariant: AppColors.textSecondaryDark,
        surfaceContainerHighest: AppColors.darkContainer,
        surfaceContainerHigh: AppColors.darkSurface,
        surfaceContainer: AppColors.darkBackground,
        surfaceContainerLow: AppColors.darkElevated,
        surfaceContainerLowest: AppColors.darkBackground,

        // Outline
        outline: AppColors.darkDivider,
        outlineVariant: AppColors.outlineVariant,
        scrim: Colors.black.withValues(alpha: 0.5),
      ),

      scaffoldBackgroundColor: AppColors.darkBackground,  // #0B141A

      // App Bar Theme - WhatsApp style
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,  // #202C33
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
        centerTitle: false,  // Left-aligned like WhatsApp
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTypography.headlineSmall.copyWith(
          color: AppColors.textPrimaryDark,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Card Theme - Subtle shadows for dark mode
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 1,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
        ),
      ),

      // Elevated Button - Teal primary
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,  // Teal
          foregroundColor: AppColors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.darkDivider),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
        ),
      ),

      // Input Decoration - WhatsApp style
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: AppColors.darkDivider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: AppColors.darkDivider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: AppSpacing.paddingMD,
        filled: true,
        fillColor: AppColors.darkContainer,
        hintStyle: TextStyle(color: AppColors.textTertiaryDark),
        labelStyle: TextStyle(color: AppColors.textSecondaryDark),
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondaryDark,
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: AppElevation.fab,
        shape: const CircleBorder(),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkContainer,
        elevation: AppElevation.dialog,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.dialog,
        ),
        titleTextStyle: AppTypography.headlineSmall.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondaryDark,
        ),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.bottomSheet,
        ),
        elevation: AppElevation.bottomSheet,
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: AppColors.darkDivider,
        thickness: 1,
        space: 1,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkContainer,
        labelStyle: TextStyle(color: AppColors.textPrimaryDark),
        padding: AppSpacing.paddingSM,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderRadiusSM,
        ),
      ),

      // Text Theme
      textTheme: AppTypography.textTheme.apply(
        bodyColor: AppColors.textPrimaryDark,
        displayColor: AppColors.textPrimaryDark,
      ),

      // Tab Bar Theme
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondaryDark,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.tab,
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.gray500;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary.withValues(alpha: 0.5);
          }
          return AppColors.darkContainer;
        }),
      ),

      // Theme Extensions - Custom Components
      extensions: <ThemeExtension<dynamic>>[
        CustomColorsExtension.dark,
        CardStylesExtension.dark,
        ButtonStylesExtension.dark,
        ChatBubbleTheme.dark,
      ],
    );
  }

  // ========== LIGHT THEME (OPTIONAL TOGGLE) ==========

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme - Light Mode
      colorScheme: ColorScheme.light(
        // Primary - Teal
        primary: AppColors.lightPrimary,
        onPrimary: AppColors.lightOnPrimary,
        primaryContainer: AppColors.lightPrimaryContainer,
        onPrimaryContainer: AppColors.lightOnPrimaryContainer,

        // Secondary - WhatsApp Green
        secondary: AppColors.lightSecondary,
        onSecondary: AppColors.lightOnSecondary,
        secondaryContainer: AppColors.lightSecondaryContainer,
        onSecondaryContainer: AppColors.lightOnSecondaryContainer,

        // Tertiary - Blue
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: AppColors.onTertiaryContainer,

        // Error
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onErrorContainer,

        // Surface - Light Surfaces
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightOnSurface,
        surfaceContainerHighest: AppColors.gray100,
        onSurfaceVariant: AppColors.gray700,
        surfaceContainerHigh: AppColors.gray50,
        surfaceContainer: AppColors.white,
        surfaceContainerLow: AppColors.white,
        surfaceContainerLowest: AppColors.white,

        // Outline
        outline: AppColors.lightOutline,
        outlineVariant: AppColors.lightOutlineVariant,
        scrim: Colors.black.withValues(alpha: 0.32),
      ),

      scaffoldBackgroundColor: AppColors.lightBackground,

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.lightOnSurface,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTypography.headlineSmall.copyWith(
          color: AppColors.lightOnSurface,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 1,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
        ),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: AppColors.lightOutline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: AppColors.lightOutline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding: AppSpacing.paddingMD,
        filled: true,
        fillColor: AppColors.gray50,
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.gray500,
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: AppElevation.fab,
        shape: const CircleBorder(),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.white,
        elevation: AppElevation.dialog,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.dialog,
        ),
      ),

      // Text Theme
      textTheme: AppTypography.textTheme,

      // Tab Bar Theme
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.gray500,
        indicatorColor: AppColors.primary,
        indicatorSize: TabBarIndicatorSize.tab,
      ),

      // Theme Extensions
      extensions: <ThemeExtension<dynamic>>[
        CustomColorsExtension.light,
        CardStylesExtension.light,
        ButtonStylesExtension.light,
        ChatBubbleTheme.light,
      ],
    );
  }
}
