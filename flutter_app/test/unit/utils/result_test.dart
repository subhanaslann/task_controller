import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/core/utils/result.dart';

void main() {
  group('Result Tests', () {
    test('should create Success result', () {
      // Arrange & Act
      final result = Success(42);

      // Assert
      expect(result.isSuccess, true);
      expect(result.isFailure, false);
      expect(result.data, 42);
    });

    test('should create Failure result', () {
      // Arrange & Act
      final result = Failure<int>(const NetworkException('No internet'));

      // Assert
      expect(result.isSuccess, false);
      expect(result.isFailure, true);
      expect(result.exception, isA<NetworkException>());
    });

    test('should get data or null from Success', () {
      // Arrange
      final result = Success(42);

      // Act
      final data = result.getOrNull();

      // Assert
      expect(data, 42);
    });

    test('should get null from Failure', () {
      // Arrange
      final result = Failure<int>(const NetworkException());

      // Act
      final data = result.getOrNull();

      // Assert
      expect(data, null);
    });

    test('should get data or throw from Success', () {
      // Arrange
      final result = Success(42);

      // Act
      final data = result.getOrThrow();

      // Assert
      expect(data, 42);
    });

    test('should throw exception from Failure', () {
      // Arrange
      final result = Failure<int>(const NetworkException('Error'));

      // Act & Assert
      expect(() => result.getOrThrow(), throwsA(isA<NetworkException>()));
    });

    test('should get data or default value', () {
      // Arrange
      final successResult = Success(42);
      final failureResult = Failure<int>(const NetworkException());

      // Act & Assert
      expect(successResult.getOrDefault(0), 42);
      expect(failureResult.getOrDefault(0), 0);
    });

    test('should map success data', () {
      // Arrange
      final result = Success(42);

      // Act
      final mapped = result.map((data) => data * 2);

      // Assert
      expect(mapped.isSuccess, true);
      expect(mapped.getOrNull(), 84);
    });

    test('should not map failure', () {
      // Arrange
      final result = Failure<int>(const NetworkException());

      // Act
      final mapped = result.map((data) => data * 2);

      // Assert
      expect(mapped.isFailure, true);
      expect(mapped.getOrNull(), null);
    });

    test('should fold success result', () {
      // Arrange
      final result = Success(42);

      // Act
      final folded = result.fold(
        onSuccess: (data) => 'Success: $data',
        onFailure: (exception) => 'Error: ${exception.message}',
      );

      // Assert
      expect(folded, 'Success: 42');
    });

    test('should fold failure result', () {
      // Arrange
      final result = Failure<int>(const NetworkException('No connection'));

      // Act
      final folded = result.fold(
        onSuccess: (data) => 'Success: $data',
        onFailure: (exception) => 'Error: ${exception.message}',
      );

      // Assert
      expect(folded, 'Error: No connection');
    });

    test('should flatMap success result', () {
      // Arrange
      final result = Success(42);

      // Act
      final flatMapped = result.flatMap((data) => Success(data * 2));

      // Assert
      expect(flatMapped.isSuccess, true);
      expect(flatMapped.getOrNull(), 84);
    });

    test('should not flatMap failure result', () {
      // Arrange
      final result = Failure<int>(const NetworkException());

      // Act
      final flatMapped = result.flatMap((data) => Success(data * 2));

      // Assert
      expect(flatMapped.isFailure, true);
    });
  });

  group('AppException Tests', () {
    test('should create NetworkException', () {
      // Arrange & Act
      const exception = NetworkException('Connection error');

      // Assert
      expect(exception.message, 'Connection error');
      expect(exception.toString(), 'Connection error');
    });

    test('should create ServerException', () {
      // Arrange & Act
      const exception = ServerException('500', 'Server error');

      // Assert
      expect(exception.code, '500');
      expect(exception.message, 'Server error');
    });

    test('should create UnauthorizedException', () {
      // Arrange & Act
      const exception = UnauthorizedException('Unauthorized access');

      // Assert
      expect(exception.message, 'Unauthorized access');
    });

    test('should create ValidationException', () {
      // Arrange & Act
      const exception = ValidationException('Invalid input');

      // Assert
      expect(exception.message, 'Invalid input');
    });

    test('should create UnknownException', () {
      // Arrange & Act
      const exception = UnknownException('Unknown error');

      // Assert
      expect(exception.message, 'Unknown error');
    });
  });
}
