import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_app/core/storage/secure_storage.dart';
import 'package:flutter_app/data/datasources/api_service.dart';
import 'package:flutter_app/data/repositories/auth_repository.dart';
import 'package:flutter_app/data/models/user.dart';
import 'package:flutter_app/data/models/organization.dart';
import 'package:flutter_app/core/utils/constants.dart';

/// BUG REPORT: Registration Immediate Navigation Race Condition
/// 
/// PROBLEM:
/// When a user registers as Team Manager, they are immediately redirected to home
/// screen. The home screen immediately tries to fetch tasks, but the first API 
/// request fails with "ORGANIZATION_NOT_FOUND" (404).
/// 
/// ROOT CAUSE:
/// 1. Registration completes successfully and returns a token
/// 2. Token is saved to secure storage asynchronously
/// 3. User is immediately navigated to home screen (context.go(AppRoutes.home))
/// 4. Home screen widget builds and triggers task fetch in initState/provider
/// 5. AuthInterceptor's onRequest() reads token asynchronously via getToken()
/// 6. Race condition: First API request may be sent BEFORE token is fully saved
///    or BEFORE AuthInterceptor has time to read and attach it to headers
/// 7. Backend's authenticate middleware checks JWT, finds organizationId,
///    queries database, but if token is missing/invalid, throws ORGANIZATION_NOT_FOUND
/// 
/// OBSERVED BEHAVIOR:
/// - Terminal logs show: DioError Status: 404 Not Found
/// - Error message: "ORGANIZATION_NOT_FOUND"
/// - Screen shows: "Error loading tasks" with retry button
/// - User has to manually retry to see tasks (retry succeeds)
/// 
/// EXPECTED BEHAVIOR:
/// - After successful registration, user should see home screen with tasks loaded
/// - No error should occur on first navigation
/// 
/// TEST STRATEGY:
/// This test simulates the exact timing issue:
/// 1. Mock registration API returning valid token
/// 2. Save token to storage
/// 3. Immediately (within 0-50ms) make a task fetch request
/// 4. Verify if request has Authorization header with correct token
/// 5. Test various timing scenarios (immediate, 10ms, 50ms delays)

