import '../datasources/api_service.dart';
import '../models/user.dart';
import '../../core/storage/secure_storage.dart';

class AuthRepository {
  final ApiService _apiService;
  final SecureStorage _storage;

  AuthRepository(this._apiService, this._storage);

  Future<User> login(String usernameOrEmail, String password) async {
    final response = await _apiService.login(
      LoginRequest(usernameOrEmail: usernameOrEmail, password: password),
    );
    await _storage.saveToken(response.token);
    return response.user;
  }

  Future<void> logout() async {
    await _storage.deleteToken();
  }

  Future<bool> isLoggedIn() async {
    return await _storage.hasToken();
  }

  Future<String?> getToken() async {
    return await _storage.getToken();
  }
}
