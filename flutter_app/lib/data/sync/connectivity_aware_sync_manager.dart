import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';
import 'sync_manager.dart';

/// TekTech ConnectivityAwareSyncManager
/// 
/// Enhanced sync manager with network connectivity awareness
/// - Auto-sync when going online
/// - Pause sync when offline
/// - Track connectivity state
/// - Smart retry on reconnection
class ConnectivityAwareSyncManager {
  final SyncManager _syncManager;
  final Connectivity _connectivity = Connectivity();
  final Logger _logger = Logger();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isOnline = true;
  bool _hasInitialSync = false;

  ConnectivityAwareSyncManager(this._syncManager);

  /// Initialize and start connectivity monitoring
  Future<void> init() async {
    // Check initial connectivity
    await _checkConnectivity();

    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
      onError: (error) {
        _logger.e('Connectivity stream error: $error');
      },
    );

    // Start auto-sync if online
    if (_isOnline) {
      _logger.i('Starting auto-sync (online)');
      _syncManager.startAutoSync();
      
      // Initial sync
      if (!_hasInitialSync) {
        await _performInitialSync();
      }
    } else {
      _logger.w('Device is offline, auto-sync paused');
    }
  }

  /// Check current connectivity state
  Future<void> _checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _isOnline = _isConnected(results);
      _logger.d('Connectivity check: ${_isOnline ? "online" : "offline"}');
    } catch (e) {
      _logger.e('Failed to check connectivity: $e');
      _isOnline = false;
    }
  }

  /// Handle connectivity changes
  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final wasOnline = _isOnline;
    _isOnline = _isConnected(results);

    _logger.i('Connectivity changed: ${results} (${_isOnline ? "online" : "offline"})');

    if (_isOnline && !wasOnline) {
      // Just came online - sync immediately
      _handleOnline();
    } else if (!_isOnline && wasOnline) {
      // Just went offline - pause sync
      _handleOffline();
    }
  }

  /// Handle going online
  void _handleOnline() {
    _logger.i('Device is online - resuming sync');
    
    // Start auto-sync
    _syncManager.startAutoSync();
    
    // Immediate sync to push dirty data and fetch fresh
    Future.delayed(const Duration(seconds: 1), () async {
      try {
        _logger.i('Performing reconnection sync...');
        final result = await _syncManager.syncAll(force: true);
        _logger.i('Reconnection sync result: $result');
      } catch (e) {
        _logger.e('Reconnection sync failed: $e');
      }
    });
  }

  /// Handle going offline
  void _handleOffline() {
    _logger.w('Device is offline - pausing auto-sync');
    _syncManager.stopAutoSync();
  }

  /// Perform initial sync
  Future<void> _performInitialSync() async {
    try {
      _logger.i('Performing initial sync...');
      final result = await _syncManager.syncAll();
      _logger.i('Initial sync result: $result');
      _hasInitialSync = true;
    } catch (e) {
      _logger.e('Initial sync failed: $e');
    }
  }

  /// Check if device has connectivity
  bool _isConnected(List<ConnectivityResult> results) {
    return results.any((result) =>
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet);
  }

  /// Manual sync (respects connectivity)
  Future<SyncResult> syncNow({bool force = false}) async {
    if (!_isOnline && !force) {
      _logger.w('Device is offline, skipping sync');
      return SyncResult.error('No internet connection');
    }

    return await _syncManager.syncAll(force: force);
  }

  /// Get current connectivity status
  bool get isOnline => _isOnline;

  /// Get cache stats
  Future<Map<String, dynamic>> getCacheStats() async {
    final stats = await _syncManager.getCacheStats();
    return {
      ...stats,
      'is_online': _isOnline,
      'has_initial_sync': _hasInitialSync,
    };
  }

  /// Clear cache
  Future<void> clearCache() async {
    await _syncManager.clearCache();
    _hasInitialSync = false;
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _syncManager.dispose();
  }
}
