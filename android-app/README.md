# Android App - Mini Task Tracker

Kotlin + Jetpack Compose mobile client for the Mini Task Tracker system.

## 🔧 Tech Stack

- **Language**: Kotlin
- **UI**: Jetpack Compose
- **Architecture**: MVVM + Clean Architecture
- **DI**: Hilt
- **Networking**: Retrofit + OkHttp
- **Serialization**: Kotlinx Serialization / Moshi
- **Storage**: DataStore (for JWT token)
- **Navigation**: Compose Navigation

## 📁 Project Structure (Planned)

```
android-app/
├── app/
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/com/minitasktracker/
│   │   │   │   ├── data/          # Repositories, API, DTOs
│   │   │   │   ├── domain/        # Use cases, models
│   │   │   │   ├── ui/            # Composables, ViewModels
│   │   │   │   │   ├── login/
│   │   │   │   │   ├── tasks/
│   │   │   │   │   │   ├── myactive/
│   │   │   │   │   │   ├── teamactive/
│   │   │   │   │   │   ├── mycompleted/
│   │   │   │   │   ├── admin/
│   │   │   │   │   │   ├── users/
│   │   │   │   │   │   ├── tasks/
│   │   │   │   │   └── common/
│   │   │   │   └── di/            # Hilt modules
│   │   │   ├── res/
│   │   │   │   ├── xml/
│   │   │   │   │   └── network_security_config.xml  # HTTP allowed in debug
│   │   │   └── AndroidManifest.xml
│   │   └── debug/
│   │       └── res/xml/
│   │           └── network_security_config.xml  # Cleartext traffic for dev
│   └── build.gradle.kts
├── build.gradle.kts
└── settings.gradle.kts
```

## 🚀 Getting Started

### Prerequisites

- Android Studio Hedgehog (2023.1.1) or later
- JDK 17+
- Android SDK 34+
- Min SDK: 24 (Android 7.0)

### Setup

1. **Open in Android Studio**
   ```bash
   # From monorepo root
   # Open android-app/ folder in Android Studio
   ```

2. **Configure local.properties** (if needed)
   ```properties
   sdk.dir=/path/to/Android/Sdk
   ```

3. **Sync Gradle**
   - Android Studio will prompt to sync
   - Wait for dependencies to download

4. **Configure Backend URL**
   - Debug: Uses `http://10.0.2.2:3000` (Android emulator → localhost)
   - Physical device: Update to `http://<your-computer-ip>:3000`
   - Production: Update to HTTPS endpoint in `BuildConfig` or `local.properties`

### Network Security (Development)

For debug builds, cleartext HTTP is allowed via:
- `app/src/debug/res/xml/network_security_config.xml`

**Production builds** enforce HTTPS only.

### Run

1. Start backend server (see `../server/README.md`)
2. Select emulator or device in Android Studio
3. Click **Run** ▶️

## 📱 Features

### User Screens (Bottom Navigation)
1. **My Active Tasks**: View and update status of own To-Do/In-Progress tasks
2. **Team Active Tasks**: Read-only view of all team tasks (guests see limited fields)
3. **My Completed**: View completed tasks (read-only)

### Admin Features (Admin role only)
- Switch to Admin Mode from menu
- **User Management**: Create, activate/deactivate, reset passwords, change roles
- **Task Management**: Full CRUD, assign tasks, set priority/status/guest_safe

## 🔐 Authentication

- Login with username/email + password
- JWT stored securely in DataStore (encrypted)
- Token auto-refreshed on API calls
- Logout clears token

## 🎨 Design System

### UI Component Library

Projede profesyonel, tutarlı ve erişilebilir bir UI bileşen kütüphanesi bulunmaktadır:

✅ **Temel Bileşenler:**
- **AppButton** - 5 varyant (Primary, Secondary, Tertiary, Destructive, Ghost)
- **AppTextField** / **AppTextArea** - Label, helper text, hata durumları, şifre toggle
- **TaskCard** - Priority stripe, badges, avatars, smooth animations
- **EmptyState** - 3 hazır varyant (no tasks, no completed, no search results)

