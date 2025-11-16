# Integration Tests

## TekTech Mini Task Tracker - Entegrasyon Testleri

Bu klasör, uygulamanın kritik özelliklerini test eden integration testlerini içerir.

---

## Test Dosyaları

### 1. `offline_sync_test.dart`
Offline senkronizasyon senaryolarını test eder:
- Cache'ten veri yükleme
- Optimistic UI güncellemeleri
- Online/offline geçişleri
- Auto-sync davranışı

### 2. `deep_link_test.dart`
Deep link routing ve route guard'ları test eder:
- Task detail deep links
- User detail deep links
- Admin panel role guard
- Login redirect with return URL

### 3. `localization_test.dart`
Çoklu dil desteğini test eder:
- Dil değiştirme
- Tarih formatları
- Error mesajları
- Validation mesajları

---

## Testleri Çalıştırma

### Tüm Integration Testleri
```bash
flutter test integration_test/
```

### Belirli Bir Test Dosyası
```bash
flutter test integration_test/offline_sync_test.dart
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
