import '../datasources/api_service.dart';
import '../models/user.dart';
import '../models/organization.dart';
import '../../core/storage/secure_storage.dart';

class AuthRepository {
  final ApiService _apiService;
  final SecureStorage _storage;

  AuthRepository(this._apiService, this._storage);

  Future<AuthResult> login(String usernameOrEmail, String password) async {
    final response = await _apiService.login(
      LoginRequest(usernameOrEmail: usernameOrEmail, password: password),
    );
    await _storage.saveToken(response.token);
    await _storage.saveOrganization(response.organization.toJson());
    return AuthResult(user: response.user, organization: response.organization);
  }

  Future<AuthResult> register({
    required String companyName,
    required String teamName,
    required String managerName,
    required String email,
    required String password,
  }) async {
    final response = await _apiService.register(
      RegisterRequest(
        companyName: companyName,
        teamName: teamName,
        managerName: managerName,
        email: email,
        password: password,
      ),
    );
    await _storage.saveToken(response.data.token);
    await _storage.saveOrganization(response.data.organization.toJson());
    return AuthResult(
      user: response.data.user,
      organization: response.data.organization,
    );
  }

  Future<void> logout() async {
    await _storage.clearAll();
  }

  Future<bool> isLoggedIn() async {
    return await _storage.hasToken();
  }

  Future<String?> getToken() async {
    return await _storage.getToken();
  }

  Future<Organization?> getStoredOrganization() async {
    final orgData = await _storage.getOrganization();
    if (orgData == null) return null;
    return Organization.fromJson(orgData);
  }
}

class AuthResult {
  final User user;
  final Organization organization;

  AuthResult({required this.user, required this.organization});
}
