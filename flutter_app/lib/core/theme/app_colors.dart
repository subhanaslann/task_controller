import 'package:flutter/material.dart';

/// TekTech Color System - WhatsApp Inspired Dark Theme
///
/// Based on Material 3 color roles with WhatsApp-inspired dark theme
/// Primary: Teal (#00A884) - WhatsApp brand color
/// Secondary: Green (#25D366) - WhatsApp success/active color
/// Background: Dark (#0B141A, #202C33) - WhatsApp dark mode

class AppColors {
  // ========== WHATSAPP THEME COLORS ==========

  // Teal Scale (WhatsApp Primary)
  static const Color teal900 = Color(0xFF004D40);
  static const Color teal800 = Color(0xFF00695C);
  static const Color teal700 = Color(0xFF00796B);
  static const Color teal600 = Color(0xFF00897B);
  static const Color teal500 = Color(0xFF00A884); // WhatsApp teal (main brand)
  static const Color teal400 = Color(0xFF008F6E); // Darker variant
  static const Color teal300 = Color(0xFF26D9A3); // Lighter variant
  static const Color teal200 = Color(0xFF80E5C8);
  static const Color teal100 = Color(0xFFB2F2DE);
  static const Color teal50 = Color(0xFFE0F8F1);

  // WhatsApp Green Scale (Success/Active)
  static const Color whatsappGreen900 = Color(0xFF0A5C2E);
  static const Color whatsappGreen800 = Color(0xFF0C7A3C);
  static const Color whatsappGreen700 = Color(0xFF0F9748);
  static const Color whatsappGreen600 = Color(0xFF12B454);
  static const Color whatsappGreen500 = Color(
    0xFF25D366,
  ); // WhatsApp signature green
  static const Color whatsappGreen400 = Color(0xFF51DC81);
  static const Color whatsappGreen300 = Color(0xFF7DE59C);
  static const Color whatsappGreen200 = Color(0xFFA8EEB7);
  static const Color whatsappGreen100 = Color(0xFFD4F7DB);
  static const Color whatsappGreen50 = Color(0xFFEAFBED);

  // Dark Theme Background Colors (WhatsApp Dark Mode)
  static const Color darkBackground = Color(0xFF0B141A); // Main dark background
  static const Color darkSurface = Color(0xFF202C33); // Cards, message bubbles
  static const Color darkContainer = Color(0xFF2A3942); // Elevated containers
  static const Color darkDivider = Color(0xFF2A3942); // Dividers, borders
  static const Color darkElevated = Color(0xFF1A2329); // Even darker for depth

  // Text Colors (Dark Theme Optimized)
  static const Color textPrimaryDark = Color(0xFFE9EDEF); // Main text
  static const Color textSecondaryDark = Color(0xFF8696A0); // Secondary text
  static const Color textTertiaryDark = Color(
    0xFF667781,
  ); // Tertiary text/hints
  static const Color textDisabledDark = Color(0xFF4A5B66); // Disabled state

  // Bubble Colors (WhatsApp Message Bubbles)
  static const Color bubbleOutgoing = Color(
    0xFF005C4B,
  ); // Sent messages (darker teal)
  static const Color bubbleIncoming = Color(
    0xFF202C33,
  ); // Received messages (same as surface)
  static const Color bubbleOutgoingLight = Color(
    0xFFDCF8C6,
  ); // Light theme outgoing
  static const Color bubbleIncomingLight = Color(
    0xFFFFFFFF,
  ); // Light theme incoming

  // Error - Red Scale (Softer for dark theme)
  static const Color red900 = Color(0xFF7F1D1D);
  static const Color red800 = Color(0xFF991B1B);
  static const Color red700 = Color(0xFFB91C1C);
  static const Color red600 = Color(0xFFDC2626);
  static const Color red500 = Color(0xFFE94242); // Softer red for dark theme
  static const Color red400 = Color(0xFFED6868);
  static const Color red300 = Color(0xFFF28E8E);
  static const Color red200 = Color(0xFFF6B4B4);
  static const Color red100 = Color(0xFFFBDADA);
  static const Color red50 = Color(0xFFFDEDED);

  // Warning - Amber Scale
  static const Color amber900 = Color(0xFF78350F);
  static const Color amber800 = Color(0xFF92400E);
  static const Color amber700 = Color(0xFFB45309);
  static const Color amber600 = Color(0xFFD97706);
  static const Color amber500 = Color(0xFFF59E0B); // Warning color
  static const Color amber400 = Color(0xFFFBBF24);
  static const Color amber300 = Color(0xFFFCD34D);
  static const Color amber200 = Color(0xFFFDE68A);
  static const Color amber100 = Color(0xFFFEF3C7);
  static const Color amber50 = Color(0xFFFFFBEB);

