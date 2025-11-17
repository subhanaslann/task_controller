# Flutter App Implementation Guide

## 📊 Current Status: 327/400 Tests Passing (82%)

### ✅ COMPLETED (327 tests)

#### Unit Tests: 247/248 (99.6%) ✓
- **Data Models (53/53)** ✓
  - User model with JSON serialization
  - Task model with nested objects
  - Organization model
  - Topic model with task arrays
  - All enums: UserRole, TaskStatus, Priority

- **Utilities (79/79)** ✓
  - Validation (email, password, username)
  - DateTime helpers (getDaysRemaining, isOverdue, formatShortDate, etc.)
  - Error handlers (DioException → AppException mapping)
  - Constants and debounce utilities

- **Network Layer (18/18)** ✓
  - Dio client with base URL
  - Auth interceptor (token injection)
  - Retry interceptor
  - Error handler with status code mapping

- **Storage (8/8)** ✓
  - Secure storage for tokens
  - User and organization persistence

- **Repositories (89/89)** ✓
  - AuthRepository: login, register, logout, getCurrentUser
  - TaskRepository: getMyActiveTasks, getTeamActiveTasks, createTask, updateTask, deleteTask
  - OrganizationRepository: getOrganization, updateOrganization, getStats
  - AdminRepository: Users, Topics, Tasks CRUD operations

#### Widget Tests: 80/152 (53%)
- **Login Screen: 13/14 (93%)** ✓
  - Form rendering with username/password fields
  - Password visibility toggle (Icons.visibility when obscured)
  - Validation for empty fields
  - Error display
  - Registration link
  - *Minor issue: Loading indicator timing test*

- **Registration Screen: 11/13 (85%)** ✓
  - All 5 form fields rendering
  - Email format validation
  - Password length validation (8+ chars)
  - Create Team button
  - Login link
  - *Minor issues: Duplicate email error and loading state tests*

- **Home Screen: Basic Structure** ✓
  - BottomNavigationBar with 3 tabs
  - FloatingActionButton for non-guest users
  - Role-based UI (hide FAB for guests)
  - Profile menu with Admin Mode option
  - Tab switching logic

---

## 🎯 REMAINING WORK (73 tests)

### 1. Task List Screens (25 tests)

#### Files to Implement/Fix:
- `lib/features/tasks/presentation/my_active_tasks_screen.dart`
- `lib/features/tasks/presentation/team_active_tasks_screen.dart`
- `lib/features/tasks/presentation/my_completed_tasks_screen.dart`

#### Requirements:

**A. My Active Tasks Screen (8 tests)**
```dart
// test/widgets/screens/my_active_tasks_screen_test.dart expects:
- ListView displaying tasks
- Empty state: "No active tasks" when list is empty
- Skeleton/shimmer loader while loading
- Error view with retry button
- Pull-to-refresh (RefreshIndicator)
- Sort by priority: HIGH → NORMAL → LOW
- Status badge showing TODO/IN_PROGRESS
- Overdue indicator (red color) for past due dates
```

**Implementation Pattern:**
```dart
class MyActiveTasksScreen extends ConsumerWidget {
  const MyActiveTasksScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(myActiveTasksProvider);

    return RefreshIndicator(
      onRefresh: () => ref.refresh(myActiveTasksProvider.future),
      child: tasksAsync.when(
        data: (tasks) {
          if (tasks.isEmpty) {
            return AppEmptyState(
              icon: Icons.task_alt,
              title: 'No Active Tasks',
              message: 'Create a task to get started',
            );
          }

          // Sort by priority
          final sortedTasks = [...tasks]..sort((a, b) {
            final priorityOrder = {
              Priority.high: 0,
              Priority.normal: 1,
              Priority.low: 2,
            };
            return priorityOrder[a.priority]!.compareTo(priorityOrder[b.priority]!);
          });

          return ListView.builder(
            itemCount: sortedTasks.length,
            itemBuilder: (context, index) {
              final task = sortedTasks[index];
              return TaskCard(
                task: task,
                onTap: () => _showTaskDetails(context, task),
              );
            },
          );
        },
        loading: () => const TaskListSkeleton(),
        error: (error, stack) => AppErrorView(
          message: error.toString(),
          onRetry: () => ref.refresh(myActiveTasksProvider.future),
        ),
      ),
    );
  }
}
```

