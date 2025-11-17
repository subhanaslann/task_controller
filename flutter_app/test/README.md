# Flutter App Test Suite

This directory contains comprehensive tests for the Mini Task Tracker Flutter application.

## Test Structure

```
test/
├── integration/
│   └── api_integration_test.dart    # API integration tests (requires backend)
├── widgets/
│   └── task_card_widget_test.dart   # UI component tests
├── helpers/                          # Test helpers and utilities
├── mocks/                            # Mock objects
└── README.md                         # This file
```

## Test Categories

### 1. Integration Tests (`test/integration/`)

**Purpose:** Verify that the Flutter app correctly integrates with the Node.js backend

**Coverage:**
- ✅ Authentication (login, registration)
- ✅ Task management (CRUD operations)
- ✅ Organization management
- ✅ Topic management
- ✅ Admin features
- ✅ Error handling
- ✅ Data model validation

**Requirements:**
- Backend server must be running on `http://localhost:8080`
- Test database must be seeded with test data

**Run Integration Tests:**
```bash
# Start backend first
cd server
npm run dev

# In another terminal, run Flutter integration tests
cd flutter_app
flutter test test/integration/api_integration_test.dart
```

**Expected Output:**
- All endpoints should return correct status codes
- Response data should match expected models
- Authentication flow should work end-to-end

---

### 2. Widget Tests (`test/widgets/`)

**Purpose:** Verify UI components render correctly and respond to user interactions

**Coverage:**
- ✅ Task card display
- ✅ Priority colors (HIGH: Red, NORMAL: Blue, LOW: Gray)
- ✅ Status colors (TODO: Gray, IN_PROGRESS: Amber, DONE: Green)
- ✅ Due date formatting
- ✅ Overdue indicators
- ✅ Completed task display

**Run Widget Tests:**
```bash
flutter test test/widgets/task_card_widget_test.dart
```

**No backend required** - these tests are isolated and fast

---

## Running All Tests

### Run All Tests:
```bash
cd flutter_app
flutter test
```

### Run Tests with Coverage:
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Run Specific Test File:
```bash
flutter test test/integration/api_integration_test.dart
flutter test test/widgets/task_card_widget_test.dart
```

### Run Tests in Watch Mode:
```bash
flutter test --watch
```

---

## Integration Test Details

### Test Data Requirements

The integration tests expect the following test users to exist in the database:

**Admin User:**
- Email: `admin@test.com`
- Password: `admin123`
- Role: `ADMIN`

You can seed the database with:
```bash
cd server
npm run prisma:seed
```

### Test Scenarios Covered

#### 1. Authentication (7 tests)
- ✅ Health check endpoint
- ✅ Login with valid credentials
- ✅ Login with invalid credentials (401)
- ✅ Team registration
- ✅ Token generation
- ✅ Organization data in response
- ✅ User role validation

#### 2. Task Management (5 tests)
- ✅ Get my active tasks
- ✅ Get team active tasks
- ✅ Get my completed tasks
- ✅ Create task (self-assign)
- ✅ Invalid scope handling

#### 3. Organization Management (2 tests)
- ✅ Get current organization
- ✅ Get organization statistics
- ⚠️  **Note:** Tests verify actual backend endpoints vs spec

#### 4. Topics (1 test)
- ✅ Get active topics

#### 5. Admin Features (2 tests)
- ✅ Get all topics (admin)
- ✅ Get all users (admin)

#### 6. Error Handling (3 tests)
- ✅ Unauthorized requests (401)
- ✅ Invalid token (401)
- ✅ Non-existent routes (404)

#### 7. Data Model Validation (3 tests)
- ✅ User model structure
- ✅ Organization model structure
- ✅ Task model structure

---

## Known Issues & Spec Deviations

### 🔴 Critical: Organization Endpoint Mismatch

**Spec Says:**
```
GET /organization/:id
PATCH /organization/:id
GET /organization/:id/stats
```

**Backend Implements:**
```
GET /organization
PATCH /organization
GET /organization/stats
```

