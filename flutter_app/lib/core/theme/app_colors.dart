import 'package:flutter/material.dart';

/// TekTech Color System - Material 3 Compliant
///
/// Based on Material 3 color roles with custom brand colors
/// Primary: Indigo 600 (#4F46E5)
/// Secondary: Green 500 (#22C55E)
/// Error: Red 500 (#EF4444)

class AppColors {
  // Primary - Indigo Scale (Material 3 Compliant)
  static const Color indigo900 = Color(0xFF312E81);
  static const Color indigo800 = Color(0xFF3730A3);
  static const Color indigo700 = Color(0xFF4338CA);
  static const Color indigo600 = Color(0xFF4F46E5); // Brand primary
  static const Color indigo500 = Color(0xFF6366F1);
  static const Color indigo400 = Color(0xFF818CF8);
  static const Color indigo300 = Color(0xFFA5B4FC);
  static const Color indigo200 = Color(0xFFC7D2FE);
  static const Color indigo100 = Color(0xFFE0E7FF);
  static const Color indigo50 = Color(0xFFEEF2FF);

  // Secondary - Green Scale (Material 3 Compliant)
  static const Color green900 = Color(0xFF14532D);
  static const Color green800 = Color(0xFF166534);
  static const Color green700 = Color(0xFF15803D);
  static const Color green600 = Color(0xFF16A34A);
  static const Color green500 = Color(0xFF22C55E); // Brand secondary & Success
  static const Color green400 = Color(0xFF4ADE80);
  static const Color green300 = Color(0xFF86EFAC);
  static const Color green200 = Color(0xFFBBF7D0);
  static const Color green100 = Color(0xFFDCFCE7);
  static const Color green50 = Color(0xFFF0FDF4);

  // Error - Red Scale (Material 3 Compliant)
  static const Color red900 = Color(0xFF7F1D1D);
  static const Color red800 = Color(0xFF991B1B);
  static const Color red700 = Color(0xFFB91C1C);
  static const Color red600 = Color(0xFFDC2626);
  static const Color red500 = Color(0xFFEF4444); // Error color
  static const Color red400 = Color(0xFFF87171);
  static const Color red300 = Color(0xFFFCA5A5);
  static const Color red200 = Color(0xFFFECACA);
  static const Color red100 = Color(0xFFFEE2E2);
  static const Color red50 = Color(0xFFFEF2F2);

  // Warning - Amber Scale (Material 3 Compliant)
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

  // Info - Cyan Scale (Material 3 Compliant)
  static const Color cyan900 = Color(0xFF164E63);
  static const Color cyan800 = Color(0xFF155E75);
  static const Color cyan700 = Color(0xFF0E7490);
  static const Color cyan600 = Color(0xFF0891B2);
  static const Color cyan500 = Color(0xFF06B6D4); // Info color
  static const Color cyan400 = Color(0xFF22D3EE);
  static const Color cyan300 = Color(0xFF67E8F9);
  static const Color cyan200 = Color(0xFFA5F3FC);
  static const Color cyan100 = Color(0xFFCFFAFE);
  static const Color cyan50 = Color(0xFFECFEFF);

  // Neutral - Gray Scale (Material 3 Compliant)
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

  // Material 3 Semantic Colors
  static const Color primary = indigo600;
  static const Color onPrimary = white;
  static const Color primaryContainer = indigo100;
  static const Color onPrimaryContainer = indigo900;

  static const Color secondary = green500;
  static const Color onSecondary = white;
  static const Color secondaryContainer = green100;
  static const Color onSecondaryContainer = green900;

  static const Color tertiary = cyan500;
  static const Color onTertiary = white;
  static const Color tertiaryContainer = cyan100;
  static const Color onTertiaryContainer = cyan900;

  static const Color error = red500;
  static const Color onError = white;
  static const Color errorContainer = red100;
  static const Color onErrorContainer = red900;

  static const Color warning = amber500;
  static const Color onWarning = black;
  static const Color warningContainer = amber100;
  static const Color onWarningContainer = amber900;

  static const Color info = cyan500;
  static const Color onInfo = white;
  static const Color infoContainer = cyan100;
  static const Color onInfoContainer = cyan900;