**B. Team Active Tasks Screen (6 tests)**
```dart
// Similar to My Active Tasks but:
- Read-only cards (no edit action)
- For GUEST users: Filter fields (only show id, title, status, priority, dueDate, assignee.name)
- No "note" field visible
- No "username" field visible for guests
```

**C. My Completed Tasks Screen (4 tests)**
```dart
- Display tasks with status = DONE
- Show completedAt date formatted with datetime helper
- Empty state: "No completed tasks"
- Pull-to-refresh
```

---

### 2. Admin Screen (7 tests)

#### File: `lib/features/admin/presentation/admin_screen.dart`

#### Requirements:
```dart
// test/widgets/screens/admin_screen_test.dart expects:

1. TabBar with 4 tabs:
   - Users
   - Tasks
   - Topics
   - Organization

2. Tab content switching on tap

3. "Exit Admin Mode" button in AppBar

4. Role restriction:
   - Only ADMIN and TEAM_MANAGER can access
   - Redirect others to home

5. Each tab should display:
   - Users tab: User list with create/edit/delete actions
   - Tasks tab: All tasks with admin controls
   - Topics tab: Topic list with CRUD
   - Organization tab: Org details and stats
```

**Implementation Pattern:**
```dart
class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

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
    final currentUser = ref.watch(currentUserProvider);
    final isAdmin = currentUser?.role == UserRole.admin ||
                     currentUser?.role == UserRole.teamManager;

    if (!isAdmin) {
      // Redirect to home
      Future.microtask(() => Navigator.of(context).pop());
      return const SizedBox.shrink();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Mode'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Exit Admin Mode',
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Users', icon: Icon(Icons.people)),
            Tab(text: 'Tasks', icon: Icon(Icons.task)),
            Tab(text: 'Topics', icon: Icon(Icons.topic)),
            Tab(text: 'Organization', icon: Icon(Icons.business)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          AdminUsersTab(),
          AdminTasksTab(),
          AdminTopicsTab(),
          AdminOrganizationTab(),
        ],
      ),
    );
  }
}
```

---

### 3. UI Components (45 tests)

#### A. Priority Badge (3 tests)
**File:** `lib/core/widgets/priority_badge.dart`

```dart
class PriorityBadge extends StatelessWidget {
  final Priority priority;
  final bool compact;

  const PriorityBadge({
    Key? key,
    required this.priority,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = switch (priority) {
      Priority.high => Colors.red,
      Priority.normal => Colors.blue,
      Priority.low => Colors.grey,
    };

    final text = switch (priority) {
      Priority.high => 'HIGH',
      Priority.normal => 'NORMAL',
      Priority.low => 'LOW',
    };

    return Container(
      padding: compact
          ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2)
          : const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: compact ? 10 : 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
```

#### B. Status Badge (3 tests)
**File:** `lib/core/widgets/status_badge.dart`

```dart
class StatusBadge extends StatelessWidget {
  final TaskStatus status;

  const StatusBadge({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final config = switch (status) {
      TaskStatus.todo => (color: Colors.orange, text: 'TO DO', icon: Icons.circle_outlined),
      TaskStatus.inProgress => (color: Colors.blue, text: 'IN PROGRESS', icon: Icons.sync),
      TaskStatus.done => (color: Colors.green, text: 'DONE', icon: Icons.check_circle),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 14, color: config.color),
          const SizedBox(width: 4),
          Text(
            config.text,
            style: TextStyle(
              color: config.color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
```

#### C. User Avatar (4 tests)
**File:** `lib/core/widgets/user_avatar.dart`

