import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_placeholder.dart';
import '../../../core/providers/providers.dart';
import '../../../data/models/topic.dart';
import '../../../data/models/task.dart';
import '../../../core/utils/constants.dart';

final guestTopicsProvider = FutureProvider.autoDispose<List<Topic>>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  
  // Guest kullanıcı için direkt visibleTopicIds kullan
  if (currentUser == null) {
    return [];
  }
  
  try {
    // Tüm kullanıcılar için /topics endpoint'ini kullan (otomatik filtreleme sunucu tarafında)
    final apiService = ref.watch(apiServiceProvider);
    final response = await apiService.getTopicsForUser();
    return response.topics;
  } catch (e) {
    print('DEBUG: Topics yüklenirken hata: $e');
    rethrow;
  }
});

class GuestTopicsScreen extends ConsumerWidget {
  const GuestTopicsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicsAsync = ref.watch(guestTopicsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(guestTopicsProvider);
      },
      child: topicsAsync.when(
        data: (topics) {
          if (topics.isEmpty) {
            return const EmptyState(
              icon: Icons.topic,
              title: 'No Topics',
              message: 'You don\'t have access to any topics yet.\nContact your admin for access.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            itemCount: topics.length,
            itemBuilder: (context, index) {
              final topic = topics[index];
              final tasks = topic.tasks ?? [];
              return _TopicCard(
                topic: topic,
                tasks: tasks,
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
                  ref.invalidate(guestTopicsProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTopicDetails(BuildContext context, Topic topic) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(topic.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (topic.description != null) ...[
                const Text(
                  'Description:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Gap(4),
                Text(topic.description!),
                const Gap(16),
              ],
              Text(
                'Status: ${topic.isActive ? "Active" : "Inactive"}',
                style: TextStyle(
                  color: topic.isActive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (topic.count != null) ...[
                const Gap(8),
                Text('Total Tasks: ${topic.count!.tasks}'),
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

class _TopicCard extends StatefulWidget {
  final Topic topic;
  final List<Task> tasks;

  const _TopicCard({
    required this.topic,
    required this.tasks,
  });

  @override
  State<_TopicCard> createState() => _TopicCardState();
}

class _TopicCardState extends State<_TopicCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.topic.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (widget.topic.description != null) ...[
                        const Gap(4),
                        Text(
                          widget.topic.description!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                      const Gap(4),
                      Text(
                        '${widget.tasks.length} görev',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _expanded = !_expanded;
                    });
                  },
                  icon: Icon(
                    _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  ),
                ),
              ],
            ),
            // Tasks List
            if (_expanded) ...[
              const Gap(16),
              if (widget.tasks.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Henüz görev yok',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                )
              else
                ...widget.tasks.map((task) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _TaskItem(task: task),
                    )),
            ],
          ],
        ),
      ),
    );
  }
}

class _TaskItem extends StatelessWidget {
  final Task task;

  const _TaskItem({required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                _PriorityBadge(priority: task.priority),
              ],
            ),
            if (task.note != null) ...[
              const Gap(4),
              Text(
                task.note!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[700],
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const Gap(8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  task.assignee?.name ?? 'Atanmamış',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                _StatusChip(status: task.status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final Priority priority;

  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (priority) {
      case Priority.high:
        color = Colors.red;
        break;
      case Priority.normal:
        color = Colors.orange;
        break;
      case Priority.low:
        color = Colors.green;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        priority.value,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final TaskStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case TaskStatus.done:
        color = Colors.green;
        break;
      case TaskStatus.inProgress:
        color = Colors.blue;
        break;
      case TaskStatus.todo:
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.value,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
