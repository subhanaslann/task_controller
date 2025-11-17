import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/core/network/dio_error_handler.dart';
import 'package:flutter_app/core/exceptions/app_exception.dart';
import 'package:dio/dio.dart';
import 'dart:io';

void main() {
  group('DioErrorHandler Tests', () {
    test('should handle connection timeout error', () {
      // Arrange
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
        message: 'Connection timeout',
      );

      // Act
      final result = DioErrorHandler.handleError(error);

      // Assert
      expect(result, isA<TimeoutException>());
    });

    test('should handle send timeout error', () {
      // Arrange
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.sendTimeout,
      );

      // Act
      final result = DioErrorHandler.handleError(error);

      // Assert
      expect(result, isA<TimeoutException>());
    });

    test('should handle 401 unauthorized error', () {
      // Arrange
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 401,
          data: {
            'error': {'message': 'Unauthorized'},
          },
        ),
      );

      // Act
      final result = DioErrorHandler.handleError(error);

      // Assert
      expect(result, isA<UnauthorizedException>());
    });

    test('should handle 403 forbidden error', () {
      // Arrange
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 403,
          data: {
            'error': {'message': 'Forbidden'},
          },
        ),
      );

      // Act
      final result = DioErrorHandler.handleError(error);

      // Assert
      expect(result, isA<ForbiddenException>());
    });

    test('should handle 404 not found error', () {
      // Arrange
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 404,
        ),
      );

      // Act
      final result = DioErrorHandler.handleError(error);

      // Assert
      expect(result, isA<NotFoundException>());
    });

    test('should handle connection error', () {
      // Arrange
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionError,
        error: const SocketException('No internet'),
      );

      // Act
      final result = DioErrorHandler.handleError(error);

      // Assert
      expect(result, isA<NetworkException>());
    });

    test('should handle cancel error', () {
      // Arrange
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.cancel,
      );

      // Act
      final result = DioErrorHandler.handleError(error);

      // Assert
      expect(result, isA<UnknownException>());
    });
  });
}