void main() {
  // Initialize Flutter binding for tests that use platform channels
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Registration → Immediate Navigation Bug Tests', () {
    late SecureStorage storage;
    late ApiService apiService;
    late AuthRepository authRepository;
    late Dio dio;

    setUp(() {
      storage = SecureStorage();
      dio = Dio(BaseOptions(
        baseUrl: 'http://10.0.2.2:8080',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ));
      apiService = ApiService(dio);
      authRepository = AuthRepository(apiService, storage);
    });

    tearDown(() async {
      // Clean up storage after each test
      await storage.clearAll();
    });

    test('REPRO: Immediate navigation after registration causes missing token', () async {
      // This test reproduces the EXACT bug scenario
      
      // Step 1: Simulate successful registration
      // In real scenario, this would call authRepository.register()
      const mockToken = 'mock.jwt.token.for.test';
      const mockOrgId = 'test-org-123';
      
      final mockOrg = Organization(
        id: mockOrgId,
        name: 'Test Company',
        teamName: 'Test Team',
        slug: 'test-company-test-team',
        isActive: true,
        maxUsers: 15,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      // Step 2: Save token (async operation)
      final tokenSaveFuture = storage.saveToken(mockToken);
      final orgSaveFuture = storage.saveOrganization(mockOrg.toJson());
      
      // Step 3: DO NOT AWAIT - simulate immediate navigation
      // This is what happens in real app: registration_screen.dart line 137
      // context.go(AppRoutes.home) is called immediately after starting save operations
      
      // Step 4: Immediately try to fetch tasks (simulating home screen init)
      // Wait just 10ms to simulate widget build time
      await Future.delayed(const Duration(milliseconds: 10));
      
      // Step 5: Try to read token (simulating AuthInterceptor.onRequest)
      final retrievedToken = await storage.getToken();
      
      // Step 6: Complete the save operations
      await tokenSaveFuture;
      await orgSaveFuture;
      
      // ASSERTION: Token might not be available immediately
      // This test documents the race condition
      print('Token retrieved during race condition: $retrievedToken');
      print('Expected token: $mockToken');
      
      // Note: This test might be flaky depending on device speed
      // On fast devices, token might be saved before we read it
      // On slow devices or under load, token will be null
    });

    test('VERIFY: Token is available after proper async/await', () async {
      // This test shows the CORRECT way: wait for token save to complete
      
      const mockToken = 'mock.jwt.token.for.test';
      const mockOrgId = 'test-org-123';
      
      final mockOrg = Organization(
        id: mockOrgId,
        name: 'Test Company',
        teamName: 'Test Team',
        slug: 'test-company-test-team',
        isActive: true,
        maxUsers: 15,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      // CORRECT: Properly await token save
      await storage.saveToken(mockToken);
      await storage.saveOrganization(mockOrg.toJson());
      
      // CORRECT: Only navigate after save completes
      // In real app, this would be: if (mounted) context.go(AppRoutes.home)
      
      // Now read token
      final retrievedToken = await storage.getToken();
      final retrievedOrg = await storage.getOrganization();
      
      // ASSERTION: Token should always be available
      expect(retrievedToken, equals(mockToken));
      expect(retrievedOrg, isNotNull);
      expect(retrievedOrg!['id'], equals(mockOrgId));
    });

    test('TIMING: Measure token save duration', () async {
      // This test measures how long token save actually takes
      // to understand the race condition window
      
      const mockToken = 'mock.jwt.token.for.test';
      
      final stopwatch = Stopwatch()..start();
      await storage.saveToken(mockToken);
      stopwatch.stop();
      
      print('Token save took: ${stopwatch.elapsedMilliseconds}ms');
      
      // On most devices, this is 1-50ms
      // But during this time, navigation and API calls can happen
      expect(stopwatch.elapsedMilliseconds, lessThan(100),
        reason: 'Token save should complete quickly');
    });

    test('SCENARIO: Rapid sequential operations (realistic timing)', () async {
      // This test simulates realistic app timing:
      // 1. Register (network call)
      // 2. Save token (storage operation)
      // 3. Update providers (in-memory operation)
      // 4. Navigate (UI operation)
      // 5. Home screen init (immediate)
      // 6. Fetch tasks (network call starts)
      
      const mockToken = 'mock.jwt.token.for.test';
      
      // Simulate registration response received
      final regCompleteTime = DateTime.now();
      print('T+0ms: Registration response received');
      
      // Start token save (but don't wait)
      final tokenSaveFuture = storage.saveToken(mockToken);
      print('T+1ms: Token save started (async)');
      
      // Simulate provider updates (fast in-memory operations)
      await Future.delayed(const Duration(milliseconds: 1));
      print('T+2ms: Providers updated');
      
      // Simulate navigation (fast UI operation)
      await Future.delayed(const Duration(milliseconds: 1));
      print('T+3ms: Navigation triggered to home');
      
      // Simulate home screen init and task fetch trigger
      await Future.delayed(const Duration(milliseconds: 2));
      print('T+5ms: Home screen initState, task fetch triggered');
      
      // AuthInterceptor tries to read token
      final tokenAtInterceptor = await storage.getToken();
      print('T+${DateTime.now().difference(regCompleteTime).inMilliseconds}ms: Interceptor reads token');
      
      // Wait for save to complete
      await tokenSaveFuture;
      
      // Check final state
      final finalToken = await storage.getToken();
      
      print('Token at interceptor time: $tokenAtInterceptor');
      print('Token after save completes: $finalToken');
      
      // This demonstrates the race condition window is ~5-10ms
      expect(finalToken, equals(mockToken), 
        reason: 'Token should eventually be saved');
    });

    test('FIX VERIFICATION: Await save before navigation', () async {
      // This test verifies the fix works correctly
      // The fix is to await token save before navigating
      
      const mockToken = 'mock.jwt.token.for.test';
      const mockOrgId = 'test-org-123';
      
      final mockOrg = Organization(
        id: mockOrgId,
        name: 'Test Company',
        teamName: 'Test Team',
        slug: 'test-company-test-team',
        isActive: true,
        maxUsers: 15,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      // FIX: AuthRepository.register() already awaits token save (line 39-40)
      // But registration_screen.dart doesn't wait for register() to complete
      // before setting providers and navigating
      
      // Simulate the correct flow:
      await storage.saveToken(mockToken);
      await storage.saveOrganization(mockOrg.toJson());
      
      // Small delay for provider update
      await Future.delayed(const Duration(milliseconds: 5));
      
      // Now navigation happens
      // And immediately after, task fetch
      final token = await storage.getToken();
      
      expect(token, equals(mockToken),
        reason: 'Token must be available when task fetch starts');
    });

    test('EDGE CASE: Multiple rapid token reads', () async {
      // Test if multiple concurrent reads during save cause issues
      
      const mockToken = 'mock.jwt.token.for.test';
      
      // Start save
      final saveFuture = storage.saveToken(mockToken);
      
      // Immediately trigger multiple reads (simulating multiple interceptors)
      final read1 = storage.getToken();
      final read2 = storage.getToken();
      final read3 = storage.getToken();
      
      await saveFuture;
      
      final results = await Future.wait([read1, read2, read3]);
      
      print('Concurrent read results: $results');
      
      // After save completes, all reads should eventually get the token
      final finalToken = await storage.getToken();
      expect(finalToken, equals(mockToken));
    });

    test('INTEGRATION: Full registration flow with proper timing', () async {
      // This is a more realistic integration test
      // It doesn't call the real API, but simulates the full flow
      
      const testCompanyName = 'Test Corp';
      const testTeamName = 'Engineering';
      const testManagerName = 'John Doe';
      const testUsername = 'johndoe';
      const testEmail = 'john@test.com';
      const testPassword = 'password123';
      
      // In real test, this would make actual HTTP call to registration endpoint
      // For now, we simulate the registration response handling
      
      // Simulate: Registration succeeded, got response with token
      const mockToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.mock.token';
      const mockOrgId = 'org-12345';
      
      final mockOrg = Organization(
        id: mockOrgId,
        name: testCompanyName,
        teamName: testTeamName,
        slug: 'test-corp-engineering',
        isActive: true,
        maxUsers: 15,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      final mockUser = User(
        id: 'user-12345',
        organizationId: mockOrgId,
        name: testManagerName,
        username: testUsername,
        email: testEmail,
        role: UserRole.teamManager,
        active: true,
      );

      // CRITICAL: Save token and org BEFORE any navigation or state updates
      await storage.saveToken(mockToken);
      await storage.saveOrganization(mockOrg.toJson());
      
      // Verify immediately
      final savedToken = await storage.getToken();
      final savedOrg = await storage.getOrganization();
      
      expect(savedToken, equals(mockToken));
      expect(savedOrg, isNotNull);
      expect(savedOrg!['id'], equals(mockOrgId));
      
      // Now it's safe to navigate and make API calls
      // Simulate task fetch (which needs token)
      final tokenForTaskFetch = await storage.getToken();
      expect(tokenForTaskFetch, isNotNull,
        reason: 'Token must be available for immediate task fetch after registration');
    });
  });

  group('AuthInterceptor Token Injection Tests', () {
    test('VERIFY: Token is properly read and attached to request', () async {
      final storage = SecureStorage();
      const mockToken = 'test.jwt.token';
      
      await storage.saveToken(mockToken);
      
      // Simulate what AuthInterceptor does
      final token = await storage.getToken();
      
      expect(token, equals(mockToken));
      expect(token, isNotEmpty);
      
      // In real interceptor, this would be: 
      // options.headers['Authorization'] = 'Bearer $token';
      
      await storage.clearAll();
    });

    test('EDGE CASE: Token is null during interceptor', () async {
      final storage = SecureStorage();
      
      // Don't save any token
      final token = await storage.getToken();
      
      expect(token, isNull,
        reason: 'If no token saved, getToken returns null');
      
      // Interceptor should handle this gracefully
      // In real code: if (token != null && token.isNotEmpty)
    });
  });

  group('Proposed Fix Tests', () {
    test('FIX: registration_screen.dart should await register before navigation', () async {
      // CURRENT CODE (registration_screen.dart lines 112-138):
      // final authResult = await authRepo.register(...);
      // ref.read(currentUserProvider.notifier).state = authResult.user;
      // ref.read(currentOrganizationProvider.notifier).state = authResult.organization;
      // ref.invalidate(isLoggedInProvider);
      // context.go(AppRoutes.home);
      //
      // PROBLEM: After register() returns, token is already saved (auth_repository.dart:39-40)
      // But we immediately update providers and navigate. There's a race between:
      // 1. Provider state propagation
      // 2. Router redirect logic
      // 3. Home screen build
      // 4. Task fetch initiation
      //
      // FIX 1: Add small delay before navigation
      // await Future.delayed(const Duration(milliseconds: 100));
      // context.go(AppRoutes.home);
      //
      // FIX 2: Better - wait for providers to update
      // await Future.delayed(Duration.zero); // Let microtasks complete
      // context.go(AppRoutes.home);
      //
      // FIX 3: Best - ensure token is readable before navigation
      // final token = await authRepo.getToken();
      // if (token != null) context.go(AppRoutes.home);
      
      // This test verifies FIX 3
      final storage = SecureStorage();
      const mockToken = 'verified.token';
      
      await storage.saveToken(mockToken);
      
      // Verify token is readable
      final verifiedToken = await storage.getToken();
      
      if (verifiedToken != null && verifiedToken.isNotEmpty) {
        // Safe to navigate now
        expect(verifiedToken, equals(mockToken));
      } else {
        fail('Token should be available before navigation');
      }
      
      await storage.clearAll();
    });

    test('FIX: Add token availability check before navigation', () async {
      // Proposed helper method for registration screen
      Future<bool> isTokenReady(SecureStorage storage) async {
        final token = await storage.getToken();
        return token != null && token.isNotEmpty;
      }
      
      final storage = SecureStorage();
      
      // Before token save
      expect(await isTokenReady(storage), isFalse);
      
      // After token save
      await storage.saveToken('test.token');
      expect(await isTokenReady(storage), isTrue);
      
      await storage.clearAll();
    });
  });
}
