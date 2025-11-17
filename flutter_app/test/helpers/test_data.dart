import 'package:flutter_app/data/models/organization.dart';
import 'package:flutter_app/data/models/organization_stats.dart';
import 'package:flutter_app/data/models/task.dart';
import 'package:flutter_app/data/models/topic.dart';
import 'package:flutter_app/data/models/user.dart';
import 'package:flutter_app/core/utils/constants.dart';

/// Test data generators for consistent test data across all tests

class TestData {
  // User Test Data
  static User createTestUser({
    String? id,
    String? organizationId,
    String? name,
    String? username,
    String? email,
    UserRole? role,
    bool? active,
    List<String>? visibleTopicIds,
  }) {
    return User(
      id: id ?? 'test-user-id-1',
      organizationId: organizationId ?? 'test-org-id-1',
      name: name ?? 'Test User',
      username: username ?? 'testuser',
      email: email ?? 'testuser@test.com',
      role: role ?? UserRole.member,
      active: active ?? true,
      visibleTopicIds: visibleTopicIds ?? [],
    );
  }

  static User get adminUser => createTestUser(
        id: 'admin-user-id',
        name: 'Admin User',
        username: 'admin',
        email: 'admin@test.com',
        role: UserRole.admin,
      );

  static User get teamManagerUser => createTestUser(
        id: 'manager-user-id',
        name: 'Team Manager',
        username: 'manager',
        email: 'manager@test.com',
        role: UserRole.teamManager,
      );

  static User get memberUser => createTestUser(
        id: 'member-user-id',
        name: 'Member User',
        username: 'member',
        email: 'member@test.com',
        role: UserRole.member,
      );

  static User get guestUser => createTestUser(
        id: 'guest-user-id',
        name: 'Guest User',
        username: 'guest',
        email: 'guest@test.com',
        role: UserRole.guest,
        visibleTopicIds: ['test-topic-id-1'],
      );

  // Organization Test Data
  static Organization createTestOrganization({
    String? id,
    String? name,
    String? teamName,
    String? slug,
    bool? isActive,
    int? maxUsers,
  }) {
    return Organization(
      id: id ?? 'test-org-id-1',
      name: name ?? 'Test Organization',
      teamName: teamName ?? 'Test Team',
      slug: slug ?? 'test-org-test-team',
      isActive: isActive ?? true,
      maxUsers: maxUsers ?? 15,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
  }

  static Organization get testOrganization => createTestOrganization();

  // Organization Stats Test Data
  static OrganizationStats createTestOrgStats({
    int? userCount,
    int? activeUserCount,
    int? taskCount,
    int? activeTaskCount,
    int? completedTaskCount,
    int? topicCount,
    int? activeTopicCount,
  }) {
    return OrganizationStats(
      userCount: userCount ?? 10,
      activeUserCount: activeUserCount ?? 8,
      taskCount: taskCount ?? 50,
      activeTaskCount: activeTaskCount ?? 30,
      completedTaskCount: completedTaskCount ?? 20,
      topicCount: topicCount ?? 5,
      activeTopicCount: activeTopicCount ?? 4,
    );
  }

  // Task Test Data
  static Task createTestTask({
    String? id,
    String? organizationId,
    String? topicId,
    String? title,
    String? note,
    String? assigneeId,
    TaskStatus? status,
    Priority? priority,
    String? dueDate,
    String? createdAt,
    String? updatedAt,
    String? completedAt,
    TopicRef? topic,
    Assignee? assignee,
  }) {
    return Task(
      id: id ?? 'test-task-id-1',
      organizationId: organizationId ?? 'test-org-id-1',
      topicId: topicId,
      title: title ?? 'Test Task',
      note: note ?? 'Test task note',
      assigneeId: assigneeId ?? 'test-user-id-1',
      status: status ?? TaskStatus.todo,
      priority: priority ?? Priority.normal,
      dueDate: dueDate,
      createdAt: createdAt ?? DateTime.now().toIso8601String(),
      updatedAt: updatedAt ?? DateTime.now().toIso8601String(),
      completedAt: completedAt,
      topic: topic,
      assignee: assignee ?? Assignee(
        id: 'test-user-id-1',
        name: 'Test User',
        username: 'testuser',
      ),
    );
  }

  static Task get todoTask => createTestTask(
        id: 'task-todo-1',
        title: 'TODO Task',
        status: TaskStatus.todo,
        priority: Priority.high,
      );

  static Task get inProgressTask => createTestTask(
        id: 'task-progress-1',
        title: 'In Progress Task',
        status: TaskStatus.inProgress,
        priority: Priority.normal,
      );

  static Task get completedTask => createTestTask(
        id: 'task-done-1',
        title: 'Completed Task',
        status: TaskStatus.done,
        priority: Priority.low,
        completedAt: DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      );

  static Task get overdueTask => createTestTask(
        id: 'task-overdue-1',
        title: 'Overdue Task',
        status: TaskStatus.todo,
        priority: Priority.high,
        dueDate: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      );

  static List<Task> get taskList => [
        todoTask,
        inProgressTask,
        completedTask,
        overdueTask,
      ];

  // Topic Test Data
  static Topic createTestTopic({
    String? id,
    String? organizationId,
    String? title,
    String? description,
    bool? isActive,
    List<Task>? tasks,
  }) {
    return Topic(
      id: id ?? 'test-topic-id-1',
      organizationId: organizationId ?? 'test-org-id-1',
      title: title ?? 'Test Topic',
      description: description ?? 'Test topic description',
      isActive: isActive ?? true,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
      tasks: tasks,
    );
  }

  static Topic get testTopic => createTestTopic(
        id: 'topic-1',
        title: 'Backend Development',
        description: 'API and database tasks',
      );

  static Topic get testTopic2 => createTestTopic(
        id: 'topic-2',
        title: 'Frontend Development',
        description: 'UI/UX tasks',
      );

  static List<Topic> get topicList => [testTopic, testTopic2];

  // Login Response Data
  static Map<String, dynamic> createLoginResponse({
    String? token,
    User? user,
    Organization? organization,
  }) {
    return {
      'token': token ?? 'test-jwt-token-12345',
      'user': (user ?? memberUser).toJson(),
      'organization': (organization ?? testOrganization).toJson(),
    };
  }

  // Registration Response Data
  static Map<String, dynamic> createRegisterResponse({
    String? message,
    Organization? organization,
    User? user,
    String? token,
  }) {
    return {
      'message': message ?? 'Team registered successfully',
      'data': {
        'organization': (organization ?? testOrganization).toJson(),
        'user': (user ?? teamManagerUser).toJson(),
        'token': token ?? 'test-jwt-token-67890',
      },
    };
  }

  // Error Response Data
  static Map<String, dynamic> createErrorResponse({
    String? code,
    String? message,
  }) {
    return {
      'error': {
        'code': code ?? 'VALIDATION_ERROR',
        'message': message ?? 'Validation failed',
      },
    };
  }

  // Task List Response Data
  static Map<String, dynamic> createTaskListResponse(List<Task> tasks) {
    return {
      'tasks': tasks.map((t) => t.toJson()).toList(),
    };
  }

  // Topic List Response Data
  static Map<String, dynamic> createTopicListResponse(List<Topic> topics) {
    return {
      'topics': topics.map((t) => t.toJson()).toList(),
    };
  }

  // User List Response Data
  static Map<String, dynamic> createUserListResponse(List<User> users) {
    return {
      'users': users.map((u) => u.toJson()).toList(),
    };
  }
}

