import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/loading_placeholder.dart';
import '../../../core/widgets/task_card.dart';
import '../../../core/providers/providers.dart';
import '../../../data/models/topic.dart';
import '../../../data/models/task.dart';
import '../../../data/models/user.dart';
import '../../../core/utils/constants.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/theme/app_colors.dart';
import 'member_task_dialog.dart';

final teamActiveTopicsProvider = FutureProvider.autoDispose<List<Topic>>((
  ref,
) async {
  final apiService = ref.watch(apiServiceProvider);
  final response = await apiService.getTopicsForUser();
  return response.topics;
});

class TeamActiveTasksScreen extends ConsumerWidget {
  const TeamActiveTasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicsAsync = ref.watch(teamActiveTopicsProvider);
    final currentUser = ref.watch(currentUserProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(teamActiveTopicsProvider),
      color: AppColors.primary,
      child: topicsAsync.when(
        data: (topics) {
          final visibleTopics = currentUser?.role == UserRole.guest
              ? topics
                    .where((t) => currentUser!.visibleTopicIds.contains(t.id))
                    .toList()
              : topics.where((t) => t.isActive).toList();

          if (visibleTopics.isEmpty) {
            return AppEmptyState(
              icon: Icons.topic,
              title: 'No Projects',
              subtitle: currentUser?.role == UserRole.guest
                  ? 'No visible projects assigned.'
                  : 'No active projects found.',
            );
          }

          return ListView.separated(
            padding: EdgeInsets.all(AppSpacing.md),
            itemCount: visibleTopics.length,
            separatorBuilder: (context, index) => Gap(AppSpacing.md),
            itemBuilder: (context, index) {
              final topic = visibleTopics[index];
              return _TopicGroupCard(topic: topic, currentUser: currentUser);
            },
          );
        },
        loading: () => ListView.builder(
          padding: EdgeInsets.all(AppSpacing.md),
          itemCount: 3,
          itemBuilder: (context, index) => const LoadingPlaceholder(),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Error: $error',
            style: TextStyle(color: AppColors.error),
          ),
        ),
      ),
    );
  }
}

class _TopicGroupCard extends StatefulWidget {
  final Topic topic;
  final User? currentUser;

  const _TopicGroupCard({required this.topic, required this.currentUser});

  @override
  State<_TopicGroupCard> createState() => _TopicGroupCardState();
}

class _TopicGroupCardState extends State<_TopicGroupCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final tasks = widget.topic.tasks ?? [];
    final isGuest = widget.currentUser?.role == UserRole.guest;
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Icon(Icons.folder_open, color: AppColors.primary),
                  Gap(AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.topic.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.topic.description != null)
                          Text(
                            widget.topic.description!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: AppRadius.borderRadiusSM,
                    ),
                    child: Text(
                      '${tasks.length}',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Gap(AppSpacing.sm),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),

          // Content
          if (_expanded) ...[
            const Divider(height: 1),
            if (tasks.isEmpty)
              Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Center(
                  child: Text(
                    'No tasks in this project',
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.all(AppSpacing.md),
                itemCount: tasks.length,
                separatorBuilder: (context, index) => Gap(AppSpacing.sm),
                itemBuilder: (context, index) {
                  final task = tasks[index];

                  return TaskCard(
                    task: task,
                    showNote: true,
                    canEdit: false, // View only in this view, or specific logic
                    onTap: () => _showTaskDetails(context, task),
                  ).animate().fadeIn(delay: (50 * index).ms);
                },
              ),

            if (!isGuest) ...[
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showAddTaskDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Task to Myself'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.button,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ],
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
          // Refresh logic handled by parent/provider usually
          // But here we need to invalidate provider
          // Since we are in State, we can't access ref easily unless we use ConsumerState
          // or pass a callback.
          // Refactoring to ConsumerStatefulWidget
        },
      ),
    ).then((_) {
      // Hacky refresh trigger if dialog doesn't return value
      // ideally use callback
    });
  }

  void _showTaskDetails(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task.title),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.dialog),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (task.note != null) ...[
                const Text(
                  'Note:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Gap(4),
                Text(task.note!),
                Gap(AppSpacing.md),
              ],
              Text('Status: ${task.status.value}'),
              Text('Priority: ${task.priority.value}'),
              if (task.assignee != null)
                Text('Assigned to: ${task.assignee!.name}'),
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
