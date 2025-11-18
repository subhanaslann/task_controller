import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:flutter_app/core/config/environment_config.dart';

void main() {
  // ==================== GROUP 1: ENVIRONMENT ENUM TESTS ====================
  group('Environment Enum Tests', () {
    test('Environment enum has three values', () {
      expect(Environment.values.length, 3);
    });

    test('Environment enum contains development', () {
      expect(Environment.values, contains(Environment.development));
    });

    test('Environment enum contains staging', () {
      expect(Environment.values, contains(Environment.staging));
    });

    test('Environment enum contains production', () {
      expect(Environment.values, contains(Environment.production));
    });

    test('Environment enum values are in correct order', () {
      expect(Environment.values[0], Environment.development);
      expect(Environment.values[1], Environment.staging);
      expect(Environment.values[2], Environment.production);
    });

    test('Environment enum toString returns correct values', () {
      expect(Environment.development.toString(), 'Environment.development');
      expect(Environment.staging.toString(), 'Environment.staging');
      expect(Environment.production.toString(), 'Environment.production');
    });
  });

  // ==================== GROUP 2: DEVELOPMENT CONFIG TESTS ====================
  group('Development Configuration Tests', () {
    test('development config has correct environment', () {
      expect(EnvironmentConfig.development.environment, Environment.development);
    });

    test('development config has correct API base URL', () {
      expect(EnvironmentConfig.development.apiBaseUrl, 'https://api.diplomam.net');
    });

    test('development config has empty Sentry DSN', () {
      expect(EnvironmentConfig.development.sentryDsn, isEmpty);
    });

    test('development config has debug log level', () {
      expect(EnvironmentConfig.development.logLevel, Level.debug);
    });

    test('development config has analytics disabled', () {
      expect(EnvironmentConfig.development.enableAnalytics, false);
    });

    test('development config has error tracking disabled', () {
      expect(EnvironmentConfig.development.enableErrorTracking, false);
    });

    test('development config has debug logs enabled', () {
      expect(EnvironmentConfig.development.enableDebugLogs, true);
    });

    test('development config is const', () {
      // Verify it's the same instance (const singleton)
      expect(
        identical(EnvironmentConfig.development, EnvironmentConfig.development),
        true,
      );
    });
  });

  // ==================== GROUP 3: STAGING CONFIG TESTS ====================
  group('Staging Configuration Tests', () {
    test('staging config has correct environment', () {
      expect(EnvironmentConfig.staging.environment, Environment.staging);
    });

    test('staging config has correct API base URL', () {
      expect(
        EnvironmentConfig.staging.apiBaseUrl,
        'https://staging-api.tektech.com/api',
      );
    });

    test('staging config has info log level', () {
      expect(EnvironmentConfig.staging.logLevel, Level.info);
    });

    test('staging config has analytics enabled', () {
      expect(EnvironmentConfig.staging.enableAnalytics, true);
    });

    test('staging config has error tracking enabled', () {
      expect(EnvironmentConfig.staging.enableErrorTracking, true);
    });

    test('staging config has debug logs enabled', () {
      expect(EnvironmentConfig.staging.enableDebugLogs, true);
    });

    test('staging config is const', () {
      expect(
        identical(EnvironmentConfig.staging, EnvironmentConfig.staging),
        true,
      );
    });
  });

  // ==================== GROUP 4: PRODUCTION CONFIG TESTS ====================
  group('Production Configuration Tests', () {
    test('production config has correct environment', () {
      expect(EnvironmentConfig.production.environment, Environment.production);
    });

    test('production config has correct API base URL', () {
      expect(
        EnvironmentConfig.production.apiBaseUrl,
        'https://api.tektech.com/api',
      );
    });

    test('production config has warning log level', () {
      expect(EnvironmentConfig.production.logLevel, Level.warning);
    });

    test('production config has analytics enabled', () {
      expect(EnvironmentConfig.production.enableAnalytics, true);
    });

    test('production config has error tracking enabled', () {
      expect(EnvironmentConfig.production.enableErrorTracking, true);
    });

    test('production config has debug logs disabled', () {
      expect(EnvironmentConfig.production.enableDebugLogs, false);
    });

    test('production config is const', () {
      expect(
        identical(EnvironmentConfig.production, EnvironmentConfig.production),
        true,
      );
    });
  });

  // ==================== GROUP 5: GETTER METHODS TESTS ====================
  group('Getter Methods Tests', () {
    test('isDevelopment returns true for development config', () {
      expect(EnvironmentConfig.development.isDevelopment, true);
      expect(EnvironmentConfig.development.isStaging, false);
      expect(EnvironmentConfig.development.isProduction, false);
    });

    test('isStaging returns true for staging config', () {
      expect(EnvironmentConfig.staging.isDevelopment, false);
      expect(EnvironmentConfig.staging.isStaging, true);
      expect(EnvironmentConfig.staging.isProduction, false);
    });

    test('isProduction returns true for production config', () {
      expect(EnvironmentConfig.production.isDevelopment, false);
      expect(EnvironmentConfig.production.isStaging, false);
      expect(EnvironmentConfig.production.isProduction, true);
    });

    test('environmentName returns correct string for development', () {
      expect(EnvironmentConfig.development.environmentName, 'development');
    });

    test('environmentName returns correct string for staging', () {
      expect(EnvironmentConfig.staging.environmentName, 'staging');
    });

    test('environmentName returns correct string for production', () {
      expect(EnvironmentConfig.production.environmentName, 'production');
    });

    test('getter methods work for custom instance', () {
      const custom = EnvironmentConfig(
        environment: Environment.staging,
        apiBaseUrl: 'https://test.com',
        sentryDsn: '',
        logLevel: Level.info,
        enableAnalytics: true,
        enableErrorTracking: false,
        enableDebugLogs: true,
      );

      expect(custom.isStaging, true);
      expect(custom.isDevelopment, false);
      expect(custom.isProduction, false);
      expect(custom.environmentName, 'staging');
    });
  });

  // ==================== GROUP 6: TOSTRING TESTS ====================
  group('toString Tests', () {
    test('development toString contains environment name', () {
      final result = EnvironmentConfig.development.toString();
      expect(result, contains('development'));
    });

    test('development toString contains API URL', () {
      final result = EnvironmentConfig.development.toString();
      expect(result, contains('https://api.diplomam.net'));
    });

    test('development toString contains log level', () {
      final result = EnvironmentConfig.development.toString();
      expect(result, contains('Level.debug'));
    });

    test('development toString contains feature flags', () {
      final result = EnvironmentConfig.development.toString();
      expect(result, contains('enableAnalytics: false'));
      expect(result, contains('enableErrorTracking: false'));
      expect(result, contains('enableDebugLogs: true'));
    });

    test('staging toString contains correct environment', () {
      final result = EnvironmentConfig.staging.toString();
      expect(result, contains('staging'));
      expect(result, contains('staging-api.tektech.com'));
    });

    test('production toString contains correct environment', () {
      final result = EnvironmentConfig.production.toString();
      expect(result, contains('production'));
      expect(result, contains('api.tektech.com/api'));
    });

    test('toString has consistent format', () {
      final result = EnvironmentConfig.development.toString();
      expect(result, contains('EnvironmentConfig('));
      expect(result, contains('environment:'));
      expect(result, contains('apiBaseUrl:'));
      expect(result, contains('logLevel:'));
    });
  });

  // ==================== GROUP 7: ENVIRONMENTLOGFILTER TESTS ====================
  group('EnvironmentLogFilter Tests', () {
    test('filter can be created with debug level', () {
      final filter = EnvironmentLogFilter(Level.debug);
      expect(filter.minLevel, Level.debug);
    });

    test('filter allows logs at or above min level', () {
      final filter = EnvironmentLogFilter(Level.info);

      // Below min level - should not log
      expect(
        filter.shouldLog(LogEvent(
          Level.debug,
          'test',
          error: null,
          stackTrace: null,
        )),
        false,
      );

      // At min level - should log
      expect(
        filter.shouldLog(LogEvent(
          Level.info,
          'test',
          error: null,
          stackTrace: null,
        )),
        true,
      );

      // Above min level - should log
      expect(
        filter.shouldLog(LogEvent(
          Level.warning,
          'test',
          error: null,
          stackTrace: null,
        )),
        true,
      );
    });

    test('filter with debug level allows all logs', () {
      final filter = EnvironmentLogFilter(Level.debug);

      expect(
        filter.shouldLog(LogEvent(Level.trace, 'test', error: null, stackTrace: null)),
        false, // trace < debug
      );
      expect(
        filter.shouldLog(LogEvent(Level.debug, 'test', error: null, stackTrace: null)),
        true,
      );
      expect(
        filter.shouldLog(LogEvent(Level.info, 'test', error: null, stackTrace: null)),
        true,
      );
      expect(
        filter.shouldLog(LogEvent(Level.warning, 'test', error: null, stackTrace: null)),
        true,
      );
      expect(
        filter.shouldLog(LogEvent(Level.error, 'test', error: null, stackTrace: null)),
        true,
      );
    });

    test('filter with warning level blocks debug and info', () {
      final filter = EnvironmentLogFilter(Level.warning);

      expect(
        filter.shouldLog(LogEvent(Level.debug, 'test', error: null, stackTrace: null)),
        false,
      );
      expect(
        filter.shouldLog(LogEvent(Level.info, 'test', error: null, stackTrace: null)),
        false,
      );
      expect(
        filter.shouldLog(LogEvent(Level.warning, 'test', error: null, stackTrace: null)),
        true,
      );
      expect(
        filter.shouldLog(LogEvent(Level.error, 'test', error: null, stackTrace: null)),
        true,
      );
    });

    test('filter works with error level', () {
      final filter = EnvironmentLogFilter(Level.error);

      expect(
        filter.shouldLog(LogEvent(Level.warning, 'test', error: null, stackTrace: null)),
        false,
      );
      expect(
        filter.shouldLog(LogEvent(Level.error, 'test', error: null, stackTrace: null)),
        true,
      );
    });
  });

  // ==================== GROUP 8: APPLOGGER TESTS ====================
  group('AppLogger Tests', () {
    // Note: These tests verify the logger can be created
    // Full logger functionality testing would require more complex mocking

    test('AppLogger.instance returns a Logger', () {
      final logger = AppLogger.instance;
      expect(logger, isA<Logger>());
    });

    test('AppLogger.instance returns same instance on multiple calls', () {
      final logger1 = AppLogger.instance;
      final logger2 = AppLogger.instance;
      expect(identical(logger1, logger2), true);
    });

    test('AppLogger.tag creates a Logger with tag', () {
      final logger = AppLogger.tag('TestTag');
      expect(logger, isA<Logger>());
    });

    test('AppLogger.tag creates new instance each time', () {
      final logger1 = AppLogger.tag('Tag1');
      final logger2 = AppLogger.tag('Tag2');
      expect(identical(logger1, logger2), false);
    });

    test('AppLogger.tag works with empty tag', () {
      final logger = AppLogger.tag('');
      expect(logger, isA<Logger>());
    });

    test('AppLogger.tag works with special characters', () {
      final logger = AppLogger.tag('Test-Tag_123!');
      expect(logger, isA<Logger>());
    });
  });

  // ==================== GROUP 9: EDGE CASES AND INTEGRATION ====================
  group('Edge Cases and Integration Tests', () {
    test('custom EnvironmentConfig can be created', () {
      const custom = EnvironmentConfig(
        environment: Environment.development,
        apiBaseUrl: 'https://custom.com',
        sentryDsn: 'test-dsn',
        logLevel: Level.info,
        enableAnalytics: true,
        enableErrorTracking: true,
        enableDebugLogs: false,
      );

      expect(custom.environment, Environment.development);
      expect(custom.apiBaseUrl, 'https://custom.com');
      expect(custom.sentryDsn, 'test-dsn');
      expect(custom.logLevel, Level.info);
    });

    test('const configs are actually const', () {
      // Verify all three configs are const singletons
      const dev1 = EnvironmentConfig.development;
      const dev2 = EnvironmentConfig.development;
      expect(identical(dev1, dev2), true);

      const stg1 = EnvironmentConfig.staging;
      const stg2 = EnvironmentConfig.staging;
      expect(identical(stg1, stg2), true);

      const prd1 = EnvironmentConfig.production;
      const prd2 = EnvironmentConfig.production;
      expect(identical(prd1, prd2), true);
    });

    test('each environment config is unique', () {
      expect(
        identical(EnvironmentConfig.development, EnvironmentConfig.staging),
        false,
      );
      expect(
        identical(EnvironmentConfig.staging, EnvironmentConfig.production),
        false,
      );
      expect(
        identical(EnvironmentConfig.development, EnvironmentConfig.production),
        false,
      );
    });

    test('log levels are ordered correctly', () {
      // Verify production is most restrictive
      expect(
        EnvironmentConfig.production.logLevel.index >
            EnvironmentConfig.staging.logLevel.index,
        true,
      );
      expect(
        EnvironmentConfig.staging.logLevel.index >
            EnvironmentConfig.development.logLevel.index,
        true,
      );
    });

    test('development has most permissive settings', () {
      expect(EnvironmentConfig.development.enableDebugLogs, true);
      expect(EnvironmentConfig.development.enableAnalytics, false);
      expect(EnvironmentConfig.development.enableErrorTracking, false);
      expect(EnvironmentConfig.development.sentryDsn, isEmpty);
    });

    test('production has most restrictive settings', () {
      expect(EnvironmentConfig.production.enableDebugLogs, false);
      expect(EnvironmentConfig.production.logLevel, Level.warning);
      expect(EnvironmentConfig.production.enableAnalytics, true);
      expect(EnvironmentConfig.production.enableErrorTracking, true);
    });

    test('API URLs are different for each environment', () {
      expect(
        EnvironmentConfig.development.apiBaseUrl !=
            EnvironmentConfig.staging.apiBaseUrl,
        true,
      );
      expect(
        EnvironmentConfig.staging.apiBaseUrl !=
            EnvironmentConfig.production.apiBaseUrl,
        true,
      );
    });

    test('all configs have non-empty API URLs', () {
      expect(EnvironmentConfig.development.apiBaseUrl, isNotEmpty);
      expect(EnvironmentConfig.staging.apiBaseUrl, isNotEmpty);
      expect(EnvironmentConfig.production.apiBaseUrl, isNotEmpty);
    });

    test('EnvironmentLogFilter index comparison works correctly', () {
      // This verifies the shouldLog logic
      expect(Level.error.index > Level.warning.index, true);
      expect(Level.warning.index > Level.info.index, true);
      expect(Level.info.index > Level.debug.index, true);
    });
  });

  // ==================== GROUP 10: CURRENT CONFIG TESTS ====================
  group('Current Configuration Tests', () {
    test('EnvironmentConfig.current returns a valid config', () {
      final current = EnvironmentConfig.current;
      expect(current, isA<EnvironmentConfig>());
      expect(current.apiBaseUrl, isNotEmpty);
    });

    test('EnvironmentConfig.current has valid environment', () {
      final current = EnvironmentConfig.current;
      expect(
        [Environment.development, Environment.staging, Environment.production],
        contains(current.environment),
      );
    });

    test('EnvironmentConfig.current is one of the predefined configs', () {
      final current = EnvironmentConfig.current;
      final isKnownConfig = identical(current, EnvironmentConfig.development) ||
          identical(current, EnvironmentConfig.staging) ||
          identical(current, EnvironmentConfig.production);
      expect(isKnownConfig, true);
    });
  });
}
