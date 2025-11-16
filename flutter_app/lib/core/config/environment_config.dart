import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// TekTech Environment Configuration
/// 
/// Environment-specific configuration for:
/// - API endpoints
/// - Log levels
/// - Feature flags
/// - Analytics/Error tracking DSN
enum Environment {
  development,
  staging,
  production,
}

class EnvironmentConfig {
  final Environment environment;
  final String apiBaseUrl;
  final String sentryDsn;
  final Level logLevel;
  final bool enableAnalytics;
  final bool enableErrorTracking;
  final bool enableDebugLogs;
  
  const EnvironmentConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.sentryDsn,
    required this.logLevel,
    required this.enableAnalytics,
    required this.enableErrorTracking,
    required this.enableDebugLogs,
  });

  /// Development configuration
  static const development = EnvironmentConfig(
    environment: Environment.development,
    apiBaseUrl: 'https://api.diplomam.net',
    sentryDsn: '', // Empty in dev - won't send to Sentry
    logLevel: Level.debug,
    enableAnalytics: false,
    enableErrorTracking: false,
    enableDebugLogs: true,
  );

  /// Staging configuration
  static const staging = EnvironmentConfig(
    environment: Environment.staging,
    apiBaseUrl: 'https://staging-api.tektech.com/api',
    // TODO: Replace with your actual Sentry DSN from sentry.io
    // Get DSN: https://sentry.io → Project Settings → Client Keys (DSN)
    sentryDsn: '', // 'https://YOUR_KEY@o123456.ingest.sentry.io/YOUR_PROJECT_ID'
    logLevel: Level.info,
    enableAnalytics: true,
    enableErrorTracking: true,
    enableDebugLogs: true,
  );

  /// Production configuration
  static const production = EnvironmentConfig(
    environment: Environment.production,
    apiBaseUrl: 'https://api.tektech.com/api',
    // TODO: Replace with your actual Sentry DSN from sentry.io
    // Get DSN: https://sentry.io → Project Settings → Client Keys (DSN)
    sentryDsn: '', // 'https://YOUR_KEY@o123456.ingest.sentry.io/YOUR_PROJECT_ID'
    logLevel: Level.warning,
    enableAnalytics: true,
    enableErrorTracking: true,
    enableDebugLogs: false,
  );

  /// Get current environment based on build mode
  static EnvironmentConfig get current {
    // In debug mode, use development
    if (kDebugMode) {
      return development;
    }
    
    // In release mode, check environment variable or use production
    // You can customize this logic based on flavor/environment
    const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'production');
    
    switch (flavor) {
      case 'staging':
        return staging;
      case 'production':
      default:
        return production;
    }
  }

  /// Check if current environment is development
  bool get isDevelopment => environment == Environment.development;

  /// Check if current environment is staging
  bool get isStaging => environment == Environment.staging;

  /// Check if current environment is production
  bool get isProduction => environment == Environment.production;

  /// Get environment name
  String get environmentName {
    switch (environment) {
      case Environment.development:
        return 'development';
      case Environment.staging:
        return 'staging';
      case Environment.production:
        return 'production';
    }
  }

  @override
  String toString() {
    return '''
EnvironmentConfig(
  environment: $environmentName,
  apiBaseUrl: $apiBaseUrl,
  logLevel: $logLevel,
  enableAnalytics: $enableAnalytics,
  enableErrorTracking: $enableErrorTracking,
  enableDebugLogs: $enableDebugLogs,
)''';
  }
}

/// Custom Logger Filter based on Environment
class EnvironmentLogFilter extends LogFilter {
  final Level minLevel;

  EnvironmentLogFilter(this.minLevel);

  @override
  bool shouldLog(LogEvent event) {
    return event.level.index >= minLevel.index;
  }
}

/// Logger Factory with Environment Configuration
class AppLogger {
  static Logger? _instance;

  /// Get configured logger instance
  static Logger get instance {
    if (_instance != null) return _instance!;

    final config = EnvironmentConfig.current;
    
    _instance = Logger(
      filter: EnvironmentLogFilter(config.logLevel),
      printer: PrettyPrinter(
        methodCount: config.enableDebugLogs ? 2 : 0,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true,
      ),
      output: ConsoleOutput(),
    );

    return _instance!;
  }

  /// Create logger with custom tag
  static Logger tag(String tag) {
    return Logger(
      filter: EnvironmentLogFilter(EnvironmentConfig.current.logLevel),
      printer: PrefixPrinter(
        PrettyPrinter(
          methodCount: EnvironmentConfig.current.enableDebugLogs ? 2 : 0,
          errorMethodCount: 8,
          lineLength: 120,
          colors: true,
          printEmojis: true,
          printTime: true,
        ),
        info: tag,
      ),
      output: ConsoleOutput(),
    );
  }
}
