import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../utils/constants.dart';

/// TekTech StatusBadge Component - WhatsApp Inspired
///
/// Displays task status as a colored badge with icon
/// - Color-coded based on status (todo/in_progress/done)
/// - Localized labels (TR/EN)
/// - WhatsApp teal for in_progress, green for done
/// - Consistent sizing and styling
/// - Optional icon display
class StatusBadge extends StatelessWidget {
  final TaskStatus status;
  final bool showIcon;
  final double? fontSize;

  const StatusBadge({
    super.key,
    required this.status,
    this.showIcon = true,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final config = _getStatusConfig(status, l10n);

    return Semantics(
      label: 'Görev durumu: ${config.label}',
      readOnly: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: config.color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: config.color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              Icon(config.icon, size: fontSize ?? 14, color: config.color),
              const SizedBox(width: 4),
            ],
            Text(
              config.label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: config.color,
                fontWeight: FontWeight.w600,
                fontSize: fontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _StatusConfig _getStatusConfig(TaskStatus status, AppLocalizations l10n) {
    switch (status) {
      case TaskStatus.todo:
        return _StatusConfig(
          color: AppColors.statusTodo, // Gray
          icon: Icons.radio_button_unchecked,
          label: l10n.statusTodo,
        );
      case TaskStatus.inProgress:
        return _StatusConfig(
          color: AppColors.statusInProgress, // WhatsApp Teal
          icon: Icons.autorenew,
          label: l10n.statusInProgress,
        );
      case TaskStatus.done:
        return _StatusConfig(
          color: AppColors.statusDone, // WhatsApp Green
          icon: Icons.check_circle_outline,
          label: l10n.statusDone,
        );
    }
  }
}

class _StatusConfig {
  final Color color;
  final IconData icon;
  final String label;

  _StatusConfig({required this.color, required this.icon, required this.label});
}
