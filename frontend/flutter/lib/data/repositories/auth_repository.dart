import '../datasources/firebase_service.dart';
import '../models/user.dart';
import '../models/organization.dart';
import '../../core/storage/secure_storage.dart';

class AuthRepository {
  final FirebaseService _firebaseService;
  final SecureStorage _storage;

  AuthRepository(this._firebaseService, this._storage);

  Future<AuthResult> login(String usernameOrEmail, String password) async {
    final response = await _firebaseService.login(usernameOrEmail, password);

    final user = User.fromJson(response['user']);
    final organization = Organization.fromJson(response['organization']);

    await _storage.saveOrganization(organization.toJson());

    return AuthResult(user: user, organization: organization);
  }

  Future<AuthResult> register({
    required String companyName,
    required String teamName,
    required String managerName,
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await _firebaseService.registerTeam(
      companyName: companyName,
      teamName: teamName,
      managerName: managerName,
      username: username,
      email: email,
      password: password,
    );

    final user = User.fromJson(response['user']);
    final organization = Organization.fromJson(response['organization']);

    await _storage.saveOrganization(organization.toJson());

    return AuthResult(user: user, organization: organization);
  }

  Future<void> logout() async {
    await _firebaseService.logout();
    await _storage.clearAll();
  }

  Future<bool> isLoggedIn() async {
    return _firebaseService.currentUser != null;
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