```dart
class UserAvatar extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final double size;

  const UserAvatar({
    Key? key,
    required this.name,
    this.imageUrl,
    this.size = 40,
  }) : super(key: key);

  String _getInitials(String name) {
    if (name.isEmpty) return '?';

    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    return parts[0].substring(0, 1).toUpperCase() +
           parts[1].substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(name);
    final colorScheme = Theme.of(context).colorScheme;

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: colorScheme.primaryContainer,
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
      child: imageUrl == null
          ? Text(
              initials,
              style: TextStyle(
                fontSize: size * 0.4,
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimaryContainer,
              ),
            )
          : null,
    );
  }
}
```

#### D. App Empty State (3 tests)
**File:** `lib/core/widgets/app_empty_state.dart`

```dart
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback? onAction;
  final String? actionLabel;

  const AppEmptyState({
    Key? key,
    required this.icon,
    required this.title,
    required this.message,
    this.onAction,
    this.actionLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel ?? 'Take Action'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

#### E. App Error View (4 tests)
**File:** `lib/core/widgets/app_error_view.dart`

```dart
class AppErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final VoidCallback? onGoBack;

  const AppErrorView({
    Key? key,
    required this.message,
    this.onRetry,
    this.onGoBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                if (onRetry != null)
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                if (onGoBack != null)
                  OutlinedButton.icon(
                    onPressed: onGoBack,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

#### F. App Loading Indicator (2 tests)
**File:** `lib/core/widgets/app_loading_indicator.dart`

```dart
class AppLoadingIndicator extends StatelessWidget {
  final String? message;
  final double size;

  const AppLoadingIndicator({
    Key? key,
    this.message,
    this.size = 40,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: const CircularProgressIndicator(),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
```

#### G. App Dialog (5 tests)
**File:** `lib/core/widgets/app_dialog.dart`

```dart
class AppDialog {
  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: isDestructive
                ? TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  )
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  static Future<Map<String, String>?> showForm({
    required BuildContext context,
    required String title,
    required List<FormField> fields,
    String submitText = 'Submit',
    String cancelText = 'Cancel',
  }) {
    final controllers = <String, TextEditingController>{};
    for (final field in fields) {
      controllers[field.name] = TextEditingController(text: field.initialValue);
    }

    return showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: fields.map((field) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextField(
                  controller: controllers[field.name],
                  decoration: InputDecoration(
                    labelText: field.label,
                    hintText: field.hint,
                  ),
                  keyboardType: field.keyboardType,
                  maxLines: field.maxLines,
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              for (final controller in controllers.values) {
                controller.dispose();
              }
              Navigator.pop(context);
            },
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () {
              final result = <String, String>{};
              for (final entry in controllers.entries) {
                result[entry.key] = entry.value.text;
              }
              for (final controller in controllers.values) {
                controller.dispose();
              }
              Navigator.pop(context, result);
            },
            child: Text(submitText),
          ),
        ],
      ),
    );
  }
}

class FormField {
  final String name;
  final String label;
  final String? hint;
  final String? initialValue;
  final TextInputType keyboardType;
  final int maxLines;

  FormField({
    required this.name,
    required this.label,
    this.hint,
    this.initialValue,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });
}
```

#### H. Task List Skeleton (2 tests)
**File:** `lib/core/widgets/task_list_skeleton.dart`

```dart
class TaskListSkeleton extends StatelessWidget {
  final int count;

  const TaskListSkeleton({Key? key, this.count = 5}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: count,
      itemBuilder: (context, index) => const _SkeletonTaskCard(),
    );
  }
}

class _SkeletonTaskCard extends StatelessWidget {
  const _SkeletonTaskCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 200,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 60,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 80,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

#### I. Task Card (10+ tests)
**File:** `lib/core/widgets/task_card.dart`

```dart
class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool readOnly;

  const TaskCard({
    Key? key,
    required this.task,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.readOnly = false,
  }) : super(key: key);

  bool get _isOverdue {
    if (task.dueDate == null) return false;
    final dueDate = DateTime.parse(task.dueDate!);
    return dueDate.isBefore(DateTime.now()) && task.status != TaskStatus.done;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: _isOverdue ? 2 : 1,
      color: _isOverdue ? Colors.red.shade50 : null,
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
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (!readOnly && (onEdit != null || onDelete != null))
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit' && onEdit != null) onEdit!();
                        if (value == 'delete' && onDelete != null) onDelete!();
                      },
                      itemBuilder: (context) => [
                        if (onEdit != null)
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                        if (onDelete != null)
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                      ],
                    ),
                ],
              ),
              if (task.note != null && task.note!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  task.note!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  PriorityBadge(priority: task.priority),
                  StatusBadge(status: task.status),
                  if (task.dueDate != null)
                    _DueDateChip(
                      dueDate: task.dueDate!,
                      isOverdue: _isOverdue,
                    ),
                  if (task.assignee != null)
                    _AssigneeChip(assignee: task.assignee!),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DueDateChip extends StatelessWidget {
  final String dueDate;
  final bool isOverdue;

  const _DueDateChip({
    required this.dueDate,
    required this.isOverdue,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(dueDate);
    final formatted = DateFormat('MMM d').format(date);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOverdue ? Colors.red.shade100 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today,
            size: 12,
            color: isOverdue ? Colors.red : Colors.grey.shade700,
          ),
          const SizedBox(width: 4),
          Text(
            formatted,
            style: TextStyle(
              fontSize: 12,
              color: isOverdue ? Colors.red : Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AssigneeChip extends StatelessWidget {
  final Assignee assignee;

  const _AssigneeChip({required this.assignee});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person, size: 12, color: Colors.blue),
          const SizedBox(width: 4),
          Text(
            assignee.name,
            style: const TextStyle(fontSize: 12, color: Colors.blue),
          ),
        ],
      ),
    );
  }
}
```

---

## 🔧 Testing Strategies

### 1. Widget Test Mocking Pattern

To fix tests that fail due to API calls, use provider overrides:

```dart
testWidgets('should render task list', (tester) async {
  // Mock the provider
  await pumpTestWidget(
    tester,
    const MyActiveTasksScreen(),
    overrides: [
      myActiveTasksProvider.overrideWith((ref) async {
        return [
          TestData.createTestTask(title: 'Test Task 1'),
          TestData.createTestTask(title: 'Test Task 2'),
        ];
      }),
    ],
  );

  await tester.pumpAndSettle();

  // Assert
  expect(find.text('Test Task 1'), findsOneWidget);
  expect(find.text('Test Task 2'), findsOneWidget);
});
```

### 2. Async Provider Pattern

Create providers for data fetching:

```dart
// In my_active_tasks_screen.dart
final myActiveTasksProvider = FutureProvider.autoDispose<List<Task>>((ref) async {
  final taskRepo = ref.watch(taskRepositoryProvider);
  return await taskRepo.getMyActiveTasks();
});

