import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/user.dart';
import '../models/task.dart';
import '../models/topic.dart';
import '../models/organization.dart';
import '../models/organization_stats.dart';

part 'api_service.g.dart';

@RestApi()
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  // Auth
  @POST('/auth/login')
  Future<AuthResponse> login(@Body() LoginRequest request);

  @POST('/auth/register')
  Future<RegisterResponse> register(@Body() RegisterRequest request);

  // Tasks - View
  @GET('/tasks/view')
  Future<TasksResponse> getTasks(@Query('scope') String scope);

  @PATCH('/tasks/{id}/status')
  Future<TaskResponse> updateTaskStatus(
    @Path('id') String id,
    @Body() UpdateStatusRequest request,
  );

  // Topics - View (for all users)
  @GET('/topics/active')
  Future<TopicsResponse> getTopicsForUser();

  // Admin - Topics
  @GET('/admin/topics')
  Future<TopicsResponse> getTopics();

  @POST('/admin/topics')
  Future<TopicResponse> createTopic(@Body() CreateTopicRequest request);

  @PATCH('/admin/topics/{id}')
  Future<TopicResponse> updateTopic(
    @Path('id') String id,
    @Body() UpdateTopicRequest request,
  );

  @DELETE('/admin/topics/{id}')
  Future<void> deleteTopic(@Path('id') String id);

  // Admin - Users
  @GET('/users')
  Future<UsersResponse> getUsers();

  @POST('/users')
  Future<UserResponse> createUser(@Body() CreateUserRequest request);

  @PATCH('/users/{id}')
  Future<UserResponse> updateUser(
    @Path('id') String id,
    @Body() UpdateUserRequest request,
  );

  // Member - Tasks (self-assign)
  @POST('/tasks')
  Future<TaskResponse> createMemberTask(
    @Body() CreateMemberTaskRequest request,
  );

  @PATCH('/tasks/{id}')
  Future<TaskResponse> updateMemberTask(
    @Path('id') String id,
    @Body() UpdateTaskRequest request,
  );

  @DELETE('/tasks/{id}')
  Future<DeleteResponse> deleteMemberTask(@Path('id') String id);

  // Admin - Tasks
  @POST('/admin/tasks')
  Future<Task> createTask(@Body() CreateTaskRequest request);

  @PATCH('/admin/tasks/{id}')
  Future<Task> updateTask(
    @Path('id') String id,
    @Body() UpdateTaskRequest request,
  );

  @DELETE('/admin/tasks/{id}')
  Future<void> deleteTask(@Path('id') String id);

  // Admin - Guest Access
  @POST('/admin/topics/{topicId}/guest-access')
  Future<void> addGuestAccess(
    @Path('topicId') String topicId,
    @Body() GuestAccessRequest request,
  );

  @DELETE('/admin/topics/{topicId}/guest-access/{userId}')
  Future<void> removeGuestAccess(
    @Path('topicId') String topicId,
    @Path('userId') String userId,
  );

  // Organization
  // NOTE: Backend uses JWT token to get organization ID (more secure)
  // No need to pass organization ID in URL
  @GET('/organization')
  Future<OrganizationResponse> getOrganization();

  @PATCH('/organization')
  Future<OrganizationResponse> updateOrganization(
    @Body() UpdateOrganizationRequest request,
  );

  @GET('/organization/stats')
  Future<OrganizationStatsResponse> getOrganizationStats();

  // Profile
  @PATCH('/profile')
  Future<ProfileResponse> updateProfile(@Body() UpdateProfileRequest request);

  @GET('/profile')
  Future<ProfileResponse> getProfile();
}

// Request/Response DTOs
class LoginRequest {
  final String usernameOrEmail;
  final String password;

  LoginRequest({required this.usernameOrEmail, required this.password});

  Map<String, dynamic> toJson() => {
    'usernameOrEmail': usernameOrEmail,
    'password': password,
  };
}

class AuthResponse {
  final String token;
  final User user;
  final Organization organization;

  AuthResponse({
    required this.token,
    required this.user,
    required this.organization,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      user: User.fromJson(json['user']),
      organization: Organization.fromJson(json['organization']),
    );
  }
}

class TasksResponse {
  final List<Task> tasks;

  TasksResponse({required this.tasks});

  factory TasksResponse.fromJson(Map<String, dynamic> json) {
    return TasksResponse(
      tasks: (json['tasks'] as List).map((e) => Task.fromJson(e)).toList(),
    );
  }
}

