import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../storage/secure_storage.dart';
import '../network/dio_client.dart';
import '../../data/datasources/api_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/task_repository.dart';
import '../../data/repositories/admin_repository.dart';
import '../../data/cache/cache_repository.dart';
import '../../data/sync/sync_manager.dart';
import '../../data/sync/connectivity_aware_sync_manager.dart';
import '../../data/models/user.dart';

// Core providers
final secureStorageProvider = Provider<SecureStorage>((ref) => SecureStorage());

final dioClientProvider = Provider<DioClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return DioClient(storage);
});

final apiServiceProvider = Provider<ApiService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ApiService(dioClient.dio);
});

// Repository providers
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthRepository(apiService, storage);
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return TaskRepository(apiService);
});

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AdminRepository(apiService);
});

// Cache and Sync providers
final cacheRepositoryProvider = Provider<CacheRepository>((ref) {
  return CacheRepository();
});

final syncManagerProvider = Provider<SyncManager>((ref) {
  final cacheRepo = ref.watch(cacheRepositoryProvider);
  final taskRepo = ref.watch(taskRepositoryProvider);
  final adminRepo = ref.watch(adminRepositoryProvider);
  
  return SyncManager(
    cacheRepo: cacheRepo,
    taskRepo: taskRepo,
    adminRepo: adminRepo,
  );
});

final connectivityAwareSyncManagerProvider = Provider<ConnectivityAwareSyncManager>((ref) {
  final syncManager = ref.watch(syncManagerProvider);
  return ConnectivityAwareSyncManager(syncManager);
});

// Connectivity state provider
final connectivityProvider = StreamProvider<bool>((ref) {
  final connectivity = Connectivity();
  
  return connectivity.onConnectivityChanged.map((results) {
    return results.any((result) =>
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet);
  });
});

// Auth state provider
final currentUserProvider = StateProvider<User?>((ref) => null);

final isLoggedInProvider = FutureProvider<bool>((ref) async {
  final authRepo = ref.watch(authRepositoryProvider);
  return await authRepo.isLoggedIn();
});
