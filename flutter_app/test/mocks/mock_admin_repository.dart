import 'package:flutter_app/data/models/task.dart';
import 'package:flutter_app/data/models/topic.dart';
import 'package:flutter_app/data/models/user.dart';
import 'package:flutter_app/data/repositories/admin_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockAdminRepository extends Mock implements AdminRepository {
  // Mock responses for user management
  
  void mockGetUsers(List<User> users) {
    when(() => getUsers()).thenAnswer((_) async => users);
  }

  void mockGetUsersError(Exception error) {
    when(() => getUsers()).thenThrow(error);
  }

  void mockCreateUser(User user) {
    when(() => createUser(any())).thenAnswer((_) async => user);
  }

  void mockCreateUserError(Exception error) {
    when(() => createUser(any())).thenThrow(error);
  }

  void mockUpdateUser(User user) {
    when(() => updateUser(any(), any())).thenAnswer((_) async => user);
  }

  void mockDeleteUser() {
    when(() => deleteUser(any())).thenAnswer((_) async => {});
  }

  // Mock responses for topic management
  
  void mockGetTopics(List<Topic> topics) {
    when(() => getTopics()).thenAnswer((_) async => topics);
  }

  void mockCreateTopic(Topic topic) {
    when(() => createTopic(any())).thenAnswer((_) async => topic);
  }

  void mockUpdateTopic(Topic topic) {
    when(() => updateTopic(any(), any())).thenAnswer((_) async => topic);
  }

  void mockDeleteTopic() {
    when(() => deleteTopic(any())).thenAnswer((_) async => {});
  }

  // Mock responses for task management (admin)
  
  void mockGetAllTasks(List<Task> tasks) {
    when(() => getAllTasks()).thenAnswer((_) async => tasks);
  }

  void mockCreateAdminTask(Task task) {
    when(() => createTask(any())).thenAnswer((_) async => task);
  }

  void mockUpdateAdminTask(Task task) {
    when(() => updateTask(any(), any())).thenAnswer((_) async => task);
  }

  void mockDeleteAdminTask() {
    when(() => deleteTask(any())).thenAnswer((_) async => {});
  }
}

