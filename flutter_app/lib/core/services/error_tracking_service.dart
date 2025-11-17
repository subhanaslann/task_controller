import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:logger/logger.dart';

/// TekTech Error Tracking Service
/// 
/// Sentry-based error tracking with:
/// - Automatic crash reporting
/// - PII (Personally Identifiable Information) scrubbing
/// - Environment-based configuration
/// - Custom error context
class ErrorTrackingService {
  static final Logger _logger = Logger();
  static bool _initialized = false;

  /// Initialize Sentry with configuration
  static Future<void> init({
    required String dsn,
    required String environment,
    double tracesSampleRate = 0.1,
    bool enableAutoSessionTracking = true,
  }) async {
    if (_initialized) {
      _logger.w('ErrorTrackingService already initialized');
      return;
    }

    await SentryFlutter.init(
      (options) {
        options.dsn = dsn;
        options.environment = environment;
        options.tracesSampleRate = tracesSampleRate;
        options.enableAutoSessionTracking = enableAutoSessionTracking;
        
        // Debug mode settings
        options.debug = kDebugMode;
        
        // PII scrubbing - remove sensitive data
        options.beforeSend = _scrubPII;
        options.beforeBreadcrumb = _scrubBreadcrumbPII;

        // Performance monitoring
        options.enableAutoPerformanceTracing = true;
      },
    );

    _initialized = true;
    _logger.i('ErrorTrackingService initialized (env: $environment)');
  }

  /// Scrub PII from error events before sending
  static SentryEvent? _scrubPII(SentryEvent event, Hint hint) {
    // Remove sensitive fields from contexts
    final scrubbedContexts = _scrubContexts(event.contexts);
    
    // Remove sensitive request data
    final scrubbedRequest = _scrubRequest(event.request);
    
    // Remove sensitive user data (keep only non-PII fields)
    final scrubbedUser = _scrubUser(event.user);
    
    return event.copyWith(
      contexts: scrubbedContexts,
      request: scrubbedRequest,
      user: scrubbedUser,
    );
  }

  /// Scrub PII from breadcrumbs
  static Breadcrumb? _scrubBreadcrumbPII(Breadcrumb? breadcrumb, Hint hint) {
    if (breadcrumb == null) return null;
    
    // Remove sensitive data from breadcrumb data
    final scrubbedData = <String, dynamic>{};
    breadcrumb.data?.forEach((key, value) {
      if (!_isSensitiveKey(key)) {
        scrubbedData[key] = value;
      } else {
        scrubbedData[key] = '[REDACTED]';
      }
    });
    
    return breadcrumb.copyWith(data: scrubbedData);
  }

  /// Scrub sensitive contexts
  static Contexts _scrubContexts(Contexts contexts) {
    final scrubbed = Contexts(
      device: contexts.device,
      operatingSystem: contexts.operatingSystem,
      runtimes: contexts.runtimes,
      app: contexts.app,
      browser: contexts.browser,
      gpu: contexts.gpu,
      culture: contexts.culture,
    );
    
    return scrubbed;
  }

  /// Scrub sensitive request data
  static SentryRequest? _scrubRequest(SentryRequest? request) {
    if (request == null) return null;
    
    // Remove sensitive headers
    final scrubbedHeaders = <String, String>{};
    request.headers?.forEach((key, value) {
      if (!_isSensitiveKey(key)) {
        scrubbedHeaders[key] = value;
      } else {
        scrubbedHeaders[key] = '[REDACTED]';
      }
    });
    
    // Remove sensitive query params
    final scrubbedQueryString = _scrubQueryString(request.queryString);
    
    return request.copyWith(
      headers: scrubbedHeaders,
      queryString: scrubbedQueryString,
      // Remove cookies entirely
      cookies: null,
    );
  }

  /// Scrub sensitive user data
  static SentryUser? _scrubUser(SentryUser? user) {
    if (user == null) return null;
    
    // Keep only non-PII fields
    return SentryUser(
      id: user.id, // User ID is okay if it's not email/name
      // Remove email, username, IP
      email: null,
      username: null,
      ipAddress: null,
      // Keep other metadata
      data: user.data,
    );
  }

  /// Scrub query string
  static String? _scrubQueryString(String? queryString) {
    if (queryString == null) return null;
    
    final params = Uri.splitQueryString(queryString);
    final scrubbed = <String, String>{};
    
    params.forEach((key, value) {
      if (!_isSensitiveKey(key)) {
        scrubbed[key] = value;
      } else {
        scrubbed[key] = '[REDACTED]';
      }
    });
    
    return Uri(queryParameters: scrubbed).query;
  }

  /// Check if key is sensitive (contains PII)
  static bool _isSensitiveKey(String key) {
    final lowerKey = key.toLowerCase();
    const sensitivePatterns = [
      'password',
      'token',
      'auth',
      'secret',
      'api_key',
      'apikey',
      'access_token',
      'refresh_token',
      'bearer',
      'email',
      'phone',
      'ssn',
      'credit_card',
      'card_number',
    ];
    
    return sensitivePatterns.any((pattern) => lowerKey.contains(pattern));
  }

  /// Report error with context
  static Future<void> reportError(
    dynamic exception,
    StackTrace? stackTrace, {
    String? context,
    Map<String, dynamic>? extra,
    SentryLevel? level,
  }) async {
    if (!_initialized) {
      _logger.w('ErrorTrackingService not initialized, logging error locally');
      _logger.e('Error: $exception', error: exception, stackTrace: stackTrace);
      return;
    }

    try {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
        hint: Hint.withMap({
          if (context != null) 'context': context,
          if (extra != null) ...extra,
        }),
      );
      
      _logger.d('Error reported to Sentry: $exception');
    } catch (e) {
      _logger.e('Failed to report error to Sentry', error: e);
    }
  }

  /// Add breadcrumb for debugging
  static void addBreadcrumb({
    required String message,
    String? category,
    SentryLevel? level,
    Map<String, dynamic>? data,
  }) {
    if (!_initialized) return;

    Sentry.addBreadcrumb(
      Breadcrumb(
        message: message,
        category: category,
        level: level ?? SentryLevel.info,
        data: data,
        timestamp: DateTime.now().toUtc(),
      ),
    );
  }

  /// Set user context (non-PII)
  static void setUser({
    required String id,
    Map<String, dynamic>? data,
  }) {
    if (!_initialized) return;

    Sentry.configureScope((scope) {
      scope.setUser(SentryUser(
        id: id,
        data: data,
      ));
    });
  }

  /// Clear user context (on logout)
  static void clearUser() {
    if (!_initialized) return;

    Sentry.configureScope((scope) {
      scope.setUser(null);
    });
  }

  /// Set custom tag
  static void setTag(String key, String value) {
    if (!_initialized) return;

    Sentry.configureScope((scope) {
      scope.setTag(key, value);
    });
  }

  /// Set custom context
  static void setContext(String key, Map<String, dynamic> value) {
    if (!_initialized) return;

    Sentry.configureScope((scope) {
      scope.setContexts(key, value);
    });
  }

  /// Capture message
  static Future<void> captureMessage(
    String message, {
    SentryLevel? level,
    Map<String, dynamic>? extra,
  }) async {
    if (!_initialized) {
      _logger.i(message);
      return;
    }

    await Sentry.captureMessage(
      message,
      level: level ?? SentryLevel.info,
      hint: extra != null ? Hint.withMap(extra) : null,
    );
  }

  /// Close Sentry (call on app dispose)
  static Future<void> close() async {
    if (!_initialized) return;
    
    await Sentry.close();
    _initialized = false;
    _logger.i('ErrorTrackingService closed');
  }
}
