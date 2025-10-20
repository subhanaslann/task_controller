# 🚀 Deployment Rehberi - Mini Task Tracker

Bu rehber, Mini Task Tracker projesini production ortamına deploy etmek için gereken tüm adımları içerir.

## 📋 Ön Hazırlık

### Gereksinimler
- Node.js 18+ (Backend için)
- Docker (opsiyonel ama önerilen)
- Android Studio veya Gradle CLI (APK build için)
- Bir VPS veya cloud hosting hesabı (DigitalOcean, Render, Railway, vb.)

---

## 1. 🖥️ Backend Deployment

Backend'inizi deploy etmek için birkaç seçeneğiniz var:

### Seçenek A: VPS ile Deployment (DigitalOcean, Linode, Hetzner)

#### 1.1. Sunucu Hazırlığı

```bash
# Sunucuya SSH ile bağlanın
ssh root@your-server-ip

# Sistem güncellemesi
apt update && apt upgrade -y

# Docker kurulumu
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Git kurulumu
apt install git -y
```

#### 1.2. Projeyi Sunucuya Yükleme

```bash
# Projeyi klonlayın
cd /opt
git clone https://github.com/your-username/mini-task-tracker.git
cd mini-task-tracker/server

# Production .env dosyası oluşturun
nano .env
```

`.env` içeriği:
```env
PORT=8080
NODE_ENV=production
JWT_SECRET=cok-uzun-ve-gizli-bir-key-buraya-gelecek
JWT_EXPIRES_IN=7d
DATABASE_URL=file:/app/data/prod.db
MAX_ACTIVE_USERS=15
```

#### 1.3. Docker ile Çalıştırma

```bash
# Docker image oluştur
docker build -t mini-task-tracker:latest .

# Container'ı çalıştır
docker run -d \
  --name tasktracker \
  -p 8080:8080 \
  -v $(pwd)/data:/app/data \
  -v $(pwd)/.env:/app/.env \
  --restart unless-stopped \
  mini-task-tracker:latest

# Logları kontrol et
docker logs -f tasktracker
```

#### 1.4. Nginx ile Reverse Proxy (HTTPS için)

```bash
# Nginx kurulumu
apt install nginx certbot python3-certbot-nginx -y

# Nginx konfigürasyonu
nano /etc/nginx/sites-available/tasktracker
```

Nginx config dosyası:
```nginx
server {
    listen 80;
    server_name api.sizindomain.com;

    location / {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

```bash
# Config'i aktifleştir
ln -s /etc/nginx/sites-available/tasktracker /etc/nginx/sites-enabled/
nginx -t
systemctl reload nginx

# SSL sertifikası al (Let's Encrypt)
certbot --nginx -d api.sizindomain.com
```

#### 1.5. Veritabanını Seed Etme

```bash
# Container içine gir
docker exec -it tasktracker sh

# Seed komutunu çalıştır
npm run prisma:seed:prod

# Çıkış
exit
```

**Varsayılan Admin Kullanıcısı:**
- Username: `admin`
- Password: `admin123`
- Email: `admin@minitasktracker.local`

⚠️ **ÖNEMLİ**: Production'da admin şifresini hemen değiştirin!

---

### Seçenek B: Railway.app (Kolay ve Hızlı)

```bash
# Railway CLI kurulumu
npm i -g @railway/cli

# Login
railway login

# Proje klasörüne git
cd server

# Deploy
railway up

