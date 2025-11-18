import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// TekTech LoadingOverlay - WhatsApp-Style Fullscreen Loading
///
/// Features:
/// - Fullscreen semi-transparent overlay
/// - WhatsApp-style circular indicator
/// - Optional loading message
/// - Prevents user interaction during loading
class LoadingOverlay extends StatelessWidget {
  final String? message;
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({
    super.key,
    required this.child,
    this.isLoading = false,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: AppColors.black.withValues(alpha: 0.5),
            child: Center(
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                      if (message != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          message!,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Show loading overlay with message
  static Future<T> show<T>({
    required BuildContext context,
    required Future<T> Function() future,
    String? message,
  }) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Center(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      message,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );

    try {
      // Execute future
      final result = await future();
      // Close dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      return result;
    } catch (e) {
      // Close dialog on error
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      rethrow;
    }
  }
}

/// Extension for easy access
extension LoadingOverlayExtension on BuildContext {
  Future<T> showLoading<T>({
    required Future<T> Function() future,
    String? message,
  }) {
    return LoadingOverlay.show(
      context: this,
      future: future,
      message: message,
    );
  }
}
