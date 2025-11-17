import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// TekTech PriorityBadge Component
/// 
/// Displays task priority as a colored badge with icon
/// - Color-coded based on priority (low/normal/high)
/// - Consistent sizing and styling
/// - Optional icon display
class PriorityBadge extends StatelessWidget {
  final Priority priority;
  final bool showIcon;
  final double? fontSize;

  const PriorityBadge({
    Key? key,
    required this.priority,
    this.showIcon = true,
    this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = _getPriorityConfig(priority);

    return Semantics(
      label: 'Öncelik: ${config.label}',
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

  _PriorityConfig _getPriorityConfig(Priority priority) {
    switch (priority) {
      case Priority.low:
        return _PriorityConfig(
          color: const Color(0xFF6B7280), // Gray
          icon: Icons.arrow_downward,
          label: 'LOW',
        );
      case Priority.normal:
        return _PriorityConfig(
          color: const Color(0xFF3B82F6), // Blue
          icon: Icons.remove,
          label: 'NORMAL',
        );
      case Priority.high:
        return _PriorityConfig(
          color: const Color(0xFFEF4444), // Red
          icon: Icons.arrow_upward,
          label: 'HIGH',
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
