import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../storage/secure_storage.dart';
import '../utils/constants.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/retry_interceptor.dart';
import 'dio_error_handler.dart';

class DioClient {
  late final Dio _dio;
  final SecureStorage _storage;
  final Logger _logger = Logger();

  DioClient(this._storage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors (order matters!)
    // 1. Pretty logger FIRST to see all requests/responses
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        compact: true,
      ),
    );
    
    // 2. Auth interceptor (token injection + refresh)
    _dio.interceptors.add(AuthInterceptor(_storage, _dio));
    
    // 3. Retry interceptor (exponential backoff)
    _dio.interceptors.add(RetryInterceptor(
      maxRetries: 3,
      initialDelay: const Duration(milliseconds: 500),
    ));
    
    // 4. Error mapping interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          // Map DioException to AppException
          final appException = DioErrorHandler.handleError(error);
          _logger.e('API Error: ${appException.message}');
          
          // Wrap in DioException with AppException as error
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: appException,
              response: error.response,
              type: error.type,
            ),
          );
        },
      ),
    );
  }

  Dio get dio => _dio;
}
