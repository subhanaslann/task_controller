import 'package:flutter_app/data/models/task.dart';
import 'package:flutter_app/data/repositories/task_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockTaskRepository extends Mock implements TaskRepository {
  // Mock responses for task retrieval

  void mockGetMyActiveTasks(List<Task> tasks) {
    when(() => getMyActiveTasks()).thenAnswer((_) async => tasks);
  }

  void mockGetMyActiveTasksError(Exception error) {
    when(() => getMyActiveTasks()).thenThrow(error);
  }

  void mockGetTeamActiveTasks(List<Task> tasks) {
    when(() => getTeamActiveTasks()).thenAnswer((_) async => tasks);
  }

  void mockGetTeamActiveTasksError(Exception error) {
    when(() => getTeamActiveTasks()).thenThrow(error);
  }

  void mockGetMyCompletedTasks(List<Task> tasks) {
    when(() => getMyCompletedTasks()).thenAnswer((_) async => tasks);
  }

  void mockGetMyCompletedTasksError(Exception error) {
    when(() => getMyCompletedTasks()).thenThrow(error);
  }

  // Mock responses for task status update

  void mockUpdateTaskStatus() {
    when(() => updateTaskStatus(any(), any())).thenAnswer((_) async => {});
  }

  void mockUpdateTaskStatusError(Exception error) {
    when(() => updateTaskStatus(any(), any())).thenThrow(error);
  }

  // Mock responses for member task operations

  void mockCreateMemberTask(Task task) {
    when(() => createMemberTask(any())).thenAnswer((_) async => task);
  }

  void mockCreateMemberTaskError(Exception error) {
    when(() => createMemberTask(any())).thenThrow(error);
  }

  void mockUpdateMemberTask(Task task) {
    when(() => updateMemberTask(any(), any())).thenAnswer((_) async => task);
  }

  void mockUpdateMemberTaskError(Exception error) {
    when(() => updateMemberTask(any(), any())).thenThrow(error);
  }

  void mockDeleteMemberTask() {
    when(() => deleteMemberTask(any())).thenAnswer((_) async => {});
  }

  void mockDeleteMemberTaskError(Exception error) {
    when(() => deleteMemberTask(any())).thenThrow(error);
  }

  // Mock responses for admin task operations

  void mockCreateTask(Task task) {
    when(() => createTask(any())).thenAnswer((_) async => task);
  }

  void mockCreateTaskError(Exception error) {
    when(() => createTask(any())).thenThrow(error);
  }

  void mockUpdateTask(Task task) {
    when(() => updateTask(any(), any())).thenAnswer((_) async => task);
  }

  void mockUpdateTaskError(Exception error) {
    when(() => updateTask(any(), any())).thenThrow(error);
  }

  void mockDeleteTask() {
    when(() => deleteTask(any())).thenAnswer((_) async => {});
  }

  void mockDeleteTaskError(Exception error) {
    when(() => deleteTask(any())).thenThrow(error);
  }
}
