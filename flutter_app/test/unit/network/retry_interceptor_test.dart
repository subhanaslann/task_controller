import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/core/network/interceptors/retry_interceptor.dart';

void main() {
  group('RetryInterceptor Tests', () {
    test('should create retry interceptor with default values', () {
      // Arrange & Act
      final interceptor = RetryInterceptor();

      // Assert
      expect(interceptor, isA<RetryInterceptor>());
    });

    test('should create retry interceptor with custom max retries', () {
      // Arrange & Act
      final interceptor = RetryInterceptor(maxRetries: 5);

      // Assert
      expect(interceptor, isA<RetryInterceptor>());
    });

    test('should create retry interceptor with custom initial delay', () {
      // Arrange & Act
      final interceptor = RetryInterceptor(
        initialDelay: const Duration(seconds: 1),
      );

      // Assert
      expect(interceptor, isA<RetryInterceptor>());
    });

    test('should create retry interceptor with all custom parameters', () {
      // Arrange & Act
      final interceptor = RetryInterceptor(
        maxRetries: 3,
        initialDelay: const Duration(milliseconds: 500),
      );

      // Assert
      expect(interceptor, isA<RetryInterceptor>());
    });
  });
}
