# Build Instructions

Complete guide to build and run the Mini Task Tracker Flutter app.

## Prerequisites

- Flutter SDK 3.35.6+
- Dart 3.9.2+
- **Android**: Android Studio + Android SDK
- **iOS**: macOS + Xcode 15+

## Quick Start

### 1. Install Dependencies

```bash
cd flutter_app
flutter pub get
```

### 2. Generate Code

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Run the App

```bash
# Run on connected device/emulator
flutter run

# Run on specific device
flutter devices  # List devices
flutter run -d <device_id>

# Run on Android emulator
flutter run -d emulator-5554

# Run on iOS simulator
flutter run -d iPhone
```

## Build for Production

### Android APK

```bash
# Debug APK
flutter build apk --debug

# Release APK (unsigned)
flutter build apk --release

# Split APKs by ABI (smaller size)
flutter build apk --split-per-abi
```

**Output:** `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (for Play Store)

```bash
flutter build appbundle --release
```

**Output:** `build/app/outputs/bundle/release/app-release.aab`

### iOS

```bash
# Debug build
flutter build ios --debug

# Release build
flutter build ios --release

# Build IPA for distribution
flutter build ipa
```

**Output:** `build/ios/ipa/flutter_app.ipa`

## Platform-Specific Configuration

### Android

#### App Name
Change in `android/app/src/main/AndroidManifest.xml`:
```xml
<application android:label="Your App Name" ...>
```

#### App Icon
Replace icons in:
- `android/app/src/main/res/mipmap-*/ic_launcher.png`

Generate icons: https://appicon.co/

#### Package Name
Change in `android/app/build.gradle`:
```gradle
defaultConfig {
    applicationId "com.yourcompany.app"
}
```

### iOS

#### App Name
In Xcode:
1. Open `ios/Runner.xcworkspace`
2. Select Runner target
3. General tab → Display Name

#### Bundle Identifier
In Xcode:
1. Select Runner target
2. General tab → Bundle Identifier

#### App Icon
Replace `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

## Testing

### Run Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run with coverage
flutter test --coverage
```

### Check Code Quality

```bash
# Analyze code
flutter analyze

# Format code
flutter format lib/

# Check for outdated packages
flutter pub outdated
```

## Development Tips

### Hot Reload
While running `flutter run`:
- Press `r` → Hot reload
- Press `R` → Hot restart
- Press `h` → Help
- Press `q` → Quit

### Clear Cache

```bash
# Clean build files
flutter clean

# Clear pub cache
flutter pub cache clean

# Reinstall dependencies
flutter pub get

# Rebuild generated code
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Debug Mode

```bash
# Run with verbose logging
flutter run -v

# Open DevTools
flutter pub global activate devtools
flutter pub global run devtools

# Then in another terminal
flutter run --devtools
```

## Common Issues

### Build Runner Errors

```bash
flutter pub run build_runner clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Android Build Fails

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### iOS Build Fails

```bash
cd ios
pod install
cd ..
flutter clean
flutter pub get
flutter run
```

### Secure Storage Issues (iOS Simulator)

Delete app and reinstall:
```bash
flutter clean
flutter run
```

## Environment Variables

### API Base URL

Change in `lib/core/utils/constants.dart`:
```dart
static const String baseUrl = 'https://api.diplomam.net';
```

### Build Flavors (Advanced)

Create different environments (dev, staging, prod):

**Android:** `android/app/build.gradle`
```gradle
flavorDimensions "environment"
productFlavors {
    dev {
        applicationIdSuffix ".dev"
    }
    prod {
        // Production config
    }
}
```

**Run with flavor:**
```bash
flutter run --flavor dev
flutter build apk --flavor prod
```

## Performance Profiling

```bash
# Profile mode (optimized + profiling enabled)
flutter run --profile

# Release mode (fully optimized)
flutter run --release
```

## Deployment

### Android Play Store

1. Build app bundle:
   ```bash
   flutter build appbundle --release
   ```

2. Sign the bundle (if not signed):
   ```bash
   # Generate keystore (one-time)
   keytool -genkey -v -keystore my-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias my-key-alias
   
   # Configure in android/key.properties
   ```

3. Upload to Play Console

### iOS App Store

1. Build IPA:
   ```bash
   flutter build ipa
   ```

2. Upload via:
   - Xcode Organizer (Window → Organizer)
   - Transporter app
   - Command line: `xcrun altool`

3. Submit for review in App Store Connect

## CI/CD

### GitHub Actions Example

```yaml
name: Build and Test
on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.35.6'
      - run: flutter pub get
      - run: flutter pub run build_runner build
      - run: flutter test
      - run: flutter build apk
```

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Flutter Cookbook](https://docs.flutter.dev/cookbook)
- [Dart Documentation](https://dart.dev/guides)
- [Riverpod Documentation](https://riverpod.dev/)
- [Dio Documentation](https://pub.dev/packages/dio)