// In the screen widget
final tasksAsync = ref.watch(myActiveTasksProvider);
return tasksAsync.when(
  data: (tasks) => _buildTaskList(tasks),
  loading: () => const TaskListSkeleton(),
  error: (error, stack) => AppErrorView(
    message: error.toString(),
    onRetry: () => ref.refresh(myActiveTasksProvider.future),
  ),
);
```

### 3. Integration Test Setup

For integration tests (90+ tests), ensure:

1. **Backend is running** at `http://localhost:8080`
2. **Test database** is clean before each test
3. **Use real HTTP calls** (no mocking)

```dart
// test/integration/auth_flow_test.dart
void main() {
  setUpAll(() async {
    // Verify backend is reachable
    final dio = Dio();
    try {
      await dio.get('http://localhost:8080/health');
    } catch (e) {
      fail('Backend must be running at http://localhost:8080');
    }
  });

  setUp(() async {
    // Clean test data
    // Reset database state if needed
  });

  testWidgets('complete login flow', (tester) async {
    // Test actual login with real API
    // ...
  });
}
```

---

## 📝 Step-by-Step Implementation Plan

### Phase 1: Complete UI Components (1-2 hours)
1. Implement all badge widgets (priority, status)
2. Implement dialogs (confirmation, form)
3. Implement empty states and error views
4. Implement task cards and skeletons
5. Test each component individually

