import '../datasources/firebase_service.dart';
import '../models/user.dart';
import '../models/topic.dart';

class AdminRepository {
  final FirebaseService _firebaseService;

  AdminRepository(this._firebaseService);

  // Users
  Future<List<User>> getUsers() async {
    final usersData = await _firebaseService.getUsers();
    return usersData.map((data) => User.fromJson(data)).toList();
  }

  Future<User> createUser({
    required String name,
    required String username,
    required String email,
    required String password,
    required String role,
    bool? active,
    List<String>? visibleTopicIds,
  }) async {
    final userData = await _firebaseService.createUser({
      'name': name,
      'username': username,
      'email': email,
      'password': password,
      'role': role,
      if (active != null) 'active': active,
      if (visibleTopicIds != null) 'visibleTopicIds': visibleTopicIds,
    });
    return User.fromJson(userData);
  }

  Future<User> updateUser({
    required String userId,
    String? name,
    String? role,
    bool? active,
    String? password,
    List<String>? visibleTopicIds,
  }) async {
    final userData = await _firebaseService.updateUser({
      'userId': userId,
      if (name != null) 'name': name,
      if (role != null) 'role': role,
      if (active != null) 'active': active,
      if (password != null) 'password': password,
      if (visibleTopicIds != null) 'visibleTopicIds': visibleTopicIds,
    });
    return User.fromJson(userData);
  }

  Future<void> deleteUser(String userId) async {
    await _firebaseService.deleteUser(userId);
  }

  // Topics
  Future<List<Topic>> getTopics() async {
    final topicsData = await _firebaseService.getAllTopics();
    return topicsData.map((data) => Topic.fromJson(data)).toList();
  }

  Future<Topic> createTopic({
    required String title,
    String? description,
    bool? isActive,
  }) async {
    final topicData = await _firebaseService.createTopic({
      'title': title,
      if (description != null) 'description': description,
      if (isActive != null) 'isActive': isActive,
    });
    return Topic.fromJson(topicData);
  }

  Future<Topic> updateTopic({
    required String topicId,
    String? title,
    String? description,
    bool? isActive,
  }) async {
    final topicData = await _firebaseService.updateTopic({
      'topicId': topicId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (isActive != null) 'isActive': isActive,
    });
    return Topic.fromJson(topicData);
  }

  Future<void> deleteTopic(String topicId) async {
    await _firebaseService.deleteTopic(topicId);
  }
}
