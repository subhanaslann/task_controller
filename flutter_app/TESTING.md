# Testing Guide

## TekTech Mini Task Tracker - Kapsamlı Test Rehberi

Bu rehber, uygulamanın kritik özelliklerini test etmek için adım adım talimatlar içerir.

---

## 1. Offline Scenarios Test (Airplane Mode)

### Amaç
Uygulamanın internet bağlantısı olmadan çalışabildiğini ve senkronizasyon stratejisinin doğru çalıştığını doğrulamak.

### Test Senaryoları

#### Senaryo 1: Offline Mode Activation
```bash
# Adımlar:
1. Uygulamayı başlat (online)
2. Görevleri görüntüle ve cache'lendiğini doğrula
3. Airplane mode'u aç
4. Uygulamayı yeniden başlat veya yenile

# Beklenen Sonuç:
✓ Cache'lenmiş görevler görüntülenir
✓ "Çevrimdışı Mod" göstergesi görünür
✓ Hiçbir hata mesajı yok
✓ UI responsive ve kullanılabilir
```

#### Senaryo 2: Optimistic Updates Offline
```bash
# Adımlar:
1. Airplane mode aktif (offline)
2. Bir görevin durumunu değiştir (TODO → IN_PROGRESS)
3. Görevi düzenle (not ekle)
4. Cache stats'ı kontrol et

# Beklenen Sonuç:
✓ Değişiklikler hemen UI'da görünür (optimistic)
✓ Görev "dirty" olarak işaretlenir
✓ Cache'te değişiklik kaydedilir
✓ Hata mesajı yok
```

#### Senaryo 3: Sync on Reconnection
```bash
# Adımlar:
1. Offline değişiklikler yap (Senaryo 2)
2. Airplane mode'u kapat (online)
3. 1-2 saniye bekle (auto-sync tetiklenir)
4. Loglara bak veya cache stats kontrol et

# Beklenen Sonuç:
✓ Auto-sync otomatik başlar
✓ Dirty tasks sunucuya push edilir
✓ Fresh data fetch edilir
✓ "Senkronizasyon tamamlandı" mesajı (opsiyonel)
✓ Dirty flag temizlenir
```

### Test Komutları
```bash
# Android - Airplane mode simüle et
adb shell cmd connectivity airplane-mode enable
adb shell cmd connectivity airplane-mode disable

# iOS - Simulator üzerinden
# Settings -> Airplane Mode toggle

# Cache stats kontrolü (debug build)
# Uygulamada debug drawer veya settings ekranında göster:
final stats = await connectivityAwareSyncManager.getCacheStats();
print(stats);
```

### Loglar
```
I/SyncManager: Device is online - resuming sync
I/SyncManager: Performing reconnection sync...
I/SyncManager: Syncing 2 dirty tasks
D/SyncManager: Synced dirty task: task-123
I/SyncManager: Sync completed in 2s
```

---

## 2. Deep Link Testing

### Amaç
Uygulamanın deep link'lerle doğru şekilde açıldığını ve route guard'ların çalıştığını doğrulamak.

### Android Deep Link Testing

#### Setup - AndroidManifest.xml
```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    
    <data android:scheme="https" />
    <data android:host="app.tektech.com" />
    <data android:pathPrefix="/task" />
    <data android:pathPrefix="/user" />
    <data android:pathPrefix="/admin" />
</intent-filter>
```

#### Test Komutları
```bash
# Task detail deep link
adb shell am start -W -a android.intent.action.VIEW \
  -d "https://app.tektech.com/task/task-123" \
  com.tektech.mini_task_tracker

# User detail deep link
adb shell am start -W -a android.intent.action.VIEW \
  -d "https://app.tektech.com/user/user-456" \
  com.tektech.mini_task_tracker

# Admin panel (role guard test)
adb shell am start -W -a android.intent.action.VIEW \
  -d "https://app.tektech.com/admin" \
  com.tektech.mini_task_tracker

# Custom scheme (alternative)
adb shell am start -W -a android.intent.action.VIEW \
  -d "tektech://task/task-123" \
  com.tektech.mini_task_tracker
```

### iOS Deep Link Testing

#### Setup - Info.plist
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>tektech</string>
        </array>
    </dict>
</array>
```

#### Test Komutları
```bash
# Simulator üzerinde
xcrun simctl openurl booted "https://app.tektech.com/task/task-123"

