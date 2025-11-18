import 'package:flutter_app/core/utils/constants.dart';
import 'package:flutter_app/data/datasources/api_service.dart';
import 'package:flutter_app/data/models/task.dart';
import 'package:flutter_app/data/repositories/task_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_data.dart';

class MockApiService extends Mock implements ApiService {}

class FakeCreateMemberTaskRequest extends Fake
    implements CreateMemberTaskRequest {}

class FakeUpdateTaskRequest extends Fake implements UpdateTaskRequest {}

class FakeUpdateStatusRequest extends Fake implements UpdateStatusRequest {}

class FakeCreateTaskRequest extends Fake implements CreateTaskRequest {}

void main() {
  late TaskRepository repository;
  late MockApiService mockApiService;

  setUpAll(() {
    registerFallbackValue(FakeCreateMemberTaskRequest());
    registerFallbackValue(FakeUpdateTaskRequest());
    registerFallbackValue(FakeUpdateStatusRequest());
    registerFallbackValue(FakeCreateTaskRequest());
  });

  setUp(() {
    mockApiService = MockApiService();
    repository = TaskRepository(mockApiService);
  });

  group('TaskRepository - Get Tasks', () {
    test('getMyActiveTasks should return user\'s active tasks', () async {
      // Arrange
      final testTasks = [TestData.todoTask, TestData.inProgressTask];
      final mockResponse = TasksResponse(tasks: testTasks);

      when(
        () => mockApiService.getTasks('my_active'),
      ).thenAnswer((_) async => mockResponse);

      // Act
      final result = await repository.getMyActiveTasks();

      // Assert
      expect(result.length, 2);
      expect(result[0].status, TaskStatus.todo);
      expect(result[1].status, TaskStatus.inProgress);
      verify(() => mockApiService.getTasks('my_active')).called(1);
    });

    test('getMyActiveTasks should throw on API error', () async {
      // Arrange
      when(
        () => mockApiService.getTasks('my_active'),
      ).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(() => repository.getMyActiveTasks(), throwsException);
    });

    test('getTeamActiveTasks should return all team active tasks', () async {
      // Arrange
      final testTasks = TestData.taskList
          .where((t) => t.status != TaskStatus.done)
          .toList();
      final mockResponse = TasksResponse(tasks: testTasks);

      when(
        () => mockApiService.getTasks('team_active'),
      ).thenAnswer((_) async => mockResponse);

      // Act
      final result = await repository.getTeamActiveTasks();

      // Assert
      expect(result.isNotEmpty, true);
      expect(result.every((t) => t.status != TaskStatus.done), true);
      verify(() => mockApiService.getTasks('team_active')).called(1);
    });

    test('getTeamActiveTasks should handle empty list', () async {
      // Arrange
      final mockResponse = TasksResponse(tasks: []);

      when(
        () => mockApiService.getTasks('team_active'),
      ).thenAnswer((_) async => mockResponse);

      // Act
      final result = await repository.getTeamActiveTasks();

      // Assert
      expect(result.isEmpty, true);
    });

    test('getMyCompletedTasks should return only completed tasks', () async {
      // Arrange
      final testTasks = [TestData.completedTask];
      final mockResponse = TasksResponse(tasks: testTasks);

      when(
        () => mockApiService.getTasks('my_done'),
      ).thenAnswer((_) async => mockResponse);

      // Act
      final result = await repository.getMyCompletedTasks();

      // Assert
      expect(result.length, 1);
      expect(result[0].status, TaskStatus.done);
      expect(result[0].completedAt, isNotNull);
      verify(() => mockApiService.getTasks('my_done')).called(1);
    });

    test('getMyCompletedTasks should throw on unauthorized access', () async {
      // Arrange
      when(
        () => mockApiService.getTasks('my_done'),
      ).thenThrow(Exception('Unauthorized'));

      // Act & Assert
      expect(() => repository.getMyCompletedTasks(), throwsException);
    });
  });

  group('TaskRepository - Update Task Status', () {
    test('updateTaskStatus should update task to IN_PROGRESS', () async {
      // Arrange
      const taskId = 'task-123';
      final mockResponse = TaskResponse(
        task: Task(
          id: taskId,
          title: 'Test Task',
          status: TaskStatus.inProgress,
          priority: Priority.normal,
          organizationId: 'org-123',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
      );
      when(
        () => mockApiService.updateTaskStatus(taskId, any()),
      ).thenAnswer((_) async => mockResponse);

      // Act
      await repository.updateTaskStatus(taskId, TaskStatus.inProgress);

      // Assert
      verify(() => mockApiService.updateTaskStatus(taskId, any())).called(1);
    });

    test('updateTaskStatus should update task to DONE', () async {
      // Arrange
      const taskId = 'task-456';
      final mockResponse = TaskResponse(
        task: Task(
          id: taskId,
          title: 'Test Task',
          status: TaskStatus.done,
          priority: Priority.normal,
          organizationId: 'org-123',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
          completedAt: DateTime.now().toIso8601String(),
        ),
      );
      when(
        () => mockApiService.updateTaskStatus(taskId, any()),
      ).thenAnswer((_) async => mockResponse);

      // Act
      await repository.updateTaskStatus(taskId, TaskStatus.done);

      // Assert
      verify(() => mockApiService.updateTaskStatus(taskId, any())).called(1);
    });

    test('updateTaskStatus should throw on forbidden access', () async {
      // Arrange
      const taskId = 'other-user-task';
      when(
        () => mockApiService.updateTaskStatus(taskId, any()),
      ).thenThrow(Exception('Forbidden'));

      // Act & Assert
      expect(
        () => repository.updateTaskStatus(taskId, TaskStatus.done),
        throwsException,
      );
    });

    test('updateTaskStatus should throw on task not found', () async {
      // Arrange
      const taskId = 'non-existent-task';
      when(
        () => mockApiService.updateTaskStatus(taskId, any()),
      ).thenThrow(Exception('Not found'));

      // Act & Assert
      expect(
        () => repository.updateTaskStatus(taskId, TaskStatus.done),
        throwsException,
      );
    });
  });

  group('TaskRepository - Member Operations', () {
    test('createMemberTask should create and auto-assign task', () async {
      // Arrange
      final newTask = TestData.createTestTask(
        title: 'New Member Task',
        status: TaskStatus.todo,
      );
      final mockResponse = TaskResponse(task: newTask);

      when(
        () => mockApiService.createMemberTask(any()),
      ).thenAnswer((_) async => mockResponse);

      final request = CreateMemberTaskRequest(
        title: 'New Member Task',
        priority: Priority.normal.value,
      );

      // Act
      final result = await repository.createMemberTask(request);

      // Assert
      expect(result.title, 'New Member Task');
      expect(result.status, TaskStatus.todo);
      verify(() => mockApiService.createMemberTask(any())).called(1);
    });

    test('createMemberTask should throw on validation error', () async {
      // Arrange
      when(
        () => mockApiService.createMemberTask(any()),
      ).thenThrow(Exception('Validation error'));

      final request = CreateMemberTaskRequest(
        title: '', // Empty title
        priority: Priority.normal.value,
      );

      // Act & Assert
      expect(() => repository.createMemberTask(request), throwsException);
    });

    test('updateMemberTask should update own task', () async {
      // Arrange
      const taskId = 'my-task-123';
      final updatedTask = TestData.createTestTask(
        id: taskId,
        title: 'Updated Task',
        priority: Priority.high,
      );
      final mockResponse = TaskResponse(task: updatedTask);

      when(
        () => mockApiService.updateMemberTask(taskId, any()),
      ).thenAnswer((_) async => mockResponse);

      final request = UpdateTaskRequest(
        title: 'Updated Task',
        priority: Priority.high.value,
      );

      // Act
      final result = await repository.updateMemberTask(taskId, request);

      // Assert
      expect(result.title, 'Updated Task');
      expect(result.priority, Priority.high);
      verify(() => mockApiService.updateMemberTask(taskId, any())).called(1);
    });

    test('updateMemberTask should throw on forbidden access', () async {
      // Arrange
      const taskId = 'other-user-task';
      when(
        () => mockApiService.updateMemberTask(taskId, any()),
      ).thenThrow(Exception('Forbidden'));

      final request = UpdateTaskRequest(title: 'Updated');

      // Act & Assert
      expect(
        () => repository.updateMemberTask(taskId, request),
        throwsException,
      );
    });

    test('deleteMemberTask should delete own task', () async {
      // Arrange
      const taskId = 'my-task-to-delete';
      final mockResponse = DeleteResponse(success: true);

      when(
        () => mockApiService.deleteMemberTask(taskId),
      ).thenAnswer((_) async => mockResponse);

      // Act
      await repository.deleteMemberTask(taskId);

      // Assert
      verify(() => mockApiService.deleteMemberTask(taskId)).called(1);
    });

    test('deleteMemberTask should throw on forbidden access', () async {
      // Arrange
      const taskId = 'other-user-task';
      when(
        () => mockApiService.deleteMemberTask(taskId),
      ).thenThrow(Exception('Forbidden'));

      // Act & Assert
      expect(() => repository.deleteMemberTask(taskId), throwsException);
    });
  });

  group('TaskRepository - Admin Operations', () {
    test('createTask should allow assigning to any user', () async {
      // Arrange
      final newTask = TestData.createTestTask(
        title: 'Admin Created Task',
        assigneeId: 'other-user-id',
      );

      when(
        () => mockApiService.createTask(any()),
      ).thenAnswer((_) async => newTask);

      final request = CreateTaskRequest(
        title: 'Admin Created Task',
        assigneeId: 'other-user-id',
        status: TaskStatus.todo.value,
        priority: Priority.normal.value,
      );

      // Act
      final result = await repository.createTask(request);

      // Assert
      expect(result.title, 'Admin Created Task');
      expect(result.assigneeId, 'other-user-id');
      verify(() => mockApiService.createTask(any())).called(1);
    });

    test('createTask should throw on invalid assignee', () async {
      // Arrange
      when(
        () => mockApiService.createTask(any()),
      ).thenThrow(Exception('Assignee not found'));

      final request = CreateTaskRequest(
        title: 'Task',
        assigneeId: 'non-existent-user',
        status: TaskStatus.todo.value,
        priority: Priority.normal.value,
      );

      // Act & Assert
      expect(() => repository.createTask(request), throwsException);
    });

    test('updateTask should update any task in organization', () async {
      // Arrange
      const taskId = 'any-task-id';
      final updatedTask = TestData.createTestTask(
        id: taskId,
        title: 'Admin Updated',
      );

      when(
        () => mockApiService.updateTask(taskId, any()),
      ).thenAnswer((_) async => updatedTask);

      final request = UpdateTaskRequest(title: 'Admin Updated');

      // Act
      final result = await repository.updateTask(taskId, request);

      // Assert
      expect(result.title, 'Admin Updated');
      verify(() => mockApiService.updateTask(taskId, any())).called(1);
    });

    test('deleteTask should delete any task in organization', () async {
      // Arrange
      const taskId = 'task-to-delete';
      when(() => mockApiService.deleteTask(taskId)).thenAnswer((_) async => {});

      // Act
      await repository.deleteTask(taskId);

      // Assert
      verify(() => mockApiService.deleteTask(taskId)).called(1);
    });

    test('deleteTask should throw on task not found', () async {
      // Arrange
      const taskId = 'non-existent-task';
      when(
        () => mockApiService.deleteTask(taskId),
      ).thenThrow(Exception('Not found'));

      // Act & Assert
      expect(() => repository.deleteTask(taskId), throwsException);
    });
  });
}
