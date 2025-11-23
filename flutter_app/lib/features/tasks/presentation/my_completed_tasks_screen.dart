import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/task_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/loading_placeholder.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/providers/providers.dart';
import '../../../core/utils/constants.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/task.dart';
import '../../../l10n/app_localizations.dart';

final myCompletedTasksProvider = FutureProvider.autoDispose<List<Task>>((
  ref,
) async {
  final taskRepo = ref.watch(taskRepositoryProvider);
  final tasks = await taskRepo.getMyCompletedTasks();
  // Sort by completed date descending
  tasks.sort((a, b) {
    final dateA = a.completedAt != null
        ? DateTime.tryParse(a.completedAt!)
        : null;
    final dateB = b.completedAt != null
        ? DateTime.tryParse(b.completedAt!)
        : null;
    if (dateA == null) return 1;
    if (dateB == null) return -1;
    return dateB.compareTo(dateA);
  });
  return tasks;
});

class MyCompletedTasksScreen extends ConsumerStatefulWidget {
  const MyCompletedTasksScreen({super.key});

  @override
  ConsumerState<MyCompletedTasksScreen> createState() =>
      _MyCompletedTasksScreenState();
}

class _MyCompletedTasksScreenState
    extends ConsumerState<MyCompletedTasksScreen> {
  Future<void> _undoTask(Task task) async {
    try {
      final taskRepo = ref.read(taskRepositoryProvider);
      await taskRepo.updateTaskStatus(task.id, TaskStatus.todo);

      if (mounted && context.mounted) {
        ref.invalidate(myCompletedTasksProvider);
        AppSnackbar.showInfo(
          context: context,
          message: 'Task moved back to Active',
        );
      }
    } catch (e) {
      if (mounted && context.mounted) {
        AppSnackbar.showError(context: context, message: 'Failed to undo: $e');
      }
    }
  }

  Map<String, List<Task>> _groupTasksByDate(
    List<Task> tasks,
    AppLocalizations? l10n,
  ) {
    final grouped = <String, List<Task>>{};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (var task in tasks) {
      if (task.completedAt == null) continue;

      final completedDate = DateTime.tryParse(task.completedAt!);
      if (completedDate == null) continue;

      final dateOnly = DateTime(
        completedDate.year,
        completedDate.month,
        completedDate.day,
      );

      String key;
      if (dateOnly == today) {
        key = l10n?.today ?? 'Today';
      } else if (dateOnly == yesterday) {
        key = l10n?.yesterday ?? 'Yesterday';
      } else {
        key = DateFormat('MMMM d, y').format(dateOnly);
      }

      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(task);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(myCompletedTasksProvider);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return tasksAsync.when(
      data: (tasks) {
        if (tasks.isEmpty) {
          return AppEmptyState(
            icon: Icons.check_circle_outline,
            title: l10n?.completedTasks ?? 'Completed Tasks',
            subtitle: 'You haven\'t completed any tasks yet.',
          );
        }

        final groupedTasks = _groupTasksByDate(tasks, l10n);

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(myCompletedTasksProvider),
          color: AppColors.primary,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            itemCount: groupedTasks.length,
            itemBuilder: (context, index) {
              final key = groupedTasks.keys.elementAt(index);
              final groupTasks = groupedTasks[key]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    child: Text(
                      key,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...groupTasks.map(
                    (task) => Dismissible(
                      key: Key(task.id),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (direction) async {
                        await _undoTask(task);
                        return true;
                      },
                      background: Container(
                        color: AppColors.info,
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: AppSpacing.lg),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: const [
                            Text(
                              'Undo',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Gap(8),
                            Icon(Icons.undo, color: Colors.white),
                          ],
                        ),
                      ),
                      child:
                          TaskCard(
                                task: task,
                                showNote: true,
                                canEdit: false,
                                onTap: () => _showTaskDetails(context, task),
                              )
                              .animate()
                              .fadeIn(duration: 300.ms)
                              .slideX(begin: 0.05, end: 0),
                    ),
                  ),
                  const Gap(16),
                ],
              );
            },
          ),
        );
      },
      loading: () => ListView.builder(
        padding: EdgeInsets.all(AppSpacing.md),
        itemCount: 3,
        itemBuilder: (context, index) => const LoadingPlaceholder(),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const Gap(16),
            Text('Error: $error', style: TextStyle(color: AppColors.error)),
            TextButton(
              onPressed: () => ref.invalidate(myCompletedTasksProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTaskDetails(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task.title),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.dialog),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task.topic != null && task.topic!.title != null) ...[
                _buildDetailRow(Icons.topic, 'Topic', task.topic!.title!),
                const Gap(12),
              ],
              if (task.note != null && task.note!.isNotEmpty) ...[
                _buildDetailRow(Icons.description, 'Note', task.note!),
                const Gap(12),
              ],
              _buildDetailRow(
                Icons.check_circle,
                'Completed',
                task.completedAt ?? 'N/A',
              ),
              const Gap(12),
              _buildDetailRow(Icons.flag, 'Priority', task.priority.value),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.outline,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Gap(2),
              Text(value, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }
}