**Reason:** Backend uses JWT token to get organization ID (more secure)

**Tests:** Integration tests verify the **actual backend** implementation

**Action Required:** Flutter app should use `/organization` not `/organization/:id`

---

## Widget Test Details

### Task Card Tests (13 tests)

**Color Validation:**
- High priority: `#EF4444` (Red 500)
- Normal priority: `#3B82F6` (Blue 500)
- Low priority: `#6B7280` (Gray 500)
- TODO status: `#6B7280` (Gray 500)
- IN_PROGRESS status: `#F59E0B` (Amber 500)
- DONE status: `#10B981` (Emerald 500)

**Layout Tests:**
- Priority stripe (4px left border)
- Title rendering
- Note preview (first 100 chars)
- Due date formatting
- Overdue indicators (red text)
- Completion date display

---

## Test Configuration

### Test Timeout

Default: 2 minutes per test

To increase timeout:
```dart
testWidgets('my test', (tester) async {
  // ...
}, timeout: const Timeout(Duration(minutes: 5)));
```

### Test Environment

The integration tests use:
- Base URL: `http://localhost:8080`
- Timeout: 10 seconds for connections
- Auto-retry: No (fails fast)

### Mocking

For unit tests (not yet implemented), consider mocking:
- API service (`ApiService`)
- Repositories
- Notifiers (Riverpod providers)

---

## Coverage Goals

| Category | Target | Current |
|----------|--------|---------|
| Integration | 80% of API endpoints | ~85% |
| Widget | 70% of UI components | ~15% |
| Unit | 70% of business logic | 0% (TODO) |

---

## Continuous Integration

### GitHub Actions Example:

```yaml
name: Flutter Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.9.2'

      - name: Install dependencies
        working-directory: flutter_app
        run: flutter pub get

      - name: Run tests
        working-directory: flutter_app
        run: flutter test

      - name: Generate coverage
        working-directory: flutter_app
        run: flutter test --coverage
```

---

## Troubleshooting

### Integration Tests Failing?

1. **Check backend is running:**
   ```bash
   curl http://localhost:8080/health
   ```

2. **Verify database is seeded:**
   ```bash
   cd server && npm run prisma:seed
   ```

3. **Check CORS settings:**
   - Backend should allow `localhost` origins in development

4. **Verify test credentials:**
   - Email: `admin@test.com`
   - Password: `admin123`

### Widget Tests Failing?

1. **Update golden files if needed:**
   ```bash
   flutter test --update-goldens
   ```

2. **Clear cache:**
   ```bash
   flutter clean
   flutter pub get
   ```

---

## Adding New Tests

### Integration Test Template:

```dart
test('My new API test', () async {
  // Arrange
  final request = MyRequest(data: 'test');

  // Act
  final response = await apiService.myEndpoint(request);

  // Assert
  expect(response.statusCode, 200);
  expect(response.data, isNotNull);
});
```

### Widget Test Template:

```dart
testWidgets('My widget test', (WidgetTester tester) async {
  // Arrange
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: MyWidget(),
      ),
    ),
  );

  // Act
  await tester.tap(find.byType(Button));
  await tester.pump();

  // Assert
  expect(find.text('Expected'), findsOneWidget);
});
```

---

## Resources

- [Flutter Testing Guide](https://flutter.dev/docs/testing)
- [Riverpod Testing](https://riverpod.dev/docs/cookbooks/testing)
- [Widget Testing](https://flutter.dev/docs/cookbook/testing/widget/introduction)
- [Integration Testing](https://flutter.dev/docs/testing/integration-tests)

---

## Maintenance

**Last Updated:** November 17, 2025
**Test Coverage:** ~45% (Integration + Widget)
**Total Tests:** 20+ tests

**TODO:**
- [ ] Add unit tests for repositories
- [ ] Add unit tests for notifiers
- [ ] Add golden tests for UI components
- [ ] Add E2E tests using `integration_test` package
- [ ] Increase widget test coverage to 70%