class UpdateStatusRequest {
  final String status;

  UpdateStatusRequest({required this.status});

  Map<String, dynamic> toJson() => {'status': status};
}

class TopicsResponse {
  final List<Topic> topics;

  TopicsResponse({required this.topics});

  factory TopicsResponse.fromJson(Map<String, dynamic> json) {
    try {
      final topicsList = json['topics'] as List;
      final parsedTopics = topicsList.map((e) {
        final topicMap = e as Map<String, dynamic>;
        return Topic.fromJson(topicMap);
      }).toList();

      return TopicsResponse(topics: parsedTopics);
    } catch (e) {
      rethrow;
    }
  }
}

class TopicResponse {
  final Topic topic;

  TopicResponse({required this.topic});

  factory TopicResponse.fromJson(Map<String, dynamic> json) {
    return TopicResponse(topic: Topic.fromJson(json['topic']));
  }
}

class CreateTopicRequest {
  final String title;
  final String? description;
  final bool? isActive;

  CreateTopicRequest({required this.title, this.description, this.isActive});

  Map<String, dynamic> toJson() => {
    'title': title,
    if (description != null) 'description': description,
    if (isActive != null) 'isActive': isActive,
  };
}

class UpdateTopicRequest {
  final String? title;
  final String? description;
  final bool? isActive;

  UpdateTopicRequest({this.title, this.description, this.isActive});

  Map<String, dynamic> toJson() => {
    if (title != null) 'title': title,
    if (description != null) 'description': description,
    if (isActive != null) 'isActive': isActive,
  };
}

class UsersResponse {
  final List<User> users;

  UsersResponse({required this.users});

  factory UsersResponse.fromJson(Map<String, dynamic> json) {
    return UsersResponse(
      users: (json['users'] as List).map((e) => User.fromJson(e)).toList(),
    );
  }
}

class UserResponse {
  final User user;

  UserResponse({required this.user});

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(user: User.fromJson(json['user']));
  }
}

class CreateUserRequest {
  final String name;
  final String username;
  final String email;
  final String password;
  final String role;
  final bool? active;
  final List<String>? visibleTopicIds;

  CreateUserRequest({
    required this.name,
    required this.username,
    required this.email,
    required this.password,
    required this.role,
    this.active,
    this.visibleTopicIds,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'username': username,
    'email': email,
    'password': password,
    'role': role,
    if (active != null) 'active': active,
    if (visibleTopicIds != null) 'visibleTopicIds': visibleTopicIds,
  };
}

class UpdateUserRequest {
  final String? name;
  final String? role;
  final bool? active;
  final String? password;
  final List<String>? visibleTopicIds;

  UpdateUserRequest({
    this.name,
    this.role,
    this.active,
    this.password,
    this.visibleTopicIds,
  });

  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (role != null) 'role': role,
    if (active != null) 'active': active,
    if (password != null) 'password': password,
    if (visibleTopicIds != null) 'visibleTopicIds': visibleTopicIds,
  };
}

class CreateTaskRequest {
  final String title;
  final String? topicId;
  final String? note;
  final String? assigneeId;
  final String status;
  final String priority;
  final String? dueDate;

  CreateTaskRequest({
    required this.title,
    this.topicId,
    this.note,
    this.assigneeId,
    required this.status,
    required this.priority,
    this.dueDate,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    if (topicId != null) 'topicId': topicId,
    if (note != null) 'note': note,
    if (assigneeId != null) 'assigneeId': assigneeId,
    'status': status,
    'priority': priority,
    if (dueDate != null) 'dueDate': dueDate,
  };
}

class UpdateTaskRequest {
  final String? title;
  final String? topicId;
  final String? note;
  final String? assigneeId;
  final String? status;
  final String? priority;
  final String? dueDate;

  UpdateTaskRequest({
    this.title,
    this.topicId,
    this.note,
    this.assigneeId,
    this.status,
    this.priority,
    this.dueDate,
  });

  Map<String, dynamic> toJson() => {
    if (title != null) 'title': title,
    if (topicId != null) 'topicId': topicId,
    if (note != null) 'note': note,
    if (assigneeId != null) 'assigneeId': assigneeId,
    if (status != null) 'status': status,
    if (priority != null) 'priority': priority,
    if (dueDate != null) 'dueDate': dueDate,
  };
}

class GuestAccessRequest {
  final String userId;

