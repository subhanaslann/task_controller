import 'package:flutter_app/data/models/task.dart';
import 'package:flutter_app/core/utils/constants.dart';
import 'package:flutter_app/data/datasources/api_service.dart';

/// Mock TaskRepository for testing
/// 
/// Simulates task operations with predefined responses
class MockTaskRepository {
  List<Task> _tasks = [];

  MockTaskRepository() {
    _tasks = _createMockTasks();
  }

  Future<List<Task>> getMyActiveTasks() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _tasks
        .where((t) => t.status != TaskStatus.done && t.assigneeId == 'user-1')
        .toList();
  }

  Future<List<Task>> getTeamActiveTasks() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _tasks.where((t) => t.status != TaskStatus.done).toList();
  }

  Future<List<Task>> getMyCompletedTasks() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _tasks
        .where((t) => t.status == TaskStatus.done && t.assigneeId == 'user-1')
        .toList();
  }

  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    await Future.delayed(const Duration(milliseconds: 50));
    
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) {
      throw Exception('Task not found');
    }

    _tasks[index] = _tasks[index].copyWith(status: status);
  }

  Future<Task> createTask(CreateTaskRequest request) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final newTask = Task(
      id: 'task-${DateTime.now().millisecondsSinceEpoch}',
      title: request.title,
      note: request.note,
      topicId: request.topicId,
      assigneeId: request.assigneeId,
      status: TaskStatus.fromString(request.status),
      priority: Priority.fromString(request.priority),
      dueDate: request.dueDate,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );

    _tasks.add(newTask);
    return newTask;
  }

  Future<Task> updateTask(String taskId, UpdateTaskRequest request) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) {
      throw Exception('Task not found');
    }

    final updated = _tasks[index].copyWith(
      status: request.status != null ? TaskStatus.fromString(request.status!) : null,
      priority: request.priority != null ? Priority.fromString(request.priority!) : null,
      note: request.note,
      dueDate: request.dueDate,
    );

    _tasks[index] = updated;
    return updated;
  }

  Future<void> deleteTask(String taskId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _tasks.removeWhere((t) => t.id == taskId);
  }

  // Test helpers
  void reset() {
    _tasks = _createMockTasks();
  }

  void setTasks(List<Task> tasks) {
    _tasks = List.from(tasks);
  }

  List<Task> getTasks() => List.from(_tasks);

  // Create mock tasks
  List<Task> _createMockTasks() {
    final now = DateTime.now();
    
    return [
      Task(
        id: 'task-1',
        title: 'Complete project documentation',
        note: 'Write comprehensive docs',
        topicId: 'topic-1',
        assigneeId: 'user-1',
        status: TaskStatus.todo,
        priority: Priority.high,
        dueDate: now.add(const Duration(days: 2)).toIso8601String(),
        createdAt: now.subtract(const Duration(days: 1)).toIso8601String(),
        updatedAt: now.toIso8601String(),
        topic: TopicRef(id: 'topic-1', title: 'Development'),
        assignee: Assignee(id: 'user-1', name: 'Test User'),
      ),
      Task(
        id: 'task-2',
        title: 'Fix login bug',
        topicId: 'topic-1',
        assigneeId: 'user-1',
        status: TaskStatus.inProgress,
        priority: Priority.high,
        dueDate: now.add(const Duration(days: 1)).toIso8601String(),
        createdAt: now.subtract(const Duration(days: 2)).toIso8601String(),
        updatedAt: now.toIso8601String(),
        topic: TopicRef(id: 'topic-1', title: 'Development'),
        assignee: Assignee(id: 'user-1', name: 'Test User'),
      ),
      Task(
        id: 'task-3',
        title: 'Code review',
        topicId: 'topic-2',
        assigneeId: 'user-2',
        status: TaskStatus.todo,
        priority: Priority.normal,
        dueDate: now.add(const Duration(days: 3)).toIso8601String(),
        createdAt: now.toIso8601String(),
        updatedAt: now.toIso8601String(),
        topic: TopicRef(id: 'topic-2', title: 'Review'),
        assignee: Assignee(id: 'user-2', name: 'Other User'),
      ),
      Task(
        id: 'task-4',
        title: 'Update dependencies',
        note: 'Update to latest versions',
        topicId: 'topic-1',
        assigneeId: 'user-1',
        status: TaskStatus.done,
        priority: Priority.low,
        dueDate: now.subtract(const Duration(days: 1)).toIso8601String(),
        createdAt: now.subtract(const Duration(days: 5)).toIso8601String(),
        updatedAt: now.toIso8601String(),
        completedAt: now.toIso8601String(),
        topic: TopicRef(id: 'topic-1', title: 'Development'),
        assignee: Assignee(id: 'user-1', name: 'Test User'),
      ),
    ];
  }
}
