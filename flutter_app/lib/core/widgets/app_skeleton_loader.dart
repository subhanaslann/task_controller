import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// TekTech AppSkeletonLoader Component
///
/// Skeleton loading placeholders with shimmer effect
/// - Card and list variants
/// - Animated shimmer effect
/// - Configurable count
class AppSkeletonLoader extends StatelessWidget {
  final SkeletonType type;
  final int count;

  const AppSkeletonLoader({
    super.key,
    this.type = SkeletonType.card,
    this.count = 3,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      itemCount: count,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppTheme.spacing12),
      itemBuilder: (context, index) {
        switch (type) {
          case SkeletonType.card:
            return const _SkeletonCard();
          case SkeletonType.listTile:
            return const _SkeletonListTile();
          case SkeletonType.taskCard:
            return const _SkeletonTaskCard();
        }
      },
    );
  }
}

enum SkeletonType { card, listTile, taskCard }

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ShimmerBox(
              width: double.infinity,
              height: 20,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: AppTheme.spacing12),
            _ShimmerBox(
              width: double.infinity,
              height: 16,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: AppTheme.spacing8),
            _ShimmerBox(
              width: 150,
              height: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonListTile extends StatelessWidget {
  const _SkeletonListTile();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: _ShimmerBox(
          width: 40,
          height: 40,
          borderRadius: BorderRadius.circular(20),
        ),
        title: _ShimmerBox(
          width: double.infinity,
          height: 16,
          borderRadius: BorderRadius.circular(4),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: _ShimmerBox(
            width: 200,
            height: 14,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

class _SkeletonTaskCard extends StatelessWidget {
  const _SkeletonTaskCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Row(
          children: [
            _ShimmerBox(
              width: 4,
              height: 64,
              borderRadius: BorderRadius.circular(2),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _ShimmerBox(
                        width: 80,
                        height: 20,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const Spacer(),
                      _ShimmerBox(
                        width: 60,
                        height: 20,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing8),
                  _ShimmerBox(
                    width: double.infinity,
                    height: 18,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: AppTheme.spacing12),
                  Row(
                    children: [
                      _ShimmerBox(
                        width: 60,
                        height: 20,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const Spacer(),
                      _ShimmerBox(
                        width: 32,
                        height: 32,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.borderRadius,
  });

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final baseColor = isDark
        ? theme.colorScheme.surfaceContainerHighest
        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);
    final highlightColor = isDark
        ? theme.colorScheme.surface
        : Colors.white.withValues(alpha: 0.8);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ],
            ),
          ),
        );
      },
    );
  }
}
