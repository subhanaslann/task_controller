import 'package:flutter_app/data/sync/sync_manager.dart';
import 'package:flutter_app/data/sync/connectivity_aware_sync_manager.dart';
import 'package:mocktail/mocktail.dart';

class MockSyncManager extends Mock implements SyncManager {
  // Mock responses for sync operations

  void mockStartAutoSync() {
    when(() => startAutoSync()).thenReturn(null);
  }

  void mockStopAutoSync() {
    when(() => stopAutoSync()).thenReturn(null);
  }

  void mockSyncAll(SyncResult result) {
    when(() => syncAll(force: any(named: 'force'))).thenAnswer((_) async => result);
  }

  void mockSyncAllError(Exception error) {
    when(() => syncAll(force: any(named: 'force'))).thenThrow(error);
  }

  void mockGetCacheStats(Map<String, dynamic> stats) {
    when(() => getCacheStats()).thenAnswer((_) async => stats);
  }

  void mockClearCache() {
    when(() => clearCache()).thenAnswer((_) async => {});
  }

  void mockDispose() {
    when(() => dispose()).thenReturn(null);
  }
}

class MockConnectivityAwareSyncManager extends Mock implements ConnectivityAwareSyncManager {
  // Mock responses for connectivity-aware sync

  void mockInit() {
    when(() => init()).thenAnswer((_) async => {});
  }

  void mockInitError(Exception error) {
    when(() => init()).thenThrow(error);
  }

  void mockSyncNow(SyncResult result) {
    when(() => syncNow(force: any(named: 'force'))).thenAnswer((_) async => result);
  }

  void mockSyncNowError(Exception error) {
    when(() => syncNow(force: any(named: 'force'))).thenThrow(error);
  }

  void mockIsOnline(bool isOnline) {
    when(() => this.isOnline).thenReturn(isOnline);
  }

  void mockGetCacheStats(Map<String, dynamic> stats) {
    when(() => getCacheStats()).thenAnswer((_) async => stats);
  }

  void mockClearCache() {
    when(() => clearCache()).thenAnswer((_) async => {});
  }

  void mockDispose() {
    when(() => dispose()).thenReturn(null);
  }
}
