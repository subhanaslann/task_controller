import '../datasources/api_service.dart';
import '../models/task.dart';
import '../../core/utils/constants.dart';

class TaskRepository {
  final ApiService _apiService;

  TaskRepository(this._apiService);

  Future<List<Task>> getMyActiveTasks() async {
    final response = await _apiService.getTasks('my_active');
    return response.tasks;
  }

  Future<List<Task>> getTeamActiveTasks() async {
    final response = await _apiService.getTasks('team_active');
    return response.tasks;
  }

  Future<List<Task>> getMyCompletedTasks() async {
    final response = await _apiService.getTasks('my_done');
    return response.tasks;
  }

  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    await _apiService.updateTaskStatus(
      taskId,
      UpdateStatusRequest(status: status.value),
    );
  }

  // Member operations (self-assign)
  Future<Task> createMemberTask(CreateMemberTaskRequest request) async {
    final response = await _apiService.createMemberTask(request);
    return response.task;
  }

  Future<Task> updateMemberTask(String taskId, UpdateTaskRequest request) async {
    final response = await _apiService.updateMemberTask(taskId, request);
    return response.task;
  }

  Future<void> deleteMemberTask(String taskId) async {
    await _apiService.deleteMemberTask(taskId);
  }

  // Admin operations
  Future<Task> createTask(CreateTaskRequest request) async {
    return await _apiService.createTask(request);
  }

  Future<Task> updateTask(String taskId, UpdateTaskRequest request) async {
    return await _apiService.updateTask(taskId, request);
  }

  Future<void> deleteTask(String taskId) async {
    await _apiService.deleteTask(taskId);
  }
}
