import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../../../core/widgets/task_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/loading_placeholder.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/providers/providers.dart';
import '../../../core/utils/constants.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/task.dart';
import '../../../l10n/app_localizations.dart';

final myActiveTasksProvider = FutureProvider.autoDispose<List<Task>>((
  ref,
) async {
  final taskRepo = ref.watch(taskRepositoryProvider);
  return await taskRepo.getMyActiveTasks();
});

class MyActiveTasksScreen extends ConsumerStatefulWidget {
  const MyActiveTasksScreen({super.key});

  @override
  ConsumerState<MyActiveTasksScreen> createState() =>
      _MyActiveTasksScreenState();
}

class _MyActiveTasksScreenState extends ConsumerState<MyActiveTasksScreen> {
  String _selectedFilter = 'all'; // all, high, overdue

  Future<void> _refreshTasks() async {
    ref.invalidate(myActiveTasksProvider);
  }

  Future<void> _updateTaskStatus(String taskId, TaskStatus newStatus) async {
    try {
      final taskRepo = ref.read(taskRepositoryProvider);
      await taskRepo.updateTaskStatus(taskId, newStatus);

      if (mounted) {
        // Status updates are usually optimistic or quick, so we just refresh
        _refreshTasks();
      }
    } catch (e) {
      if (mounted && context.mounted) {
        AppSnackbar.showError(
          context: context,
          message: 'Failed to update task: $e',
        );
      }
    }
  }

  Future<void> _deleteTask(String taskId) async {
    try {
      final taskRepo = ref.read(taskRepositoryProvider);
      await taskRepo.deleteTask(taskId);

      if (mounted && context.mounted) {
        AppSnackbar.showSuccess(context: context, message: 'Task deleted');
        _refreshTasks();
      }
    } catch (e) {
      if (mounted && context.mounted) {
        AppSnackbar.showError(
          context: context,
          message: 'Failed to delete task: $e',
        );
      }
    }
  }

  List<Task> _filterTasks(List<Task> tasks) {
    switch (_selectedFilter) {
      case 'high':
        return tasks.where((t) => t.priority == Priority.high).toList();
      case 'overdue':
        final now = DateTime.now();
        return tasks.where((t) {
          if (t.dueDate == null) return false;
          try {
            // Simplified date parsing for demo
            // In real app, use DateTime.parse(t.dueDate!)
            return DateTime.parse(t.dueDate!).isBefore(now);
          } catch (_) {
            return false;
          }
        }).toList();
      case 'all':
      default:
        return tasks;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(myActiveTasksProvider);
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        // Filter Bar
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', 'all'),
                const Gap(8),
                _buildFilterChip('High Priority', 'high'),
                const Gap(8),
                _buildFilterChip('Overdue', 'overdue'),
              ],
            ),
          ),
        ),

        // Task List
        Expanded(
          child: tasksAsync.when(
            data: (tasks) {
              final filteredTasks = _filterTasks(tasks);

              return RefreshIndicator(
                onRefresh: _refreshTasks,
                color: AppColors.primary,
                child: filteredTasks.isEmpty
                    ? AppEmptyState(
                        icon: Icons.task_alt,
                        title: l10n?.emptyTasksTitle ?? 'No Active Tasks',
                        subtitle: _selectedFilter != 'all'
                            ? 'Try changing filters'
                            : (l10n?.emptyTasksMessage ??
                                  'You don\'t have any active tasks.'),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        itemCount: filteredTasks.length,
                        separatorBuilder: (context, index) => const Gap(8),
                        itemBuilder: (context, index) {
                          final task = filteredTasks[index];
                          return Dismissible(
                            key: Key(task.id),
                            direction: DismissDirection.horizontal,
                            confirmDismiss: (direction) async {
                              if (direction == DismissDirection.startToEnd) {
                                // Swipe Right -> Complete
                                await _updateTaskStatus(
                                  task.id,
                                  TaskStatus.done,
                                );
                                return true;
                              } else {
                                // Swipe Left -> Delete
                                final confirm =
                                    await ConfirmationDialog.showDelete(
                                      context: context,
                                      itemName: task.title,
                                    );
                                if (confirm) {
                                  await _deleteTask(task.id);
                                  return true;
                                }
                                return false;
                              }
                            },
                            background: Container(
                              color: AppColors.success,
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.only(left: AppSpacing.lg),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                              ),
                            ),
                            secondaryBackground: Container(
                              color: AppColors.error,
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.only(right: AppSpacing.lg),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            child:
                                TaskCard(
                                      task: task,
                                      showNote: true,
                                      canEdit: true,
                                      onStatusChange: (newStatus) {
                                        if (newStatus != null) {
                                          _updateTaskStatus(task.id, newStatus);
                                        }
                                      },
                                      onTap: () =>
                                          _showTaskDetails(context, task),
                                    )
                                    .animate()
                                    .fadeIn(delay: (50 * index).ms)
                                    .slideX(begin: 0.1, end: 0),
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
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppColors.error,
                  ),
                  const Gap(16),
                  Text(
                    'Error loading tasks',
                    style: TextStyle(color: AppColors.error),
                  ),
                  TextButton(
                    onPressed: _refreshTasks,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      checkmarkColor: isSelected ? AppColors.white : null,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected
            ? AppColors.white
            : Theme.of(context).colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.borderRadiusSM,
        side: BorderSide(
          color: isSelected ? AppColors.primary : Colors.transparent,
        ),
      ),
      showCheckmark: false,
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
              if (task.topic != null) ...[
                _buildDetailRow(Icons.topic, 'Topic', task.topic!.title),
                const Gap(12),
              ],
              if (task.note != null && task.note!.isNotEmpty) ...[
                _buildDetailRow(Icons.description, 'Note', task.note!),
                const Gap(12),
              ],
              _buildDetailRow(Icons.flag, 'Priority', task.priority.value),
              const Gap(12),
              _buildDetailRow(
                Icons.calendar_today,
                'Due Date',
                task.dueDate ?? 'No date',
              ),
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
