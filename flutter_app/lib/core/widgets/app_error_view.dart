import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// TekTech AppErrorView Component
/// 
/// Generic error display widget
/// - Error icon
/// - Error message
/// - Optional retry button
/// - Consistent error styling
class AppErrorView extends StatelessWidget {
  final String message;
  final String? details;
  final VoidCallback? onRetry;
  final IconData icon;
  final double iconSize;

  const AppErrorView({
    Key? key,
    required this.message,
    this.details,
    this.onRetry,
    this.icon = Icons.error_outline,
    this.iconSize = 64,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: AppTheme.spacing16),
            Text(
              message,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            if (details != null) ...[
              const SizedBox(height: AppTheme.spacing8),
              Text(
                details!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: AppTheme.spacing24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Tekrar Dene'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
