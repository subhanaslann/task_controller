# iOS Setup Instructions

## Requirements

- macOS computer
- Xcode 15+ installed
- iOS device or simulator

## Steps

### 1. Open Project in Xcode

```bash
cd flutter_app
open ios/Runner.xcworkspace
```

### 2. Configure Signing

1. In Xcode, select `Runner` in the project navigator
2. Select the `Runner` target
3. Go to **Signing & Capabilities** tab
4. Select your **Team** (Apple Developer account)
5. Xcode will automatically create a provisioning profile

### 3. Update Display Name (Optional)

In Xcode:
- Select `Runner` target
- Go to **General** tab
- Change **Display Name** to `Mini Task Tracker`

### 4. Update Bundle Identifier

Default: `com.minitasktracker.flutterApp`

To change:
1. Select `Runner` target
2. Go to **General** tab
3. Update **Bundle Identifier** (e.g., `com.yourcompany.minitasktracker`)

### 5. Build & Run

**Using Xcode:**
1. Select target device (simulator or physical device)
2. Click **Run** button (▶️) or press `Cmd + R`

**Using Flutter CLI:**
```bash
flutter run -d <device_id>

# List available devices
flutter devices

# Run on specific iOS device
flutter run -d iPhone
```

## App Transport Security (ATS)

The app is configured to allow HTTPS connections. The API base URL is:
```
https://api.diplomam.net
```

No additional ATS configuration needed since the API uses HTTPS.

## Build for Distribution

### Debug Build
```bash
flutter build ios --debug
```

### Release Build
```bash
flutter build ios --release
```

### Create IPA for TestFlight/App Store
```bash
flutter build ipa

# The IPA will be created at:
# build/ios/ipa/flutter_app.ipa
```

Then upload to App Store Connect via:
- Xcode Organizer
- Transporter app
- `xcrun altool`

## Troubleshooting

### "Failed to register bundle identifier"
- Make sure your Apple Developer account has access
- Try a different bundle identifier

### Code signing error
- Check that you selected correct Team
- Verify provisioning profile is valid

### Simulator not starting
```bash
# List simulators
xcrun simctl list devices

# Boot a simulator
xcrun simctl boot "iPhone 15"
```

### App crashes on launch
- Check Xcode console for error messages
- Verify API URL is reachable
- Test network connectivity

## Network Permissions

iOS automatically allows HTTPS connections. For HTTP connections (not recommended in production), you would need to add to `Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

**Note:** The app uses HTTPS (api.diplomam.net), so this is NOT needed.
