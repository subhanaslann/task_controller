import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../utils/constants.dart';

/// TekTech PriorityBadge Component - WhatsApp Inspired
///
/// Displays task priority as a colored badge with icon
/// - Color-coded based on priority (low/normal/high)
/// - Localized labels (TR/EN)
/// - Consistent sizing and styling
/// - Optional icon display
/// - Uses AppColors for theme consistency
class PriorityBadge extends StatelessWidget {
  final Priority priority;
  final bool showIcon;
  final double? fontSize;

  const PriorityBadge({
    super.key,
    required this.priority,
    this.showIcon = true,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final config = _getPriorityConfig(priority, l10n);

    return Semantics(
      label: 'Öncelik: ${config.label}',
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

  _PriorityConfig _getPriorityConfig(Priority priority, AppLocalizations l10n) {
    switch (priority) {
      case Priority.low:
        return _PriorityConfig(
          color: AppColors.priorityLow,  // Blue
          icon: Icons.arrow_downward,
          label: l10n.priorityLow,
        );
      case Priority.normal:
        return _PriorityConfig(
          color: AppColors.priorityNormal,  // Amber
          icon: Icons.remove,
          label: l10n.priorityNormal,
        );
      case Priority.high:
        return _PriorityConfig(
          color: AppColors.priorityHigh,  // Red
          icon: Icons.arrow_upward,
          label: l10n.priorityHigh,
        );
    }
  }
}

class _PriorityConfig {
  final Color color;
  final IconData icon;
  final String label;

  _PriorityConfig({
    required this.color,
    required this.icon,
    required this.label,
  });
}
