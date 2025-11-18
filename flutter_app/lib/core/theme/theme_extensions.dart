import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'design_tokens.dart';

/// TekTech Custom Theme Extensions
///
/// Theme extensions for custom component styles that aren't
/// covered by default Material Theme

/// Custom colors extension
@immutable
class CustomColorsExtension extends ThemeExtension<CustomColorsExtension> {
  final Color priorityLow;
  final Color priorityNormal;
  final Color priorityHigh;
  final Color statusTodo;
  final Color statusInProgress;
  final Color statusDone;
  final Color cardHover;
  final Color divider;

  const CustomColorsExtension({
    required this.priorityLow,
    required this.priorityNormal,
    required this.priorityHigh,
    required this.statusTodo,
    required this.statusInProgress,
    required this.statusDone,
    required this.cardHover,
    required this.divider,
  });

  /// Light theme colors
  static const CustomColorsExtension light = CustomColorsExtension(
    priorityLow: AppColors.green500,
    priorityNormal: AppColors.cyan500,
    priorityHigh: AppColors.red500,
    statusTodo: AppColors.gray500,
    statusInProgress: AppColors.cyan500,
    statusDone: AppColors.green500,
    cardHover: AppColors.gray50,
    divider: AppColors.gray200,
  );

  /// Dark theme colors
  static const CustomColorsExtension dark = CustomColorsExtension(
    priorityLow: AppColors.green400,
    priorityNormal: AppColors.cyan400,
    priorityHigh: AppColors.red400,
    statusTodo: AppColors.gray400,
    statusInProgress: AppColors.cyan400,
    statusDone: AppColors.green400,
    cardHover: AppColors.gray800,
    divider: AppColors.gray700,
  );

  @override
  ThemeExtension<CustomColorsExtension> copyWith({
    Color? priorityLow,
    Color? priorityNormal,
    Color? priorityHigh,
    Color? statusTodo,
    Color? statusInProgress,
    Color? statusDone,
    Color? cardHover,
    Color? divider,
  }) {
    return CustomColorsExtension(
      priorityLow: priorityLow ?? this.priorityLow,
      priorityNormal: priorityNormal ?? this.priorityNormal,
      priorityHigh: priorityHigh ?? this.priorityHigh,
      statusTodo: statusTodo ?? this.statusTodo,
      statusInProgress: statusInProgress ?? this.statusInProgress,
      statusDone: statusDone ?? this.statusDone,
      cardHover: cardHover ?? this.cardHover,
      divider: divider ?? this.divider,
    );
  }

  @override
  ThemeExtension<CustomColorsExtension> lerp(
    ThemeExtension<CustomColorsExtension>? other,
    double t,
  ) {
    if (other is! CustomColorsExtension) return this;

    return CustomColorsExtension(
      priorityLow: Color.lerp(priorityLow, other.priorityLow, t)!,
      priorityNormal: Color.lerp(priorityNormal, other.priorityNormal, t)!,
      priorityHigh: Color.lerp(priorityHigh, other.priorityHigh, t)!,
      statusTodo: Color.lerp(statusTodo, other.statusTodo, t)!,
      statusInProgress: Color.lerp(
        statusInProgress,
        other.statusInProgress,
        t,
      )!,
      statusDone: Color.lerp(statusDone, other.statusDone, t)!,
      cardHover: Color.lerp(cardHover, other.cardHover, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
    );
  }
}

/// Card styles extension
@immutable
class CardStylesExtension extends ThemeExtension<CardStylesExtension> {
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final double elevation;
  final double elevationHover;
  final List<BoxShadow> shadow;
  final List<BoxShadow> shadowHover;

  const CardStylesExtension({
    required this.padding,
    required this.borderRadius,
    required this.elevation,
    required this.elevationHover,
    required this.shadow,
    required this.shadowHover,
  });

  /// Light theme card styles
  static const CardStylesExtension light = CardStylesExtension(
    padding: AppSpacing.paddingMD,
    borderRadius: AppRadius.card,
    elevation: AppElevation.card,
    elevationHover: AppElevation.cardHover,
    shadow: AppShadows.cardShadow,
    shadowHover: AppShadows.cardHoverShadow,
  );

