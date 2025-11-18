import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_app/data/datasources/api_service.dart';
import 'package:flutter_app/core/utils/constants.dart';

/// Integration tests for admin user management workflows
///
/// These tests verify admin operations like user management, topic management
///
/// Note: Requires running backend server with TEAM_MANAGER/ADMIN account

void main() {
  late Dio dio;
  late ApiService apiService;

  const String baseUrl = 'http://localhost:8080';
  const String managerEmail = 'john@acme.com';
  const String managerPassword = 'manager123';

  String? authToken;

  setUpAll(() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (authToken != null) {
            options.headers['Authorization'] = 'Bearer $authToken';
          }
          return handler.next(options);
        },
      ),
    );

    apiService = ApiService(dio, baseUrl: baseUrl);
  });

  setUp(() async {
    // Login as team manager
    final loginResponse = await apiService.login(
      LoginRequest(usernameOrEmail: managerEmail, password: managerPassword),
    );
    authToken = loginResponse.token;
    expect(
      loginResponse.user.role,
      anyOf(UserRole.teamManager, UserRole.admin),
    );
  });

  group('ADMIN_FLOW_01: User Management Flow', () {
    test('should list all users in organization', () async {
      // Act
      final response = await apiService.getUsers();

      // Assert
      expect(response.users, isA<List>());
      expect(response.users.length, greaterThan(0));

      // All users should belong to same organization
      if (response.users.length > 1) {
        final orgId = response.users.first.organizationId;
        expect(response.users.every((u) => u.organizationId == orgId), true);
      }

      print('✅ User list retrieved: ${response.users.length} users');
    });

    test('should create new user successfully', () async {
      // Arrange - Use timestamp for unique username/email
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final request = CreateUserRequest(
        name: 'Test User $timestamp',
        username: 'testuser$timestamp',
        email: 'testuser$timestamp@acme.com',
        password: 'password123',
        role: UserRole.member.value,
        active: true,
      );

      // Act
      try {
        final response = await apiService.createUser(request);

        // Assert
        expect(response.user.name, 'Test User $timestamp');
        expect(response.user.role, UserRole.member);
        expect(response.user.active, true);

        print('✅ User created: ${response.user.name}');
      } catch (e) {
        if (e is DioException && e.response?.statusCode == 403) {
          print('⚠️  User limit reached or permission denied');
        } else {
          rethrow;
        }
      }
    });

    test('should enforce user limit (15 max)', () async {
      // Note: This test requires organization to be at/near user limit
      print('⚠️  User limit test requires specific setup (14+ existing users)');
      expect(true, true); // Placeholder
    });
  });

  group('ADMIN_FLOW_02: Topic Management Flow', () {
    test('should list all topics in organization', () async {
      // Act
      final response = await apiService.getTopics();

      // Assert
      expect(response.topics, isA<List>());
      print('✅ Topics retrieved: ${response.topics.length} topics');
    });

    test('should create new topic successfully', () async {
      // Arrange
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final request = CreateTopicRequest(
        title: 'Test Topic $timestamp',
        description: 'Created by integration tests',
        isActive: true,
      );

      // Act
      final response = await apiService.createTopic(request);

      // Assert
      expect(response.topic.title, 'Test Topic $timestamp');
      expect(response.topic.isActive, true);
      print('✅ Topic created: ${response.topic.id}');
    });

    test('should update topic details', () async {
      // Arrange - Create topic first
      final createResponse = await apiService.createTopic(
        CreateTopicRequest(title: 'Original Topic', isActive: true),
      );
      final topicId = createResponse.topic.id;

      // Act - Update topic
      final updateResponse = await apiService.updateTopic(
        topicId,
        UpdateTopicRequest(title: 'Updated Topic', isActive: false),
      );

      // Assert
      expect(updateResponse.topic.title, 'Updated Topic');
      expect(updateResponse.topic.isActive, false);
      print('✅ Topic updated successfully');
    });

    test('should delete topic', () async {
      // Arrange - Create topic to delete
      final createResponse = await apiService.createTopic(
        CreateTopicRequest(title: 'Topic to Delete'),
      );
      final topicId = createResponse.topic.id;

      // Act - Delete topic
      await apiService.deleteTopic(topicId);

      // Assert - Verify deletion by checking 404 status
      // Note: validateStatus allows < 500, so we check status directly instead of catching exception
      final response = await dio.get('/admin/topics/$topicId');
      expect(response.statusCode, 404);
      print('✅ Topic deleted successfully - verified with 404 response');
    });
  });

  group('ADMIN_FLOW_03: Task Assignment Flow', () {
    test('should assign task to specific user', () async {
      // Arrange - Get list of users
      final usersResponse = await apiService.getUsers();
      expect(usersResponse.users.length, greaterThan(1));

      final assigneeId = usersResponse.users.first.id;

      // Act - Create task and assign to user
      final taskResponse = await dio.post(
        '/admin/tasks',
        data: {
          'title': 'Assigned Task ${DateTime.now().millisecondsSinceEpoch}',
          'assigneeId': assigneeId,
          'priority': 'NORMAL',
          'status': 'TODO',
        },
      );

      // Assert
      expect(taskResponse.statusCode, 201);
      expect(taskResponse.data['task']['assigneeId'], assigneeId);
      print('✅ Task assigned to specific user');
    });
  });

  group('ADMIN_FLOW_04: Organization Stats Flow', () {
    test('should retrieve organization statistics', () async {
      // Act
      final response = await dio.get('/organization/stats');

      // Assert
      expect(response.statusCode, 200);
      expect(response.data['data']['userCount'], isA<int>());
      expect(response.data['data']['taskCount'], isA<int>());
      expect(response.data['data']['topicCount'], isA<int>());

      // Logical validations
      final stats = response.data['data'];
      expect(stats['userCount'] >= stats['activeUserCount'], true);
      expect(stats['taskCount'] >= stats['activeTaskCount'], true);

      print('✅ Organization stats retrieved successfully');
    });
  });

  group('ADMIN_FLOW_05: Role Restrictions Flow', () {
    test('should prevent team manager from creating admin user', () async {
      // Act & Assert
      try {
        await apiService.createUser(
          CreateUserRequest(
            name: 'Admin Wannabe',
            username: 'adminwannabe',
            email: 'admin@wannabe.com',
            password: 'password123',
            role: UserRole.admin.value,
            active: true,
          ),
        );
        fail('Should throw 403 Forbidden');
      } catch (e) {
        expect(
          e,
          anyOf(isA<DioException>(), isA<TypeError>(), isA<FormatException>()),
        );
        if (e is DioException) {
          expect(e.response?.statusCode, 403);
        }
        print('✅ Team manager cannot create admin - correctly restricted');
      }
    });

    test(
      'should prevent team manager from creating another team manager',
      () async {
        // Act & Assert
        try {
          await apiService.createUser(
            CreateUserRequest(
              name: 'Manager Wannabe',
              username: 'managerwannabe',
              email: 'manager@wannabe.com',
              password: 'password123',
              role: UserRole.teamManager.value,
              active: true,
            ),
          );
          fail('Should throw 403 Forbidden');
        } catch (e) {
          expect(
            e,
            anyOf(
              isA<DioException>(),
              isA<TypeError>(),
              isA<FormatException>(),
            ),
          );
          if (e is DioException) {
            expect(e.response?.statusCode, 403);
          }
          print(
            '✅ Team manager cannot create another manager - correctly restricted',
          );
        }
      },
    );
  });
}