  // Info - Blue Scale
  static const Color blue900 = Color(0xFF1E3A8A);
  static const Color blue800 = Color(0xFF1E40AF);
  static const Color blue700 = Color(0xFF1D4ED8);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color blue500 = Color(0xFF3B82F6); // Info color
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue300 = Color(0xFF93C5FD);
  static const Color blue200 = Color(0xFFBFDBFE);
  static const Color blue100 = Color(0xFFDBEAFE);
  static const Color blue50 = Color(0xFFEFF6FF);

  // Neutral - Gray Scale
  static const Color gray950 = Color(0xFF030712);
  static const Color gray900 = Color(0xFF111827);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray50 = Color(0xFFF9FAFB);

  // Pure colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // ========== MATERIAL 3 SEMANTIC COLORS (DARK THEME) ==========

  // Primary (Teal - WhatsApp theme)
  static const Color primary = teal500;
  static const Color onPrimary = white;
  static const Color primaryContainer = teal700;
  static const Color onPrimaryContainer = teal100;

  // Secondary (WhatsApp Green)
  static const Color secondary = whatsappGreen500;
  static const Color onSecondary = white;
  static const Color secondaryContainer = whatsappGreen700;
  static const Color onSecondaryContainer = whatsappGreen100;

  // Tertiary (Blue for info)
  static const Color tertiary = blue500;
  static const Color onTertiary = white;
  static const Color tertiaryContainer = blue700;
  static const Color onTertiaryContainer = blue100;

  // Error
  static const Color error = red500;
  static const Color onError = white;
  static const Color errorContainer = red700;
  static const Color onErrorContainer = red100;

  // Warning
  static const Color warning = amber500;
  static const Color onWarning = black;
  static const Color warningContainer = amber700;
  static const Color onWarningContainer = amber100;

  // Info
  static const Color info = blue500;
  static const Color onInfo = white;
  static const Color infoContainer = blue700;
  static const Color onInfoContainer = blue100;

  // Surface Colors (Dark Theme - WhatsApp)
  static const Color surface = darkSurface;
  static const Color onSurface = textPrimaryDark;
  static const Color surfaceVariant = darkContainer;
  static const Color onSurfaceVariant = textSecondaryDark;
  static const Color surfaceContainerHighest = darkContainer;
  static const Color surfaceContainerHigh = darkSurface;
  static const Color surfaceContainer = darkBackground;
  static const Color surfaceContainerLow = darkElevated;
  static const Color surfaceContainerLowest = darkBackground;

  // Background
  static const Color background = darkBackground;
  static const Color onBackground = textPrimaryDark;
  static const Color outline = darkDivider;
  static const Color outlineVariant = Color(0xFF3A4A54);

  // ========== LIGHT THEME COLORS (FOR OPTIONAL TOGGLE) ==========

  // Light Primary (Teal)
  static const Color lightPrimary = teal500;
  static const Color lightOnPrimary = white;
  static const Color lightPrimaryContainer = teal100;
  static const Color lightOnPrimaryContainer = teal900;

  // Light Secondary (WhatsApp Green)
  static const Color lightSecondary = whatsappGreen500;
  static const Color lightOnSecondary = white;
  static const Color lightSecondaryContainer = whatsappGreen100;
  static const Color lightOnSecondaryContainer = whatsappGreen900;

  // Light Surface
  static const Color lightSurface = Color(0xFFFFFBFE);
  static const Color lightOnSurface = gray900;
  static const Color lightBackground = Color(0xFFFFFBFE);
  static const Color lightOnBackground = gray900;
  static const Color lightOutline = gray400;
  static const Color lightOutlineVariant = gray200;

  // ========== APPLICATION-SPECIFIC COLORS ==========

  // Priority Colors (Semantic)
  static const Color priorityHigh = Color(0xFFEF4444); // Red
  static const Color priorityNormal = Color(0xFF3B82F6); // Blue
  static const Color priorityLow = Color(0xFF6B7280); // Gray

  // Status Colors (Semantic)
  static const Color statusTodo = gray500; // #6B7280
  static const Color statusInProgress = teal500; // #00A884 (WhatsApp teal)
  static const Color statusDone = whatsappGreen500; // #25D366 (WhatsApp green)

  // Online/Active Indicator
  static const Color online = whatsappGreen500;
  static const Color offline = gray500;
  static const Color away = amber500;

  // Success (Alias)
  static const Color success = whatsappGreen500;

  // ========== OPACITY VARIANTS ==========

  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  // Common opacity levels
  static const double opacityTransparent = 0.0;
  static const double opacitySubtle = 0.1;
  static const double opacityLight = 0.3;
  static const double opacityMedium = 0.5;
  static const double opacityStrong = 0.7;
  static const double opacityOpaque = 1.0;
}
