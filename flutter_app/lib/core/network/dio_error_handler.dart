import 'dart:io';
import 'package:dio/dio.dart';
import '../exceptions/app_exception.dart';

/// TekTech DioErrorHandler
/// 
/// Maps Dio errors to user-friendly AppException types
/// - Network errors
/// - HTTP status codes
/// - Timeout errors
/// - Parse errors
class DioErrorHandler {
  static AppException handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(
          details: error.message,
        );

      case DioExceptionType.badResponse:
        return _handleHttpError(error);

      case DioExceptionType.cancel:
        return UnknownException(
          message: 'İstek iptal edildi',
          details: error.message,
        );

      case DioExceptionType.connectionError:
        if (error.error is SocketException) {
          return NetworkException(
            details: 'Sunucuya bağlanılamadı',
          );
        }
        return NetworkException(
          details: error.message,
        );

      case DioExceptionType.badCertificate:
        return NetworkException(
          message: 'Güvenlik sertifikası hatası',
          details: error.message,
        );

      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return NetworkException();
        }
        return UnknownException(
          details: error.message,
        );
    }
  }

  static AppException _handleHttpError(DioException error) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    // Extract error message from response if available
    String? serverMessage;
    String? details;
    
    if (data is Map<String, dynamic>) {
      // Check if error is nested under 'error' key (new API format)
      if (data.containsKey('error') && data['error'] is Map<String, dynamic>) {
        final errorObj = data['error'] as Map<String, dynamic>;
        serverMessage = errorObj['message'] as String?;
        details = errorObj['code'] as String?;
      } else {
        // Old format
        serverMessage = data['message'] as String?;
        details = data['error'] as String? ?? data['details'] as String?;
      }
    }

    switch (statusCode) {
      case 400:
        return BadRequestException(
          message: serverMessage ?? 'Geçersiz istek',
          details: details,
        );

      case 401:
        return UnauthorizedException(
          message: serverMessage ?? 'Oturum süreniz dolmuş',
          details: details,
        );

      case 403:
        return ForbiddenException(
          message: serverMessage ?? 'Bu işlem için yetkiniz yok',
          details: details,
        );

      case 404:
        return NotFoundException(
          message: serverMessage ?? 'İstenen kaynak bulunamadı',
          details: details,
        );

      case 422:
        Map<String, List<String>>? fieldErrors;
        if (data is Map<String, dynamic> && data.containsKey('errors')) {
          final errors = data['errors'] as Map<String, dynamic>?;
          if (errors != null) {
            fieldErrors = errors.map(
              (key, value) => MapEntry(
                key,
                (value is List)
                    ? value.cast<String>()
                    : [value.toString()],
              ),
            );
          }
        }
        
        return ValidationException(
          message: serverMessage ?? 'Girdiğiniz bilgileri kontrol edin',
          details: details,
          fieldErrors: fieldErrors,
        );

      case 500:
      case 502:
      case 503:
      case 504:
        return ServerException(
          message: serverMessage ?? 'Sunucu hatası',
          details: details,
          statusCode: statusCode,
        );

      default:
        return UnknownException(
          message: serverMessage ?? 'Beklenmeyen hata',
          details: 'HTTP $statusCode: $details',
        );
    }
  }
}
