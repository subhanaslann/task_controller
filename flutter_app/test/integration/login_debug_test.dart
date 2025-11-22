import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_app/data/datasources/api_service.dart';
import 'package:flutter_app/core/utils/constants.dart';

/// Debug test to investigate login issues with custom username
///
/// To run this test:
/// flutter test test/integration/login_debug_test.dart
void main() {
  late Dio dio;
  late ApiService apiService;

  const String baseUrl = 'http://localhost:8080';
  
  // Unique credentials for this test run
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final testUsername = 'debug_user_$timestamp';
  final testEmail = 'debug_$timestamp@example.com';
  const testPassword = 'Password123!';

  setUpAll(() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    // Add interceptor for logging
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint('REQUEST: ${options.method} ${options.path}');
          debugPrint('DATA: ${options.data}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('RESPONSE: ${response.statusCode}');
          return handler.next(response);
        },
        onError: (error, handler) {
          debugPrint('ERROR: ${error.message}');
          if (error.response != null) {
            debugPrint('ERROR DATA: ${error.response?.data}');
          }
          return handler.next(error);
        },
      ),
    );

    apiService = ApiService(dio, baseUrl: baseUrl);
  });

  group('Login Debug Tests', () {
    test('should register with custom username and login successfully', () async {
      debugPrint('\n--- STARTING REGISTRATION ---');
      debugPrint('Attempting to register with username: $testUsername');

      try {
        // 1. Register
        final registerResponse = await apiService.register(
          RegisterRequest(
            companyName: 'Debug Company',
            teamName: 'Debug Team',
            managerName: 'Debug Manager',
            username: testUsername, // Explicitly setting username
            email: testEmail,
            password: testPassword,
          ),
        );

        expect(registerResponse.data.token, isNotEmpty);
        expect(registerResponse.data.user.username, testUsername);
        debugPrint('✅ Registration Successful!');
        debugPrint('Registered Username: ${registerResponse.data.user.username}');

        // 2. Login with Username
        debugPrint('\n--- ATTEMPTING LOGIN WITH USERNAME ---');
        final loginResponse = await apiService.login(
          LoginRequest(
            usernameOrEmail: testUsername,
            password: testPassword,
          ),
        );

        expect(loginResponse.token, isNotEmpty);
        expect(loginResponse.user.username, testUsername);
        debugPrint('✅ Login with Username Successful!');

        // 3. Login with Email
        debugPrint('\n--- ATTEMPTING LOGIN WITH EMAIL ---');
        final loginEmailResponse = await apiService.login(
          LoginRequest(
            usernameOrEmail: testEmail,
            password: testPassword,
          ),
        );

        expect(loginEmailResponse.token, isNotEmpty);
        debugPrint('✅ Login with Email Successful!');

      } catch (e) {
        debugPrint('❌ TEST FAILED');
        if (e is DioException) {
          debugPrint('Status: ${e.response?.statusCode}');
          debugPrint('Data: ${e.response?.data}');
        } else {
          debugPrint('Error: $e');
        }
        rethrow;
      }
    });
  });
}
