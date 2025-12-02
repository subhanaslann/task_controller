import '../datasources/firebase_service.dart';
import '../models/task.dart';
import '../models/topic.dart';
import '../../core/utils/constants.dart';

class TaskRepository {
  final FirebaseService _firebaseService;

  TaskRepository(this._firebaseService);

  Future<List<Topic>> getActiveTopics() async {
    final topicsData = await _firebaseService.getActiveTopics();
    return topicsData.map((data) => Topic.fromJson(data)).toList();
  }

  Future<List<Task>> getMyActiveTasks() async {
    final tasksData = await _firebaseService.getMyActiveTasks();
    return tasksData.map((data) => Task.fromJson(data)).toList();
  }

  Future<List<Task>> getTeamActiveTasks() async {
    final tasksData = await _firebaseService.getTeamActiveTasks();
    return tasksData.map((data) => Task.fromJson(data)).toList();
  }

  Future<List<Task>> getMyCompletedTasks() async {
    final tasksData = await _firebaseService.getMyCompletedTasks();
    return tasksData.map((data) => Task.fromJson(data)).toList();
  }

  Future<Task> updateTaskStatus(String taskId, TaskStatus status) async {
    final taskData = await _firebaseService.updateTaskStatus(taskId, status.value);
    return Task.fromJson(taskData);
  }

  // Member operations (self-assign)
  Future<Task> createMemberTask({
    String? topicId,
    required String title,
    String? note,
    String? status,
    String? priority,
    DateTime? dueDate,
  }) async {
    final taskData = await _firebaseService.createMemberTask({
      if (topicId != null) 'topicId': topicId,
      'title': title,
      if (note != null) 'note': note,
      if (status != null) 'status': status,
      if (priority != null) 'priority': priority,
      if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
    });
    return Task.fromJson(taskData);
  }

  Future<Task> updateMemberTask({
    required String taskId,
    String? title,
    String? note,
    String? status,
    String? priority,
    DateTime? dueDate,
  }) async {
    final taskData = await _firebaseService.updateMemberTask({
      'taskId': taskId,
      if (title != null) 'title': title,
      if (note != null) 'note': note,
      if (status != null) 'status': status,
      if (priority != null) 'priority': priority,
      if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
    });
    return Task.fromJson(taskData);
  }

  Future<void> deleteMemberTask(String taskId) async {
    await _firebaseService.deleteMemberTask(taskId);
  }

  // Admin operations
  Future<Task> createTask({
    String? topicId,
    required String title,
    String? note,
    String? assigneeId,
    String? status,
    String? priority,
    DateTime? dueDate,
  }) async {
    final taskData = await _firebaseService.createTask({
      if (topicId != null) 'topicId': topicId,
      'title': title,
      if (note != null) 'note': note,
      if (assigneeId != null) 'assigneeId': assigneeId,
      if (status != null) 'status': status,
      if (priority != null) 'priority': priority,
      if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
    });
    return Task.fromJson(taskData);
  }

  Future<Task> updateTask({
    required String taskId,
    String? title,
    String? note,
    String? assigneeId,
    String? status,
    String? priority,
    DateTime? dueDate,
  }) async {
    final taskData = await _firebaseService.updateTask({
      'taskId': taskId,
      if (title != null) 'title': title,
      if (note != null) 'note': note,
      if (assigneeId != null) 'assigneeId': assigneeId,
      if (status != null) 'status': status,
      if (priority != null) 'priority': priority,
      if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
    });
    return Task.fromJson(taskData);
  }

  Future<void> deleteTask(String taskId) async {
    await _firebaseService.deleteTask(taskId);
  }
}