  // Surface Colors (Light Theme)
  static const Color surface = Color(0xFFFFFBFE);
  static const Color onSurface = gray900;
  static const Color surfaceVariant = Color(0xFFE7E0EC);
  static const Color onSurfaceVariant = gray700;
  static const Color surfaceContainerHighest = gray200;
  static const Color surfaceContainerHigh = gray100;
  static const Color surfaceContainer = white;
  static const Color surfaceContainerLow = gray50;
  static const Color surfaceContainerLowest = white;

  static const Color background = Color(0xFFFFFBFE);
  static const Color onBackground = gray900;
  static const Color outline = gray400;
  static const Color outlineVariant = gray200;

  // Dark Theme Colors
  static const Color darkPrimary = indigo300;
  static const Color darkOnPrimary = indigo900;
  static const Color darkPrimaryContainer = indigo700;
  static const Color darkOnPrimaryContainer = indigo100;

  static const Color darkSecondary = green300;
  static const Color darkOnSecondary = green900;
  static const Color darkSecondaryContainer = green700;
  static const Color darkOnSecondaryContainer = green100;

  static const Color darkTertiary = cyan300;
  static const Color darkOnTertiary = cyan900;
  static const Color darkTertiaryContainer = cyan700;
  static const Color darkOnTertiaryContainer = cyan100;

  static const Color darkError = red300;
  static const Color darkOnError = red900;
  static const Color darkErrorContainer = red700;
  static const Color darkOnErrorContainer = red100;

  static const Color darkSurface = Color(0xFF101014);
  static const Color darkOnSurface = gray100;
  static const Color darkSurfaceVariant = Color(0xFF49454F);
  static const Color darkOnSurfaceVariant = gray300;
  static const Color darkSurfaceContainerHighest = Color(0xFF2B2930);
  static const Color darkSurfaceContainerHigh = Color(0xFF211F26);
  static const Color darkSurfaceContainer = Color(0xFF1D1B20);
  static const Color darkSurfaceContainerLow = Color(0xFF1A181D);
  static const Color darkSurfaceContainerLowest = Color(0xFF0F0D13);

  static const Color darkBackground = Color(0xFF101014);
  static const Color darkOnBackground = gray100;
  static const Color darkOutline = gray600;
  static const Color darkOutlineVariant = gray700;

  // Blue Scale for Priority Normal
  static const Color blue900 = Color(0xFF1E3A8A);
  static const Color blue800 = Color(0xFF1E40AF);
  static const Color blue700 = Color(0xFF1D4ED8);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color blue500 = Color(0xFF3B82F6); // Priority Normal
  static const Color blue400 = Color(0xFF60A5FA);
  static const Color blue300 = Color(0xFF93C5FD);
  static const Color blue200 = Color(0xFFBFDBFE);
  static const Color blue100 = Color(0xFFDBEAFE);
  static const Color blue50 = Color(0xFFEFF6FF);

  // Emerald Scale for Status Done
  static const Color emerald900 = Color(0xFF064E3B);
  static const Color emerald800 = Color(0xFF065F46);
  static const Color emerald700 = Color(0xFF047857);
  static const Color emerald600 = Color(0xFF059669);
  static const Color emerald500 = Color(0xFF10B981); // Status Done
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald300 = Color(0xFF6EE7B7);
  static const Color emerald200 = Color(0xFFA7F3D0);
  static const Color emerald100 = Color(0xFFD1FAE5);
  static const Color emerald50 = Color(0xFFECFDF5);

  // Priority Colors (Semantic) - Spec Compliant
  static const Color priorityHigh = red500; // #EF4444
  static const Color priorityNormal = blue500; // #3B82F6
  static const Color priorityLow = gray500; // #6B7280

  // Status Colors (Semantic) - Spec Compliant
  static const Color statusTodo = gray500; // #6B7280
  static const Color statusInProgress = amber500; // #F59E0B
  static const Color statusDone = emerald500; // #10B981

  // Success, Warning, Info (Aliases for consistency)
  static const Color success = green500;
}