✅ **Dialog & Feedback:**
- **AppDialog** - Confirm, Alert, Custom dialog'lar
- **AppSnackbar** - Success, Error, Warning, Info bildirimleri

✅ **Form & Filter:**
- **AppCheckbox** / **AppSwitch** - Label ve açıklama desteği
- **FilterBar** - Arama + chip-based filtreler
- **StatusBadge** / **PriorityBadge** - Görev durumu ve öncelik rozetleri

✅ **Component Catalog (DEBUG)**
- DEBUG modda **Menü > Component Catalog** ile tüm bileşenlerin önizleme ekranı erişilebilir

### Stil Rehberi

**Tam dokümantasyon için:** [`STIL_REHBERI.md`](./STIL_REHBERI.md)

**Design Tokens:**
- **Renk Paleti**: Indigo 600 primary, Material 3 color scheme
- **Spacing**: 8dp grid system (4dp, 8dp, 12dp, 16dp, 20dp, 24dp, 32dp)
- **Typography**: Material 3 type scale
- **Corner Radius**: 4dp, 8dp, 12dp, 16dp, 24dp, 28dp
- **Elevation**: 0dp, 1dp, 2dp, 4dp

**Erişilebilirlik:**
- WCAG AA standartlarına uygun kontrast oranları
- Minimum 48x48dp touch targets
- Ekran okuyucu desteği
- Semantic etiketler ve roller

### Theme

- Material 3 Design
- Light + Dark theme desteği
- Responsive layouts (phone/tablet)
- Accessibility: TalkBack support, content descriptions

## 🧪 Testing (To Be Implemented)

- Unit tests: ViewModels, Use Cases
- UI tests: Compose UI Testing
- Integration tests: Repository layer

## 📦 Project Status

✅ **UI Component System Complete!**

The Android project is fully functional with:
- ✅ Gradle configuration (Kotlin DSL)
- ✅ All dependencies (Hilt, Retrofit, Compose, etc.)
- ✅ Clean Architecture (data, domain, features)
- ✅ Network security config (debug allows cleartext)
- ✅ Hilt DI modules
- ✅ API interfaces & DTOs
- ✅ Repository layer
- ✅ Navigation setup with Compose Navigation
- ✅ Material3 custom theme (Indigo 600 based)
- ✅ **Professional UI component library** (🆕)
- ✅ **Component Catalog** (DEBUG only)
- ✅ **Design tokens & style guide**
- ✅ Login, Task Management, and Admin screens
- ✅ Task CRUD operations
- ✅ User & Topic management (Admin)

✅ **Full functionality implemented!**

## 🔨 Build Commands

```bash
# Build debug APK
./gradlew assembleDebug

# Install on connected device/emulator
./gradlew installDebug

# Build release APK
./gradlew assembleRelease

# Run tests
./gradlew test

# Clean build
./gradlew clean
```

## 🔍 Quick Start Guide

### 1️⃣ Kullanıcı Girişi
```kotlin
// Varsayılan kullanıcılar
- Admin: admin / admin123
- Member: alice / password
- Guest: guest1 / password
```

### 2️⃣ Bileşen Kullanımı
```kotlin
import com.example.minitasktracker.core.ui.components.*

// Button
AppButton(
  text = "Kaydet",
  onClick = { },
  variant = ButtonVariant.PRIMARY
)

// Text Field
AppTextField(
  value = text,
  onValueChange = { text = it },
  label = "Görev Başlığı",
  isRequired = true
)

// Task Card
TaskCard(
  task = task,
  onStatusChange = { newStatus -> },
  onClick = { },
  showNote = true
)
```

### 3️⃣ Bileşen Kataloğu
```
1. Uygulamayı DEBUG modda çalıştır
2. Menü (...) > Component Catalog
3. Tüm UI bileşenlerini gör ve test et
```

## 📦 Next Steps (Enhancement)

1. ✅ ~~UI Component System~~ (Tamamlandı)
2. ✅ ~~Task Management~~ (Tamamlandı)
3. ✅ ~~Admin Features~~ (Tamamlandı)
4. Unit tests & UI tests
5. Performance optimizations
6. Offline support (Room + sync)
7. Push notifications

## 🔗 API Reference

See main `README.md` at repository root for API endpoints.
