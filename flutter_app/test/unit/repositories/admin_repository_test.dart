import 'package:flutter_app/data/datasources/api_service.dart';
import 'package:flutter_app/data/models/topic.dart';
import 'package:flutter_app/data/models/user.dart';
import 'package:flutter_app/data/repositories/admin_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_data.dart';

class MockApiService extends Mock implements ApiService {}

class FakeCreateUserRequest extends Fake implements CreateUserRequest {}

class FakeUpdateUserRequest extends Fake implements UpdateUserRequest {}

class FakeCreateTopicRequest extends Fake implements CreateTopicRequest {}

class FakeUpdateTopicRequest extends Fake implements UpdateTopicRequest {}

class FakeGuestAccessRequest extends Fake implements GuestAccessRequest {}

void main() {
  late AdminRepository repository;
  late MockApiService mockApiService;

  setUpAll(() {
    registerFallbackValue(FakeCreateUserRequest());
    registerFallbackValue(FakeUpdateUserRequest());
    registerFallbackValue(FakeCreateTopicRequest());
    registerFallbackValue(FakeUpdateTopicRequest());
    registerFallbackValue(FakeGuestAccessRequest());
  });

  setUp(() {
    mockApiService = MockApiService();
    repository = AdminRepository(mockApiService);
  });

  group('AdminRepository - User Management', () {
    test('getUsers should return all users in organization', () async {
      // Arrange
      final testUsers = [
        TestData.adminUser,
        TestData.teamManagerUser,
        TestData.memberUser,
        TestData.guestUser,
      ];
      final mockResponse = UsersResponse(users: testUsers);
      
      when(() => mockApiService.getUsers())
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await repository.getUsers();

      // Assert
      expect(result.length, 4);
      expect(result.any((u) => u.role == UserRole.admin), true);
      expect(result.any((u) => u.role == UserRole.teamManager), true);
      expect(result.any((u) => u.role == UserRole.member), true);
      expect(result.any((u) => u.role == UserRole.guest), true);
      verify(() => mockApiService.getUsers()).called(1);
    });

    test('getUsers should throw on forbidden (member trying to access)', () async {
      // Arrange
      when(() => mockApiService.getUsers())
          .thenThrow(Exception('Forbidden'));

      // Act & Assert
      expect(() => repository.getUsers(), throwsException);
    });

    test('createUser should create new member user', () async {
      // Arrange
      final newUser = TestData.createTestUser(
        id: 'new-user-id',
        name: 'New User',
        username: 'newuser',
        email: 'newuser@test.com',
        role: UserRole.member,
      );
      
      when(() => mockApiService.createUser(any()))
          .thenAnswer((_) async => newUser);

      final request = CreateUserRequest(
        name: 'New User',
        username: 'newuser',
        email: 'newuser@test.com',
        password: 'password123',
        role: UserRole.member.value,
        active: true,
      );

      // Act
      final result = await repository.createUser(request);

      // Assert
      expect(result.name, 'New User');
      expect(result.role, UserRole.member);
      verify(() => mockApiService.createUser(any())).called(1);
    });

    test('createUser should throw on user limit reached (15 max)', () async {
      // Arrange
      when(() => mockApiService.createUser(any()))
          .thenThrow(Exception('User limit reached'));

      final request = CreateUserRequest(
        name: 'User',
        username: 'user16',
        email: 'user16@test.com',
        password: 'password',
        role: UserRole.member.value,
      );

      // Act & Assert
      expect(() => repository.createUser(request), throwsException);
    });

    test('createUser should throw when team manager tries to create admin', () async {
      // Arrange
      when(() => mockApiService.createUser(any()))
          .thenThrow(Exception('Forbidden'));

      final request = CreateUserRequest(
        name: 'Admin',
        username: 'admin',
        email: 'admin@test.com',
        password: 'password',
        role: UserRole.admin.value,
      );

      // Act & Assert
      expect(() => repository.createUser(request), throwsException);
    });

    test('createUser should throw when team manager tries to create another manager', () async {
      // Arrange
      when(() => mockApiService.createUser(any()))
          .thenThrow(Exception('Forbidden'));

      final request = CreateUserRequest(
        name: 'Manager',
        username: 'manager2',
        email: 'manager2@test.com',
        password: 'password',
        role: UserRole.teamManager.value,
      );

      // Act & Assert
      expect(() => repository.createUser(request), throwsException);
    });

    test('updateUser should update user details', () async {
      // Arrange
      const userId = 'user-123';
      when(() => mockApiService.updateUser(userId, any()))
          .thenAnswer((_) async => {});

      final request = UpdateUserRequest(
        name: 'Updated Name',
        active: false,
      );

      // Act
      await repository.updateUser(userId, request);

      // Assert
      verify(() => mockApiService.updateUser(userId, any())).called(1);
    });

    test('updateUser should handle null parse error gracefully', () async {
      // Arrange
      const userId = 'user-123';
      when(() => mockApiService.updateUser(userId, any()))
          .thenThrow(Exception('type Null is not a subtype'));

      final request = UpdateUserRequest(active: false);

      // Act & Assert - Should not throw
      expect(
        () => repository.updateUser(userId, request),
        returnsNormally,
      );
    });
  });

  group('AdminRepository - Topic Management', () {
    test('getTopics should return all topics', () async {
      // Arrange
      final testTopics = TestData.topicList;
      final mockResponse = TopicsResponse(topics: testTopics);
      
      when(() => mockApiService.getTopics())
          .thenAnswer((_) async => mockResponse);

      // Act
      final result = await repository.getTopics();

      // Assert
      expect(result.length, 2);
      expect(result[0].title, 'Backend Development');
      expect(result[1].title, 'Frontend Development');
      verify(() => mockApiService.getTopics()).called(1);
    });

    test('getTopics should throw on forbidden', () async {
      // Arrange
      when(() => mockApiService.getTopics())
          .thenThrow(Exception('Forbidden'));

      // Act & Assert
      expect(() => repository.getTopics(), throwsException);
    });

    test('createTopic should create new topic', () async {
      // Arrange
      final newTopic = TestData.createTestTopic(
        id: 'new-topic-id',
        title: 'New Topic',
        description: 'New topic description',
        isActive: true,
      );
      final mockResponse = TopicResponse(topic: newTopic);
      
      when(() => mockApiService.createTopic(any()))
          .thenAnswer((_) async => mockResponse);

      final request = CreateTopicRequest(
        title: 'New Topic',
        description: 'New topic description',
        isActive: true,
      );

      // Act
      final result = await repository.createTopic(request);

      // Assert
      expect(result.title, 'New Topic');
      expect(result.isActive, true);
      verify(() => mockApiService.createTopic(any())).called(1);
    });

    test('createTopic should throw on validation error', () async {
      // Arrange
      when(() => mockApiService.createTopic(any()))
          .thenThrow(Exception('Validation error'));

      final request = CreateTopicRequest(title: ''); // Empty title

      // Act & Assert
      expect(() => repository.createTopic(request), throwsException);
    });

    test('updateTopic should update topic details', () async {
      // Arrange
      const topicId = 'topic-123';
      final updatedTopic = TestData.createTestTopic(
        id: topicId,
        title: 'Updated Topic',
        isActive: false,
      );
      final mockResponse = TopicResponse(topic: updatedTopic);
      
      when(() => mockApiService.updateTopic(topicId, any()))
          .thenAnswer((_) async => mockResponse);

      final request = UpdateTopicRequest(
        title: 'Updated Topic',
        isActive: false,
      );

      // Act
      final result = await repository.updateTopic(topicId, request);

      // Assert
      expect(result.title, 'Updated Topic');
      expect(result.isActive, false);
      verify(() => mockApiService.updateTopic(topicId, any())).called(1);
    });

    test('updateTopic should throw on topic not found', () async {
      // Arrange
      const topicId = 'non-existent-topic';
      when(() => mockApiService.updateTopic(topicId, any()))
          .thenThrow(Exception('Not found'));

      final request = UpdateTopicRequest(title: 'Updated');

      // Act & Assert
      expect(
        () => repository.updateTopic(topicId, request),
        throwsException,
      );
    });

    test('deleteTopic should delete topic', () async {
      // Arrange
      const topicId = 'topic-to-delete';
      when(() => mockApiService.deleteTopic(topicId))
          .thenAnswer((_) async => {});

      // Act
      await repository.deleteTopic(topicId);

      // Assert
      verify(() => mockApiService.deleteTopic(topicId)).called(1);
    });

    test('deleteTopic should throw on topic not found', () async {
      // Arrange
      const topicId = 'non-existent-topic';
      when(() => mockApiService.deleteTopic(topicId))
          .thenThrow(Exception('Not found'));

      // Act & Assert
      expect(() => repository.deleteTopic(topicId), throwsException);
    });
  });

  group('AdminRepository - Guest Access Management', () {
    test('addGuestAccess should grant guest access to topic', () async {
      // Arrange
      const topicId = 'topic-123';
      const userId = 'guest-user-id';
      when(() => mockApiService.addGuestAccess(topicId, any()))
          .thenAnswer((_) async => {});

      // Act
      await repository.addGuestAccess(topicId, userId);

      // Assert
      verify(() => mockApiService.addGuestAccess(topicId, any())).called(1);
    });

    test('addGuestAccess should throw on validation error', () async {
      // Arrange
      const topicId = 'topic-123';
      const userId = 'non-guest-user'; // User is not a GUEST
      when(() => mockApiService.addGuestAccess(topicId, any()))
          .thenThrow(Exception('User must have GUEST role'));

      // Act & Assert
      expect(
        () => repository.addGuestAccess(topicId, userId),
        throwsException,
      );
    });

    test('removeGuestAccess should revoke guest access from topic', () async {
      // Arrange
      const topicId = 'topic-123';
      const userId = 'guest-user-id';
      when(() => mockApiService.removeGuestAccess(topicId, userId))
          .thenAnswer((_) async => {});

      // Act
      await repository.removeGuestAccess(topicId, userId);

      // Assert
      verify(() => mockApiService.removeGuestAccess(topicId, userId)).called(1);
    });

    test('removeGuestAccess should throw on access not found', () async {
      // Arrange
      const topicId = 'topic-123';
      const userId = 'guest-user-id';
      when(() => mockApiService.removeGuestAccess(topicId, userId))
          .thenThrow(Exception('Access not found'));

      // Act & Assert
      expect(
        () => repository.removeGuestAccess(topicId, userId),
        throwsException,
      );
    });
  });
}

