import 'package:json_annotation/json_annotation.dart';

class ApiConstants {
  // Use 10.0.2.2 to access localhost from Android emulator
  static const String baseUrl = 'http://10.0.2.2:8080';
  static const String loginEndpoint = '/auth/login';
  static const String tasksEndpoint = '/tasks';
  static const String usersEndpoint = '/users';
  static const String topicsEndpoint = '/topics';
}

enum TaskStatus {
  @JsonValue('TODO')
  todo('TODO'),
  @JsonValue('IN_PROGRESS')
  inProgress('IN_PROGRESS'),
  @JsonValue('DONE')
  done('DONE');

  final String value;
  const TaskStatus(this.value);

  static TaskStatus fromString(String value) {
    return TaskStatus.values.firstWhere(
      (e) => e.value == value.toUpperCase(),
      orElse: () => TaskStatus.todo,
    );
  }
}

enum Priority {
  @JsonValue('LOW')
  low('LOW'),
  @JsonValue('NORMAL')
  normal('NORMAL'),
  @JsonValue('HIGH')
  high('HIGH');

  final String value;
  const Priority(this.value);

  static Priority fromString(String value) {
    return Priority.values.firstWhere(
      (e) => e.value == value.toUpperCase(),
      orElse: () => Priority.normal,
    );
  }
}

enum UserRole {
  @JsonValue('ADMIN')
  admin('ADMIN'),
  @JsonValue('TEAM_MANAGER')
  teamManager('TEAM_MANAGER'),
  @JsonValue('MEMBER')
  member('MEMBER'),
  @JsonValue('GUEST')
  guest('GUEST');

  final String value;
  const UserRole(this.value);

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (e) => e.value == value.toUpperCase(),
      orElse: () => UserRole.member,
    );
  }
}
