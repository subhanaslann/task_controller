import 'package:flutter_app/data/datasources/api_service.dart';
import 'package:mocktail/mocktail.dart';

class MockApiService extends Mock implements ApiService {
  // This mock can be used for low-level API testing
  // Most tests should use repository mocks instead
  
  // Mock login
  void mockLogin(Map<String, dynamic> response) {
    when(() => login(any())).thenAnswer((_) async => response as LoginResponse);
  }

  void mockLoginError(Exception error) {
    when(() => login(any())).thenThrow(error);
  }

  // Mock register
  void mockRegister(Map<String, dynamic> response) {
    when(() => register(any())).thenAnswer((_) async => response as RegisterResponse);
  }

  // Add more API endpoint mocks as needed
}

