import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// TekTech StatusBadge Component
/// 
/// Displays task status as a colored badge with icon
/// - Color-coded based on status (todo/in_progress/done)
/// - Consistent sizing and styling
/// - Optional icon display
class StatusBadge extends StatelessWidget {
  final TaskStatus status;
  final bool showIcon;
  final double? fontSize;

  const StatusBadge({
    Key? key,
    required this.status,
    this.showIcon = true,
    this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = _getStatusConfig(status);

    return Semantics(
      label: 'Görev durumu: ${config.label}',
      readOnly: true,
      child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: config.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              config.icon,
              size: fontSize ?? 14,
              color: config.color,
            ),
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

  _StatusConfig _getStatusConfig(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return _StatusConfig(
          color: const Color(0xFF6B7280), // Gray
          icon: Icons.radio_button_unchecked,
          label: 'Yapılacak',
        );
      case TaskStatus.inProgress:
        return _StatusConfig(
          color: const Color(0xFF3B82F6), // Blue
          icon: Icons.autorenew,
          label: 'Devam Ediyor',
        );
      case TaskStatus.done:
        return _StatusConfig(
          color: const Color(0xFF10B981), // Green
          icon: Icons.check_circle_outline,
          label: 'Tamamlandı',
        );
    }
  }
}

class _StatusConfig {
  final Color color;
  final IconData icon;
  final String label;

  _StatusConfig({
    required this.color,
    required this.icon,
    required this.label,
  });
}