# Custom scheme
xcrun simctl openurl booted "tektech://task/task-123"
```

### Beklenen Sonuçlar

#### ✓ Task Detail Deep Link
- App açılır
- TaskDetailScreen gösterilir
- Task ID doğru parse edilir
- Görev verisi yüklenir veya cache'ten okunur

#### ✓ Admin Deep Link (Authenticated User)
- Logged in + Admin role → Admin panel açılır
- Logged in + Member role → Home'a redirect edilir
- Not logged in → Login screen (returnUrl ile)

#### ✓ Login Redirect
```
1. User not logged in
2. Click deep link: /admin
3. Redirected to: /login?returnUrl=%2Fadmin
4. After login → /admin (original destination)
```

---

## 3. Language Switching Test

### Amaç
Uygulamanın çoklu dil desteğini ve locale değişikliklerini doğrulamak.

### Setup - main.dart
```dart
class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider); // Riverpod state

    return MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale, // Dynamic locale
      
      // Router setup
      routerConfig: AppRouter.createRouter(ref),
    );
  }
}

// Locale provider
final localeProvider = StateProvider<Locale>((ref) => const Locale('tr'));
```

### Test Senaryoları

#### Senaryo 1: Runtime Language Switch
```dart
// Settings screen'de language dropdown
Widget build(BuildContext context, WidgetRef ref) {
  final l10n = AppLocalizations.of(context)!;
  
  return DropdownButton<String>(
    value: Localizations.localeOf(context).languageCode,
    items: [
      DropdownMenuItem(value: 'tr', child: Text('Türkçe')),
      DropdownMenuItem(value: 'en', child: Text('English')),
    ],
    onChanged: (lang) {
      if (lang != null) {
        ref.read(localeProvider.notifier).state = Locale(lang);
      }
    },
  );
}
```

#### Senaryo 2: Test Checklist
```bash
# Adımlar:
1. App'i TR locale ile başlat
2. Ana ekranda TR metinleri gör: "Görevlerim", "Ana Sayfa"
3. Settings → Language → English seç
4. UI anında güncellenir: "My Tasks", "Home"
5. Tarih formatları değişir: "15 Oca" → "15 Jan"
6. Error mesajları EN: "Session Expired" vs "Oturum Süresi Doldu"

# Beklenen Sonuç:
✓ Tüm UI metinleri değişir
✓ Tarih/saat formatları locale-aware
✓ Hata mesajları doğru dilde
✓ Placeholder'lar çalışır: "5 gün kaldı" vs "5 days remaining"
```

### DateTimeHelper Test
```dart
// TR locale
DateTimeHelper.formatShortDate(DateTime(2024, 1, 15), Locale('tr'));
// Output: "15 Oca"

// EN locale
DateTimeHelper.formatShortDate(DateTime(2024, 1, 15), Locale('en'));
// Output: "15 Jan"

// Relative time
DateTimeHelper.getRelativeTime(DateTime.now(), context);
// TR: "Bugün", EN: "Today"
```

### Validation Messages Test
```dart
final l10n = AppLocalizations.of(context)!;

// TR
l10n.validation_minLength(8); // "En az 8 karakter olmalıdır"
l10n.daysRemaining(5);        // "5 gün kaldı"

// EN
l10n.validation_minLength(8); // "Must be at least 8 characters"
l10n.daysRemaining(5);        // "5 days remaining"
```

---

## 4. Sync Performance Profiling

### Amaç
Senkronizasyon performansını ölçmek ve optimize etmek.

### Profiling Setup

#### Method 1: Flutter DevTools
```bash
# Run app in profile mode
flutter run --profile

# Open DevTools
flutter pub global activate devtools
flutter pub global run devtools

# Timeline view'da:
1. "Record" buton
2. Sync operation tetikle
3. "Stop" buton
4. Frame analizi yap
```

#### Method 2: Custom Logging
```dart
// SyncManager içinde zaten var:
final startTime = DateTime.now();
// ... sync operations ...
final duration = DateTime.now().difference(startTime);
_logger.i('Sync completed in ${duration.inSeconds}s');
```

#### Method 3: Performance Metrics
```dart
class SyncMetrics {
  int dirtyTasksSynced = 0;
  int tasksFetched = 0;
  int usersFetched = 0;
  Duration? networkTime;
  Duration? cacheWriteTime;
  Duration? totalTime;
  
