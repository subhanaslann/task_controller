import 'dart:async';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

/// TekTech RetryInterceptor
/// 
/// Automatically retries failed requests with exponential backoff
/// - Configurable retry count and delays
/// - Only retries idempotent methods (GET, PUT, DELETE, PATCH, HEAD)
/// - Exponential backoff with jitter
/// - Respects HTTP status codes (only retries 5xx, timeouts, connection errors)
class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration initialDelay;
  final double backoffMultiplier;
  final Logger _logger = Logger();

  RetryInterceptor({
    this.maxRetries = 3,
    this.initialDelay = const Duration(milliseconds: 500),
    this.backoffMultiplier = 2.0,
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Check if request is retryable
    if (!_shouldRetry(err)) {
      return handler.next(err);
    }

    // Get retry count from extra data
    final retryCount = err.requestOptions.extra['retry_count'] as int? ?? 0;

    if (retryCount >= maxRetries) {
      _logger.w('Max retries ($maxRetries) reached for ${err.requestOptions.path}');
      return handler.next(err);
    }

    // Calculate delay with exponential backoff and jitter
    final delay = _calculateDelay(retryCount);
    _logger.i(
      'Retrying request ${err.requestOptions.path} (attempt ${retryCount + 1}/$maxRetries) after ${delay.inMilliseconds}ms',
    );

    // Wait before retry
    await Future.delayed(delay);

    // Update retry count
    final newOptions = err.requestOptions.copyWith(
      extra: {
        ...err.requestOptions.extra,
        'retry_count': retryCount + 1,
      },
    );

    try {
      // Retry the request
      final response = await Dio().fetch(newOptions);
      return handler.resolve(response);
    } catch (e) {
      if (e is DioException) {
        return handler.reject(e);
      }
      return handler.reject(
        DioException(
          requestOptions: newOptions,
          error: e,
        ),
      );
    }
  }

  bool _shouldRetry(DioException err) {
    // Only retry idempotent methods
    final method = err.requestOptions.method.toUpperCase();
    if (!['GET', 'PUT', 'DELETE', 'PATCH', 'HEAD'].contains(method)) {
      return false;
    }

    // Check error type
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;

      case DioExceptionType.badResponse:
        // Only retry server errors (5xx)
        final statusCode = err.response?.statusCode;
        return statusCode != null && statusCode >= 500;

      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return false;
    }
  }

  Duration _calculateDelay(int retryCount) {
    // Exponential backoff: initialDelay * (backoffMultiplier ^ retryCount)
    final delayMs = initialDelay.inMilliseconds *
        (backoffMultiplier * retryCount).round();

    // Add jitter (random 0-25% of delay)
    final jitter = (delayMs * 0.25 * (DateTime.now().millisecond % 100) / 100).round();

    return Duration(milliseconds: delayMs + jitter);
  }
}
