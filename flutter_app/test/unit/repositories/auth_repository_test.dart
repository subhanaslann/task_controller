import 'package:flutter_app/core/storage/secure_storage.dart';
import 'package:flutter_app/core/utils/constants.dart';
import 'package:flutter_app/data/datasources/api_service.dart';
import 'package:flutter_app/data/models/organization.dart';
import 'package:flutter_app/data/models/user.dart';
import 'package:flutter_app/data/repositories/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/test_data.dart';

class MockApiService extends Mock implements ApiService {}

class MockSecureStorage extends Mock implements SecureStorage {}

class FakeLoginRequest extends Fake implements LoginRequest {}

class FakeRegisterRequest extends Fake implements RegisterRequest {}

void main() {
  late AuthRepository repository;
  late MockApiService mockApiService;
  late MockSecureStorage mockStorage;

  setUpAll(() {
    registerFallbackValue(FakeLoginRequest());
    registerFallbackValue(FakeRegisterRequest());
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    mockApiService = MockApiService();
    mockStorage = MockSecureStorage();
    repository = AuthRepository(mockApiService, mockStorage);
  });

  group('AuthRepository - Login', () {
    test('login should save token and return user with organization', () async {
      // Arrange
      final testUser = TestData.memberUser;
      final testOrg = TestData.testOrganization;
      final mockResponse = AuthResponse(
        token: 'test-jwt-token',
        user: testUser,
        organization: testOrg,
      );

      when(() => mockApiService.login(any())).thenAnswer((_) async => mockResponse);
      when(() => mockStorage.saveToken(any())).thenAnswer((_) async => {});
      when(() => mockStorage.saveOrganization(any())).thenAnswer((_) async => {});

      // Act
      final result = await repository.login('testuser@test.com', 'password123');

      // Assert
      expect(result.user.id, testUser.id);
      expect(result.user.email, testUser.email);
      expect(result.organization.id, testOrg.id);
      
      verify(() => mockApiService.login(any())).called(1);
      verify(() => mockStorage.saveToken('test-jwt-token')).called(1);
      verify(() => mockStorage.saveOrganization(any())).called(1);
    });

    test('login should throw exception on invalid credentials', () async {
      // Arrange
      when(() => mockApiService.login(any())).thenThrow(
        Exception('Invalid credentials'),
      );

      // Act & Assert
      expect(
        () => repository.login('wrong@test.com', 'wrongpass'),
        throwsException,
      );
      
      verifyNever(() => mockStorage.saveToken(any()));
    });

    test('login should handle network error', () async {
      // Arrange
      when(() => mockApiService.login(any())).thenThrow(
        Exception('Network error'),
      );

      // Act & Assert
      expect(
        () => repository.login('test@test.com', 'password'),
        throwsException,
      );
    });

    test('login should pass correct credentials to API', () async {
      // Arrange
      final testUser = TestData.memberUser;
      final testOrg = TestData.testOrganization;
      final mockResponse = AuthResponse(
        token: 'test-token',
        user: testUser,
        organization: testOrg,
      );

      LoginRequest? capturedRequest;
      when(() => mockApiService.login(any())).thenAnswer((invocation) async {
        capturedRequest = invocation.positionalArguments[0] as LoginRequest;
        return mockResponse;
      });
      when(() => mockStorage.saveToken(any())).thenAnswer((_) async => {});
      when(() => mockStorage.saveOrganization(any())).thenAnswer((_) async => {});

      // Act
      await repository.login('testuser', 'mypassword');

      // Assert
      expect(capturedRequest?.usernameOrEmail, 'testuser');
      expect(capturedRequest?.password, 'mypassword');
    });
  });

  group('AuthRepository - Register', () {
    test('register should create new team and save token', () async {
      // Arrange
      final testUser = TestData.teamManagerUser;
      final testOrg = TestData.testOrganization;
      final mockResponse = RegisterResponse(
        message: 'Team registered successfully',
        data: RegisterData(
          organization: testOrg,
          user: testUser,
          token: 'new-team-token',
        ),
      );

      when(() => mockApiService.register(any())).thenAnswer((_) async => mockResponse);
      when(() => mockStorage.saveToken(any())).thenAnswer((_) async => {});
      when(() => mockStorage.saveOrganization(any())).thenAnswer((_) async => {});

      // Act
      final result = await repository.register(
        companyName: 'Test Company',
        teamName: 'Test Team',
        managerName: 'Test Manager',
        email: 'manager@test.com',
        password: 'password123',
      );

      // Assert
      expect(result.user.role, UserRole.teamManager);
      expect(result.organization.name, testOrg.name);
      
      verify(() => mockApiService.register(any())).called(1);
      verify(() => mockStorage.saveToken('new-team-token')).called(1);
      verify(() => mockStorage.saveOrganization(any())).called(1);
    });

    test('register should throw exception on duplicate email', () async {
      // Arrange
      when(() => mockApiService.register(any())).thenThrow(
        Exception('Email already registered'),
      );

      // Act & Assert
      expect(
        () => repository.register(
          companyName: 'Company',
          teamName: 'Team',
          managerName: 'Manager',
          email: 'existing@test.com',
          password: 'password',
        ),
        throwsException,
      );
      
      verifyNever(() => mockStorage.saveToken(any()));
    });

    test('register should validate password length', () async {
      // Arrange - password too short should be rejected by API
      when(() => mockApiService.register(any())).thenThrow(
        Exception('Password too short'),
      );

      // Act & Assert
      expect(
        () => repository.register(
          companyName: 'Company',
          teamName: 'Team',
          managerName: 'Manager',
          email: 'test@test.com',
          password: 'short',
        ),
        throwsException,
      );
    });
  });

  group('AuthRepository - Logout', () {
    test('logout should clear all stored data', () async {
      // Arrange
      when(() => mockStorage.clearAll()).thenAnswer((_) async => {});

      // Act
      await repository.logout();

      // Assert
      verify(() => mockStorage.clearAll()).called(1);
    });

    test('logout should not throw if storage is already empty', () async {
      // Arrange
      when(() => mockStorage.clearAll()).thenAnswer((_) async => {});

      // Act & Assert
      expect(() => repository.logout(), returnsNormally);
    });
  });

  group('AuthRepository - Token Management', () {
    test('isLoggedIn should return true when token exists', () async {
      // Arrange
      when(() => mockStorage.hasToken()).thenAnswer((_) async => true);

      // Act
      final result = await repository.isLoggedIn();

      // Assert
      expect(result, true);
      verify(() => mockStorage.hasToken()).called(1);
    });

    test('isLoggedIn should return false when token does not exist', () async {
      // Arrange
      when(() => mockStorage.hasToken()).thenAnswer((_) async => false);

      // Act
      final result = await repository.isLoggedIn();

      // Assert
      expect(result, false);
    });

    test('getToken should return stored token', () async {
      // Arrange
      when(() => mockStorage.getToken()).thenAnswer((_) async => 'stored-token');

      // Act
      final token = await repository.getToken();

      // Assert
      expect(token, 'stored-token');
      verify(() => mockStorage.getToken()).called(1);
    });

    test('getToken should return null when no token exists', () async {
      // Arrange
      when(() => mockStorage.getToken()).thenAnswer((_) async => null);

      // Act
      final token = await repository.getToken();

      // Assert
      expect(token, null);
    });
  });

  group('AuthRepository - Organization Storage', () {
    test('getStoredOrganization should return organization from storage', () async {
      // Arrange
      final testOrg = TestData.testOrganization;
      when(() => mockStorage.getOrganization()).thenAnswer((_) async => testOrg.toJson());

      // Act
      final result = await repository.getStoredOrganization();

      // Assert
      expect(result, isNotNull);
      expect(result!.id, testOrg.id);
      expect(result.name, testOrg.name);
      verify(() => mockStorage.getOrganization()).called(1);
    });

    test('getStoredOrganization should return null when no organization stored', () async {
      // Arrange
      when(() => mockStorage.getOrganization()).thenAnswer((_) async => null);

      // Act
      final result = await repository.getStoredOrganization();

      // Assert
      expect(result, null);
    });
  });
}

