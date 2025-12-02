import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'app_button.dart';

/// TekTech AppDialog Component
///
/// Modern dialog with consistent styling
/// - Confirm dialog (yes/no actions)
/// - Alert dialog (single action)
/// - Custom content dialog
class AppDialog extends StatelessWidget {
  final String title;
  final String? message;
  final IconData? icon;
  final String confirmText;
  final VoidCallback onConfirm;
  final String? dismissText;
  final VoidCallback onDismiss;
  final ButtonVariant confirmButtonVariant;

  const AppDialog({
    super.key,
    required this.title,
    this.message,
    this.icon,
    this.confirmText = 'Tamam',
    required this.onConfirm,
    this.dismissText = 'İptal',
    required this.onDismiss,
    this.confirmButtonVariant = ButtonVariant.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radius24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            if (icon != null) ...[
              Icon(
                icon,
                size: 48,
                color: confirmButtonVariant == ButtonVariant.destructive
                    ? AppTheme.errorColor
                    : AppTheme.primaryColor,
              ),
              const SizedBox(height: 16),
            ],
            // Title
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            // Message
            if (message != null) ...[
              const SizedBox(height: 12),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            // Actions
            Row(
              children: [
                if (dismissText != null) ...[
                  Expanded(
                    child: AppButton(
                      text: dismissText!,
                      onPressed: onDismiss,
                      variant: ButtonVariant.ghost,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: AppButton(
                    text: confirmText,
                    onPressed: () {
                      onConfirm();
                      onDismiss();
                    },
                    variant: confirmButtonVariant,
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

/// Confirmation Dialog - For destructive actions
class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onConfirm;
  final VoidCallback onDismiss;
  final String confirmText;
  final String dismissText;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    required this.onDismiss,
    this.confirmText = 'Onayla',
    this.dismissText = 'İptal',
  });

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: title,
      message: message,
      icon: Icons.warning_amber_rounded,
      confirmText: confirmText,
      onConfirm: onConfirm,
      dismissText: dismissText,
      onDismiss: onDismiss,
      confirmButtonVariant: ButtonVariant.destructive,
    );
  }
}

/// Alert Dialog - Single action, informational
class AppAlertDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onDismiss;
  final String buttonText;

  const AppAlertDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onDismiss,
    this.buttonText = 'Tamam',
  });

  @override
  Widget build(BuildContext context) {
    return AppDialog(
      title: title,
      message: message,
      confirmText: buttonText,
      onConfirm: () {},
      dismissText: null,
      onDismiss: onDismiss,
    );
  }
}

/// Custom Content Dialog - For complex content
class CustomDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final String confirmText;
  final VoidCallback onConfirm;
  final String? dismissText;
  final VoidCallback onDismiss;

  const CustomDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmText = 'Tamam',
    required this.onConfirm,
    this.dismissText = 'İptal',
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radius24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Custom content
            content,
            const SizedBox(height: 24),
            // Actions
            Row(
              children: [
                if (dismissText != null) ...[
                  Expanded(
                    child: AppButton(
                      text: dismissText!,
                      onPressed: onDismiss,
                      variant: ButtonVariant.ghost,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: AppButton(
                    text: confirmText,
                    onPressed: () {
                      onConfirm();
                      onDismiss();
                    },
                    variant: ButtonVariant.primary,
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
