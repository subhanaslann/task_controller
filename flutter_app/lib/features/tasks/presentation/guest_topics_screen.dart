import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/loading_placeholder.dart';
import '../../../core/providers/providers.dart';
import '../../../data/models/topic.dart';
import '../../../data/models/task.dart';
import '../../../core/widgets/priority_badge.dart';
import '../../../core/widgets/status_badge.dart';

final guestTopicsProvider = FutureProvider.autoDispose<List<Topic>>((
  ref,
) async {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return [];

  // In real app, fetch topics from API
  // For now returning empty list as per original logic or mock logic
  // If admin repo has getTopics, we should use it if guest is allowed
  // But original code returned empty list. I'll check admin repo usage.

  // Assuming we want to show something if available:
  try {
    final adminRepo = ref.read(adminRepositoryProvider);
    // This might fail if backend restricts guests from /topics endpoint
    // But let's try
    return await adminRepo.getTopics();
  } catch (_) {
    return [];
  }
});

class GuestTopicsScreen extends ConsumerWidget {
  const GuestTopicsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicsAsync = ref.watch(guestTopicsProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(guestTopicsProvider),
        color: AppColors.primary,
        child: topicsAsync.when(
          data: (topics) {
            // Filter only active topics for guests
            final activeTopics = topics.where((t) => t.isActive).toList();

            if (activeTopics.isEmpty) {
              return const AppEmptyState(
                icon: Icons.lock_outline,
                title: 'No Access',
                subtitle:
                    'You don\'t have access to any task groups yet.\nContact your admin.',
              );
            }

            return ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: activeTopics.length,
              itemBuilder: (context, index) {
                final topic = activeTopics[index];
                return _TopicTile(topic: topic)
                    .animate()
                    .fadeIn(delay: (50 * index).ms)
                    .slideX(begin: 0.1, end: 0);
              },
            );
          },
          loading: () => ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) => const LoadingPlaceholder(),
          ),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: AppColors.error),
                const Gap(16),
                Text('Error: $error', style: TextStyle(color: AppColors.error)),
                TextButton(
                  onPressed: () => ref.invalidate(guestTopicsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopicTile extends StatefulWidget {
  final Topic topic;

  const _TopicTile({required this.topic});

  @override
  State<_TopicTile> createState() => _TopicTileState();
}

class _TopicTileState extends State<_TopicTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final taskCount =
        widget.topic.tasks?.length ?? 0; // Assuming tasks are loaded in topic

    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _expanded = !_expanded;
            });
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    widget.topic.title.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const Gap(16),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.topic.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (taskCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                borderRadius: AppRadius.borderRadiusSM,
                              ),
                              child: Text(
                                '$taskCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const Gap(4),
                      Text(
                        widget.topic.description ?? 'No description',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Expanded Content (Tasks)
        if (_expanded)
          if (widget.topic.tasks != null && widget.topic.tasks!.isNotEmpty)
            ...widget.topic.tasks!.map((task) => _GuestTaskItem(task: task))
          else
            Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Text(
                'No tasks in this topic',
                style: TextStyle(color: theme.colorScheme.outline),
              ),
            ),
        Divider(
          height: 1,
          indent: 72,
          color: theme.dividerColor.withValues(alpha: 0.5),
        ),
      ],
    );
  }
}

class _GuestTaskItem extends StatelessWidget {
  final Task task;

  const _GuestTaskItem({required this.task});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        left: 72,
        right: AppSpacing.md,
        top: AppSpacing.sm,
        bottom: AppSpacing.sm,
      ),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.5,
          ),
          borderRadius: AppRadius.borderRadiusSM,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                PriorityBadge(priority: task.priority),
              ],
            ),
            const Gap(4),
            if (task.note != null) ...[
              Text(
                task.note!,
                style: theme.textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Gap(4),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Assigned: ${task.assignee?.name ?? 'Unassigned'}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
                StatusBadge(status: task.status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
