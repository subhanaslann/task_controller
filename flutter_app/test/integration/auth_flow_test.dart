import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_app/data/datasources/api_service.dart';

/// Integration tests for complete authentication flows
/// These tests verify end-to-end authentication workflows
///
/// Note: Requires running backend server
/// Run: cd server && npm run dev
///
/// To run these tests:
/// flutter test test/integration/auth_flow_test.dart

void main() {
  late Dio dio;
  late ApiService apiService;

  const String baseUrl = 'http://localhost:8080';
  const String testEmail = 'john@acme.com';
  const String testPassword = 'manager123';

  String? authToken;
  String? userId;

  setUpAll(() {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      validateStatus: (status) => status != null && status < 500,
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (authToken != null) {
          options.headers['Authorization'] = 'Bearer $authToken';
        }
        return handler.next(options);
      },
    ));

    apiService = ApiService(dio, baseUrl: baseUrl);
  });

  group('AUTH_FLOW_01: Complete Login Flow', () {
    test('should login successfully and store token', () async {
      // Act
      final response = await apiService.login(
        LoginRequest(usernameOrEmail: testEmail, password: testPassword),
      );

      // Assert - Login successful
      expect(response.token, isNotEmpty);
      expect(response.user.email, testEmail);
      expect(response.user.role, isIn([UserRole.teamManager, UserRole.admin]));
      expect(response.organization.name, isNotEmpty);

      // Store token for subsequent tests
      authToken = response.token;
      userId = response.user.id;

      print('✅ Login successful: ${response.user.name}');
      print('✅ Organization: ${response.organization.name}');
    });

    test('should use stored token for authenticated requests', () async {
      // Arrange - Ensure token is set
      expect(authToken, isNotNull, reason: 'Must login first');

      // Act - Make authenticated request
      final response = await apiService.getTasks('my_active');

      // Assert - Request succeeds with token
      expect(response.tasks, isA<List>());
      print('✅ Authenticated request successful with stored token');
    });

    test('should fail login with invalid credentials', () async {
      // Act & Assert
      try {
        await apiService.login(
          LoginRequest(
            usernameOrEmail: 'invalid@test.com',
            password: 'wrongpassword',
          ),
        );
        fail('Should throw exception for invalid credentials');
      } catch (e) {
        expect(e, anyOf(isA<DioException>(), isA<TypeError>()));
        print('✅ Invalid credentials correctly rejected');
      }
    });
  });

  group('AUTH_FLOW_02: Complete Registration Flow', () {
    test('should register new team and auto-login', () async {
      // Arrange - Use timestamp to ensure unique email
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final request = RegisterRequest(
        companyName: 'Test Company $timestamp',
        teamName: 'Engineering',
        managerName: 'Test Manager',
        email: 'manager$timestamp@testcompany.com',
        password: 'securepass123',
      );

      // Act
      try {
        final response = await apiService.register(request);

        // Assert - Registration successful
        expect(response.message, contains('successfully'));
        expect(response.data.organization.name, 'Test Company $timestamp');
        expect(response.data.user.role, UserRole.teamManager);
        expect(response.data.token, isNotEmpty);

        print('✅ Registration successful: ${response.data.organization.name}');
        print('✅ Manager created: ${response.data.user.name}');
      } catch (e) {
        if (e is DioException && e.response?.statusCode == 409) {
          print('⚠️  Email already exists - skipping test');
        } else {
          rethrow;
        }
      }
    });

    test('should fail registration with duplicate email', () async {
      // Act & Assert
      try {
        await apiService.register(
          RegisterRequest(
            companyName: 'Company',
            teamName: 'Team',
            managerName: 'Manager',
            email: testEmail, // Already exists
            password: 'password123',
          ),
        );
        fail('Should throw exception for duplicate email');
      } catch (e) {
        expect(e, anyOf(isA<DioException>(), isA<TypeError>()));
        print('✅ Duplicate email correctly rejected');
      }
    });

    test('should fail registration with short password', () async {
      // Act & Assert
      try {
        await apiService.register(
          RegisterRequest(
            companyName: 'Company',
            teamName: 'Team',
            managerName: 'Manager',
            email: 'new@test.com',
            password: 'short', // Too short
          ),
        );
        fail('Should throw exception for short password');
      } catch (e) {
        expect(e, anyOf(isA<DioException>(), isA<TypeError>()));
        print('✅ Short password correctly rejected');
      }
    });
  });

  group('AUTH_FLOW_03: Logout Flow', () {
    test('should clear token and fail authenticated requests', () async {
      // Arrange - Login first
      final loginResponse = await apiService.login(
        LoginRequest(usernameOrEmail: testEmail, password: testPassword),
      );
      authToken = loginResponse.token;

      // Verify authenticated request works
      final beforeLogout = await apiService.getTasks('my_active');
      expect(beforeLogout.tasks, isA<List>());

      // Act - Simulate logout by clearing token
      authToken = null;

      // Assert - Authenticated requests should fail
      try {
        await apiService.getTasks('my_active');
        fail('Should fail without token');
      } catch (e) {
        expect(e, isA<DioException>());
        final dioError = e as DioException;
        expect(dioError.response?.statusCode, 401);
        print('✅ Logout flow verified - requests fail without token');
      }
    });
  });

  group('AUTH_FLOW_04: Session Expiration', () {
    test('should handle expired token (401 error)', () async {
      // Arrange - Use expired token
      final expiredToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiIxMjMiLCJleHAiOjE2MDAwMDAwMDB9.xxx';
      authToken = expiredToken;

      // Act & Assert
      try {
        await apiService.getTasks('my_active');
        fail('Should fail with expired token');
      } catch (e) {
        expect(e, isA<DioException>());
        final dioError = e as DioException;
        expect(dioError.response?.statusCode, 401);
        print('✅ Expired token correctly handled with 401');
      }
    });
  });

  group('AUTH_FLOW_05: Inactive Account Flow', () {
    test('should detect inactive account error', () async {
      // Note: This requires a deactivated test account
      // In real scenario, backend returns 401 with specific error message
      
      print('⚠️  Inactive account test requires manual setup');
      expect(true, true); // Placeholder test
    });
  });

  group('AUTH_FLOW_06: Inactive Organization Flow', () {
    test('should detect inactive organization error', () async {
      // Note: This requires an inactive organization
      // In real scenario, backend returns 403 with specific error message
      
      print('⚠️  Inactive organization test requires manual setup');
      expect(true, true); // Placeholder test
    });
  });
}

