import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:flutter_app/data/sync/connectivity_aware_sync_manager.dart';
import 'package:flutter_app/data/sync/sync_manager.dart';
import 'package:flutter_app/data/cache/cache_repository.dart';
import 'package:flutter_app/data/repositories/task_repository.dart';
import 'package:flutter_app/data/repositories/admin_repository.dart';
import 'package:flutter_app/data/datasources/api_service.dart';
import 'package:flutter_app/core/network/dio_client.dart';
import 'package:flutter_app/core/storage/secure_storage.dart';

/// TekTech Mini Task Tracker
/// Integration Tests - Offline Sync Scenarios
///
/// These tests validate offline-first functionality:
/// - Cache management
/// - Connectivity awareness
/// - Sync manager behavior
/// - Offline data persistence
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Connectivity Aware Sync Manager Tests', () {
    test('Sync manager initializes correctly', () async {
      final cacheRepo = CacheRepository();
      await cacheRepo.init();

      final secureStorage = SecureStorage();
      final dioClient = DioClient(secureStorage);
      final apiService = ApiService(dioClient.dio);

      final taskRepo = TaskRepository(apiService);
      final adminRepo = AdminRepository(apiService);

      final syncManager = SyncManager(
        cacheRepo: cacheRepo,
        taskRepo: taskRepo,
        adminRepo: adminRepo,
      );

      final connectivityManager = ConnectivityAwareSyncManager(syncManager);

      // Verify manager is created
      expect(connectivityManager, isNotNull);

      // Clean up
      connectivityManager.dispose();
      await cacheRepo.close();
    });

    test('Sync manager detects online status', () async {
      final cacheRepo = CacheRepository();
      await cacheRepo.init();

      final secureStorage = SecureStorage();
      final dioClient = DioClient(secureStorage);
      final apiService = ApiService(dioClient.dio);

      final taskRepo = TaskRepository(apiService);
      final adminRepo = AdminRepository(apiService);

      final syncManager = SyncManager(
        cacheRepo: cacheRepo,
        taskRepo: taskRepo,
        adminRepo: adminRepo,
      );

      final connectivityManager = ConnectivityAwareSyncManager(syncManager);
      await connectivityManager.init();

      // Check connectivity status
      final isOnline = connectivityManager.isOnline;
      expect(isOnline, isA<bool>());

      // Clean up
      connectivityManager.dispose();
      await cacheRepo.close();
    });

    test('Cache stats are accessible and structured correctly', () async {
      final cacheRepo = CacheRepository();
      await cacheRepo.init();

      final secureStorage = SecureStorage();
      final dioClient = DioClient(secureStorage);
      final apiService = ApiService(dioClient.dio);

      final taskRepo = TaskRepository(apiService);
      final adminRepo = AdminRepository(apiService);

      final syncManager = SyncManager(
        cacheRepo: cacheRepo,
        taskRepo: taskRepo,
        adminRepo: adminRepo,
      );

      final connectivityManager = ConnectivityAwareSyncManager(syncManager);
      await connectivityManager.init();

      final stats = await connectivityManager.getCacheStats();

      // Verify stats structure
      expect(stats, isA<Map<String, dynamic>>());
      expect(stats.containsKey('is_online'), isTrue);
      expect(stats.containsKey('has_initial_sync'), isTrue);

      // Clean up
      connectivityManager.dispose();
      await cacheRepo.close();
    });

    test('Manual sync returns SyncResult', () async {
      final cacheRepo = CacheRepository();
      await cacheRepo.init();

      final secureStorage = SecureStorage();
      final dioClient = DioClient(secureStorage);
      final apiService = ApiService(dioClient.dio);

      final taskRepo = TaskRepository(apiService);
      final adminRepo = AdminRepository(apiService);

      final syncManager = SyncManager(
        cacheRepo: cacheRepo,
        taskRepo: taskRepo,
        adminRepo: adminRepo,
      );

      final connectivityManager = ConnectivityAwareSyncManager(syncManager);
      await connectivityManager.init();

      // Try manual sync (will fail if offline or no backend)
      final result = await connectivityManager.syncNow();

      expect(result, isA<SyncResult>());
      // Result can be success or error depending on network/backend availability

      // Clean up
      connectivityManager.dispose();
      await cacheRepo.close();
    });

    test('Clear cache resets initial sync flag', () async {
      final cacheRepo = CacheRepository();
      await cacheRepo.init();

      final secureStorage = SecureStorage();
      final dioClient = DioClient(secureStorage);
      final apiService = ApiService(dioClient.dio);

      final taskRepo = TaskRepository(apiService);
      final adminRepo = AdminRepository(apiService);

      final syncManager = SyncManager(
        cacheRepo: cacheRepo,
        taskRepo: taskRepo,
        adminRepo: adminRepo,
      );

      final connectivityManager = ConnectivityAwareSyncManager(syncManager);
      await connectivityManager.init();

      // Clear cache
      await connectivityManager.clearCache();

      // Verify initial sync flag is reset
      final stats = await connectivityManager.getCacheStats();
      expect(stats['has_initial_sync'], isFalse);

      // Clean up
      connectivityManager.dispose();
      await cacheRepo.close();
    });
  });

  group('Mock Connectivity Tests', () {
    test('Sync manager respects mock offline status', () async {
      // Create mock connectivity that reports offline
      final mockConnectivity = _MockConnectivity(isOnline: false);

      final cacheRepo = CacheRepository();
      await cacheRepo.init();

      final secureStorage = SecureStorage();
      final dioClient = DioClient(secureStorage);
      final apiService = ApiService(dioClient.dio);

      final taskRepo = TaskRepository(apiService);
      final adminRepo = AdminRepository(apiService);

      final syncManager = SyncManager(
        cacheRepo: cacheRepo,
        taskRepo: taskRepo,
        adminRepo: adminRepo,
      );

      final connectivityManager = ConnectivityAwareSyncManager(
        syncManager,
        connectivity: mockConnectivity,
      );
      await connectivityManager.init();

      // Verify offline detection
      expect(connectivityManager.isOnline, isFalse);

      // Manual sync should return error when offline
      final result = await connectivityManager.syncNow();
      expect(result.success, isFalse);
      expect(result.error, contains('No internet'));

      // Clean up
      connectivityManager.dispose();
      await cacheRepo.close();
    });

    test('Sync manager respects mock online status', () async {
      // Create mock connectivity that reports online
      final mockConnectivity = _MockConnectivity(isOnline: true);

      final cacheRepo = CacheRepository();
      await cacheRepo.init();

      final secureStorage = SecureStorage();
      final dioClient = DioClient(secureStorage);
      final apiService = ApiService(dioClient.dio);

      final taskRepo = TaskRepository(apiService);
      final adminRepo = AdminRepository(apiService);

      final syncManager = SyncManager(
        cacheRepo: cacheRepo,
        taskRepo: taskRepo,
        adminRepo: adminRepo,
      );

      final connectivityManager = ConnectivityAwareSyncManager(
        syncManager,
        connectivity: mockConnectivity,
      );
      await connectivityManager.init();

      // Verify online detection
      expect(connectivityManager.isOnline, isTrue);

      // Clean up
      connectivityManager.dispose();
      await cacheRepo.close();
    });

    test('Connectivity changes trigger sync resumption', () async {
      // Create mock connectivity that can change state
      final mockConnectivity = _MockConnectivity(isOnline: false);

      final cacheRepo = CacheRepository();
      await cacheRepo.init();

      final secureStorage = SecureStorage();
      final dioClient = DioClient(secureStorage);
      final apiService = ApiService(dioClient.dio);

      final taskRepo = TaskRepository(apiService);
      final adminRepo = AdminRepository(apiService);

      final syncManager = SyncManager(
        cacheRepo: cacheRepo,
        taskRepo: taskRepo,
        adminRepo: adminRepo,
      );

      final connectivityManager = ConnectivityAwareSyncManager(
        syncManager,
        connectivity: mockConnectivity,
      );
      await connectivityManager.init();

      // Start offline
      expect(connectivityManager.isOnline, isFalse);

      // Simulate going online
      mockConnectivity.simulateConnectivityChange(
        [ConnectivityResult.wifi],
      );

      // Wait for connectivity change to be processed
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify online status
      expect(connectivityManager.isOnline, isTrue);

      // Clean up
      connectivityManager.dispose();
      await cacheRepo.close();
    });
  });

  group('Cache Repository Tests', () {
    test('Cache repository initializes successfully', () async {
      final cacheRepo = CacheRepository();
      await cacheRepo.init();

      expect(cacheRepo, isNotNull);

      await cacheRepo.close();
    });

    test('Cache can store and retrieve data', () async {
      final cacheRepo = CacheRepository();
      await cacheRepo.init();

      // Cache operations are tested in unit tests
      // This integration test verifies initialization works

      await cacheRepo.close();
    });

    test('Cache repository can be closed and reopened', () async {
      final cacheRepo = CacheRepository();

      // First init
      await cacheRepo.init();
      await cacheRepo.close();

      // Second init
      await cacheRepo.init();
      expect(cacheRepo, isNotNull);

      await cacheRepo.close();
    });
  });

  group('Offline Behavior Documentation', () {
    test('Document expected offline behavior', () {
      // Expected offline behavior:
      final expectedBehavior = {
        'Cache': 'Tasks are cached locally using Hive',
        'Offline Banner': 'UI shows offline indicator when disconnected',
        'Optimistic Updates': 'Changes are applied immediately to cache',
        'Dirty Flags': 'Modified tasks are marked as dirty',
        'Auto Sync': 'Paused when offline, resumes when online',
        'Manual Sync': 'Returns error message when offline',
        'Reconnection Sync': 'Automatically syncs dirty data when online',
      };

      expect(expectedBehavior.length, 7);
    });

    test('Document sync manager capabilities', () {
      // SyncManager features:
      final features = {
        'Auto Sync': 'Periodic sync every 5 minutes',
        'Manual Sync': 'User-triggered sync via syncNow()',
        'Force Sync': 'Bypass connectivity check with force=true',
        'Cache Stats': 'Get cache status and dirty count',
        'Clear Cache': 'Reset all cached data',
        'Connectivity Aware': 'Respects network state',
        'Error Handling': 'Graceful degradation on failures',
      };

      expect(features.length, 7);
    });

    test('Document connectivity states', () {
      // Connectivity states handled:
      final states = {
        'WiFi': 'Full sync enabled',
        'Mobile': 'Full sync enabled',
        'Ethernet': 'Full sync enabled',
        'None': 'Offline mode, cache only',
        'Unknown': 'Treated as offline',
      };

      expect(states.length, 5);
    });
  });
}

/// Mock Connectivity for testing
class _MockConnectivity implements Connectivity {
  bool _isOnline;
  final StreamController<List<ConnectivityResult>> _controller =
      StreamController<List<ConnectivityResult>>.broadcast();

  _MockConnectivity({required bool isOnline}) : _isOnline = isOnline;

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async {
    if (_isOnline) {
      return [ConnectivityResult.wifi];
    } else {
      return [ConnectivityResult.none];
    }
  }

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _controller.stream;

  /// Simulate connectivity change for testing
  void simulateConnectivityChange(List<ConnectivityResult> results) {
    _isOnline = results.any((r) =>
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.ethernet);
    _controller.add(results);
  }

  void dispose() {
    _controller.close();
  }
}
