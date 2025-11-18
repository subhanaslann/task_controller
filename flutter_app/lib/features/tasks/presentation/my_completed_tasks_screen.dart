import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../core/widgets/task_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_placeholder.dart';
import '../../../core/providers/providers.dart';
import '../../../data/models/task.dart';

final myCompletedTasksProvider = FutureProvider.autoDispose<List<Task>>((
  ref,
) async {
  final taskRepo = ref.watch(taskRepositoryProvider);
  return await taskRepo.getMyCompletedTasks();
});

class MyCompletedTasksScreen extends ConsumerWidget {
  const MyCompletedTasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(myCompletedTasksProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(myCompletedTasksProvider);
      },
      child: tasksAsync.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return const EmptyState(
              icon: Icons.check_circle_outline,
              title: 'No Completed Tasks',
              message: 'You haven\'t completed any tasks yet.',
            );
          }

          return ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: tasks.length,
            separatorBuilder: (context, index) => const SizedBox(height: 0),
            itemBuilder: (context, index) {
              final task = tasks[index];
              return TaskCard(
                task: task,
                showNote: true,
                canEdit: false, // Completed tasks are read-only
                onTap: () => _showTaskDetails(context, task),
              );
            },
          );
        },
        loading: () => ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: 3,
          itemBuilder: (context, index) => const LoadingPlaceholder(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 60, color: Colors.red),
              const Gap(16),
              Text('Error: $error'),
              const Gap(16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(myCompletedTasksProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
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
              if (task.completedAt != null) ...[
                const Gap(4),
                Text('Completed: ${task.completedAt}'),
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