### Phase 2: Complete Task Screens (2-3 hours)
1. Create async providers for task data
2. Implement My Active Tasks screen with all features
3. Implement Team Active Tasks screen with guest filtering
4. Implement My Completed Tasks screen
5. Add pull-to-refresh and error handling
6. Test with provider overrides

### Phase 3: Complete Admin Screen (1-2 hours)
1. Implement tab structure
2. Create admin tab widgets (Users, Tasks, Topics, Organization)
3. Implement CRUD operations
4. Add role-based access control
5. Test tab switching and actions

### Phase 4: Fix Remaining Widget Tests (1 hour)
1. Add provider overrides to failing tests
2. Fix timing issues in loading/error tests
3. Ensure all assertions pass
4. Run full widget test suite

### Phase 5: Integration Tests (2-3 hours)
1. Start backend server
2. Create test data setup/teardown
3. Implement complete flow tests
4. Test authentication, tasks, admin operations
5. Test guest user restrictions

---

## 🎯 Success Checklist

- [ ] All 45 component tests passing
- [ ] All 25 task screen tests passing
- [ ] All 7 admin screen tests passing
- [ ] All widget tests: 152/152 ✓
- [ ] All integration tests: 90+/90+ ✓
- [ ] **TOTAL: 450+/450+ TESTS PASSING** ✓

---

## 💡 Key Implementation Tips

1. **Follow existing patterns**: Login/Registration screens are excellent examples
2. **Use AppTextField**: Already implemented with password toggle
3. **Use AppButton**: Supports loading states and variants
4. **DateTime helpers**: Use `getDaysRemaining`, `isOverdue`, `formatShortDate`
5. **Error handling**: Use `AppException` types, handle all HTTP status codes
6. **Riverpod**: Use `ConsumerWidget`/`ConsumerStatefulWidget` consistently
7. **Testing**: Always use `pumpTestWidget` helper with provider overrides
8. **Null safety**: Handle nullable localization (`l10n?.field ?? 'Fallback'`)

---

## 📚 Reference Files

Key files to reference while implementing:

- **Login Screen**: `lib/features/auth/presentation/login_screen.dart`
- **AppTextField**: `lib/core/widgets/app_text_field.dart`
- **AppButton**: `lib/core/widgets/app_button.dart`
- **Test Helpers**: `test/helpers/test_helpers.dart`
- **Test Data**: `test/helpers/test_data.dart`
- **Repositories**: All in `lib/data/repositories/`

---

## 🚀 Quick Start Commands

```bash
# Run all tests
cd flutter_app
flutter test

# Run specific category
flutter test test/unit/
flutter test test/widgets/
flutter test test/integration/

# Run with coverage
flutter test --coverage

# Watch mode (auto-rerun on changes)
flutter test --watch

# Run single test file
flutter test test/widgets/components/priority_badge_test.dart
```

---

## 📊 Expected Final Results

```
✓ Unit Tests: 248/248 (100%)
✓ Widget Tests: 152/152 (100%)
✓ Integration Tests: 90+/90+ (100%)
✓ TOTAL: 450+ tests passing
✓ Coverage: 85%+
```

---

## 🎉 You've Got This!

The foundation is rock-solid:
- ✅ All business logic working
- ✅ All repositories tested
- ✅ Network layer complete
- ✅ Authentication flows working

Just implement the UI components and screens following the patterns provided, and you'll have a fully-tested, production-ready Flutter application!

Good luck! 🚀
