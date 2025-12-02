import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../exceptions/app_exception.dart';

/// TekTech ErrorHandler
/// 
/// Global error handling and user notification
/// - Extracts AppException from errors
/// - Shows user-friendly snackbars
/// - Consistent error display across app
class ErrorHandler {
  /// Show error as snackbar
  static void showError(BuildContext context, dynamic error, {StackTrace? stackTrace}) {
    final appException = _extractAppException(error);
    
    _showSnackBar(
      context,
      message: appException.message,
      details: appException.details,
      isError: true,
    );
  }

  /// Show success message
  static void showSuccess(BuildContext context, String message) {
    _showSnackBar(
      context,
      message: message,
      isError: false,
    );
  }

  /// Show info message
  static void showInfo(BuildContext context, String message, {String? details}) {
    _showSnackBar(
      context,
      message: message,
      details: details,
      isError: false,
    );
  }

  /// Show error dialog with details
  static Future<void> showErrorDialog(
    BuildContext context,
    dynamic error, {
    String? title,
    VoidCallback? onRetry,
  }) async {
    final appException = _extractAppException(error);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title ?? 'Hata'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(appException.message),
            if (appException.details != null) ...[
              const SizedBox(height: 8),
              Text(
                appException.details!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ],
        ),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('Tekrar Dene'),
            ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  /// Extract AppException from various error types
  static AppException _extractAppException(dynamic error) {
    if (error is AppException) {
      return error;
    }

    if (error is DioException) {
      // Check if error object is AppException (set by error interceptor)
      if (error.error is AppException) {
        return error.error as AppException;
      }
      // Fallback: create generic error
      return UnknownException(
        message: error.message ?? 'Beklenmeyen hata',
        details: error.response?.data?.toString(),
      );
    }

    // Generic error
    return UnknownException(
      details: error?.toString(),
    );
  }

  /// Show snackbar with consistent styling
  static void _showSnackBar(
    BuildContext context, {
    required String message,
    String? details,
    required bool isError,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isError ? Icons.error_outline : Icons.check_circle_outline,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (details != null) ...[
              const SizedBox(height: 4),
              Text(
                details,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        backgroundColor: isError ? colorScheme.error : colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: Duration(seconds: isError ? 4 : 2),
        action: SnackBarAction(
          label: 'Kapat',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
