/// TekTech App Exception Hierarchy
///
/// User-friendly error types for consistent error handling
/// - Network errors
/// - Authentication errors
/// - Validation errors
/// - Server errors
library;

abstract class AppException implements Exception {
  final String message;
  final String? details;
  final int? statusCode;

  AppException({required this.message, this.details, this.statusCode});

  @override
  String toString() => message;
}

// Network Errors
class NetworkException extends AppException {
  NetworkException({
    super.message = 'İnternet bağlantınızı kontrol edin',
    super.details,
  });
}

class TimeoutException extends AppException {
  TimeoutException({
    super.message = 'İstek zaman aşımına uğradı',
    super.details,
  });
}

// Authentication Errors
class UnauthorizedException extends AppException {
  UnauthorizedException({
    super.message = 'Oturum süreniz dolmuş. Lütfen tekrar giriş yapın',
    super.details,
    super.statusCode = 401,
  });
}

class ForbiddenException extends AppException {
  ForbiddenException({
    super.message = 'Bu işlem için yetkiniz bulunmuyor',
    super.details,
    super.statusCode = 403,
  });
}

// Client Errors
class BadRequestException extends AppException {
  BadRequestException({
    super.message = 'Geçersiz istek',
    super.details,
    super.statusCode = 400,
  });
}

class NotFoundException extends AppException {
  NotFoundException({
    super.message = 'İstenen kaynak bulunamadı',
    super.details,
    super.statusCode = 404,
  });
}

class ConflictException extends AppException {
  ConflictException({
    super.message = 'Kaynak zaten mevcut',
    super.details,
    super.statusCode = 409,
  });
}

class ValidationException extends AppException {
  final Map<String, List<String>>? fieldErrors;

  ValidationException({
    super.message = 'Girdiğiniz bilgileri kontrol edin',
    super.details,
    this.fieldErrors,
    super.statusCode = 422,
  });
}

// Server Errors
class ServerException extends AppException {
  ServerException({
    super.message = 'Sunucu hatası oluştu. Lütfen daha sonra tekrar deneyin',
    super.details,
    super.statusCode = 500,
  });
}

class ServiceUnavailableException extends AppException {
  ServiceUnavailableException({
    super.message = 'Servis şu anda kullanılamıyor',
    super.details,
    super.statusCode = 503,
  });
}

// Data Errors
class CacheException extends AppException {
  CacheException({
    super.message = 'Veri önbelleğinde hata oluştu',
    super.details,
  });
}

class ParseException extends AppException {
  ParseException({
    super.message = 'Veri işlenirken hata oluştu',
    super.details,
  });
}

// Generic/Unknown Errors
class UnknownException extends AppException {
  UnknownException({
    super.message = 'Beklenmeyen bir hata oluştu',
    super.details,
  });
}
