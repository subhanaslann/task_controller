import 'package:flutter_app/data/cache/cache_repository.dart';
import 'package:flutter_app/data/cache/cache_models.dart';
import 'package:flutter_app/data/models/task.dart';
import 'package:flutter_app/data/models/user.dart';
import 'package:mocktail/mocktail.dart';

class MockCacheRepository extends Mock implements CacheRepository {
  // Mock responses for task operations

  void mockGetAllTasks(List<Task> tasks) {
    when(() => getAllTasks()).thenAnswer((_) async => tasks);
  }

  void mockGetAllTasksError(Exception error) {
    when(() => getAllTasks()).thenThrow(error);
  }

  void mockGetTask(Task? task) {
    when(() => getTask(any())).thenAnswer((_) async => task);
  }

  void mockCacheTasks() {
    when(() => cacheTasks(any())).thenAnswer((_) async => {});
  }

  void mockCacheTask() {
    when(() => cacheTask(any())).thenAnswer((_) async => {});
  }

  void mockUpdateTaskOptimistic() {
    when(() => updateTaskOptimistic(
      any(),
      title: any(named: 'title'),
      note: any(named: 'note'),
      status: any(named: 'status'),
      priority: any(named: 'priority'),
      dueDate: any(named: 'dueDate'),
    )).thenAnswer((_) async => {});
  }

  void mockGetDirtyTasks(List<TaskCache> dirtyTasks) {
    when(() => getDirtyTasks()).thenAnswer((_) async => dirtyTasks);
  }

  void mockClearDirtyFlag() {
    when(() => clearDirtyFlag(any())).thenAnswer((_) async => {});
  }

  void mockDeleteTask() {
    when(() => deleteTask(any())).thenAnswer((_) async => {});
  }

  // Mock responses for user operations

  void mockGetAllUsers(List<User> users) {
    when(() => getAllUsers()).thenAnswer((_) async => users);
  }

  void mockGetUser(User? user) {
    when(() => getUser(any())).thenAnswer((_) async => user);
  }

  void mockCacheUsers() {
    when(() => cacheUsers(any())).thenAnswer((_) async => {});
  }

  void mockCacheUser() {
    when(() => cacheUser(any())).thenAnswer((_) async => {});
  }

  // Mock responses for sync metadata

  void mockGetLastSyncTime(DateTime? lastSyncTime) {
    when(() => getLastSyncTime(any())).thenAnswer((_) async => lastSyncTime);
  }

  void mockIsCacheStale(bool isStale) {
    when(() => isCacheStale(any(), any())).thenAnswer((_) async => isStale);
  }

  void mockGetCacheStats(Map<String, dynamic> stats) {
    when(() => getCacheStats()).thenAnswer((_) async => stats);
  }

  void mockClearAll() {
    when(() => clearAll()).thenAnswer((_) async => {});
  }

  void mockClose() {
    when(() => close()).thenAnswer((_) async => {});
  }

  void mockInit() {
    when(() => init()).thenAnswer((_) async => {});
  }
}
