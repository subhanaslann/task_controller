import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/task_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_placeholder.dart';
import '../../../core/providers/providers.dart';
import '../../../core/utils/constants.dart';
import '../../../data/models/task.dart';

final myActiveTasksProvider = FutureProvider.autoDispose<List<Task>>((
  ref,
) async {
  final taskRepo = ref.watch(taskRepositoryProvider);
  return await taskRepo.getMyActiveTasks();
});

class MyActiveTasksScreen extends ConsumerStatefulWidget {
  const MyActiveTasksScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MyActiveTasksScreen> createState() =>
      _MyActiveTasksScreenState();
}

class _MyActiveTasksScreenState extends ConsumerState<MyActiveTasksScreen> {
  Future<void> _refreshTasks() async {
    ref.invalidate(myActiveTasksProvider);
  }

  Future<void> _updateTaskStatus(String taskId, TaskStatus newStatus) async {
    try {
      final taskRepo = ref.read(taskRepositoryProvider);
      await taskRepo.updateTaskStatus(taskId, newStatus);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Task status updated!')));
        _refreshTasks();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update task: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(myActiveTasksProvider);

    return tasksAsync.when(
      data: (tasks) {
        return RefreshIndicator(
          onRefresh: _refreshTasks,
          child: _buildTasksList(tasks),
        );
      },
      loading: () => ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: 3,
        itemBuilder: (context, index) => const LoadingPlaceholder(),
      ),
      error: (error, stack) => _buildError(error),
    );
  }

  Widget _buildTasksList(List<Task> tasks) {
    return tasks.isEmpty
        ? const EmptyState(
            icon: Icons.task_alt,
            title: 'No Active Tasks',
            message: 'You don\'t have any active tasks at the moment.',
          )
        : ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: tasks.length,
            separatorBuilder: (context, index) => const SizedBox(height: 0),
            itemBuilder: (context, index) {
              final task = tasks[index];
              return TaskCard(
                task: task,
                showNote: true,
                canEdit: true,
                onStatusChange: (newStatus) {
                  if (newStatus != null) {
                    _updateTaskStatus(task.id, newStatus);
                  }
                },
                onTap: () => _showTaskDetails(context, task),
              );
            },
          );
  }

  Widget _buildError(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 60, color: Colors.red),
          const Gap(16),
          Text('Error: $error'),
          const Gap(16),
          ElevatedButton(onPressed: _refreshTasks, child: const Text('Retry')),
        ],
      ),
    );
  }

  void _showTaskDetails(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task.topic != null) ...[
                Text(
                  'Topic: ${task.topic!.title}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Gap(8),
              ],
              if (task.note != null) ...[
                const Text(
                  'Note:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(task.note!),
                const Gap(8),
              ],
              Text('Status: ${task.status.value}'),
              const Gap(4),
              Text('Priority: ${task.priority.value}'),
              const Gap(4),
              if (task.assignee != null)
                Text('Assigned to: ${task.assignee!.name}'),
              if (task.dueDate != null) ...[
                const Gap(4),
                Text('Due: ${task.dueDate}'),
              ],
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
}
