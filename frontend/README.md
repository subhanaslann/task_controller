# Frontend - Mobil Uygulamalar

Mini Task Tracker mobil uygulamalari.

## Yapilandirma

```
frontend/
├── flutter/           # Flutter cross-platform (iOS/Android)
└── android-native/    # Kotlin native Android
```

## Flutter Uygulamasi

Cross-platform mobil uygulama (iOS ve Android).

### Kurulum

```bash
cd flutter
flutter pub get
```

### Calistirma

```bash
flutter run
```

### Build

Android APK:
```bash
flutter build apk --release
```

iOS:
```bash
flutter build ios --release
```

### Firebase Yapilandirmasi

FlutterFire CLI ile yapilandirma:
```bash
flutterfire configure
```

## Android Native Uygulamasi

Kotlin tabanli native Android uygulamasi.

### Kurulum

Android Studio ile ac veya:
```bash
cd android-native
./gradlew build
```

### Debug Build

```bash
./gradlew assembleDebug
```

### Release Build

```bash
./gradlew assembleRelease
```

### Firebase Yapilandirmasi

`google-services.json` dosyasini `app/` klasorune ekleyin.
