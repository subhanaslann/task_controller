import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// TekTech AppLoadingIndicator Component
///
/// Consistent loading indicator across the app
/// - Circular progress indicator
/// - Optional loading message
/// - Centered layout
class AppLoadingIndicator extends StatelessWidget {
  final String? message;
  final double? size;
  final Color? color;

  const AppLoadingIndicator({super.key, this.message, this.size, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size ?? 40,
              height: size ?? 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: color ?? theme.colorScheme.primary,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: AppTheme.spacing16),
              Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
