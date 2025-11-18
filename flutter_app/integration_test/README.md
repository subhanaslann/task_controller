# Integration Tests

## TekTech Mini Task Tracker - Entegrasyon Testleri

Bu klasör, uygulamanın kritik özelliklerini test eden integration testlerini içerir.

---

## Test Dosyaları

### 1. `auth_flow_test.dart` ✨ YENİ
Authentication flow ve kullanıcı yönetimi testleri:
- Kullanıcı kayıt işlemi
- Giriş ve çıkış işlemleri
- Form validasyonu
- Session yönetimi
- Password reset flow
- Error handling

### 2. `task_crud_test.dart` ✨ YENİ
Task CRUD operations kapsamlı testleri:
- Task oluşturma, güncelleme, silme
- Task listeleme ve filtreleme
- Arama functionality
- Sıralama ve pagination
- Offline davranış
- Optimistic UI updates

### 3. `navigation_test.dart` ✨ YENİ
Navigation ve routing kapsamlı testleri:
- Named route navigation
- Bottom navigation
- Drawer navigation
- Route guards ve authorization
- Deep navigation
- Modal ve dialog navigation
- Tab navigation

### 4. `error_handling_test.dart` ✨ YENİ
Comprehensive error handling testleri:
- Network errors (offline, timeout)
- API errors (401, 403, 404, 500)
- Validation errors
- Client errors
- Error recovery ve retry logic
- Error logging ve tracking
- Localized error messages

### 5. `theme_settings_test.dart` ✨ YENİ
Theme ve settings yönetimi testleri:
- Light/Dark theme switching
- Language switching (TR/EN)
- Settings persistence
- Notification settings
- Account settings
- Privacy settings
- Data management

### 6. `widget_interaction_test.dart` ✨ YENİ
Widget etkileşim testleri:
- Button interactions
- Form inputs ve validations
- Dropdown ve select widgets
- Checkbox ve switch interactions
- Scroll behaviors
- Gesture interactions (tap, swipe, drag)
- Dialog ve modal interactions
- Snackbar ve loading states

### 7. `offline_sync_test.dart`
Offline senkronizasyon senaryolarını test eder:
- Cache'ten veri yükleme
- Optimistic UI güncellemeleri
- Online/offline geçişleri
- Auto-sync davranışı
- Connectivity awareness

### 8. `deep_link_test.dart` (İyileştirildi)
Deep link routing ve route guard'ları test eder:
- Named route configuration
- GoRouter yapılandırması
- Route guards ve authentication
- Deep link handling (future implementation)
- URL parameter parsing

### 9. `localization_test.dart`
Çoklu dil desteğini test eder:
- Turkish ve English translations
- Dil değiştirme
- Validation mesajları
- Pluralization
- Parameter interpolation

---

## Test İstatistikleri

**Toplam Test Dosyası:** 9  
**Toplam Test Grubu:** 90+  
**Toplam Test Case:** 350+

### Test Kapsamı:
- ✅ Authentication & Authorization
- ✅ CRUD Operations
- ✅ Navigation & Routing
- ✅ Error Handling
- ✅ UI Interactions
- ✅ Theme & Settings
- ✅ Offline Sync
- ✅ Localization
- ✅ Deep Linking (partial)

---

## Testleri Çalıştırma

### Tüm Integration Testleri
```bash
flutter test integration_test/
```

### Belirli Bir Test Dosyası
```bash
# Authentication testleri
flutter test integration_test/auth_flow_test.dart

# Task CRUD testleri
flutter test integration_test/task_crud_test.dart

# Navigation testleri
flutter test integration_test/navigation_test.dart

# Error handling testleri
flutter test integration_test/error_handling_test.dart

# Theme & settings testleri
flutter test integration_test/theme_settings_test.dart

# Widget interaction testleri
flutter test integration_test/widget_interaction_test.dart

# Offline sync testleri
flutter test integration_test/offline_sync_test.dart

# Deep link testleri
flutter test integration_test/deep_link_test.dart

# Localization testleri
flutter test integration_test/localization_test.dart
```

### Cihaz/Simulator Üzerinde
```bash
# Android
flutter test integration_test/ --device-id=<device-id>

# iOS Simulator
flutter test integration_test/ --device-id="iPhone 15"
```

### Driver ile (Daha Detaylı)
```bash
flutter drive \
  --driver=integration_test/integration_test_driver.dart \
  --target=integration_test/offline_sync_test.dart \
  --profile
```

---

## Platform-Specific Setup

### Android

#### Deep Link Test Komutları
```bash
# Task detail
adb shell am start -W -a android.intent.action.VIEW \
  -d "https://app.tektech.com/task/task-123" \
  com.tektech.mini_task_tracker

# Airplane mode simulation
adb shell cmd connectivity airplane-mode enable
adb shell cmd connectivity airplane-mode disable
```

### iOS

#### Deep Link Test Komutları
```bash
# Simulator deep link
xcrun simctl openurl booted "https://app.tektech.com/task/task-123"

# List simulators
xcrun simctl list devices
```

---

## CI/CD Integration

GitHub Actions üzerinde otomatik olarak çalışır:
- Her PR'da integration testler koşar
- macOS runner'da iOS simulator üzerinde çalışır
- Test sonuçları artifact olarak saklanır

---

## Test Geliştirme

### Yeni Test Eklemek
1. `integration_test/` klasörüne yeni `.dart` dosyası oluştur
2. `IntegrationTestWidgetsFlutterBinding.ensureInitialized()` çağrısını ekle
3. Test senaryolarını yaz
4. CI/CD workflow'unu güncelle (gerekirse)

### Örnek Test Yapısı
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Özellik Testleri', () {
    testWidgets('Senaryo açıklaması', (tester) async {
      // 1. Setup
      await app.main();
      await tester.pumpAndSettle();

      // 2. Action
      await tester.tap(find.text('Button'));
      await tester.pumpAndSettle();

      // 3. Assertion
      expect(find.text('Sonuç'), findsOneWidget);
    });
  });
}
```

---

## Troubleshooting

### Test başlamıyor
- `flutter clean && flutter pub get` çalıştır
- Cihaz/simulator'un açık olduğundan emin ol
- `flutter devices` ile cihazları kontrol et

### Timeout hataları
- Test içinde yeterli `await tester.pumpAndSettle()` kullan
- Async işlemler için `await` kullanmayı unutma
- Network işlemleri için timeout değerlerini artır

### Deep link testleri çalışmıyor
- AndroidManifest.xml ve Info.plist ayarlarını kontrol et
- App'in doğru package name/bundle ID kullandığından emin ol
- Platform-specific komutların doğru çalıştığını test et

---

## Best Practices

1. **Her test bağımsız olmalı**: Testler birbirinden etkilenmemeli
2. **Mock data kullan**: Production API'ya bağlanma
3. **Cleanup yap**: Test sonunda state'i temizle
4. **Descriptive names**: Test isimlerini açıklayıcı yap
5. **Group logically**: İlgili testleri gruplayarak organize et

---

## Performance

Integration testler unit testlerden yavaştır:
- Tam UI render eder
- Gerçek cihaz/simulator kullanır
- Network/disk I/O yapar

Bu nedenle:
- Critical path'leri test et
- Edge case'ler için unit test tercih et
- Testleri paralel çalıştır (mümkünse)

---

Daha fazla bilgi için:
- [Flutter Integration Testing](https://docs.flutter.dev/testing/integration-tests)
- [integration_test package](https://pub.dev/packages/integration_test)
