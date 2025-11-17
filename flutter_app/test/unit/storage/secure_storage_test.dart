import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/core/storage/secure_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SecureStorage Tests', () {
    late SecureStorage secureStorage;

    setUp(() {
      // Mock flutter_secure_storage for testing
      FlutterSecureStorage.setMockInitialValues({});
      secureStorage = SecureStorage();
    });

    test('should save and retrieve token', () async {
      // Arrange
      const token = 'test_token_123';

      // Act
      await secureStorage.saveToken(token);
      final retrievedToken = await secureStorage.getToken();

      // Assert
      expect(retrievedToken, token);
    });

    test('should return null when no token is stored', () async {
      // Act
      final token = await secureStorage.getToken();

      // Assert
      expect(token, null);
    });

    test('should delete token', () async {
      // Arrange
      const token = 'test_token_123';
      await secureStorage.saveToken(token);

      // Act
      await secureStorage.deleteToken();
      final retrievedToken = await secureStorage.getToken();

      // Assert
      expect(retrievedToken, null);
    });

    test('should check if token exists', () async {
      // Arrange
      const token = 'test_token_123';

      // Act & Assert - Initially no token
      expect(await secureStorage.hasToken(), false);

      // Save token
      await secureStorage.saveToken(token);
      expect(await secureStorage.hasToken(), true);

      // Delete token
      await secureStorage.deleteToken();
      expect(await secureStorage.hasToken(), false);
    });

    test('should save and retrieve organization data', () async {
      // Arrange
      final orgData = {
        'id': 'org123',
        'name': 'Test Organization',
        'isActive': true,
      };

      // Act
      await secureStorage.saveOrganization(orgData);
      final retrievedData = await secureStorage.getOrganization();

      // Assert
      expect(retrievedData, orgData);
    });

    test('should return null when no organization is stored', () async {
      // Act
      final orgData = await secureStorage.getOrganization();

      // Assert
      expect(orgData, null);
    });

    test('should delete organization data', () async {
      // Arrange
      final orgData = {'id': 'org123', 'name': 'Test Organization'};
      await secureStorage.saveOrganization(orgData);

      // Act
      await secureStorage.deleteOrganization();
      final retrievedData = await secureStorage.getOrganization();

      // Assert
      expect(retrievedData, null);
    });

    test('should clear all data', () async {
      // Arrange
      const token = 'test_token_123';
      final orgData = {'id': 'org123', 'name': 'Test Organization'};
      await secureStorage.saveToken(token);
      await secureStorage.saveOrganization(orgData);

      // Act
      await secureStorage.clearAll();

      // Assert
      expect(await secureStorage.getToken(), null);
      expect(await secureStorage.getOrganization(), null);
    });
  });
}
