/// Result wrapper for error handling
/// 
/// Sealed class pattern for handling success and error states
/// Similar to Android's Result<T> class
sealed class Result<T> {
  const Result();
}

/// Success result with data
class Success<T> extends Result<T> {
  final T data;
  
  const Success(this.data);
  
  @override
  String toString() => 'Success(data: $data)';
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> &&
          runtimeType == other.runtimeType &&
          data == other.data;
  
  @override
  int get hashCode => data.hashCode;
}

/// Error result with exception
class Failure<T> extends Result<T> {
  final AppException exception;
  
  const Failure(this.exception);
  
  @override
  String toString() => 'Failure(exception: $exception)';
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<T> &&
          runtimeType == other.runtimeType &&
          exception == other.exception;
  
  @override
  int get hashCode => exception.hashCode;
}

/// Application exceptions
sealed class AppException implements Exception {
  final String message;
  
  const AppException(this.message);
  
  @override
  String toString() => message;
}

/// Network error (no internet, timeout, etc.)
class NetworkException extends AppException {
  const NetworkException([String message = 'Network error occurred']) : super(message);
}

/// Server error (4xx, 5xx responses)
class ServerException extends AppException {
  final String code;
  
  const ServerException(this.code, String message) : super(message);
  
  @override
  String toString() => 'ServerException(code: $code, message: $message)';
}

/// Unauthorized error (401)
class UnauthorizedException extends AppException {
  const UnauthorizedException([String message = 'Unauthorized']) : super(message);
}

/// Validation error (bad request)
class ValidationException extends AppException {
  const ValidationException([String message = 'Validation failed']) : super(message);
}

/// Unknown error
class UnknownException extends AppException {
  const UnknownException([String message = 'Unknown error occurred']) : super(message);
}

/// Extension methods for Result
extension ResultExtensions<T> on Result<T> {
  /// Get data or null
  T? getOrNull() {
    return switch (this) {
      Success(data: final data) => data,
      Failure() => null,
    };
  }
  
  /// Get data or throw exception
  T getOrThrow() {
    return switch (this) {
      Success(data: final data) => data,
      Failure(exception: final exception) => throw exception,
    };
  }
  
  /// Get data or default value
  T getOrDefault(T defaultValue) {
    return switch (this) {
      Success(data: final data) => data,
      Failure() => defaultValue,
    };
  }
  
  /// Check if result is success
  bool get isSuccess => this is Success<T>;
  
  /// Check if result is failure
  bool get isFailure => this is Failure<T>;
  
  /// Map success data
  Result<R> map<R>(R Function(T data) transform) {
    return switch (this) {
      Success(data: final data) => Success(transform(data)),
      Failure(exception: final exception) => Failure(exception),
    };
  }
  
  /// FlatMap for chaining operations
  Result<R> flatMap<R>(Result<R> Function(T data) transform) {
    return switch (this) {
      Success(data: final data) => transform(data),
      Failure(exception: final exception) => Failure(exception),
    };
  }
  
  /// Handle both success and error cases
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(AppException exception) onFailure,
  }) {
    return switch (this) {
      Success(data: final data) => onSuccess(data),
      Failure(exception: final exception) => onFailure(exception),
    };
  }
}
