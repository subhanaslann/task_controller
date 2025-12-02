import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import '../theme/app_colors.dart';

/// TekTech ConfirmationDialog - WhatsApp-Style Alert
///
/// Features:
/// - Clean WhatsApp-inspired design
/// - Destructive action support
/// - Async result handling
/// - Customizable title, message, and buttons
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;
  final IconData? icon;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.isDestructive = false,
    this.icon,
  });

  /// Show confirmation dialog and return user's choice
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
    IconData? icon,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
        icon: icon,
      ),
    );
    return result ?? false;
  }

  /// Shorthand for delete confirmation
  static Future<bool> showDelete({
    required BuildContext context,
    required String itemName,
  }) {
    return show(
      context: context,
      title: 'Delete',
      message:
          'Are you sure you want to delete $itemName? This action cannot be undone.',
      confirmLabel: 'Delete',
      cancelLabel: 'Cancel',
      isDestructive: true,
      icon: Icons.delete_outline,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final confirmColor = isDestructive ? AppColors.error : AppColors.primary;

    return AlertDialog(
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.dialog),
      contentPadding: EdgeInsets.zero,
      content: Container(
        padding: EdgeInsets.all(AppSpacing.lg),
        constraints: const BoxConstraints(maxWidth: 320),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon (if provided)
            if (icon != null) ...[
              Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: confirmColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: confirmColor),
              ),
              SizedBox(height: AppSpacing.md),
            ],

            // Title
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: AppSpacing.sm),

            // Message
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: AppSpacing.lg),

            // Action buttons
            Row(
              children: [
                // Cancel button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.onSurface,
                      side: BorderSide(color: theme.colorScheme.outline),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.button,
                      ),
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    ),
                    child: Text(cancelLabel),
                  ),
                ),

                SizedBox(width: AppSpacing.sm),

                // Confirm button
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: confirmColor,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.button,
                      ),
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    ),
                    child: Text(confirmLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Extension for easy access
extension ConfirmationDialogExtension on BuildContext {
  Future<bool> showConfirmation({
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
    IconData? icon,
  }) {
    return ConfirmationDialog.show(
      context: this,
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
      isDestructive: isDestructive,
      icon: icon,
    );
  }

  Future<bool> showDeleteConfirmation(String itemName) {
    return ConfirmationDialog.showDelete(context: this, itemName: itemName);
  }
}
