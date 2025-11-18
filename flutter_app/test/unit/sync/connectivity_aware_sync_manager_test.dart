import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_app/data/sync/connectivity_aware_sync_manager.dart';
import 'package:flutter_app/data/sync/sync_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/mock_sync_manager.dart';
import '../../mocks/mock_connectivity.dart';

void main() {
  late ConnectivityAwareSyncManager connectivitySyncManager;
  late MockSyncManager mockSyncManager;
  late MockConnectivity mockConnectivity;

  setUp(() {
    mockSyncManager = MockSyncManager();
    mockConnectivity = MockConnectivity();

    // Create instance with mocked dependencies
    connectivitySyncManager = ConnectivityAwareSyncManager(mockSyncManager);
  });

  tearDown(() {
    connectivitySyncManager.dispose();
  });

  group('ConnectivityAwareSyncManager - Initialization', () {
    test('init should check connectivity and start sync if online', () async {
      // Arrange
      mockConnectivity.mockCheckConnectivity([ConnectivityResult.wifi]);
      mockConnectivity.mockOnConnectivityChanged();
      mockSyncManager.mockStartAutoSync();
      mockSyncManager.mockSyncAll(SyncResult(success: true));

      // Act
      await connectivitySyncManager.init();

      // Assert
      expect(connectivitySyncManager.isOnline, true);
      verify(() => mockSyncManager.startAutoSync()).called(1);
      verify(() => mockSyncManager.syncAll(force: false)).called(1);
    });

    test('init should not start sync if offline', () async {
      // Arrange
      mockConnectivity.mockCheckConnectivity([ConnectivityResult.none]);
      mockConnectivity.mockOnConnectivityChanged();

      // Act
      await connectivitySyncManager.init();

      // Assert
      expect(connectivitySyncManager.isOnline, false);
      verifyNever(() => mockSyncManager.startAutoSync());
      verifyNever(() => mockSyncManager.syncAll(force: any(named: 'force')));
    });

    test('init should handle connectivity check errors', () async {
      // Arrange
      mockConnectivity.mockCheckConnectivityError(Exception('Network error'));
      mockConnectivity.mockOnConnectivityChanged();

      // Act
      await connectivitySyncManager.init();

      // Assert - Should default to offline on error
      expect(connectivitySyncManager.isOnline, false);
    });
  });

  group('ConnectivityAwareSyncManager - Connectivity Changes', () {
    test('should resume sync when going online', () async {
      // Arrange - Start offline
      mockConnectivity.mockCheckConnectivity([ConnectivityResult.none]);
      mockConnectivity.mockOnConnectivityChanged();
      await connectivitySyncManager.init();

      mockSyncManager.mockStartAutoSync();
      mockSyncManager.mockSyncAll(SyncResult(success: true));

      // Act - Emit online event
      mockConnectivity.emitOnline();
      await Future.delayed(Duration(milliseconds: 100));

      // Assert
      expect(connectivitySyncManager.isOnline, true);
    });

    test('should pause sync when going offline', () async {
      // Arrange - Start online
      mockConnectivity.mockCheckConnectivity([ConnectivityResult.wifi]);
      mockConnectivity.mockOnConnectivityChanged();
      mockSyncManager.mockStartAutoSync();
      mockSyncManager.mockSyncAll(SyncResult(success: true));
      mockSyncManager.mockStopAutoSync();

      await connectivitySyncManager.init();

      // Act - Emit offline event
      mockConnectivity.emitOffline();
      await Future.delayed(Duration(milliseconds: 100));

      // Assert
      expect(connectivitySyncManager.isOnline, false);
      verify(() => mockSyncManager.stopAutoSync()).called(greaterThan(0));
    });

    test('should detect mobile connection as online', () async {
      // Arrange
      mockConnectivity.mockCheckConnectivity([ConnectivityResult.none]);
      mockConnectivity.mockOnConnectivityChanged();
      await connectivitySyncManager.init();

      mockSyncManager.mockStartAutoSync();
      mockSyncManager.mockSyncAll(SyncResult(success: true));

      // Act - Emit mobile connection
      mockConnectivity.emitMobile();
      await Future.delayed(Duration(milliseconds: 100));

      // Assert
      expect(connectivitySyncManager.isOnline, true);
    });

    test('should handle rapid connectivity changes', () async {
      // Arrange
      mockConnectivity.mockCheckConnectivity([ConnectivityResult.wifi]);
      mockConnectivity.mockOnConnectivityChanged();
      mockSyncManager.mockStartAutoSync();
      mockSyncManager.mockStopAutoSync();
      mockSyncManager.mockSyncAll(SyncResult(success: true));

      await connectivitySyncManager.init();

      // Act - Rapid changes
      mockConnectivity.emitOffline();
      await Future.delayed(Duration(milliseconds: 50));
      mockConnectivity.emitOnline();
      await Future.delayed(Duration(milliseconds: 50));
      mockConnectivity.emitOffline();
      await Future.delayed(Duration(milliseconds: 50));

      // Assert - Should handle without crashes
      expect(connectivitySyncManager.isOnline, false);
    });
  });

  group('ConnectivityAwareSyncManager - Manual Sync', () {
    test('syncNow should sync when online', () async {
      // Arrange - Online
      mockConnectivity.mockCheckConnectivity([ConnectivityResult.wifi]);
      mockConnectivity.mockOnConnectivityChanged();
      mockSyncManager.mockStartAutoSync();

      final successResult = SyncResult(success: true, tasksFetched: 5);
      mockSyncManager.mockSyncAll(successResult);

      await connectivitySyncManager.init();

      // Act
      final result = await connectivitySyncManager.syncNow();

      // Assert
      expect(result.success, true);
      expect(result.tasksFetched, 5);
    });

    test('syncNow should return error when offline', () async {
      // Arrange - Offline
      mockConnectivity.mockCheckConnectivity([ConnectivityResult.none]);
      mockConnectivity.mockOnConnectivityChanged();
      await connectivitySyncManager.init();

      // Act
      final result = await connectivitySyncManager.syncNow();

      // Assert
      expect(result.success, false);
      expect(result.error, contains('No internet connection'));
      verifyNever(() => mockSyncManager.syncAll(force: any(named: 'force')));
    });

    test('syncNow with force should attempt sync even offline', () async {
      // Arrange - Offline
      mockConnectivity.mockCheckConnectivity([ConnectivityResult.none]);
      mockConnectivity.mockOnConnectivityChanged();
      mockSyncManager.mockSyncAll(SyncResult(success: false));

      await connectivitySyncManager.init();

      // Act
      await connectivitySyncManager.syncNow(force: true);

      // Assert - Should attempt sync
      verify(() => mockSyncManager.syncAll(force: true)).called(1);
    });
  });

  group('ConnectivityAwareSyncManager - Cache Stats', () {
    test('getCacheStats should include connectivity info', () async {
      // Arrange
      mockConnectivity.mockCheckConnectivity([ConnectivityResult.wifi]);
      mockConnectivity.mockOnConnectivityChanged();
      mockSyncManager.mockStartAutoSync();
      mockSyncManager.mockSyncAll(SyncResult(success: true));
      mockSyncManager.mockGetCacheStats({
        'tasks_count': 10,
        'dirty_tasks_count': 2,
      });

      await connectivitySyncManager.init();

      // Act
      final stats = await connectivitySyncManager.getCacheStats();

      // Assert
      expect(stats['tasks_count'], 10);
      expect(stats['dirty_tasks_count'], 2);
      expect(stats['is_online'], true);
      expect(stats['has_initial_sync'], true);
    });
  });

  group('ConnectivityAwareSyncManager - Cleanup', () {
    test('clearCache should clear cache and reset sync flag', () async {
      // Arrange
      mockConnectivity.mockCheckConnectivity([ConnectivityResult.wifi]);
      mockConnectivity.mockOnConnectivityChanged();
      mockSyncManager.mockStartAutoSync();
      mockSyncManager.mockSyncAll(SyncResult(success: true));
      mockSyncManager.mockClearCache();
      mockSyncManager.mockGetCacheStats({'has_initial_sync': false});

      await connectivitySyncManager.init();

      // Act
      await connectivitySyncManager.clearCache();

      // Assert
      verify(() => mockSyncManager.clearCache()).called(1);

      final stats = await connectivitySyncManager.getCacheStats();
      expect(stats['has_initial_sync'], false);
    });

    test('dispose should cancel subscriptions and dispose sync manager', () async {
      // Arrange
      mockConnectivity.mockCheckConnectivity([ConnectivityResult.wifi]);
      mockConnectivity.mockOnConnectivityChanged();
      mockSyncManager.mockStartAutoSync();
      mockSyncManager.mockSyncAll(SyncResult(success: true));
      mockSyncManager.mockDispose();

      await connectivitySyncManager.init();

      // Act
      connectivitySyncManager.dispose();

      // Assert
      verify(() => mockSyncManager.dispose()).called(1);
    });
  });
}
