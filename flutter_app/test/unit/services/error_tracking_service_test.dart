import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/core/services/error_tracking_service.dart';

// Note: This test file verifies the error tracking service structure
// Actual Sentry calls are not tested as they require platform integration
void main() {
  group('ErrorTrackingService Tests', () {
    test('should call reportError without throwing when not initialized',
        () async {
      // Arrange
      final exception = Exception('Test error');
      final stackTrace = StackTrace.current;

      // Act & Assert - Should not throw
      expect(
        () async => await ErrorTrackingService.reportError(
          exception,
          stackTrace,
          context: 'Test context',
        ),
        returnsNormally,
      );
    });

    test('should call addBreadcrumb without throwing', () {
      // Act & Assert - Should not throw
      expect(
        () => ErrorTrackingService.addBreadcrumb(
          message: 'Test breadcrumb',
          category: 'test',
        ),
        returnsNormally,
      );
    });

    test('should call setUser without throwing', () {
      // Act & Assert - Should not throw
      expect(
        () => ErrorTrackingService.setUser(
          id: 'user123',
          data: {'role': 'admin'},
        ),
        returnsNormally,
      );
    });

    test('should call clearUser without throwing', () {
      // Act & Assert - Should not throw
      expect(
        () => ErrorTrackingService.clearUser(),
        returnsNormally,
      );
    });

    test('should call setTag without throwing', () {
      // Act & Assert - Should not throw
      expect(
        () => ErrorTrackingService.setTag('env', 'test'),
        returnsNormally,
      );
    });

    test('should call setContext without throwing', () {
      // Act & Assert - Should not throw
      expect(
        () => ErrorTrackingService.setContext('test', {'key': 'value'}),
        returnsNormally,
      );
    });

    test('should call captureMessage without throwing', () async {
      // Act & Assert - Should not throw
      expect(
        () async => await ErrorTrackingService.captureMessage(
          'Test message',
          extra: {'context': 'test'},
        ),
        returnsNormally,
      );
    });
  });
}

