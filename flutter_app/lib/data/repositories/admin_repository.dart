import '../datasources/api_service.dart';
import '../models/user.dart';
import '../models/topic.dart';

class AdminRepository {
  final ApiService _apiService;

  AdminRepository(this._apiService);

  // Users
  Future<List<User>> getUsers() async {
    final response = await _apiService.getUsers();
    return response.users;
  }

  Future<User> createUser(CreateUserRequest request) async {
    return await _apiService.createUser(request);
  }

  Future<void> updateUser(String userId, UpdateUserRequest request) async {
    try {
      await _apiService.updateUser(userId, request);
    } catch (e) {
      // Response parse hatası olabilir ama istek başarılıysa (200 OK) sorun yok
      // Hata gerçekten bir network hatası ise rethrow et
      if (e.toString().contains('type') && e.toString().contains('Null')) {
        // Parse hatası, ignore et çünkü backend'den eksik alan geliyor
        return;
      }
      rethrow;
    }
  }

  // Topics
  Future<List<Topic>> getTopics() async {
    try {
      print('DEBUG: getTopics çağrıldı');
      final response = await _apiService.getTopics();
      print('DEBUG: Topics başarıyla parse edildi: ${response.topics.length} adet');
      return response.topics;
    } catch (e, stackTrace) {
      print('DEBUG: getTopics hatası: $e');
      print('DEBUG: Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<Topic> createTopic(CreateTopicRequest request) async {
    final response = await _apiService.createTopic(request);
    return response.topic;
  }

  Future<Topic> updateTopic(String topicId, UpdateTopicRequest request) async {
    final response = await _apiService.updateTopic(topicId, request);
    return response.topic;
  }

  Future<void> deleteTopic(String topicId) async {
    await _apiService.deleteTopic(topicId);
  }

  // Guest Access
  Future<void> addGuestAccess(String topicId, String userId) async {
    await _apiService.addGuestAccess(
      topicId,
      GuestAccessRequest(userId: userId),
    );
  }

  Future<void> removeGuestAccess(String topicId, String userId) async {
    await _apiService.removeGuestAccess(topicId, userId);
  }
}
