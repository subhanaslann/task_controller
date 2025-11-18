import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../../core/providers/providers.dart';
import '../../../data/datasources/api_service.dart';
import '../../../data/models/user.dart';
import '../../../data/models/topic.dart';
import '../../../data/models/task.dart';
import '../../../core/utils/constants.dart';
import '../../../core/widgets/task_card.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/theme/app_colors.dart';
import 'admin_dialogs.dart';
import 'organization_tab.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Exit Admin Mode',
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Users'),
            Tab(icon: Icon(Icons.task), text: 'Tasks'),
            Tab(icon: Icon(Icons.topic), text: 'Topics'),
            Tab(icon: Icon(Icons.business), text: 'Org'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _UserManagementTab(),
          _TaskManagementTab(),
          _TopicManagementTab(),
          OrganizationTab(),
        ],
      ),
    );
  }
}

// User Management Tab
class _UserManagementTab extends ConsumerStatefulWidget {
  const _UserManagementTab();

  @override
  ConsumerState<_UserManagementTab> createState() => _UserManagementTabState();
}

class _UserManagementTabState extends ConsumerState<_UserManagementTab> {
  Future<List<User>>? _usersFuture;
  Future<List<Topic>>? _topicsFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _usersFuture = ref.read(adminRepositoryProvider).getUsers();
      _topicsFuture = ref.read(adminRepositoryProvider).getTopics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<User>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final users = snapshot.data ?? [];
          if (users.isEmpty) {
            return const AppEmptyState(icon: Icons.people, title: 'No Users');
          }

          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView.separated(
              padding: EdgeInsets.all(AppSpacing.md),
              itemCount: users.length,
              separatorBuilder: (context, index) => Gap(AppSpacing.sm),
              itemBuilder: (context, index) {
                final user = users[index];
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.card,
                    side: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                        style: const TextStyle(color: AppColors.primary),
                      ),
                    ),
                    title: Text(
                      user.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${user.username} • ${user.role.value}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          user.active ? Icons.check_circle : Icons.cancel,
                          color: user.active
                              ? AppColors.success
                              : AppColors.error,
                          size: 20,
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () async {
                            final topics = await _topicsFuture ?? [];
                            if (!mounted || !context.mounted) return;
                            showDialog(
                              context: context,
                              builder: (context) => UserEditDialog(
                                user: user,
                                topics: topics,
                                onSave:
                                    (
                                      userId,
                                      name,
                                      role,
                                      active,
                                      password,
                                      visibleTopicIds,
                                    ) async {
                                      try {
                                        final request = UpdateUserRequest(
                                          name: name,
                                          role: role,
                                          active: active,
                                          password: password,
                                          visibleTopicIds: visibleTopicIds,
                                        );
                                        await ref
                                            .read(adminRepositoryProvider)
                                            .updateUser(userId, request);
                                        _refresh();
                                        if (context.mounted) {
                                          AppSnackbar.showSuccess(
                                            context: context,
                                            message: 'User updated',
                                          );
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          AppSnackbar.showError(
                                            context: context,
                                            message: 'Error: $e',
                                          );
                                        }
                                      }
                                    },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.secondary,
        onPressed: () async {
          final topics = await _topicsFuture ?? [];
          if (!mounted || !context.mounted) return;
          showDialog(
            context: context,
            builder: (context) => UserCreateDialog(
              topics: topics,
              onSave:
                  (
                    name,
                    username,
                    email,
                    password,
                    role,
                    visibleTopicIds,
                  ) async {
                    try {
                      await ref
                          .read(adminRepositoryProvider)
                          .createUser(
                            CreateUserRequest(
                              name: name,
                              username: username,
                              email: email,
                              password: password,
                              role: role,
                              visibleTopicIds: visibleTopicIds,
                            ),
                          );
                      _refresh();
                      if (context.mounted) {
                        AppSnackbar.showSuccess(
                          context: context,
                          message: 'User created',
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        AppSnackbar.showError(
                          context: context,
                          message: 'Error: $e',
                        );
                      }
                    }
                  },
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// Task Management Tab
class _TaskManagementTab extends ConsumerStatefulWidget {
  const _TaskManagementTab();

  @override
  ConsumerState<_TaskManagementTab> createState() => _TaskManagementTabState();
}

class _TaskManagementTabState extends ConsumerState<_TaskManagementTab> {
  Future<List<Task>>? _tasksFuture;
  Future<List<Topic>>? _topicsFuture;
  Future<List<User>>? _usersFuture;
  String? _selectedTopicFilter;
  TaskStatus? _selectedStatusFilter;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _tasksFuture = ref.read(taskRepositoryProvider).getTeamActiveTasks();
      _topicsFuture = ref.read(adminRepositoryProvider).getTopics();
      _usersFuture = ref.read(adminRepositoryProvider).getUsers();
    });
  }

  List<Task> _filterTasks(List<Task> tasks) {
    return tasks.where((task) {
      bool matchesTopic =
          _selectedTopicFilter == null || task.topicId == _selectedTopicFilter;
      bool matchesStatus =
          _selectedStatusFilter == null || task.status == _selectedStatusFilter;
      return matchesTopic && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: FutureBuilder<List<Task>>(
              future: _tasksFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final tasks = _filterTasks(snapshot.data ?? []);
                if (tasks.isEmpty) {
                  return const AppEmptyState(
                    icon: Icons.task,
                    title: 'No Tasks',
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => _refresh(),
                  child: ListView.separated(
                    padding: EdgeInsets.all(AppSpacing.md),
                    itemCount: tasks.length,
                    separatorBuilder: (context, index) => Gap(AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Stack(
                        children: [
                          TaskCard(
                            task: task,
                            showNote: true,
                            canEdit: false,
                            onTap: () {},
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  onPressed: () => _showEditTaskDialog(task),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    size: 20,
                                    color: AppColors.error,
                                  ),
                                  onPressed: () =>
                                      _showDeleteConfirmation(task),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.secondary,
        onPressed: _showCreateTaskDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterBar() {
    return FutureBuilder<List<Topic>>(
      future: _topicsFuture,
      builder: (context, snapshot) {
        final topics = snapshot.data ?? [];
        return Container(
          padding: EdgeInsets.all(AppSpacing.sm),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Row(
            children: [
              Expanded(
                child: DropdownButton<String?>(
                  value: _selectedTopicFilter,
                  isExpanded: true,
                  hint: const Text('All Topics'),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Topics'),
                    ),
                    ...topics.map(
                      (t) =>
                          DropdownMenuItem(value: t.id, child: Text(t.title)),
                    ),
                  ],
                  onChanged: (v) => setState(() => _selectedTopicFilter = v),
                ),
              ),
              Gap(AppSpacing.md),
              Expanded(
                child: DropdownButton<TaskStatus?>(
                  value: _selectedStatusFilter,
                  isExpanded: true,
                  hint: const Text('All Statuses'),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Statuses'),
                    ),
                    ...TaskStatus.values.map(
                      (s) => DropdownMenuItem(value: s, child: Text(s.value)),
                    ),
                  ],
                  onChanged: (v) => setState(() => _selectedStatusFilter = v),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCreateTaskDialog() async {
    final topics = await _topicsFuture ?? [];
    final users = await _usersFuture ?? [];
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => TaskCreateDialog(
        topics: topics,
        users: users,
        onSave:
            (
              title,
              topicId,
              note,
              assigneeId,
              status,
              priority,
              dueDate,
            ) async {
              try {
                await ref
                    .read(taskRepositoryProvider)
                    .createTask(
                      CreateTaskRequest(
                        title: title,
                        topicId: topicId,
                        note: note,
                        assigneeId: assigneeId,
                        status: status,
                        priority: priority,
                        dueDate: dueDate,
                      ),
                    );
                _refresh();
              } catch (e) {
                if (context.mounted) {
                  AppSnackbar.showError(context: context, message: 'Error: $e');
                }
              }
            },
      ),
    );
  }

  void _showEditTaskDialog(Task task) async {
    final topics = await _topicsFuture ?? [];
    final users = await _usersFuture ?? [];
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => TaskEditDialog(
        task: task,
        topics: topics,
        users: users,
        onSave:
            (
              taskId,
              title,
              topicId,
              note,
              assigneeId,
              status,
              priority,
              dueDate,
            ) async {
              try {
                await ref
                    .read(taskRepositoryProvider)
                    .updateTask(
                      taskId,
                      UpdateTaskRequest(
                        title: title,
                        topicId: topicId,
                        note: note,
                        assigneeId: assigneeId,
                        status: status,
                        priority: priority,
                        dueDate: dueDate,
                      ),
                    );
                _refresh();
              } catch (e) {
                if (context.mounted) {
                  AppSnackbar.showError(context: context, message: 'Error: $e');
                }
              }
            },
      ),
    );
  }

  void _showDeleteConfirmation(Task task) async {
    final confirm = await ConfirmationDialog.showDelete(
      context: context,
      itemName: task.title,
    );
    if (confirm) {
      try {
        await ref.read(taskRepositoryProvider).deleteTask(task.id);
        _refresh();
      } catch (e) {
        if (mounted && context.mounted) {
          AppSnackbar.showError(context: context, message: 'Error: $e');
        }
      }
    }
  }
}

// Topic Management Tab
class _TopicManagementTab extends ConsumerStatefulWidget {
  const _TopicManagementTab();

  @override
  ConsumerState<_TopicManagementTab> createState() =>
      _TopicManagementTabState();
}

class _TopicManagementTabState extends ConsumerState<_TopicManagementTab> {
  Future<List<Topic>>? _topicsFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _topicsFuture = ref.read(adminRepositoryProvider).getTopics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Topic>>(
        future: _topicsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final topics = snapshot.data ?? [];
          if (topics.isEmpty) {
            return const AppEmptyState(icon: Icons.topic, title: 'No Topics');
          }

          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView.separated(
              padding: EdgeInsets.all(AppSpacing.md),
              itemCount: topics.length,
              separatorBuilder: (context, index) => Gap(AppSpacing.sm),
              itemBuilder: (context, index) {
                final topic = topics[index];
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.card,
                    side: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.topic, color: AppColors.primary),
                    title: Text(
                      topic.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: topic.description != null
                        ? Text(topic.description!)
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          topic.isActive ? Icons.check_circle : Icons.cancel,
                          color: topic.isActive
                              ? AppColors.success
                              : AppColors.error,
                          size: 20,
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => TopicEditDialog(
                                topic: topic,
                                onSave:
                                    (id, title, description, isActive) async {
                                      try {
                                        await ref
                                            .read(adminRepositoryProvider)
                                            .updateTopic(
                                              id,
                                              UpdateTopicRequest(
                                                title: title,
                                                description: description,
                                                isActive: isActive,
                                              ),
                                            );
                                        _refresh();
                                      } catch (e) {
                                        if (context.mounted) {
                                          AppSnackbar.showError(
                                            context: context,
                                            message: 'Error: $e',
                                          );
                                        }
                                      }
                                    },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.secondary,
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => TopicCreateDialog(
              onSave: (title, description) async {
                try {
                  await ref
                      .read(adminRepositoryProvider)
                      .createTopic(
                        CreateTopicRequest(
                          title: title,
                          description: description,
                        ),
                      );
                  _refresh();
                } catch (e) {
                  if (context.mounted) {
                    AppSnackbar.showError(
                      context: context,
                      message: 'Error: $e',
                    );
                  }
                }
              },
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
