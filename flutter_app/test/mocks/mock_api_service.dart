import 'package:flutter_app/data/datasources/api_service.dart';
import 'package:mocktail/mocktail.dart';

class MockApiService extends Mock implements ApiService {
  // This mock can be used for low-level API testing
  // Most tests should use repository mocks instead

  // Mock login
  void mockLogin(AuthResponse response) {
    when(() => login(any())).thenAnswer((_) async => response);
  }

  void mockLoginError(Exception error) {
    when(() => login(any())).thenThrow(error);
  }

  // Mock register
  void mockRegister(RegisterResponse response) {
    when(() => register(any())).thenAnswer((_) async => response);
  }

  // Add more API endpoint mocks as needed
}
