import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// TekTech Snackbar Types
enum SnackbarType { success, error, warning, info }

/// TekTech AppSnackbar
///
/// Consistent notification/toast component
/// - Success (green)
/// - Error (red)
/// - Warning (amber)
/// - Info (cyan)
class AppSnackbar {
  /// Show a custom snackbar
  static void show({
    required BuildContext context,
    required String message,
    SnackbarType type = SnackbarType.info,
    String? actionLabel,
    VoidCallback? onActionPressed,
    Duration duration = const Duration(seconds: 4),
  }) {
    final (icon, containerColor, contentColor) = _getColors(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: contentColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: contentColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: containerColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius12),
        ),
        action: actionLabel != null && onActionPressed != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: contentColor,
                onPressed: onActionPressed,
              )
            : null,
        duration: duration,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Show success snackbar
  static void showSuccess({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context: context,
      message: message,
      type: SnackbarType.success,
      duration: duration,
    );
  }

  /// Show error snackbar
  static void showError({
    required BuildContext context,
    required String message,
    String? actionLabel,
    VoidCallback? onActionPressed,
    Duration duration = const Duration(seconds: 5),
  }) {
    show(
      context: context,
      message: message,
      type: SnackbarType.error,
      actionLabel: actionLabel ?? 'Tekrar Dene',
      onActionPressed: onActionPressed,
      duration: duration,
    );
  }

  /// Show warning snackbar
  static void showWarning({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context: context,
      message: message,
      type: SnackbarType.warning,
      duration: duration,
    );
  }

  /// Show info snackbar
  static void showInfo({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context: context,
      message: message,
      type: SnackbarType.info,
      duration: duration,
    );
  }

  /// Get colors for snackbar type
  static (IconData, Color, Color) _getColors(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return (Icons.check_circle, AppTheme.secondaryColor, Colors.white);
      case SnackbarType.error:
        return (Icons.error, AppTheme.errorColor, Colors.white);
      case SnackbarType.warning:
        return (
          Icons.warning_amber_rounded,
          AppTheme.warningColor,
          Colors.white,
        );
      case SnackbarType.info:
        return (Icons.info, AppTheme.infoColor, Colors.white);
    }
  }
}