  @override
  String toString() {
    return '''
    Sync Metrics:
    - Dirty synced: $dirtyTasksSynced
    - Tasks fetched: $tasksFetched
    - Users fetched: $usersFetched
    - Network: ${networkTime?.inMilliseconds}ms
    - Cache write: ${cacheWriteTime?.inMilliseconds}ms
    - Total: ${totalTime?.inMilliseconds}ms
    ''';
  }
}
```

### Performance Benchmarks

#### Target Metrics
```
Initial Sync (100 tasks + 20 users):
- Network fetch: < 2s
- Cache write: < 500ms
- Total: < 3s

Dirty Task Sync (5 tasks):
- Network push: < 1s
- Cache update: < 200ms
- Total: < 1.5s

Background Sync (incremental):
- Check staleness: < 50ms
- Fetch if needed: < 2s
- Total: < 2.5s
```

### Optimization Tips
```dart
// 1. Batch cache writes
await _tasksBox.putAll(Map.fromEntries(
  tasks.map((t) => MapEntry(t.id, TaskCache.fromTask(t)))
));

// 2. Parallel network calls
final results = await Future.wait([
  _taskRepo.getMyActiveTasks(),
  _adminRepo.getUsers(),
]);

// 3. Cancel pending requests on new sync
final cancelToken = CancelToken();
// Pass to Dio requests

// 4. Debounce rapid syncs
final debouncer = Debouncer(duration: Duration(seconds: 5));
debouncer(() => syncManager.syncAll());
```

---

## 5. Integration Test Suite

### Setup
```dart
// test_driver/integration_test.dart
import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Offline Sync Tests', () {
    testWidgets('Offline mode shows cached tasks', (tester) async {
      // TODO: Implement
    });
    
    testWidgets('Optimistic updates work offline', (tester) async {
      // TODO: Implement
    });
  });

  group('Deep Link Tests', () {
    testWidgets('Task deep link opens detail screen', (tester) async {
      // TODO: Implement
    });
  });

  group('i18n Tests', () {
    testWidgets('Language switch updates UI', (tester) async {
      // TODO: Implement
    });
  });
}
```

### Run Integration Tests
```bash
flutter test integration_test/

# With device
flutter test integration_test/ --device-id=<device-id>
```

---

## Test Checklist

### ✅ Offline Functionality
- [ ] App loads with cached data when offline
- [ ] Optimistic UI updates work
- [ ] Dirty tasks are tracked
- [ ] Auto-sync resumes on reconnection
- [ ] Dirty tasks are pushed after reconnection

### ✅ Deep Links
- [ ] Task detail deep link works
- [ ] User detail deep link works
- [ ] Admin deep link respects role guard
- [ ] Login redirect preserves return URL
- [ ] Deep link works when app is closed
- [ ] Deep link works when app is in background

### ✅ Language Switching
- [ ] TR/EN switch works in runtime
- [ ] All UI strings update
- [ ] Date formats change with locale
- [ ] Error messages are localized
- [ ] Placeholders work correctly

### ✅ Sync Performance
- [ ] Initial sync < 3s (normal network)
- [ ] Background sync doesn't block UI
- [ ] No memory leaks during sync
- [ ] Proper error handling on network failure

---

## Debugging Tools

### Sync Status Widget (Debug)
```dart
// Add to Scaffold
if (kDebugMode)
  FloatingActionButton(
    onPressed: () async {
      final stats = await syncManager.getCacheStats();
      print(stats);
    },
    child: Icon(Icons.sync),
  )
```

### Connectivity Status Banner
```dart
Consumer(
  builder: (context, ref, child) {
    final isOnline = ref.watch(connectivityProvider);
    
    if (!isOnline) {
      return MaterialBanner(
        content: Text(l10n.offlineMode),
        actions: [SizedBox.shrink()],
      );
    }
    return SizedBox.shrink();
  },
)
```

---

## CI/CD Integration

### GitHub Actions - Add test job
```yaml
test-integration:
  runs-on: macos-latest
  steps:
    - uses: actions/checkout@v4
    - uses: subosito/flutter-action@v2
    - run: flutter pub get
    - run: flutter test integration_test/
```

Tüm testler başarıyla çalıştığında, uygulamanız production-ready! 🚀
