import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/utils/constants.dart';
import '../../../data/models/user.dart';
import '../../../data/models/topic.dart';
import '../../../data/models/task.dart';

// User Create Dialog
class UserCreateDialog extends StatefulWidget {
  final List<Topic> topics;
  final Function(
    String name,
    String username,
    String email,
    String password,
    String role,
    List<String>? visibleTopicIds,
  )
  onSave;

  const UserCreateDialog({
    super.key,
    required this.topics,
    required this.onSave,
  });

  @override
  State<UserCreateDialog> createState() => _UserCreateDialogState();
}

class _UserCreateDialogState extends State<UserCreateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'MEMBER';
  final Set<String> _selectedTopicIds = {};

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create User'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                label: 'Name',
                controller: _nameController,
                isRequired: true,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const Gap(16),
              AppTextField(
                label: 'Username',
                controller: _usernameController,
                isRequired: true,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const Gap(16),
              AppTextField(
                label: 'Email',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                isRequired: true,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  if (!val.contains('@')) return 'Invalid email';
                  return null;
                },
              ),
              const Gap(16),
              AppTextField(
                label: 'Password',
                controller: _passwordController,
                obscureText: true,
                isRequired: true,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  if (val.length < 6) return 'Min 6 characters';
                  return null;
                },
              ),
              const Gap(16),
              // Role selector with FilterChips (like Android)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Role:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const Gap(8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('Member'),
                        selected: _selectedRole == 'MEMBER',
                        onSelected: (selected) {
                          setState(() {
                            _selectedRole = 'MEMBER';
                          });
                        },
                      ),
                      FilterChip(
                        label: const Text('Guest'),
                        selected: _selectedRole == 'GUEST',
                        onSelected: (selected) {
                          setState(() {
                            _selectedRole = 'GUEST';
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              // Guest kullanıcılar için topic seçici
              if (_selectedRole == 'GUEST' && widget.topics.isNotEmpty)
                const Gap(16),
              if (_selectedRole == 'GUEST' && widget.topics.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Allowed Topics:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Gap(8),
                    Wrap(
                      spacing: 8,
                      children: widget.topics
                          .where((t) => t.isActive)
                          .map(
                            (topic) => FilterChip(
                              label: Text(topic.title),
                              selected: _selectedTopicIds.contains(topic.id),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedTopicIds.add(topic.id);
                                  } else {
                                    _selectedTopicIds.remove(topic.id);
                                  }
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        AppButton(
          text: 'Create',
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final topicIds =
                  _selectedRole == 'GUEST' && _selectedTopicIds.isNotEmpty
                  ? _selectedTopicIds.toList()
                  : null;
              widget.onSave(
                _nameController.text,
                _usernameController.text,
                _emailController.text,
                _passwordController.text,
                _selectedRole,
                topicIds,
              );
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }
}

// Topic Create Dialog
class TopicCreateDialog extends StatefulWidget {
  final Function(String title, String? description) onSave;

  const TopicCreateDialog({super.key, required this.onSave});

  @override
  State<TopicCreateDialog> createState() => _TopicCreateDialogState();
}

class _TopicCreateDialogState extends State<TopicCreateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Topic'),
      content: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              label: 'Title',
              controller: _titleController,
              isRequired: true,
              validator: (val) =>
                  val == null || val.isEmpty ? 'Required' : null,
            ),
            const Gap(16),
            AppTextField(
              label: 'Description',
              controller: _descriptionController,
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        AppButton(
          text: 'Create',
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave(
                _titleController.text,
                _descriptionController.text.isEmpty
                    ? null
                    : _descriptionController.text,
              );
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }
}

// User Edit Dialog
class UserEditDialog extends StatefulWidget {
  final User user;
  final List<Topic> topics;
  final Function(
    String userId,
    String? name,
    String? role,
    bool? active,
    String? password,
    List<String>? visibleTopicIds,
  )
  onSave;

  const UserEditDialog({
    super.key,
    required this.user,
    required this.topics,
    required this.onSave,
  });

  @override
  State<UserEditDialog> createState() => _UserEditDialogState();
}

class _UserEditDialogState extends State<UserEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _passwordController;
  late String _selectedRole;
  late bool _active;
  late Set<String> _selectedTopicIds;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _passwordController = TextEditingController();
    _selectedRole = widget.user.role.value;
    _active = widget.user.active;
    _selectedTopicIds = widget.user.visibleTopicIds.toSet();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit User'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                label: 'Name',
                controller: _nameController,
                isRequired: true,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const Gap(16),
              // Role selector with FilterChips
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Role:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const Gap(8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('Member'),
                        selected: _selectedRole == 'MEMBER',
                        onSelected: (selected) {
                          setState(() {
                            _selectedRole = 'MEMBER';
                          });
                        },
                      ),
                      FilterChip(
                        label: const Text('Guest'),
                        selected: _selectedRole == 'GUEST',
                        onSelected: (selected) {
                          setState(() {
                            _selectedRole = 'GUEST';
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const Gap(16),
              SwitchListTile(
                title: const Text('Active'),
                value: _active,
                onChanged: (value) {
                  setState(() {
                    _active = value;
                  });
                },
              ),
              const Gap(16),
              AppTextField(
                label: 'New Password (optional)',
                controller: _passwordController,
                obscureText: true,
                helperText: 'Leave empty to keep current password',
              ),
              // Guest kullanıcılar için topic seçici
              if (_selectedRole == 'GUEST' && widget.topics.isNotEmpty)
                const Gap(16),
              if (_selectedRole == 'GUEST' && widget.topics.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Allowed Topics:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Gap(8),
                    Wrap(
                      spacing: 8,
                      children: widget.topics
                          .where((t) => t.isActive)
                          .map(
                            (topic) => FilterChip(
                              label: Text(topic.title),
                              selected: _selectedTopicIds.contains(topic.id),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedTopicIds.add(topic.id);
                                  } else {
                                    _selectedTopicIds.remove(topic.id);
                                  }
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        AppButton(
          text: 'Save',
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // Android kodundaki gibi: sadece değişen alanları gönder
              final topicIds = _selectedRole == 'GUEST'
                  ? _selectedTopicIds.toList()
                  : null;
              widget.onSave(
                widget.user.id,
                _nameController.text != widget.user.name
                    ? _nameController.text
                    : null,
                _selectedRole != widget.user.role.value ? _selectedRole : null,
                _active != widget.user.active ? _active : null,
                _passwordController.text.isEmpty
                    ? null
                    : _passwordController.text,
                topicIds,
              );
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }
}

// Topic Edit Dialog
class TopicEditDialog extends StatefulWidget {
  final Topic topic;
  final Function(
    String topicId,
    String title,
    String? description,
    bool isActive,
  )
  onSave;

  const TopicEditDialog({super.key, required this.topic, required this.onSave});

  @override
  State<TopicEditDialog> createState() => _TopicEditDialogState();
}

class _TopicEditDialogState extends State<TopicEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.topic.title);
    _descriptionController = TextEditingController(
      text: widget.topic.description ?? '',
    );
    _isActive = widget.topic.isActive;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Topic'),
      content: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              label: 'Title',
              controller: _titleController,
              isRequired: true,
              validator: (val) =>
                  val == null || val.isEmpty ? 'Required' : null,
            ),
            const Gap(16),
            AppTextField(
              label: 'Description',
              controller: _descriptionController,
              maxLines: 3,
            ),
            const Gap(16),
            SwitchListTile(
              title: const Text('Active'),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        AppButton(
          text: 'Save',
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave(
                widget.topic.id,
                _titleController.text,
                _descriptionController.text.isEmpty
                    ? null
                    : _descriptionController.text,
                _isActive,
              );
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }
}

// Task Create Dialog
class TaskCreateDialog extends StatefulWidget {
  final List<Topic> topics;
  final List<User> users;
  final Function(
    String title,
    String? topicId,
    String? note,
    String? assigneeId,
    String status,
    String priority,
    String? dueDate,
  )
  onSave;

  const TaskCreateDialog({
    super.key,
    required this.topics,
    required this.users,
    required this.onSave,
  });

  @override
  State<TaskCreateDialog> createState() => _TaskCreateDialogState();
}

class _TaskCreateDialogState extends State<TaskCreateDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  String? _selectedTopicId;
  String? _selectedAssigneeId;
  TaskStatus _selectedStatus = TaskStatus.todo;
  Priority _selectedPriority = Priority.normal;
  DateTime? _selectedDueDate;

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Task'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: 'Title',
                controller: _titleController,
                isRequired: true,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const Gap(16),
              // Topic dropdown
              DropdownButtonFormField<String>(
                key: ValueKey('create_topic_$_selectedTopicId'),
                initialValue: _selectedTopicId,
                decoration: const InputDecoration(
                  labelText: 'Topic',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('No Topic')),
                  ...widget.topics
                      .where((t) => t.isActive)
                      .map(
                        (topic) => DropdownMenuItem(
                          value: topic.id,
                          child: Text(topic.title),
                        ),
                      ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedTopicId = value;
                  });
                },
              ),
              const Gap(16),
              AppTextField(
                label: 'Note',
                controller: _noteController,
                maxLines: 3,
              ),
              const Gap(16),
              // Assignee dropdown
              DropdownButtonFormField<String>(
                key: ValueKey('create_assignee_$_selectedAssigneeId'),
                initialValue: _selectedAssigneeId,
                decoration: const InputDecoration(
                  labelText: 'Assignee',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Unassigned'),
                  ),
                  ...widget.users
                      .where((u) => u.active)
                      .map(
                        (user) => DropdownMenuItem(
                          value: user.id,
                          child: Text('${user.name} (${user.username})'),
                        ),
                      ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedAssigneeId = value;
                  });
                },
              ),
              const Gap(16),
              // Status selector
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Status:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const Gap(8),
                  Wrap(
                    spacing: 8,
                    children: TaskStatus.values.map((status) {
                      return FilterChip(
                        label: Text(status.value),
                        selected: _selectedStatus == status,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedStatus = status;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
              const Gap(16),
              // Priority selector
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Priority:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const Gap(8),
                  Wrap(
                    spacing: 8,
                    children: Priority.values.map((priority) {
                      return FilterChip(
                        label: Text(priority.value),
                        selected: _selectedPriority == priority,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedPriority = priority;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
              const Gap(16),
              // Due Date picker
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  _selectedDueDate == null
                      ? 'No Due Date'
                      : 'Due: ${_selectedDueDate!.toLocal().toString().split(' ')[0]}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_selectedDueDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _selectedDueDate = null;
                          });
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDueDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (date != null) {
                          setState(() {
                            _selectedDueDate = date;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        AppButton(
          text: 'Create',
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave(
                _titleController.text,
                _selectedTopicId,
                _noteController.text.isEmpty ? null : _noteController.text,
                _selectedAssigneeId,
                _selectedStatus.value,
                _selectedPriority.value,
                _selectedDueDate != null
                    ? '${_selectedDueDate!.toIso8601String().split('T')[0]}T00:00:00Z'
                    : null,
              );
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }
}

// Task Edit Dialog
class TaskEditDialog extends StatefulWidget {
  final Task task;
  final List<Topic> topics;
  final List<User> users;
  final Function(
    String taskId,
    String? title,
    String? topicId,
    String? note,
    String? assigneeId,
    String? status,
    String? priority,
    String? dueDate,
  )
  onSave;

  const TaskEditDialog({
    super.key,
    required this.task,
    required this.topics,
    required this.users,
    required this.onSave,
  });

  @override
  State<TaskEditDialog> createState() => _TaskEditDialogState();
}

class _TaskEditDialogState extends State<TaskEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _noteController;
  late String? _selectedTopicId;
  late String? _selectedAssigneeId;
  late TaskStatus _selectedStatus;
  late Priority _selectedPriority;
  late DateTime? _selectedDueDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _noteController = TextEditingController(text: widget.task.note ?? '');
    _selectedTopicId = widget.task.topicId;
    _selectedAssigneeId = widget.task.assigneeId;
    _selectedStatus = widget.task.status;
    _selectedPriority = widget.task.priority;
    _selectedDueDate = widget.task.dueDate != null
        ? DateTime.tryParse(widget.task.dueDate!)
        : null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Task'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                label: 'Title',
                controller: _titleController,
                isRequired: true,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const Gap(16),
              // Topic dropdown
              DropdownButtonFormField<String>(
                key: ValueKey('edit_topic_$_selectedTopicId'),
                initialValue: _selectedTopicId,
                decoration: const InputDecoration(
                  labelText: 'Topic',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('No Topic')),
                  ...widget.topics
                      .where((t) => t.isActive)
                      .map(
                        (topic) => DropdownMenuItem(
                          value: topic.id,
                          child: Text(topic.title),
                        ),
                      ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedTopicId = value;
                  });
                },
              ),
              const Gap(16),
              AppTextField(
                label: 'Note',
                controller: _noteController,
                maxLines: 3,
              ),
              const Gap(16),
              // Assignee dropdown
              DropdownButtonFormField<String>(
                key: ValueKey('edit_assignee_$_selectedAssigneeId'),
                initialValue: _selectedAssigneeId,
                decoration: const InputDecoration(
                  labelText: 'Assignee',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Unassigned'),
                  ),
                  ...widget.users
                      .where((u) => u.active)
                      .map(
                        (user) => DropdownMenuItem(
                          value: user.id,
                          child: Text('${user.name} (${user.username})'),
                        ),
                      ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedAssigneeId = value;
                  });
                },
              ),
              const Gap(16),
              // Status selector
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Status:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const Gap(8),
                  Wrap(
                    spacing: 8,
                    children: TaskStatus.values.map((status) {
                      return FilterChip(
                        label: Text(status.value),
                        selected: _selectedStatus == status,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedStatus = status;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
              const Gap(16),
              // Priority selector
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Priority:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  const Gap(8),
                  Wrap(
                    spacing: 8,
                    children: Priority.values.map((priority) {
                      return FilterChip(
                        label: Text(priority.value),
                        selected: _selectedPriority == priority,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedPriority = priority;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
              const Gap(16),
              // Due Date picker
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  _selectedDueDate == null
                      ? 'No Due Date'
                      : 'Due: ${_selectedDueDate!.toLocal().toString().split(' ')[0]}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_selectedDueDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _selectedDueDate = null;
                          });
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDueDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (date != null) {
                          setState(() {
                            _selectedDueDate = date;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        AppButton(
          text: 'Save',
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave(
                widget.task.id,
                _titleController.text,
                _selectedTopicId,
                _noteController.text.isEmpty ? null : _noteController.text,
                _selectedAssigneeId,
                _selectedStatus.value,
                _selectedPriority.value,
                _selectedDueDate != null
                    ? '${_selectedDueDate!.toIso8601String().split('T')[0]}T00:00:00Z'
                    : null,
              );
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }
}

// Guest Access Dialog
class GuestAccessDialog extends StatefulWidget {
  final Topic topic;
  final List<User> users;
  final Function(String userId) onAddGuest;
  final Function(String userId) onRemoveGuest;

  const GuestAccessDialog({
    super.key,
    required this.topic,
    required this.users,
    required this.onAddGuest,
    required this.onRemoveGuest,
  });

  @override
  State<GuestAccessDialog> createState() => _GuestAccessDialogState();
}

class _GuestAccessDialogState extends State<GuestAccessDialog> {
  @override
  Widget build(BuildContext context) {
    // Guest kullanıcıları filtrele
    final guestUsers = widget.users
        .where((u) => u.role == UserRole.guest)
        .toList();

    if (guestUsers.isEmpty) {
      return AlertDialog(
        title: Text('Guest Access - ${widget.topic.title}'),
        content: const Text('No guest users found in the system.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      );
    }

    return AlertDialog(
      title: Text('Guest Access - ${widget.topic.title}'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select which guest users can view this topic:',
              style: TextStyle(fontSize: 14),
            ),
            const Gap(16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: guestUsers.length,
                itemBuilder: (context, index) {
                  final user = guestUsers[index];
                  // user.visibleTopicIds'den topic erişimini kontrol et
                  // (Backend guestUserIds desteklemediği için)
                  final hasAccess = user.visibleTopicIds.contains(
                    widget.topic.id,
                  );

                  return CheckboxListTile(
                    title: Text(user.name),
                    subtitle: Text(user.username),
                    value: hasAccess,
                    onChanged: user.active
                        ? (value) {
                            if (value == true) {
                              widget.onAddGuest(user.id);
                            } else {
                              widget.onRemoveGuest(user.id);
                            }
                            Navigator.pop(context);
                          }
                        : null,
                    secondary: user.active
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.cancel, color: Colors.grey),
                  );
                },
              ),
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
    );
  }
}
