import 'package:flutter_app/data/models/user.dart';
import 'package:flutter_app/core/utils/constants.dart';

/// Mock AuthRepository for testing
///
/// Simulates auth operations with predefined responses
class MockAuthRepository {
  bool _isLoggedIn = false;
  String? _token;
  User? _currentUser;

  // Test data
  static final mockUser = User(
    id: 'user-1',
    name: 'Test User',
    username: 'testuser',
    email: 'test@example.com',
    role: UserRole.member,
    organizationId: 'org-1',
    active: true,
    visibleTopicIds: ['topic-1', 'topic-2'],
  );

  static final mockAdminUser = User(
    id: 'admin-1',
    name: 'Admin User',
    username: 'admin',
    email: 'admin@example.com',
    role: UserRole.admin,
    organizationId: 'org-1',
    active: true,
    visibleTopicIds: [],
  );

  // Mock credentials
  static const validUsername = 'testuser';
  static const validPassword = 'password123';
  static const adminUsername = 'admin';
  static const adminPassword = 'admin123';

  Future<User> login(String usernameOrEmail, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));

    // Check admin credentials
    if (usernameOrEmail == adminUsername && password == adminPassword) {
      _isLoggedIn = true;
      _token = 'mock-admin-token-${DateTime.now().millisecondsSinceEpoch}';
      _currentUser = mockAdminUser;
      return mockAdminUser;
    }

    // Check member credentials
    if (usernameOrEmail == validUsername && password == validPassword) {
      _isLoggedIn = true;
      _token = 'mock-user-token-${DateTime.now().millisecondsSinceEpoch}';
      _currentUser = mockUser;
      return mockUser;
    }

    // Invalid credentials
    throw Exception('Invalid credentials');
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 50));
    _isLoggedIn = false;
    _token = null;
    _currentUser = null;
  }

  Future<bool> isLoggedIn() async {
    return _isLoggedIn;
  }

  Future<String?> getToken() async {
    return _token;
  }

  User? get currentUser => _currentUser;

  // Test helpers
  void reset() {
    _isLoggedIn = false;
    _token = null;
    _currentUser = null;
  }

  void setLoggedIn(User user, {String? token}) {
    _isLoggedIn = true;
    _currentUser = user;
    _token = token ?? 'mock-token-${DateTime.now().millisecondsSinceEpoch}';
  }
}
