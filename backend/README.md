# Backend - Firebase Cloud Functions

Firebase tabanli serverless backend.

## Yapilandirma

```
backend/
├── functions/
│   └── src/
│       ├── auth/           # Kimlik dogrulama
│       ├── tasks/          # Gorev yonetimi
│       ├── users/          # Kullanici yonetimi
│       ├── topics/         # Konu/proje yonetimi
│       ├── organization/   # Organizasyon islemleri
│       ├── utils/          # Yardimci fonksiyonlar
│       └── index.ts        # Ana export
├── firebase.json           # Firebase yapilandirmasi
├── firestore.rules         # Guvenlik kurallari
├── firestore.indexes.json  # Firestore indeksleri
└── .firebaserc            # Proje baglantisi
```

## Kurulum

```bash
cd functions
npm install
```

## Gelistirme

Emulator ile test:
```bash
firebase emulators:start
```

## Deploy

```bash
firebase deploy --only functions
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
```

Veya hepsini birden:
```bash
firebase deploy
```

## Cloud Functions

### Auth
- `loginUser` - Kullanici girisi
- `registerTeam` - Yeni takim kaydı

### Tasks
- `createTask` - Gorev olustur (admin)
- `createMemberTask` - Gorev olustur (uye)
- `updateTask` - Gorev guncelle
- `updateTaskStatus` - Gorev durumu guncelle
- `deleteTask` - Gorev sil

### Users
- `createUser` - Kullanici olustur
- `updateUser` - Kullanici guncelle
- `deleteUser` - Kullanici sil
- `updateProfile` - Profil guncelle

### Topics
- `createTopic` - Konu olustur
- `updateTopic` - Konu guncelle
- `deleteTopic` - Konu sil

### Organization
- `updateOrganization` - Organizasyon guncelle
- `activateOrg` - Organizasyon aktif et
- `deactivateOrg` - Organizasyon pasif et
- `getOrganizationStats` - Istatistikler
