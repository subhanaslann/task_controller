/// TekTech App Exception Hierarchy
/// 
/// User-friendly error types for consistent error handling
/// - Network errors
/// - Authentication errors
/// - Validation errors
/// - Server errors

abstract class AppException implements Exception {
  final String message;
  final String? details;
  final int? statusCode;

  AppException({
    required this.message,
    this.details,
    this.statusCode,
  });

  @override
  String toString() => message;
}

// Network Errors
class NetworkException extends AppException {
  NetworkException({
    String message = 'İnternet bağlantınızı kontrol edin',
    String? details,
  }) : super(message: message, details: details);
}

class TimeoutException extends AppException {
  TimeoutException({
    String message = 'İstek zaman aşımına uğradı',
    String? details,
  }) : super(message: message, details: details);
}

// Authentication Errors
class UnauthorizedException extends AppException {
  UnauthorizedException({
    String message = 'Oturum süreniz dolmuş. Lütfen tekrar giriş yapın',
    String? details,
    int statusCode = 401,
  }) : super(message: message, details: details, statusCode: statusCode);
}

class ForbiddenException extends AppException {
  ForbiddenException({
    String message = 'Bu işlem için yetkiniz bulunmuyor',
    String? details,
    int statusCode = 403,
  }) : super(message: message, details: details, statusCode: statusCode);
}

// Client Errors
class BadRequestException extends AppException {
  BadRequestException({
    String message = 'Geçersiz istek',
    String? details,
    int statusCode = 400,
  }) : super(message: message, details: details, statusCode: statusCode);
}

class NotFoundException extends AppException {
  NotFoundException({
    String message = 'İstenen kaynak bulunamadı',
    String? details,
    int statusCode = 404,
  }) : super(message: message, details: details, statusCode: statusCode);
}

class ConflictException extends AppException {
  ConflictException({
    String message = 'Kaynak zaten mevcut',
    String? details,
    int statusCode = 409,
  }) : super(message: message, details: details, statusCode: statusCode);
}

class ValidationException extends AppException {
  final Map<String, List<String>>? fieldErrors;

  ValidationException({
    String message = 'Girdiğiniz bilgileri kontrol edin',
    String? details,
    this.fieldErrors,
    int statusCode = 422,
  }) : super(message: message, details: details, statusCode: statusCode);
}

// Server Errors
class ServerException extends AppException {
  ServerException({
    String message = 'Sunucu hatası oluştu. Lütfen daha sonra tekrar deneyin',
    String? details,
    int? statusCode = 500,
  }) : super(message: message, details: details, statusCode: statusCode);
}

class ServiceUnavailableException extends AppException {
  ServiceUnavailableException({
    String message = 'Servis şu anda kullanılamıyor',
    String? details,
    int statusCode = 503,
  }) : super(message: message, details: details, statusCode: statusCode);
}

// Data Errors
class CacheException extends AppException {
  CacheException({
    String message = 'Veri önbelleğinde hata oluştu',
    String? details,
  }) : super(message: message, details: details);
}

class ParseException extends AppException {
  ParseException({
    String message = 'Veri işlenirken hata oluştu',
    String? details,
  }) : super(message: message, details: details);
}

// Generic/Unknown Errors
class UnknownException extends AppException {
  UnknownException({
    String message = 'Beklenmeyen bir hata oluştu',
    String? details,
  }) : super(message: message, details: details);
}
