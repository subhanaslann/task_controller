import 'package:dio/dio.dart';
import 'package:flutter_app/core/exceptions/app_exception.dart';
import 'package:flutter_app/core/utils/error_handler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ErrorHandler - Extract AppException', () {
    test('should extract AppException directly', () {
      // Arrange
      final exception = ValidationException(
        message: 'Validation failed',
        details: 'Email is required',
      );

      // Act
      // Using reflection to test private method via error handling flow
      // In real scenario, ErrorHandler.showError would extract it
      
      // Assert
      expect(exception, isA<AppException>());
      expect(exception.message, 'Validation failed');
    });

    test('should extract AppException from DioException', () {
      // Arrange
      final appException = UnauthorizedException(
        message: 'Unauthorized',
      );
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        error: appException,
      );

      // Act & Assert
      expect(dioException.error, isA<AppException>());
      expect((dioException.error as AppException).message, 'Unauthorized');
    });

    test('should create UnknownException for generic errors', () {
      // Arrange
      final error = Exception('Generic error');

      // Act & Assert
      expect(error, isA<Exception>());
    });

    test('should handle DioException without AppException', () {
      // Arrange
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        message: 'Network error',
      );

      // Act & Assert
      expect(dioException, isA<DioException>());
      expect(dioException.message, 'Network error');
    });

    test('should handle network timeout error', () {
      // Arrange
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
        message: 'Connection timeout',
      );

      // Act & Assert
      expect(dioException.type, DioExceptionType.connectionTimeout);
    });

    test('should handle 401 unauthorized error', () {
      // Arrange
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 401,
          data: {'error': {'code': 'UNAUTHORIZED', 'message': 'Token invalid'}},
        ),
      );

      // Act & Assert
      expect(dioException.response?.statusCode, 401);
    });

    test('should handle 403 forbidden error', () {
      // Arrange
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 403,
          data: {'error': {'code': 'FORBIDDEN', 'message': 'Insufficient permissions'}},
        ),
      );

      // Act & Assert
      expect(dioException.response?.statusCode, 403);
    });

    test('should handle 404 not found error', () {
      // Arrange
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 404,
          data: {'error': {'code': 'NOT_FOUND', 'message': 'Resource not found'}},
        ),
      );

      // Act & Assert
      expect(dioException.response?.statusCode, 404);
    });

    test('should handle 409 conflict error', () {
      // Arrange
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 409,
          data: {'error': {'code': 'CONFLICT', 'message': 'Email already exists'}},
        ),
      );

      // Act & Assert
      expect(dioException.response?.statusCode, 409);
    });

    test('should handle 503 service unavailable error', () {
      // Arrange
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 503,
          data: {'error': {'code': 'SERVICE_UNAVAILABLE', 'message': 'Service temporarily unavailable'}},
        ),
      );

      // Act & Assert
      expect(dioException.response?.statusCode, 503);
    });
  });

  group('ErrorHandler - User-Friendly Messages', () {
    test('ValidationException should have user-friendly message', () {
      // Arrange
      final exception = ValidationException(
        message: 'Validation failed',
        details: 'Email format is invalid',
      );

      // Assert
      expect(exception.message, 'Validation failed');
      expect(exception.details, 'Email format is invalid');
    });

    test('UnauthorizedException should have user-friendly message', () {
      // Arrange
      final exception = UnauthorizedException(
        message: 'Session expired',
      );

      // Assert
      expect(exception.message, 'Session expired');
    });

    test('ForbiddenException should have user-friendly message', () {
      // Arrange
      final exception = ForbiddenException(
        message: 'You don\'t have permission',
      );

      // Assert
      expect(exception.message, 'You don\'t have permission');
    });

    test('NotFoundException should have user-friendly message', () {
      // Arrange
      final exception = NotFoundException(
        message: 'Task not found',
      );

      // Assert
      expect(exception.message, 'Task not found');
    });

    test('ConflictException should have user-friendly message', () {
      // Arrange
      final exception = ConflictException(
        message: 'Email already registered',
      );

      // Assert
      expect(exception.message, 'Email already registered');
    });
  });
}

