import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'app_button.dart';

class LoadingPlaceholder extends StatefulWidget {
  const LoadingPlaceholder({super.key});

  @override
  State<LoadingPlaceholder> createState() => _LoadingPlaceholderState();
}

class _LoadingPlaceholderState extends State<LoadingPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(
      begin: -1,
      end: 2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row
                Row(
                  children: [
                    _ShimmerBox(
                      width: 80,
                      height: 20,
                      shimmerPosition: _animation.value,
                    ),
                    const Spacer(),
                    _ShimmerBox(
                      width: 60,
                      height: 20,
                      shimmerPosition: _animation.value,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Title
                _ShimmerBox(
                  width: double.infinity,
                  height: 20,
                  shimmerPosition: _animation.value,
                ),
                const SizedBox(height: 8),
                _ShimmerBox(
                  width: 200,
                  height: 16,
                  shimmerPosition: _animation.value,
                ),
                const SizedBox(height: 16),
                // Bottom row
                Row(
                  children: [
                    _ShimmerBox(
                      width: 60,
                      height: 20,
                      shimmerPosition: _animation.value,
                    ),
                    const Spacer(),
                    _ShimmerBox(
                      width: 28,
                      height: 28,
                      shimmerPosition: _animation.value,
                      isCircle: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double shimmerPosition;
  final bool isCircle;

  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.shimmerPosition,
    this.isCircle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: isCircle
            ? BorderRadius.circular(height / 2)
            : BorderRadius.circular(4),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Colors.grey[300]!, Colors.grey[200]!, Colors.grey[300]!],
          stops: [
            (shimmerPosition - 1).clamp(0.0, 1.0),
            shimmerPosition.clamp(0.0, 1.0),
            (shimmerPosition + 1).clamp(0.0, 1.0),
          ],
        ),
      ),
    );
  }
}

/// Loading State - Full screen loading indicator
class LoadingState extends StatelessWidget {
  const LoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

/// Error State - Full screen error with retry button
class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorState({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppTheme.errorColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'Tekrar Dene',
              onPressed: onRetry,
              variant: ButtonVariant.primary,
            ),
          ],
        ),
      ),
    );
  }
}
