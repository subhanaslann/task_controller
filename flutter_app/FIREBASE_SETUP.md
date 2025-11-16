# 🔥 Firebase Setup Guide

Firebase Analytics ve Crashlytics'i aktif etmek için aşağıdaki adımları takip edin.

## 📋 Önkoşullar

- Firebase Console erişimi ([console.firebase.google.com](https://console.firebase.google.com))
- Proje oluşturulmuş veya mevcut Firebase projesi

## 🤖 Android Kurulumu

### 1. Firebase Console'da Android App Ekle

1. Firebase Console'a gidin
2. Projenizi seçin
3. **Project Settings** → **General** → **Your apps**
4. **Add app** → **Android** seçin
5. **Android package name**: `com.minitasktracker.flutter_app`
6. **App nickname** (opsiyonel): `Mini Task Tracker`
7. **Debug signing certificate SHA-1** (opsiyonel): Test için şimdilik atlayabilirsiniz
8. **Register app** butonuna tıklayın

### 2. google-services.json İndirin

1. **Download google-services.json** butonuna tıklayın
2. İndirilen dosyayı `android/app/` klasörüne kopyalayın

```bash
# Dosya konumu:
android/app/google-services.json
```

### 3. Doğrulama

```bash
# Dosya var mı kontrol et
ls android/app/google-services.json

# İçeriği kontrol et (YOUR_ placeholder'ları yok olmalı)
cat android/app/google-services.json
```

## 🍎 iOS Kurulumu

### 1. Firebase Console'da iOS App Ekle

1. Firebase Console'da aynı projede
2. **Add app** → **iOS** seçin
3. **iOS bundle ID**: `com.minitasktracker.flutterApp`
   
   > ⚠️ **Önemli**: Bundle ID'yi `ios/Runner/Info.plist` içindeki `BUNDLE_ID` ile eşleştirin
   
4. **App nickname** (opsiyonel): `Mini Task Tracker iOS`
5. **App Store ID** (opsiyonel): Şimdilik boş bırakabilirsiniz
6. **Register app** butonuna tıklayın

### 2. GoogleService-Info.plist İndirin

1. **Download GoogleService-Info.plist** butonuna tıklayın
2. İndirilen dosyayı `ios/Runner/` klasörüne kopyalayın

```bash
# Dosya konumu:
ios/Runner/GoogleService-Info.plist
```

### 3. Xcode'a Ekleyin

1. Xcode'da projeyi açın: `ios/Runner.xcworkspace`
2. **Runner** klasörüne sağ tıklayın → **Add Files to "Runner"**
3. `GoogleService-Info.plist` dosyasını seçin
4. **Copy items if needed** işaretli olsun
5. **Add** butonuna tıklayın

### 4. Doğrulama

```bash
# Dosya var mı kontrol et
ls ios/Runner/GoogleService-Info.plist

# İçeriği kontrol et
cat ios/Runner/GoogleService-Info.plist | grep PROJECT_ID
```

## ✅ Test Etme

### Analytics Test

```dart
// lib/main.dart içinde
import 'package:flutter_app/core/services/analytics_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Analytics'i initialize et
  await AnalyticsService.init();
  
  // Test event gönder
  await AnalyticsService.logAppOpen();
  
  runApp(MyApp());
}
```

### Crashlytics Test

```dart
// Test crash
import 'package:flutter_app/core/services/error_tracking_service.dart';

// Bir butona tıklandığında
ErrorTrackingService.reportError(
  Exception('Test error'),
  StackTrace.current,
  context: 'Button click test',
);
```

### Debug Modda Kontrol

```bash
# Android Logcat
flutter run
# Logcat'te "Firebase" araması yapın

# iOS Console
flutter run
# Console'da "Firebase initialization" mesajını görmelisiniz
```

## 🔧 Sorun Giderme

### "google-services.json not found"

```bash
# Dosya konumunu kontrol et
ls -la android/app/google-services.json

# Eğer yoksa, Firebase Console'dan tekrar indirin
```

### "GoogleService-Info.plist not found"

```bash
# Dosya konumunu kontrol et
ls -la ios/Runner/GoogleService-Info.plist

# Xcode'da Runner target'ında "Copy Bundle Resources" içinde olduğundan emin olun
```

### iOS Build Hatası

```bash
# Pods'u temizle ve yeniden yükle
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
```

### Placeholder Değerler Kaldı

Eğer `YOUR_PROJECT_ID` gibi placeholder'lar görüyorsanız:

1. Firebase Console'dan dosyaları **yeniden indirin**
2. Doğru projeyi seçtiğinizden emin olun
3. Eski template dosyalarını silin

## 📚 Template Dosyaları

Template dosyaları sadece referans içindir. Gerçek config dosyalarını Firebase Console'dan indirmelisiniz:

- `android/app/google-services.json.template` → SİL
- `ios/Runner/GoogleService-Info.plist.template` → SİL

Gerçek dosyalar:
- `android/app/google-services.json` ✅
- `ios/Runner/GoogleService-Info.plist` ✅

## 🎯 Önemli Notlar

1. **Config dosyalarını .gitignore'a ekleyin** (zaten ekli)
2. **Template dosyalarını commit edin** (ekip üyeleri için)
3. **Production ve Staging için ayrı Firebase projeleri** kullanın
4. **Bundle ID ve Package Name** değişirse Firebase Console'da güncelleme yapın

## 📞 Yardım

Firebase dokümantasyonu:
- [Android Setup](https://firebase.google.com/docs/android/setup)
- [iOS Setup](https://firebase.google.com/docs/ios/setup)
- [Flutter Firebase](https://firebase.flutter.dev/)
