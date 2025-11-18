import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Section Header - For grouping content
///
/// Professional section header with title and optional action button
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? action;

  const SectionHeader({super.key, required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing16,
        vertical: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

/// App Divider - Consistent divider styling
///
/// Professional divider with consistent color
class AppDivider extends StatelessWidget {
  final double? height;
  final double? thickness;
  final Color? color;

  const AppDivider({super.key, this.height, this.thickness, this.color});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: height,
      thickness: thickness ?? 1,
      color: color ?? Colors.grey.shade300,
    );
  }
}
