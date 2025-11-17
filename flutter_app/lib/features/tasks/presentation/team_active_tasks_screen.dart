import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_placeholder.dart';
import '../../../core/providers/providers.dart';
import '../../../data/models/topic.dart';
import '../../../data/models/task.dart';
import '../../../data/models/user.dart';
import '../../../core/utils/constants.dart';
import 'member_task_dialog.dart';

// Topic'leri tasks ile birlikte yükle
final teamActiveTopicsProvider = FutureProvider.autoDispose<List<Topic>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);

  // Tüm roller için /topics/active kullan (tasks dahil)
  final response = await apiService.getTopicsForUser();
  return response.topics;
});

class TeamActiveTasksScreen extends ConsumerStatefulWidget {
  const TeamActiveTasksScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TeamActiveTasksScreen> createState() => _TeamActiveTasksScreenState();
}

class _TeamActiveTasksScreenState extends ConsumerState<TeamActiveTasksScreen> {
  @override
  Widget build(BuildContext context) {
    final topicsAsync = ref.watch(teamActiveTopicsProvider);
    final currentUser = ref.watch(currentUserProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(teamActiveTopicsProvider);
      },
      child: topicsAsync.when(
        data: (topics) {
          // Guest kullanıcılar için sadece görünür topic'leri filtrele
          final visibleTopics = currentUser?.role == UserRole.guest
              ? topics.where((t) => currentUser!.visibleTopicIds.contains(t.id)).toList()
              : topics.where((t) => t.isActive).toList();

          if (visibleTopics.isEmpty) {
            return EmptyState(
              icon: Icons.topic,
              title: currentUser?.role == UserRole.guest
                  ? 'Görüntülenebilir proje yok'
                  : 'Aktif proje yok',
              message: currentUser?.role == UserRole.guest
                  ? 'Admin henüz size görünür proje atamamış'
                  : 'Henüz aktif proje bulunmuyor',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            itemCount: visibleTopics.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final topic = visibleTopics[index];
              return _TopicCard(
                topic: topic,
                currentUser: currentUser,
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
                  ref.invalidate(teamActiveTopicsProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicCard extends ConsumerStatefulWidget {
  final Topic topic;
  final User? currentUser;

  const _TopicCard({
    required this.topic,
    required this.currentUser,
  });

  @override
  ConsumerState<_TopicCard> createState() => _TopicCardState();
}

class _TopicCardState extends ConsumerState<_TopicCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final tasks = widget.topic.tasks ?? [];
    final isGuest = widget.currentUser?.role == UserRole.guest;

    return Card(
      elevation: 2,
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
                        '${tasks.length} görev',
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
            // Add Task Button (sadece Member'lar için)
            if (!isGuest) ...[
              const Gap(16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showAddTaskDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Kendime Görev Ekle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                    foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ],
            // Tasks List
            if (_expanded) ...[
              const Gap(16),
              if (tasks.isEmpty)
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
                ...tasks.map((task) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _TaskItemInTopic(
                        task: task,
                        isOwnTask: task.assigneeId == widget.currentUser?.id,
                        onTap: () => _showTaskDetails(context, task),
                      ),
                    )),
            ],
          ],
        ),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => MemberTaskDialog(
        topicId: widget.topic.id,
        topicTitle: widget.topic.title,
        onTaskCreated: () {
          ref.invalidate(teamActiveTopicsProvider);
        },
      ),
    );
  }

  void _showTaskDetails(BuildContext context, Task task) {
    final canEdit = task.assigneeId == widget.currentUser?.id &&
        widget.currentUser?.role == UserRole.member;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(canEdit ? 'Görevi Düzenle' : 'Görev Detayı'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              if (task.note != null) ...[
                const Gap(8),
                const Text('Not:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(task.note!),
              ],
              const Gap(8),
              Text('Durum: ${task.status.value}'),
              const Gap(4),
              Text('Öncelik: ${task.priority.value}'),
              const Gap(4),
              if (task.assignee != null) Text('Atanan: ${task.assignee!.name}'),
              if (task.dueDate != null) ...[
                const Gap(4),
                Text('Bitiş: ${task.dueDate}'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(canEdit ? 'İptal' : 'Kapat'),
          ),
          if (canEdit)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Burada task edit dialog açılabilir
              },
              child: const Text('Düzenle'),
            ),
        ],
      ),
    );
  }
}

class _TaskItemInTopic extends StatelessWidget {
  final Task task;
  final bool isOwnTask;
  final VoidCallback onTap;

  const _TaskItemInTopic({
    required this.task,
    required this.isOwnTask,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isOwnTask ? 3 : 1,
      color: isOwnTask
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).colorScheme.surfaceVariant,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
                            fontWeight: isOwnTask ? FontWeight.bold : FontWeight.w600,
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
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                  ),
                  _StatusBadge(status: task.status),
                ],
              ),
            ],
          ),
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
    final (text, color) = _getPriorityInfo();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  (String, Color) _getPriorityInfo() {
    switch (priority) {
      case Priority.low:
        return ('Düşük', Colors.grey);
      case Priority.normal:
        return ('Normal', Colors.blue);
      case Priority.high:
        return ('Yüksek', Colors.red);
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final TaskStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (text, color) = _getStatusInfo();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  (String, Color) _getStatusInfo() {
    switch (status) {
      case TaskStatus.todo:
        return ('Yapılacak', Colors.grey);
      case TaskStatus.inProgress:
        return ('Devam Ediyor', Colors.blue);
      case TaskStatus.done:
        return ('Tamamlandı', Colors.green);
    }
  }
}