# Environment variables ekle (Railway dashboard'dan)
# JWT_SECRET=your-secret
# NODE_ENV=production
```

Railway otomatik olarak domain verecektir (örn: `your-app.up.railway.app`)

---

### Seçenek C: Render.com (Ücretsiz Tier)

1. [render.com](https://render.com) hesabı oluşturun
2. "New Web Service" butonuna tıklayın
3. GitHub repo'nuzu bağlayın
4. Ayarları yapın:
   - **Name**: mini-task-tracker
   - **Environment**: Node
   - **Build Command**: `npm install && npm run build && npm run prisma:generate`
   - **Start Command**: `npm run prisma:migrate:deploy && npm run prisma:seed:prod && npm start`
   - **Instance Type**: Free
5. Environment Variables ekleyin:
   ```
   JWT_SECRET=your-secret-key
   NODE_ENV=production
   DATABASE_URL=file:/opt/render/project/data/prod.db
   ```
6. "Create Web Service" butonuna tıklayın

Render size otomatik HTTPS domain verecektir (örn: `your-app.onrender.com`)

---

## 2. 📱 Android APK Oluşturma

### 2.1. API URL Güncellemesi

`android-app/app/build.gradle.kts` dosyasını açın ve production URL'ini güncelleyin:

```kotlin
buildConfigField("String", "BASE_URL", "\"https://api.sizindomain.com/\"")
// Veya Railway/Render URL'i:
// buildConfigField("String", "BASE_URL", "\"https://your-app.onrender.com/\"")
```

### 2.2. Signing Key Oluşturma

**Windows PowerShell:**
```powershell
cd C:\Tektech\mini-task-tracker\android-app
keytool -genkey -v -keystore release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias tasktracker
```

**macOS/Linux:**
```bash
cd ~/mini-task-tracker/android-app
keytool -genkey -v -keystore release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias tasktracker
```

Şifre ve bilgileri girin ve kaydedin. Bu bilgileri **GÜVENLİ** bir yerde saklayın!

### 2.3. Signing Config Güncellemesi

`android-app/app/build.gradle.kts` dosyasındaki şifreleri güncelleyin:

```kotlin
signingConfigs {
  create("release") {
    storeFile = file("../release-key.jks")
    storePassword = "BURAYA-KEYSTORE-SIFRENIZ"  // Değiştirin!
    keyAlias = "tasktracker"
    keyPassword = "BURAYA-KEY-SIFRENIZ"  // Değiştirin!
  }
}
```

⚠️ **GÜVENLİK UYARISI**: Bu dosyayı git'e eklemeyin! Alternatif olarak, şifreleri `gradle.properties` dosyasında saklayabilirsiniz.

### 2.4. APK Build

**Windows PowerShell:**
```powershell
cd C:\Tektech\mini-task-tracker\android-app
.\gradlew.bat assembleRelease
```

**macOS/Linux:**
```bash
cd ~/mini-task-tracker/android-app
./gradlew assembleRelease
```

APK dosyası şurada oluşacak:
```
android-app/app/build/outputs/apk/release/app-release.apk
```

### 2.5. Google Play Store için AAB (Opsiyonel)

Play Store'a yüklemek için APK yerine AAB kullanın:

```powershell
.\gradlew.bat bundleRelease
```

AAB dosyası:
```
android-app/app/build/outputs/bundle/release/app-release.aab
```

---

## 3. 📲 Dağıtım Seçenekleri

### Seçenek A: Manuel APK Dağıtımı

1. `app-release.apk` dosyasını kullanıcılara gönderin
2. Telefonlarda **Ayarlar > Güvenlik > Bilinmeyen Kaynaklar**'ı aktifleştirin
3. APK'yı yükleyin

**장점:**
- Hızlı ve ücretsiz
- Test için ideal

**단점:**
- Her güncelleme için yeni APK göndermeniz gerek
- Play Store güvenlik avantajları yok

### Seçenek B: Google Play Store (Internal Test)

1. [Google Play Console](https://play.google.com/console) hesabı oluşturun ($25 bir kerelik ücret)
2. Yeni uygulama oluşturun
3. "Internal Testing" sekmesine gidin
4. AAB dosyasını yükleyin
5. Test kullanıcılarını ekleyin (email listesi)
6. Kullanıcılara test linkini gönderin

**장점:**
- Otomatik güncellemeler
- 100 teste kadar ücretsiz
- Play Store altyapısı

### Seçenek C: Firebase App Distribution (Önerilen Test İçin)

1. [Firebase Console](https://console.firebase.google.com) açın
2. Projenizi ekleyin
3. App Distribution'a gidin
4. APK yükleyin
5. Test kullanıcılarını davet edin

**장점:**
- Kolay kurulum
- Ücretsiz
- Güncelleme bildirimleri

---

## 4. 🔒 Production Güvenlik Checklist

- [ ] Admin şifresini değiştirin
- [ ] JWT_SECRET'ı güçlü bir key ile değiştirin
- [ ] HTTPS kullanın (Nginx + Let's Encrypt veya cloud provider SSL)
- [ ] Firewall kurallarını ayarlayın (sadece 80, 443, SSH portları açık)
- [ ] Regular backup planlayın (veritabanı)
- [ ] Rate limiting aktif mi kontrol edin (backend'de mevcut)
- [ ] APK signing key'i güvenli bir yerde saklayın
- [ ] Environment variables'ı git'e commitlemeyin

---

## 5. 📊 İzleme ve Bakım

### Backend Logları

```bash
# Docker logs
docker logs -f tasktracker

# Son 100 satır
docker logs --tail 100 tasktracker
```

### Database Backup

```bash
# SQLite backup
docker exec tasktracker sh -c 'cp /app/data/prod.db /app/data/backup-$(date +%Y%m%d).db'

# Host'a kopyala
docker cp tasktracker:/app/data/backup-20231215.db ./backup.db
```

### Güncellemeler

```bash
# Backend güncelleme
cd /opt/mini-task-tracker
git pull
docker build -t mini-task-tracker:latest .
docker stop tasktracker
docker rm tasktracker
# Yeniden çalıştır (1.3 adımındaki komut)

# Android app güncelleme
# versionCode ve versionName'i artırın
# build.gradle.kts: versionCode = 2, versionName = "1.1"
# Yeni APK/AAB build edin
```

---

## 🎉 Tamamlandı!

Backend: `https://api.sizindomain.com`  
Android App: Kullanıcılara APK gönderin veya Play Store'a yükleyin

**Test için:**
- Admin: `admin` / `admin123`
- Guest: `guest` / `guest123`

Sorularınız için: [GitHub Issues](https://github.com/your-username/mini-task-tracker/issues)
