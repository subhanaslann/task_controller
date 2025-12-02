# Mini Task Tracker

Takım ve kisisel gorev yonetimi uygulamasi.

## Proje Yapisi

```
mini-task-tracker/
├── backend/          # Firebase Cloud Functions + Firestore
├── frontend/         # Mobil uygulamalar (Flutter, Android Native)
└── legacy_server/    # Arsiv: Eski Express.js backend
```

## Backend

Firebase tabanli serverless backend:
- **Cloud Functions**: Kimlik dogrulama, gorev yonetimi, kullanici yonetimi
- **Firestore**: NoSQL veritabani
- **Firebase Auth**: Kimlik dogrulama

Deploy:
```bash
cd backend
firebase deploy
```

## Frontend

### Flutter
Cross-platform mobil uygulama (iOS/Android)
```bash
cd frontend/flutter
flutter pub get
flutter run
```

### Android Native
Kotlin tabanli native Android uygulamasi
```bash
cd frontend/android-native
./gradlew assembleDebug
```

## Lisans

MIT License
