import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:logger/logger.dart';

/// TekTech Analytics Service
/// 
/// Firebase Analytics integration for:
/// - User behavior tracking
/// - Feature usage analytics
/// - Conversion tracking
/// - Custom events
class AnalyticsService {
  static final Logger _logger = Logger();
  static FirebaseAnalytics? _analytics;
  static bool _initialized = false;

  /// Initialize Firebase Analytics
  static Future<void> init() async {
    if (_initialized) {
      _logger.w('AnalyticsService already initialized');
      return;
    }

    _analytics = FirebaseAnalytics.instance;
    _initialized = true;
    _logger.i('AnalyticsService initialized');
  }

  /// Log screen view
  static Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    if (!_initialized || _analytics == null) return;

    try {
      await _analytics!.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
      _logger.d('Screen view logged: $screenName');
    } catch (e) {
      _logger.e('Failed to log screen view', error: e);
    }
  }

  // ==================== AUTH EVENTS ====================

  /// Log login event
  static Future<void> logLogin(String method) async {
    if (!_initialized || _analytics == null) return;

    try {
      await _analytics!.logLogin(loginMethod: method);
      _logger.d('Login event logged: $method');
    } catch (e) {
      _logger.e('Failed to log login', error: e);
    }
  }

  /// Log logout event
  static Future<void> logLogout() async {
    await logEvent(
      name: 'logout',
      parameters: {'timestamp': DateTime.now().toIso8601String()},
    );
  }

  /// Log sign up event
  static Future<void> logSignUp(String method) async {
    if (!_initialized || _analytics == null) return;

    try {
      await _analytics!.logSignUp(signUpMethod: method);
      _logger.d('Sign up event logged: $method');
    } catch (e) {
      _logger.e('Failed to log sign up', error: e);
    }
  }

  // ==================== TASK EVENTS ====================

  /// Log task created
  static Future<void> logTaskCreated({
    required String taskId,
    required String status,
    required String priority,
  }) async {
    await logEvent(
      name: 'task_created',
      parameters: {
        'task_id': taskId,
        'status': status,
        'priority': priority,
      },
    );
  }

  /// Log task updated
  static Future<void> logTaskUpdated({
    required String taskId,
    required String field,
    required String oldValue,
    required String newValue,
  }) async {
    await logEvent(
      name: 'task_updated',
      parameters: {
        'task_id': taskId,
        'field': field,
        'old_value': oldValue,
        'new_value': newValue,
      },
    );
  }

  /// Log task status changed
  static Future<void> logTaskStatusChanged({
    required String taskId,
    required String fromStatus,
    required String toStatus,
  }) async {
    await logEvent(
      name: 'task_status_changed',
      parameters: {
        'task_id': taskId,
        'from_status': fromStatus,
        'to_status': toStatus,
      },
    );
  }

  /// Log task completed
  static Future<void> logTaskCompleted({
    required String taskId,
    required int daysToComplete,
  }) async {
    await logEvent(
      name: 'task_completed',
      parameters: {
        'task_id': taskId,
        'days_to_complete': daysToComplete,
      },
    );
  }

  /// Log task deleted
  static Future<void> logTaskDeleted({
    required String taskId,
    required String status,
  }) async {
    await logEvent(
      name: 'task_deleted',
      parameters: {
        'task_id': taskId,
        'status': status,
      },
    );
  }

  // ==================== SEARCH & FILTER EVENTS ====================

  /// Log search performed
  static Future<void> logSearch({
    required String query,
    int? resultCount,
  }) async {
    if (!_initialized || _analytics == null) return;

    try {
      await _analytics!.logSearch(
        searchTerm: query,
        numberOfNights: resultCount, // Reusing this field for result count
      );
      _logger.d('Search event logged: $query');
    } catch (e) {
      _logger.e('Failed to log search', error: e);
    }
  }

  /// Log filter applied
  static Future<void> logFilterApplied({
    required String filterType,
    required String filterValue,
  }) async {
    await logEvent(
      name: 'filter_applied',
      parameters: {
        'filter_type': filterType,
        'filter_value': filterValue,
      },
    );
  }

  /// Log sort changed
  static Future<void> logSortChanged({
    required String sortBy,
    required bool ascending,
  }) async {
    await logEvent(
      name: 'sort_changed',
      parameters: {
        'sort_by': sortBy,
        'ascending': ascending,
      },
    );
  }

  // ==================== SYNC EVENTS ====================

  /// Log sync started
  static Future<void> logSyncStarted({
    required bool isManual,
  }) async {
    await logEvent(
      name: 'sync_started',
      parameters: {
        'is_manual': isManual,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Log sync completed
  static Future<void> logSyncCompleted({
    required int tasksSynced,
    required int durationSeconds,
    required bool success,
  }) async {
    await logEvent(
      name: 'sync_completed',
      parameters: {
        'tasks_synced': tasksSynced,
        'duration_seconds': durationSeconds,
        'success': success,
      },
    );
  }

  /// Log sync failed
  static Future<void> logSyncFailed({
    required String error,
  }) async {
    await logEvent(
      name: 'sync_failed',
      parameters: {
        'error': error,
      },
    );
  }

  // ==================== CONNECTIVITY EVENTS ====================

  /// Log connectivity changed
  static Future<void> logConnectivityChanged({
    required bool isOnline,
  }) async {
    await logEvent(
      name: 'connectivity_changed',
      parameters: {
        'is_online': isOnline,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  // ==================== USER PROPERTY EVENTS ====================

  /// Set user ID (non-PII)
  static Future<void> setUserId(String userId) async {
    if (!_initialized || _analytics == null) return;

    try {
      await _analytics!.setUserId(id: userId);
      _logger.d('User ID set: $userId');
    } catch (e) {
      _logger.e('Failed to set user ID', error: e);
    }
  }

  /// Set user property
  static Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    if (!_initialized || _analytics == null) return;

    try {
      await _analytics!.setUserProperty(name: name, value: value);
      _logger.d('User property set: $name = $value');
    } catch (e) {
      _logger.e('Failed to set user property', error: e);
    }
  }

  /// Set user role
  static Future<void> setUserRole(String role) async {
    await setUserProperty(name: 'user_role', value: role);
  }

  // ==================== GENERIC EVENT ====================

  /// Log custom event
  static Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    if (!_initialized || _analytics == null) return;

    try {
      await _analytics!.logEvent(
        name: name,
        parameters: parameters,
      );
      _logger.d('Event logged: $name ${parameters ?? ""}');
    } catch (e) {
      _logger.e('Failed to log event: $name', error: e);
    }
  }

  // ==================== TIMING EVENTS ====================

  /// Start timing an operation
  static DateTime startTiming() {
    return DateTime.now();
  }

  /// End timing and log duration
  static Future<void> endTiming({
    required String eventName,
    required DateTime startTime,
    Map<String, Object>? additionalParams,
  }) async {
    final duration = DateTime.now().difference(startTime);
    
    await logEvent(
      name: eventName,
      parameters: {
        'duration_ms': duration.inMilliseconds,
        if (additionalParams != null) ...additionalParams,
      },
    );
  }

  // ==================== APP LIFECYCLE EVENTS ====================

  /// Log app open
  static Future<void> logAppOpen() async {
    if (!_initialized || _analytics == null) return;

    try {
      await _analytics!.logAppOpen();
      _logger.d('App open event logged');
    } catch (e) {
      _logger.e('Failed to log app open', error: e);
    }
  }

  /// Reset analytics data (use on logout)
  static Future<void> resetAnalyticsData() async {
    if (!_initialized || _analytics == null) return;

    try {
      await _analytics!.resetAnalyticsData();
      _logger.d('Analytics data reset');
    } catch (e) {
      _logger.e('Failed to reset analytics data', error: e);
    }
  }
}
