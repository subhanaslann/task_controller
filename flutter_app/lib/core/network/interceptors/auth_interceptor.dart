import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../storage/secure_storage.dart';

/// TekTech AuthInterceptor
/// 
/// Handles authentication token injection and refresh
/// - Adds Bearer token to all requests
/// - Handles 401 responses with token refresh
/// - Retries failed request after token refresh
class AuthInterceptor extends Interceptor {
  final SecureStorage _storage;
  final Dio _dio;
  final Logger _logger = Logger();
  
  bool _isRefreshing = false;
  final List<({RequestOptions options, ErrorInterceptorHandler handler})> _requestsToRetry = [];

  AuthInterceptor(this._storage, this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Skip auth for login endpoint
    if (options.path.contains('/auth/login') || options.path.contains('/auth/register')) {
      return handler.next(options);
    }

    // Add token to headers (handle async)
    _storage.getToken().then((token) {
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    }).catchError((error) {
      _logger.e('Error getting token: $error');
      handler.next(options);
    });
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle 401 Unauthorized
    if (err.response?.statusCode == 401) {
      _logger.w('Token expired, attempting refresh...');

      // Queue this request to retry after refresh
      _requestsToRetry.add((options: err.requestOptions, handler: handler));

      // If already refreshing, return early
      if (_isRefreshing) {
        _logger.i('Token refresh already in progress, queuing request');
        return;
      }

      _isRefreshing = true;

      // Handle async operations with then/catchError
      _refreshToken().then((refreshed) {
        if (refreshed) {
          _logger.i('Token refreshed successfully, retrying ${_requestsToRetry.length} requests');

          // Retry all queued requests
          final requests = List.from(_requestsToRetry);
          _requestsToRetry.clear();

          for (final request in requests) {
            _retryRequest(request.options, request.handler);
          }
        } else {
          _logger.e('Token refresh failed, clearing queue');

          // Refresh failed, reject all queued requests
          final requests = List.from(_requestsToRetry);
          _requestsToRetry.clear();

          for (final request in requests) {
            request.handler.reject(err);
          }
        }
      }).catchError((error) {
        _logger.e('Error during token refresh: $error');

        // Error during refresh, reject all queued requests
        final requests = List.from(_requestsToRetry);
        _requestsToRetry.clear();

        for (final request in requests) {
          request.handler.reject(err);
        }
      }).whenComplete(() {
        _isRefreshing = false;
      });

      return;
    }

    // Not a 401, pass through
    return handler.next(err);
  }

  Future<bool> _refreshToken() async {
    try {
      final token = await _storage.getToken();
      if (token == null) {
        _logger.w('No token to refresh');
        return false;
      }

      // Call refresh endpoint (assuming /auth/refresh exists)
      // If your API doesn't have refresh endpoint, this will fail
      // and user will be logged out (token deleted below)
      final response = await _dio.post(
        '/auth/refresh',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        final newToken = response.data['token'] as String?;
        if (newToken != null) {
          await _storage.saveToken(newToken);
          _logger.i('New token saved');
          return true;
        }
      }

      return false;
    } catch (e) {
      _logger.e('Token refresh error: $e');
      
      // Refresh failed, clear token to force re-login
      await _storage.deleteToken();
      
      return false;
    }
  }

  Future<void> _retryRequest(
    RequestOptions options,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      // Get new token
      final token = await _storage.getToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }

      // Retry the request
      final response = await _dio.fetch(options);
      handler.resolve(response);
    } catch (e) {
      if (e is DioException) {
        handler.reject(e);
      } else {
        handler.reject(
          DioException(
            requestOptions: options,
            error: e,
          ),
        );
      }
    }
  }
}
