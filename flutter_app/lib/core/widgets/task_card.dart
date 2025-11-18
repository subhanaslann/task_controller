import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../data/models/task.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';
import '../utils/constants.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final void Function(TaskStatus?)? onStatusChange;
  final bool showNote;
  final bool canEdit;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onStatusChange,
    this.showNote = false,
    this.canEdit = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      label: _buildSemanticLabel(),
      button: onTap != null,
      enabled: canEdit,
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius12),
          side: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radius12),
          child: Container(
            constraints: const BoxConstraints(minHeight: 80),
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row: Topic and Status
                Row(
                  children: [
                    // Topic badge
                    if (task.topic != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withValues(
                            alpha: 0.3,
                          ),
                          borderRadius: BorderRadius.circular(AppTheme.radius8),
                        ),
                        child: Text(
                          task.topic!.title,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Gap(8),
                    ],

                    const Spacer(),

                    // Status badge
                    if (canEdit && onStatusChange != null)
                      _buildStatusDropdown(context, theme, colorScheme)
                    else
                      _buildStatusBadge(context, theme, colorScheme),
                  ],
                ),

                const Gap(12),

                // Task title
                Text(
                  task.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // Task note (if shown)
                if (showNote && task.note != null && task.note!.isNotEmpty) ...[
                  const Gap(8),
                  Text(
                    task.note!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const Gap(12),

                // Footer row: Priority, Due date, Assignee
                Row(
                  children: [
                    // Priority indicator
                    _buildPriorityIndicator(colorScheme),

                    const Gap(12),

                    // Due date
                    if (task.dueDate != null) ...[
                      Icon(
                        Icons.schedule_outlined,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const Gap(4),
                      Text(
                        _formatDueDate(task.dueDate!),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Gap(12),
                    ],

                    const Spacer(),

                    // Assignee avatar
                    if (task.assignee != null)
                      _buildAssigneeAvatar(theme, colorScheme),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusDropdown(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(task.status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radius8),
        border: Border.all(
          color: _getStatusColor(task.status).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: DropdownButton<TaskStatus>(
        value: task.status,
        onChanged: onStatusChange,
        underline: const SizedBox.shrink(),
        icon: Icon(
          Icons.keyboard_arrow_down,
          size: 16,
          color: _getStatusColor(task.status),
        ),
        style: theme.textTheme.labelSmall?.copyWith(
          color: _getStatusColor(task.status),
          fontWeight: FontWeight.w500,
        ),
        items: TaskStatus.values.map((status) {
          return DropdownMenuItem(
            value: status,
            child: Text(_getStatusText(status)),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatusBadge(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(task.status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radius8),
        border: Border.all(
          color: _getStatusColor(task.status).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        _getStatusText(task.status),
        style: theme.textTheme.labelSmall?.copyWith(
          color: _getStatusColor(task.status),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildPriorityIndicator(ColorScheme colorScheme) {
    final priorityColor = _getPriorityColor(task.priority);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: priorityColor,
            shape: BoxShape.circle,
          ),
        ),
        const Gap(6),
        Text(
          _getPriorityText(task.priority),
          style: TextStyle(
            color: priorityColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAssigneeAvatar(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          task.assignee!.name.isNotEmpty
              ? task.assignee!.name[0].toUpperCase()
              : '?',
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _buildSemanticLabel() {
    final buffer = StringBuffer();
    buffer.write('Task: ${task.title}');

    if (task.topic != null) {
      buffer.write(', Topic: ${task.topic!.title}');
    }

    buffer.write(', Status: ${_getStatusText(task.status)}');
    buffer.write(', Priority: ${_getPriorityText(task.priority)}');

    if (task.dueDate != null) {
      buffer.write(', Due: ${_formatDueDate(task.dueDate!)}');
    }

    if (task.assignee != null) {
      buffer.write(', Assignee: ${task.assignee!.name}');
    }

    return buffer.toString();
  }

  String _getStatusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return 'To Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.done:
        return 'Done';
    }
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.todo:
        return AppColors.statusTodo;
      case TaskStatus.inProgress:
        return AppColors.statusInProgress;
      case TaskStatus.done:
        return AppColors.statusDone;
    }
  }

  String _getPriorityText(Priority priority) {
    switch (priority) {
      case Priority.low:
        return 'Low';
      case Priority.normal:
        return 'Normal';
      case Priority.high:
        return 'High';
    }
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.low:
        return AppColors.priorityLow;
      case Priority.normal:
        return AppColors.priorityNormal;
      case Priority.high:
        return AppColors.priorityHigh;
    }
  }

  String _formatDueDate(String dueDate) {
    try {
      final parsedDate = DateTime.parse(dueDate);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final taskDate = DateTime(
        parsedDate.year,
        parsedDate.month,
        parsedDate.day,
      );
      final difference = taskDate.difference(today).inDays;

      if (difference == 0) {
        return 'Today';
      } else if (difference == 1) {
        return 'Tomorrow';
      } else if (difference == -1) {
        return 'Yesterday';
      } else if (difference > 0) {
        return '$difference days left';
      } else {
        return '${-difference} days ago';
      }
    } catch (e) {
      return dueDate;
    }
  }
}
