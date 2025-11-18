import 'package:flutter_app/core/exceptions/app_exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NetworkException', () {
    test('should create NetworkException with default message', () {
      // Act
      final exception = NetworkException();

      // Assert
      expect(exception.message, contains('bağlantı'));
      expect(exception, isA<AppException>());
    });

    test('should create NetworkException with custom message', () {
      // Act
      final exception = NetworkException(message: 'Network error');

      // Assert
      expect(exception.message, 'Network error');
    });
  });

  group('ServerException', () {
    test('should create ServerException with status code', () {
      // Act
      final exception = ServerException(message: 'Server error', statusCode: 500);

      // Assert
      expect(exception.message, 'Server error');
      expect(exception.statusCode, 500);
    });
  });

  group('ValidationException', () {
    test('should create ValidationException with field errors', () {
      // Act
      final errors = {'email': ['Invalid email'], 'password': ['Too short']};
      final exception = ValidationException(message: 'Validation failed', fieldErrors: errors);

      // Assert
      expect(exception.message, 'Validation failed');
      expect(exception.fieldErrors, errors);
      expect(exception.fieldErrors?['email'], contains('Invalid email'));
    });
  });

  group('UnauthorizedException', () {
    test('should create UnauthorizedException with default message', () {
      // Act
      final exception = UnauthorizedException();

      // Assert
      expect(exception.message, contains('Oturum'));
      expect(exception.statusCode, 401);
    });

    test('should create UnauthorizedException with custom message', () {
      // Act
      final exception = UnauthorizedException(message: 'Not authorized');

      // Assert
      expect(exception.message, 'Not authorized');
      expect(exception.statusCode, 401);
    });
  });

  group('NotFoundException', () {
    test('should create NotFoundException', () {
      // Act
      final exception = NotFoundException(message: 'Resource not found');

      // Assert
      expect(exception.message, 'Resource not found');
      expect(exception.statusCode, 404);
    });
  });

  group('BadRequestException', () {
    test('should create BadRequestException', () {
      // Act
      final exception = BadRequestException(message: 'Bad request');

      // Assert
      expect(exception.message, 'Bad request');
      expect(exception.statusCode, 400);
    });
  });

  group('CacheException', () {
    test('should create CacheException', () {
      // Act
      final exception = CacheException(message: 'Cache error');

      // Assert
      expect(exception.message, 'Cache error');
    });
  });
}
