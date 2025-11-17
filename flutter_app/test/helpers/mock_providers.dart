import 'package:flutter_app/core/storage/secure_storage.dart';
import 'package:flutter_app/data/datasources/api_service.dart';
import 'package:flutter_app/data/repositories/admin_repository.dart';
import 'package:flutter_app/data/repositories/auth_repository.dart';
import 'package:flutter_app/data/repositories/organization_repository.dart';
import 'package:flutter_app/data/repositories/task_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

/// Mock classes for testing

class MockApiService extends Mock implements ApiService {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockTaskRepository extends Mock implements TaskRepository {}

class MockOrganizationRepository extends Mock implements OrganizationRepository {}

class MockAdminRepository extends Mock implements AdminRepository {}

class MockSecureStorage extends Mock implements SecureStorage {}

/// Provider overrides for testing
class MockProviders {
  static List<Override> withMockApiService(MockApiService mockApiService) {
    return [
      // Override API service provider
      // Note: Adjust provider names based on actual implementation
    ];
  }

  static List<Override> withMockRepositories({
    MockAuthRepository? authRepo,
    MockTaskRepository? taskRepo,
    MockOrganizationRepository? orgRepo,
    MockAdminRepository? adminRepo,
  }) {
    return [
      // Override repository providers
      // Note: Adjust provider names based on actual implementation
    ];
  }

  static List<Override> withMockStorage(MockSecureStorage storage) {
    return [
      // Override storage provider
    ];
  }
}

/// Helper to set up common mocks
void setupMockRepositories({
  MockAuthRepository? authRepo,
  MockTaskRepository? taskRepo,
  MockOrganizationRepository? orgRepo,
  MockAdminRepository? adminRepo,
}) {
  // Register fallback values for mocktail
  registerFallbackValue(Uri());
}

