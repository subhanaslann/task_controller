import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// TekTech AppCheckbox Component
///
/// Consistent checkbox with label
/// - WCAG AA minimum touch target
/// - Semantic accessibility
class AppCheckbox extends StatelessWidget {
  final bool checked;
  final ValueChanged<bool> onChanged;
  final String label;
  final bool enabled;

  const AppCheckbox({
    super.key,
    required this.checked,
    required this.onChanged,
    required this.label,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? () => onChanged(!checked) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: Checkbox(
                value: checked,
                onChanged: enabled
                    ? (value) => onChanged(value ?? false)
                    : null,
                activeColor: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: enabled
                      ? AppTheme.textPrimaryColor
                      : AppTheme.textDisabledColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// TekTech AppSwitch Component
///
/// Consistent switch with label and optional description
/// - WCAG AA minimum touch target
/// - Semantic accessibility
class AppSwitch extends StatelessWidget {
  final bool checked;
  final ValueChanged<bool> onChanged;
  final String label;
  final String? description;
  final bool enabled;

  const AppSwitch({
    super.key,
    required this.checked,
    required this.onChanged,
    required this.label,
    this.description,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? () => onChanged(!checked) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing16,
          vertical: 8,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: enabled
                          ? AppTheme.textPrimaryColor
                          : AppTheme.textDisabledColor,
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      description!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 48,
              height: 48,
              child: Center(
                child: Switch(
                  value: checked,
                  onChanged: enabled ? onChanged : null,
                  activeTrackColor: AppTheme.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