  /// Dark theme card styles
  static const CardStylesExtension dark = CardStylesExtension(
    padding: AppSpacing.paddingMD,
    borderRadius: AppRadius.card,
    elevation: AppElevation.card,
    elevationHover: AppElevation.cardHover,
    shadow: AppShadows.cardShadowDark,
    shadowHover: AppShadows.cardHoverShadowDark,
  );

  @override
  ThemeExtension<CardStylesExtension> copyWith({
    EdgeInsets? padding,
    BorderRadius? borderRadius,
    double? elevation,
    double? elevationHover,
    List<BoxShadow>? shadow,
    List<BoxShadow>? shadowHover,
  }) {
    return CardStylesExtension(
      padding: padding ?? this.padding,
      borderRadius: borderRadius ?? this.borderRadius,
      elevation: elevation ?? this.elevation,
      elevationHover: elevationHover ?? this.elevationHover,
      shadow: shadow ?? this.shadow,
      shadowHover: shadowHover ?? this.shadowHover,
    );
  }

  @override
  ThemeExtension<CardStylesExtension> lerp(
    ThemeExtension<CardStylesExtension>? other,
    double t,
  ) {
    if (other is! CardStylesExtension) return this;

    return CardStylesExtension(
      padding: EdgeInsets.lerp(padding, other.padding, t)!,
      borderRadius: BorderRadius.lerp(borderRadius, other.borderRadius, t)!,
      elevation: lerpDouble(elevation, other.elevation, t),
      elevationHover: lerpDouble(elevationHover, other.elevationHover, t),
      shadow: t < 0.5 ? shadow : other.shadow,
      shadowHover: t < 0.5 ? shadowHover : other.shadowHover,
    );
  }

  double lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }
}

/// Button styles extension
@immutable
class ButtonStylesExtension extends ThemeExtension<ButtonStylesExtension> {
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final double minHeight;
  final TextStyle textStyle;

  const ButtonStylesExtension({
    required this.padding,
    required this.borderRadius,
    required this.minHeight,
    required this.textStyle,
  });

  static const ButtonStylesExtension light = ButtonStylesExtension(
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    borderRadius: AppRadius.button,
    minHeight: 48,
    textStyle: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    ),
  );

  static const ButtonStylesExtension dark = ButtonStylesExtension(
    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    borderRadius: AppRadius.button,
    minHeight: 48,
    textStyle: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    ),
  );

  @override
  ThemeExtension<ButtonStylesExtension> copyWith({
    EdgeInsets? padding,
    BorderRadius? borderRadius,
    double? minHeight,
    TextStyle? textStyle,
  }) {
    return ButtonStylesExtension(
      padding: padding ?? this.padding,
      borderRadius: borderRadius ?? this.borderRadius,
      minHeight: minHeight ?? this.minHeight,
      textStyle: textStyle ?? this.textStyle,
    );
  }

  @override
  ThemeExtension<ButtonStylesExtension> lerp(
    ThemeExtension<ButtonStylesExtension>? other,
    double t,
  ) {
    if (other is! ButtonStylesExtension) return this;

    return ButtonStylesExtension(
      padding: EdgeInsets.lerp(padding, other.padding, t)!,
      borderRadius: BorderRadius.lerp(borderRadius, other.borderRadius, t)!,
      minHeight: lerpDouble(minHeight, other.minHeight, t),
      textStyle: TextStyle.lerp(textStyle, other.textStyle, t)!,
    );
  }

  double lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }
}

/// Extension helper to access custom theme extensions
extension CustomThemeExtensions on ThemeData {
  /// Get custom colors extension
  CustomColorsExtension get customColors {
    return extension<CustomColorsExtension>() ?? CustomColorsExtension.light;
  }

  /// Get card styles extension
  CardStylesExtension get cardStyles {
    return extension<CardStylesExtension>() ?? CardStylesExtension.light;
  }

  /// Get button styles extension
  ButtonStylesExtension get buttonStyles {
    return extension<ButtonStylesExtension>() ?? ButtonStylesExtension.light;
  }
}
