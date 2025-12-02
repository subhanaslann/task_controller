import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/secure_storage.dart';
import '../../data/datasources/firebase_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/task_repository.dart';
import '../../data/repositories/admin_repository.dart';
import '../../data/repositories/organization_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/models/user.dart';
import '../../data/models/organization.dart';

// Core providers
final secureStorageProvider = Provider<SecureStorage>((ref) => SecureStorage());

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

// Repository providers
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthRepository(firebaseService, storage);
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return TaskRepository(firebaseService);
});

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return AdminRepository(firebaseService);
});

final organizationRepositoryProvider = Provider<OrganizationRepository>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return OrganizationRepository(firebaseService);
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return UserRepository(firebaseService);
});

// Auth state provider
final currentUserProvider = StateProvider<User?>((ref) => null);

final currentOrganizationProvider = StateProvider<Organization?>((ref) => null);

final isLoggedInProvider = FutureProvider<bool>((ref) async {
  final authRepo = ref.watch(authRepositoryProvider);
  return await authRepo.isLoggedIn();
});
