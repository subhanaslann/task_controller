import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_app/data/datasources/api_service.dart';

/// Integration tests for task management workflows
/// 
/// These tests verify complete task CRUD flows from creation to deletion
/// 
/// Note: Requires running backend server
/// Run: cd server && npm run dev

void main() {
  late Dio dio;
  late ApiService apiService;

  const String baseUrl = 'http://localhost:8080';
  const String memberEmail = 'alice@acme.com';
  const String memberPassword = 'member123';

  String? authToken;
  String? createdTaskId;

  setUpAll(() {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      validateStatus: (status) => status != null && status < 500,
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (authToken != null) {
          options.headers['Authorization'] = 'Bearer $authToken';
        }
        return handler.next(options);
      },
    ));

    apiService = ApiService(dio, baseUrl: baseUrl);
  });

  setUp(() async {
    // Login before each test
    final loginResponse = await apiService.login(
      LoginRequest(usernameOrEmail: memberEmail, password: memberPassword),
    );
    authToken = loginResponse.token;
  });

  group('TASK_FLOW_01: Create Task Flow', () {
    test('should create task successfully', () async {
      // Arrange
      final request = CreateMemberTaskRequest(
        title: 'Integration Test Task ${DateTime.now().millisecondsSinceEpoch}',
        note: 'Created by integration tests',
        priority: Priority.high.value,
        dueDate: DateTime.now().add(const Duration(days: 7)).toIso8601String(),
      );

      // Act
      final response = await apiService.createMemberTask(request);

      // Assert
      expect(response.task, isNotNull);
      expect(response.task!.title, contains('Integration Test Task'));
      expect(response.task!.priority, Priority.high);
      expect(response.task!.status, TaskStatus.todo);

      // Store for subsequent tests
      createdTaskId = response.task!.id;

      print('✅ Task created: ${response.task!.id}');
    });

    test('should refresh task list after creation', () async {
      // Act
      final response = await apiService.getTasks('my_active');

      // Assert - Should include newly created task
      expect(response.tasks, isA<List>());
      expect(response.tasks.length, greaterThan(0));
      
      if (createdTaskId != null) {
        final createdTask = response.tasks.firstWhere(
          (t) => t.id == createdTaskId,
          orElse: () => throw Exception('Created task not found'),
        );
        expect(createdTask.id, createdTaskId);
      }

      print('✅ Task list refreshed successfully');
    });
  });

  group('TASK_FLOW_02: Update Task Status Flow', () {
    test('should update task status to IN_PROGRESS', () async {
      // Arrange - Ensure we have a task
      expect(createdTaskId, isNotNull, reason: 'Task must be created first');

      // Act
      await apiService.updateTaskStatus(
        createdTaskId!,
        UpdateStatusRequest(status: TaskStatus.inProgress.value),
      );

      // Assert - Verify status updated
      final tasks = await apiService.getTasks('my_active');
      final updatedTask = tasks.tasks.firstWhere(
        (t) => t.id == createdTaskId,
        orElse: () => throw Exception('Task not found'),
      );
      
      expect(updatedTask.status, TaskStatus.inProgress);
      print('✅ Task status updated to IN_PROGRESS');
    });

    test('should update task status to DONE and set completedAt', () async {
      // Arrange - Ensure we have a task
      expect(createdTaskId, isNotNull, reason: 'Task must be created first');

      // Act
      await apiService.updateTaskStatus(
        createdTaskId!,
        UpdateStatusRequest(status: TaskStatus.done.value),
      );

      // Assert - Verify status updated and completedAt set
      final tasks = await apiService.getTasks('my_done');
      final completedTask = tasks.tasks.firstWhere(
        (t) => t.id == createdTaskId,
        orElse: () => throw Exception('Task not found in completed'),
      );
      
      expect(completedTask.status, TaskStatus.done);
      expect(completedTask.completedAt, isNotNull);
      print('✅ Task completed with completedAt timestamp');
    });
  });

  group('TASK_FLOW_03: Edit Task Flow', () {
    test('should update task title and priority', () async {
      // Arrange - Create a new task
      final createResponse = await apiService.createMemberTask(
        CreateMemberTaskRequest(
          title: 'Task to Edit',
          priority: Priority.normal.value,
        ),
      );
      final taskId = createResponse.task!.id;

      // Act - Update task
      final updateResponse = await apiService.updateMemberTask(
        taskId,
        UpdateTaskRequest(
          title: 'Updated Task Title',
          priority: Priority.high.value,
        ),
      );

      // Assert
      expect(updateResponse.task.title, 'Updated Task Title');
      expect(updateResponse.task.priority, Priority.high);
      print('✅ Task updated successfully');
    });

    test('should update task note', () async {
      // Arrange - Create a new task
      final createResponse = await apiService.createMemberTask(
        CreateMemberTaskRequest(
          title: 'Task with Note',
          note: 'Original note',
          priority: Priority.normal.value,
        ),
      );
      final taskId = createResponse.task!.id;

      // Act - Update note
      final updateResponse = await apiService.updateMemberTask(
        taskId,
        UpdateTaskRequest(note: 'Updated note'),
      );

      // Assert
      expect(updateResponse.task.note, 'Updated note');
      print('✅ Task note updated successfully');
    });
  });

  group('TASK_FLOW_04: Delete Task Flow', () {
    test('should delete task and remove from list', () async {
      // Arrange - Create a task to delete
      final createResponse = await apiService.createMemberTask(
        CreateMemberTaskRequest(
          title: 'Task to Delete',
          priority: Priority.normal.value,
        ),
      );
      final taskId = createResponse.task!.id;

      // Verify task exists
      var tasks = await apiService.getTasks('my_active');
      var taskExists = tasks.tasks.any((t) => t.id == taskId);
      expect(taskExists, true);

      // Act - Delete task
      await apiService.deleteMemberTask(taskId);

      // Assert - Task removed from list
      tasks = await apiService.getTasks('my_active');
      taskExists = tasks.tasks.any((t) => t.id == taskId);
      expect(taskExists, false);
      
      print('✅ Task deleted and removed from list');
    });
  });

  group('TASK_FLOW_05: Pull to Refresh Flow', () {
    test('should reload tasks on refresh', () async {
      // Act - Fetch tasks multiple times
      final firstFetch = await apiService.getTasks('my_active');
      await Future.delayed(const Duration(milliseconds: 100));
      final secondFetch = await apiService.getTasks('my_active');

      // Assert - Both requests succeed
      expect(firstFetch.tasks, isA<List>());
      expect(secondFetch.tasks, isA<List>());
      print('✅ Task list can be refreshed');
    });
  });

  group('TASK_FLOW_06: Task Filtering Flow', () {
    test('should filter tasks by scope (my_active)', () async {
      // Act
      final response = await apiService.getTasks('my_active');

      // Assert - Only active tasks (TODO, IN_PROGRESS)
      expect(response.tasks.every((t) => t.status != TaskStatus.done), true);
      print('✅ my_active scope returns only active tasks');
    });

    test('should filter tasks by scope (team_active)', () async {
      // Act
      final response = await apiService.getTasks('team_active');

      // Assert - All team active tasks
      expect(response.tasks, isA<List>());
      expect(response.tasks.every((t) => t.status != TaskStatus.done), true);
      print('✅ team_active scope returns team tasks');
    });

    test('should filter tasks by scope (my_done)', () async {
      // Act
      final response = await apiService.getTasks('my_done');

      // Assert - Only completed tasks
      expect(response.tasks.every((t) => t.status == TaskStatus.done), true);
      print('✅ my_done scope returns only completed tasks');
    });
  });

  group('TASK_FLOW_07: Optimistic Update Flow', () {
    test('should handle optimistic status update', () async {
      // Arrange - Create task
      final createResponse = await apiService.createMemberTask(
        CreateMemberTaskRequest(
          title: 'Optimistic Update Task',
          priority: Priority.normal.value,
        ),
      );
      final taskId = createResponse.task!.id;

      // Act - Update status (simulating optimistic update)
      // In real app: Update local state immediately, then call API
      await apiService.updateTaskStatus(
        taskId,
        UpdateStatusRequest(status: TaskStatus.inProgress.value),
      );

      // Verify update succeeded
      final tasks = await apiService.getTasks('my_active');
      final updatedTask = tasks.tasks.firstWhere((t) => t.id == taskId);
      
      // Assert
      expect(updatedTask.status, TaskStatus.inProgress);
      print('✅ Optimistic update flow verified');
    });
  });

  group('TASK_FLOW_08: Error Recovery Flow', () {
    test('should handle task creation failure', () async {
      // Act & Assert - Create task with empty title (should fail)
      try {
        await apiService.createMemberTask(
          CreateMemberTaskRequest(
            title: '', // Empty title
            priority: Priority.normal.value,
          ),
        );
        fail('Should throw validation error');
      } catch (e) {
        expect(e, anyOf(isA<DioException>(), isA<TypeError>()));
        print('✅ Task creation validation error handled');
      }
    });

    test('should handle update of non-existent task', () async {
      // Arrange - Use non-existent task ID
      const nonExistentId = '00000000-0000-0000-0000-000000000000';

      // Act & Assert
      try {
        await apiService.updateTaskStatus(
          nonExistentId,
          UpdateStatusRequest(status: TaskStatus.done.value),
        );
        fail('Should throw 404 error');
      } catch (e) {
        expect(e, isA<DioException>());
        print('✅ Non-existent task error handled');
      }
    });
  });

  group('TASK_FLOW_09: Cross-Scope Task Visibility', () {
    test('completed task should move from my_active to my_done', () async {
      // Arrange - Create task
      final createResponse = await apiService.createMemberTask(
        CreateMemberTaskRequest(
          title: 'Task for Completion Flow',
          priority: Priority.normal.value,
        ),
      );
      final taskId = createResponse.task!.id;

      // Verify task in my_active
      var activeTasks = await apiService.getTasks('my_active');
      expect(activeTasks.tasks.any((t) => t.id == taskId), true);

      // Act - Complete task
      await apiService.updateTaskStatus(
        taskId,
        UpdateStatusRequest(status: TaskStatus.done.value),
      );

      // Assert - Task no longer in my_active
      activeTasks = await apiService.getTasks('my_active');
      expect(activeTasks.tasks.any((t) => t.id == taskId), false);

      // Assert - Task now in my_done
      final completedTasks = await apiService.getTasks('my_done');
      expect(completedTasks.tasks.any((t) => t.id == taskId), true);

      print('✅ Task correctly moved from active to completed scope');
    });
  });
}

