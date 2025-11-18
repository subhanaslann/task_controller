import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_app/data/datasources/api_service.dart';
import 'package:flutter_app/data/models/user.dart';
import 'package:flutter_app/data/models/organization.dart';
import 'package:flutter_app/core/utils/constants.dart';

/// Integration tests for API endpoints
/// These tests verify that the Flutter app's API calls match the backend implementation
///
/// Note: These tests require a running backend server
/// Run the backend with: cd server && npm run dev
///
/// To run these tests:
/// flutter test test/integration/api_integration_test.dart

void main() {
  late Dio dio;
  late ApiService apiService;

  // Test configuration
  const String baseUrl = 'http://localhost:8080';
  const String testEmail = 'john@acme.com'; // Team Manager from seed data
  const String testPassword = 'manager123';

  // Test data storage
  String? authToken;
  String? userId;
  String? organizationId;

  setUpAll(() {
    // Configure Dio for testing
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        validateStatus: (status) {
          // Accept all status codes to test error handling
          return status != null && status < 500;
        },
      ),
    );

    // Add request interceptor for auth token
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (authToken != null) {
            options.headers['Authorization'] = 'Bearer $authToken';
          }
          debugPrint('REQUEST: ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint(
            'RESPONSE: ${response.statusCode} ${response.statusMessage}',
          );
          return handler.next(response);
        },
        onError: (error, handler) {
          debugPrint('ERROR: ${error.message}');
          return handler.next(error);
        },
      ),
    );

    apiService = ApiService(dio, baseUrl: baseUrl);
  });

  group('API Integration Tests', () {
    group('1. Authentication', () {
      test('1.1 Health Check - Should return healthy status', () async {
        final response = await dio.get('/health');

        expect(response.statusCode, 200);
        expect(response.data['status'], 'healthy');
        expect(response.data['database'], 'connected');
        expect(response.data, containsPair('uptime', isA<num>()));
      });

      test('1.2 Login - Valid credentials should succeed', () async {
        final request = LoginRequest(
          usernameOrEmail: testEmail,
          password: testPassword,
        );

        final response = await apiService.login(request);

        expect(response.token, isNotEmpty);
        expect(response.user, isA<User>());
        expect(response.user.email, testEmail);
        expect(
          response.user.role,
          isIn([
            UserRole.admin,
            UserRole.teamManager,
            UserRole.member,
            UserRole.guest,
          ]),
        );
        expect(response.organization, isA<Organization>());
        expect(response.organization.id, isNotEmpty);

        // Store for subsequent tests
        authToken = response.token;
        userId = response.user.id;
        organizationId = response.user.organizationId;

        debugPrint(
          '✅ Logged in as: ${response.user.name} (${response.user.role})',
        );
        debugPrint('✅ Organization: ${response.organization.name}');
      });

      test('1.3 Login - Invalid credentials should fail with 401', () async {
        final request = LoginRequest(
          usernameOrEmail: 'invalid@test.com',
          password: 'wrongpassword',
        );

        try {
          await apiService.login(request);
          fail('Should throw exception');
        } catch (e) {
          // Retrofit/Dio may throw DioException or type error when parsing invalid response
          expect(e, anyOf(isA<DioException>(), isA<TypeError>()));
          debugPrint('✅ Invalid login correctly rejected');
        }
      });

      test('1.4 Registration - New team registration', () async {
        // Note: This will fail if email already exists
        final request = RegisterRequest(
          companyName: 'Test Company ${DateTime.now().millisecondsSinceEpoch}',
          teamName: 'QA Team',
          managerName: 'Test Manager',
          email: 'test${DateTime.now().millisecondsSinceEpoch}@example.com',
          password: 'testpass123',
        );

        try {
          final response = await apiService.register(request);

          expect(response.message, contains('successfully'));
          expect(response.data.organization, isA<Organization>());
          expect(response.data.user, isA<User>());
          expect(response.data.user.role, UserRole.teamManager);
          expect(response.data.token, isNotEmpty);

          debugPrint('✅ Registered team: ${response.data.organization.name}');
        } catch (e) {
          if (e is DioException && e.response?.statusCode == 409) {
            debugPrint('⚠️  Registration skipped - email already exists');
          } else {
            rethrow;
          }
        }
      });
    });

    group('2. Task Management (requires auth)', () {
      setUp(() {
        // Ensure we have auth token
        expect(
          authToken,
          isNotNull,
          reason: 'Authentication required for task tests',
        );
      });

      test('2.1 Get My Active Tasks', () async {
        final response = await apiService.getTasks('my_active');

        expect(response.tasks, isA<List>());
        debugPrint('✅ Found ${response.tasks.length} active tasks');

        // Verify task structure if tasks exist
        if (response.tasks.isNotEmpty) {
          final task = response.tasks.first;
          expect(task.id, isNotEmpty);
          expect(task.title, isNotEmpty);
          expect(task.status, isIn([TaskStatus.todo, TaskStatus.inProgress]));
          expect(
            task.priority,
            isIn([Priority.low, Priority.normal, Priority.high]),
          );
        }
      });

      test('2.2 Get Team Active Tasks', () async {
        final response = await apiService.getTasks('team_active');

        expect(response.tasks, isA<List>());
        debugPrint('✅ Found ${response.tasks.length} team active tasks');
      });

      test('2.3 Get My Completed Tasks', () async {
        final response = await apiService.getTasks('my_done');

        expect(response.tasks, isA<List>());
        debugPrint('✅ Found ${response.tasks.length} completed tasks');

        // Verify all tasks are DONE
        for (final task in response.tasks) {
          expect(task.status, TaskStatus.done);
          expect(task.completedAt, isNotNull);
        }
      });

      test('2.4 Create Member Task (self-assign)', () async {
        final request = CreateMemberTaskRequest(
          topicId: null, // No topic assignment
          title: 'Test Task ${DateTime.now().millisecondsSinceEpoch}',
          note: 'This is a test task created by integration tests',
          priority: 'HIGH',
          dueDate: DateTime.now()
              .add(const Duration(days: 7))
              .toUtc()
              .toIso8601String(),
        );

        final response = await apiService.createMemberTask(request);

        expect(response.task, isNotNull);
        final task = response.task;
        expect(task.title, request.title);
        expect(task.priority, Priority.high);
        expect(task.assigneeId, userId); // Auto-assigned to self
        expect(task.status, TaskStatus.todo); // Default status

        debugPrint('✅ Created task: ${task.id}');
      });

      test('2.5 Invalid scope should fail', () async {
        try {
          await apiService.getTasks('invalid_scope');
          fail('Should throw validation error');
        } catch (e) {
          // Retrofit/Dio may throw DioException or type error when parsing invalid response
          expect(e, anyOf(isA<DioException>(), isA<TypeError>()));
          debugPrint('✅ Invalid scope correctly rejected');
        }
      });
    });

    group('3. Organization Management', () {
      setUp(() {
        expect(authToken, isNotNull);
      });

      test('3.1 Get Current Organization - FIXED ENDPOINT', () async {
        // FIXED: Updated to use GET /organization (JWT-based)
        // Backend uses JWT token to determine organization ID (more secure)

        final response = await dio.get('/organization');

        expect(response.statusCode, 200);
        expect(response.data['message'], isNotNull);
        expect(response.data['data'], isNotNull);
        expect(response.data['data']['id'], organizationId);
        expect(response.data['data']['name'], isNotEmpty);

        debugPrint('✅ Organization endpoint: GET /organization');
        debugPrint('✅ Response format: {message, data}');
      });

      test('3.2 Get Organization Stats - FIXED ENDPOINT', () async {
        // FIXED: Updated to use GET /organization/stats (JWT-based)
        // Backend uses JWT token to determine organization ID (more secure)

        final response = await dio.get('/organization/stats');

        expect(response.statusCode, 200);
        expect(response.data['message'], isNotNull);
        expect(response.data['data'], isNotNull);
        expect(response.data['data']['userCount'], isA<int>());
        expect(response.data['data']['taskCount'], isA<int>());
        expect(response.data['data']['topicCount'], isA<int>());

        debugPrint('✅ Stats endpoint: GET /organization/stats');
        debugPrint('✅ Response format: {message, data}');
      });
    });

    group('4. Topics', () {
      setUp(() {
        expect(authToken, isNotNull);
      });

      test('4.1 Get Active Topics', () async {
        final response = await apiService.getTopicsForUser();

        expect(response.topics, isA<List>());
        debugPrint('✅ Found ${response.topics.length} active topics');

        // Verify topic structure if topics exist
        if (response.topics.isNotEmpty) {
          final topic = response.topics.first;
          expect(topic.id, isNotEmpty);
          expect(topic.title, isNotEmpty);
          expect(topic.isActive, true);
        }
      });
    });

    group('5. Admin Features (requires ADMIN/TEAM_MANAGER role)', () {
      setUp(() {
        expect(authToken, isNotNull);
      });

      test('5.1 Get All Topics (Admin)', () async {
        try {
          final response = await apiService.getTopics();

          expect(response.topics, isA<List>());
          debugPrint('✅ Admin can view ${response.topics.length} topics');
        } catch (e) {
          if (e is DioException && e.response?.statusCode == 403) {
            debugPrint(
              '⚠️  User does not have admin privileges - test skipped',
            );
          } else {
            rethrow;
          }
        }
      });

      test('5.2 Get All Users (Admin)', () async {
        try {
          final response = await apiService.getUsers();

          expect(response.users, isA<List>());
          debugPrint('✅ Admin can view ${response.users.length} users');

          // Verify user structure
          if (response.users.isNotEmpty) {
            final user = response.users.first;
            expect(user.id, isNotEmpty);
            expect(user.name, isNotEmpty);
            expect(user.email, isNotEmpty);
            expect(
              user.role,
              isIn([
                UserRole.admin,
                UserRole.teamManager,
                UserRole.member,
                UserRole.guest,
              ]),
            );
          }
        } catch (e) {
          if (e is DioException && e.response?.statusCode == 403) {
            debugPrint(
              '⚠️  User does not have admin privileges - test skipped',
            );
          } else {
            rethrow;
          }
        }
      });
    });

    group('6. Error Handling', () {
      test('6.1 Unauthorized request (no token) should return 401', () async {
        final tempDio = Dio(BaseOptions(baseUrl: baseUrl));
        final tempApiService = ApiService(tempDio, baseUrl: baseUrl);

        try {
          await tempApiService.getTasks('my_active');
          fail('Should throw 401 error');
        } catch (e) {
          expect(e, isA<DioException>());
          final dioError = e as DioException;
          expect(dioError.response?.statusCode, 401);
        }
      });

      test('6.2 Invalid token should return 401', () async {
        final tempDio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            headers: {'Authorization': 'Bearer invalid_token_here'},
          ),
        );
        final tempApiService = ApiService(tempDio, baseUrl: baseUrl);

        try {
          await tempApiService.getTasks('my_active');
          fail('Should throw 401 error');
        } catch (e) {
          expect(e, isA<DioException>());
          final dioError = e as DioException;
          expect(dioError.response?.statusCode, 401);
        }
      });

      test('6.3 Non-existent route should return 404', () async {
        final response = await dio.get('/nonexistent/route');
        expect(response.statusCode, 404);
      });
    });

    group('7. Data Model Validation', () {
      setUp(() {
        expect(authToken, isNotNull);
      });

      test('7.1 User model has all required fields', () async {
        final response = await apiService.login(
          LoginRequest(usernameOrEmail: testEmail, password: testPassword),
        );

        final user = response.user;

        // Required fields
        expect(user.id, isNotEmpty);
        expect(user.organizationId, isNotEmpty);
        expect(user.name, isNotEmpty);
        expect(user.username, isNotEmpty);
        expect(user.email, isNotEmpty);
        expect(
          user.role,
          isIn([
            UserRole.admin,
            UserRole.teamManager,
            UserRole.member,
            UserRole.guest,
          ]),
        );
        expect(user.active, isA<bool>());

        // Optional fields
        expect(user.visibleTopicIds, isA<List<String>>());
      });

      test('7.2 Organization model has all required fields', () async {
        final response = await apiService.login(
          LoginRequest(usernameOrEmail: testEmail, password: testPassword),
        );

        final org = response.organization;

        expect(org.id, isNotEmpty);
        expect(org.name, isNotEmpty);
        expect(org.teamName, isNotEmpty);
        expect(org.slug, isNotEmpty);
        expect(org.isActive, isA<bool>());
        expect(org.maxUsers, isA<int>());
        expect(org.maxUsers, greaterThan(0));
      });

      test('7.3 Task model has all required fields', () async {
        final response = await apiService.getTasks('my_active');

        if (response.tasks.isNotEmpty) {
          final task = response.tasks.first;

          expect(task.id, isNotEmpty);
          expect(task.title, isNotEmpty);
          expect(
            task.status,
            isIn([TaskStatus.todo, TaskStatus.inProgress, TaskStatus.done]),
          );
          expect(
            task.priority,
            isIn([Priority.low, Priority.normal, Priority.high]),
          );
          expect(task.createdAt, isNotEmpty);
          expect(task.updatedAt, isNotEmpty);

          debugPrint('✅ Task model validation passed');
        } else {
          debugPrint('⚠️  No tasks to validate - skipped');
        }
      });
    });
  });
}