  GuestAccessRequest({required this.userId});

  Map<String, dynamic> toJson() => {'userId': userId};
}

// Member Task DTOs
class CreateMemberTaskRequest {
  final String? topicId;
  final String title;
  final String? note;
  final String? priority;
  final String? dueDate;

  CreateMemberTaskRequest({
    this.topicId,
    required this.title,
    this.note,
    this.priority,
    this.dueDate,
  });

  Map<String, dynamic> toJson() => {
    if (topicId != null) 'topicId': topicId,
    'title': title,
    if (note != null) 'note': note,
    if (priority != null) 'priority': priority,
    if (dueDate != null) 'dueDate': dueDate,
  };
}

class TaskResponse {
  final Task task;

  TaskResponse({required this.task});

  factory TaskResponse.fromJson(Map<String, dynamic> json) {
    try {
      final dynamic taskNode = json['task'];

      if (taskNode is Map<String, dynamic>) {
        final task = Task.fromJson(taskNode);
        return TaskResponse(task: task);
      }

      // Fallback: bazı uçlarda task doğrudan kök düzeyinde gelebilir
      if (taskNode == null &&
          json.containsKey('id') &&
          json.containsKey('title')) {
        final task = Task.fromJson(json);
        return TaskResponse(task: task);
      }

      throw FormatException(
        "Geçersiz TaskResponse: 'task' alanı yok veya beklenmeyen tip: ${taskNode.runtimeType}",
      );
    } catch (e) {
      rethrow;
    }
  }
}

class DeleteResponse {
  final bool success;
  final String? message;

  DeleteResponse({required this.success, this.message});

  factory DeleteResponse.fromJson(Map<String, dynamic> json) {
    return DeleteResponse(
      success: json['success'] as bool? ?? true, // Default to true if null
      message: json['message'] as String?,
    );
  }
}

// Registration DTOs
class RegisterRequest {
  final String companyName;
  final String teamName;
  final String managerName;
  final String email;
  final String password;

  RegisterRequest({
    required this.companyName,
    required this.teamName,
    required this.managerName,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'companyName': companyName,
    'teamName': teamName,
    'managerName': managerName,
    'email': email,
    'password': password,
  };
}

class RegisterResponse {
  final String message;
  final RegisterData data;

  RegisterResponse({required this.message, required this.data});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      message: json['message'],
      data: RegisterData.fromJson(json['data']),
    );
  }
}

class RegisterData {
  final Organization organization;
  final User user;
  final String token;

  RegisterData({
    required this.organization,
    required this.user,
    required this.token,
  });

  factory RegisterData.fromJson(Map<String, dynamic> json) {
    return RegisterData(
      organization: Organization.fromJson(json['organization']),
      user: User.fromJson(json['user']),
      token: json['token'],
    );
  }
}

// Organization DTOs
class OrganizationResponse {
  final String? message;
  final Organization organization;

  OrganizationResponse({this.message, required this.organization});

  factory OrganizationResponse.fromJson(Map<String, dynamic> json) {
    // Backend returns: { "message": "...", "data": {...} }
    return OrganizationResponse(
      message: json['message'] as String?,
      organization: Organization.fromJson(json['data']),
    );
  }
}

class UpdateOrganizationRequest {
  final String? name;
  final String? teamName;
  final int? maxUsers;

  UpdateOrganizationRequest({this.name, this.teamName, this.maxUsers});

  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (teamName != null) 'teamName': teamName,
    if (maxUsers != null) 'maxUsers': maxUsers,
  };
}

class OrganizationStatsResponse {
  final String? message;
  final OrganizationStats stats;

  OrganizationStatsResponse({this.message, required this.stats});

  factory OrganizationStatsResponse.fromJson(Map<String, dynamic> json) {
    // Backend returns: { "message": "...", "data": {...} }
    return OrganizationStatsResponse(
      message: json['message'] as String?,
      stats: OrganizationStats.fromJson(json['data']),
    );
  }
}

class UpdateProfileRequest {
  final String? name;
  final String? avatar;
  final String? password;

  UpdateProfileRequest({this.name, this.avatar, this.password});

  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (avatar != null) 'avatar': avatar,
    if (password != null) 'password': password,
  };
}

class ProfileResponse {
  final User data;

  ProfileResponse({required this.data});

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(data: User.fromJson(json['data']));
  }
}
