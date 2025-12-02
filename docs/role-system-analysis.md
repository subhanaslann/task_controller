# Rol Sistemi Analizi Raporu

Mini Task Tracker projesinde rollerin (roles) nasıl çalıştığına dair kapsamlı analiz.

---

## 1. Rol Tanımları

Projede 4 farklı rol tanımlı:

| Rol | Açıklama |
|-----|----------|
| **ADMIN** | Sistem genelinde admin (platform yönetimi) |
| **TEAM_MANAGER** | Organizasyon sahibi/yöneticisi |
| **MEMBER** | Normal takım üyesi |
| **GUEST** | Sınırlı erişim kullanıcı |

### 1.1 Backend (Legacy Server) - TypeScript

**Dosya:** `legacy_server/src/types/index.ts`

```typescript
export enum Role {
  ADMIN = 'ADMIN',
  TEAM_MANAGER = 'TEAM_MANAGER',
  MEMBER = 'MEMBER',
  GUEST = 'GUEST'
}
```

### 1.2 Backend Functions (Firebase) - TypeScript

**Dosya:** `backend/functions/src/utils/validation.ts`

```typescript
export const RoleEnum = z.enum(['ADMIN', 'TEAM_MANAGER', 'MEMBER', 'GUEST']);
export type Role = z.infer<typeof RoleEnum>;
```

### 1.3 Frontend (Flutter) - Dart

**Dosya:** `frontend/flutter/lib/core/utils/constants.dart`

```dart
enum UserRole {
  @JsonValue('ADMIN')
  admin('ADMIN'),
  @JsonValue('TEAM_MANAGER')
  teamManager('TEAM_MANAGER'),
  @JsonValue('MEMBER')
  member('MEMBER'),
  @JsonValue('GUEST')
  guest('GUEST');

  final String value;
  const UserRole(this.value);
}
```

### 1.4 Database Şeması

**Dosya:** `legacy_server/prisma/schema.prisma`

```prisma
model User {
  id             String   @id @default(uuid())
  role           String   @default("MEMBER")
  active         Boolean  @default(true)
  // ... diğer alanlar
}
```

---

## 2. Rol Hiyerarşisi

```
ADMIN (En Yüksek)
  ├── Sistem genelinde kontrol
  ├── Tüm organizasyonlara erişim
  └── TEAM_MANAGER ve MEMBER oluşturabilir

TEAM_MANAGER
  ├── Kendi organizasyonunu kontrol
  ├── MEMBER ve GUEST oluşturabilir
  └── ADMIN oluşturamaz

MEMBER
  ├── Kendi görevlerini yönetebilir
  ├── Takım görevlerini görebilir
  └── Task oluşturabilir

GUEST (En Düşük)
  └── Sadece atanan konuları görebilir
```

---

## 3. Kullanıcılara Rol Atama

### 3.1 Kayıt Sırasında

**Dosya:** `backend/functions/src/auth/registerTeam.ts`

- İlk kayıtlı kullanıcı otomatik olarak **TEAM_MANAGER** rolü alır
- Organizasyon oluşturulur ve kullanıcı o organizasyonun sahibi olur

### 3.2 Admin Tarafından Kullanıcı Oluşturma

**Dosya:** `backend/functions/src/users/createUser.ts`

**Kısıtlamalar:**
- TEAM_MANAGER, ADMIN kullanıcı oluşturamaz
- TEAM_MANAGER, başka TEAM_MANAGER oluşturamaz
- Sadece ADMIN diğer ADMIN'ler oluşturabilir

### 3.3 Guest Kullanıcılar İçin Topic Erişimi

**Dosya:** `legacy_server/prisma/schema.prisma`

```prisma
model GuestTopicAccess {
  userId    String
  topicId   String
  user      User   @relation(fields: [userId], references: [id], onDelete: Cascade)
  topic     Topic  @relation(fields: [topicId], references: [id], onDelete: Cascade)

  @@unique([userId, topicId])
}
```

Guest kullanıcılar, `visibleTopicIds` parametresiyle erişebilecekleri topic'ler belirlenir.

---

## 4. Middleware Yetkilendirmesi

**Dosya:** `legacy_server/src/middleware/roles.ts`

```typescript
// Sistem genelinde admin kontrolü
export const requireAdmin = (req, _res, next) => {
  if (!req.user || req.user.role !== Role.ADMIN) {
    return next(new ForbiddenError('Admin access required'));
  }
  next();
};

// Team Manager veya Admin kontrolü
export const requireTeamManagerOrAdmin = (req, _res, next) => {
  if (!req.user ||
      (req.user.role !== Role.TEAM_MANAGER && req.user.role !== Role.ADMIN)) {
    return next(new ForbiddenError('Team Manager or Admin role required'));
  }
  next();
};

// Çoklu rol kontrolü
export const requireRole = (...roles: Role[]) => {
  return (req, _res, next) => {
    if (!req.user || !roles.includes(req.user.role)) {
      return next(new ForbiddenError('Insufficient permissions'));
    }
    next();
  };
};
```

---

## 5. Her Rolün Yetkileri

### 5.1 ADMIN (Sistem Yöneticisi)

| İzin | Açıklama |
|------|----------|
| Tüm Organizasyonlara Erişim | Sistem genelindeki tüm organizasyonlara erişebilir |
| Organizasyon Yönetimi | Organizasyon oluştur, güncelle, aktif/pasif yap |
| Kullanıcı Yönetimi | Tüm kullanıcıları oluştur, güncelle, sil |
| ADMIN Kullanıcı Oluşturma | Sistem admini oluşturabilir |
| TEAM_MANAGER Oluşturma | Takım yöneticisi oluşturabilir |
| Task Yönetimi | Tüm görevleri oluştur, güncelle, sil |
| Topic Yönetimi | Tüm konu oluştur, güncelle, sil |
| İstatistik Görüntüleme | Organizasyon istatistiklerini görebilir |

**Route'lar:**
- `POST /auth/login`
- `GET /organization`
- `PATCH /organization`
- `GET /organization/stats`
- `POST /organization/:id/deactivate`
- `POST /organization/:id/activate`
- `GET /admin/users`, `POST /admin/users`, `PATCH /admin/users/:id`, `DELETE /admin/users/:id`
- `GET /admin/tasks`, `POST /admin/tasks`, `PATCH /admin/tasks/:id`, `DELETE /admin/tasks/:id`
- `GET /admin/topics`, `POST /admin/topics`, `PATCH /admin/topics/:id`, `DELETE /admin/topics/:id`

### 5.2 TEAM_MANAGER (Organizasyon Yöneticisi)

| İzin | Açıklama |
|------|----------|
| Organizasyon Güncelleme | Kendi organizasyonunu güncelleyebilir |
| Kullanıcı Yönetimi | Organizasyondaki kullanıcıları yönet |
| MEMBER Oluşturma | Takım üyesi oluşturabilir |
| GUEST Oluşturma | Ziyaretçi oluşturabilir |
| Task Yönetimi | Tüm görevleri oluştur, güncelle, sil |
| Task Atama | Görevleri üyelere atayabilir |
| Topic Yönetimi | Konuları oluştur, güncelle, sil |
| İstatistik Görüntüleme | Organizasyon istatistiklerini görebilir |

**Kısıtlamalar:**
- ADMIN kullanıcı oluşturamaz
- Başka TEAM_MANAGER oluşturamaz

### 5.3 MEMBER (Takım Üyesi)

| İzin | Açıklama |
|------|----------|
| Kendi Görevleri Oluştur | Kendilerine atanan görevleri oluşturabilir |
| Kendi Görevleri Güncelle | Sadece kendi görevlerini güncelleyebilir |
| Kendi Görevleri Sil | Sadece kendi görevlerini silebilir |
| Görev Durumunu Güncelle | Status'u TODO/IN_PROGRESS/DONE olarak değiştirebilir |
| Takım Görevlerini Görüntüle | Team Active görevlerini görebilir |
| Kendi Görevlerini Görüntüle | My Active ve My Done'ı görebilir |
| Aktif Konuları Görüntüle | İlgili konuları görebilir |

**Kısıtlamalar:**
- Task oluştururken kendilerine otomatik olarak atanır
- Admin paneline erişemez
- Başka üyelerin görevlerini değiştiremez

**Route'lar:**
- `GET /tasks?scope=my_active`
- `GET /tasks?scope=my_done`
- `GET /tasks?scope=team_active`
- `POST /tasks` (kendi görevleri)
- `PATCH /tasks/:id` (kendi görevleri)
- `PATCH /tasks/:id/status` (kendi görevleri)
- `DELETE /tasks/:id` (kendi görevleri)
- `GET /topics/active`

### 5.4 GUEST (Ziyaretçi)

| İzin | Açıklama |
|------|----------|
| Sınırlı Topic Görüntüleme | Sadece atanan konuları görebilir |
| Sınırlı Task Görüntüleme | Atanan konulardaki görevleri görebilir |
| Görev Bilgisi Görüntüleme | Sınırlı alanları görebilir (ID, title, status vb) |

**Kısıtlamalar:**
- Task oluşturamaz
- Task güncelleyemez
- Task silemez
- Admin paneline erişemez

**Route'lar:**
- `GET /topics/active` (sadece accessible topics)
- `GET /tasks/:id` (sınırlı bilgi)
- `GET /tasks?scope=team_active` (sınırlı bilgi)

---

## 6. Yetki Matrisi Özeti

| İşlem | ADMIN | TEAM_MANAGER | MEMBER | GUEST |
|-------|:-----:|:------------:|:------:|:-----:|
| Tüm organizasyonlara erişim | ✅ | ❌ | ❌ | ❌ |
| Organizasyon güncelle | ✅ | ✅ | ❌ | ❌ |
| Organizasyon aktif/pasif | ✅ | ❌ | ❌ | ❌ |
| ADMIN oluştur | ✅ | ❌ | ❌ | ❌ |
| TEAM_MANAGER oluştur | ✅ | ❌ | ❌ | ❌ |
| MEMBER oluştur | ✅ | ✅ | ❌ | ❌ |
| GUEST oluştur | ✅ | ✅ | ❌ | ❌ |
| Kullanıcı güncelle/sil | ✅ | ✅ | ❌ | ❌ |
| Task oluştur | ✅ | ✅ | ✅ | ❌ |
| Tüm task'ları güncelle | ✅ | ✅ | ❌ | ❌ |
| Kendi task'ını güncelle | ✅ | ✅ | ✅ | ❌ |
| Task sil | ✅ | ✅ | ✅* | ❌ |
| Topic oluştur/güncelle/sil | ✅ | ✅ | ❌ | ❌ |
| Team active görüntüle | ✅ | ✅ | ✅ | ✅** |
| İstatistik görüntüle | ✅ | ✅ | ❌ | ❌ |
| Admin paneline erişim | ✅ | ✅ | ❌ | ❌ |

\* MEMBER sadece kendi task'larını silebilir
\** GUEST sınırlı bilgi görür (id, title, status, priority, dueDate, assignee)

---

## 7. UI'da Rol Kontrolleri

### 7.1 Frontend Navigation/Routing

**Dosya:** `frontend/flutter/lib/core/router/app_router.dart`

```dart
GoRoute(
  path: AppRoutes.admin,
  redirect: (context, state) async {
    final currentUser = ref.read(currentUserProvider);

    if (currentUser == null) {
      return AppRoutes.login;
    }

    // Admin veya TeamManager kontrolü
    final isAdmin = currentUser.role == UserRole.admin ||
                    currentUser.role == UserRole.teamManager;

    if (!isAdmin) {
      return AppRoutes.home;  // Non-admin'leri home'a yönlendir
    }

    return null;  // Admin'ler erişebilir
  },
),
```

### 7.2 Admin Panel UI

**Dosya:** `frontend/flutter/lib/features/admin/presentation/admin_screen.dart`

Admin paneli 4 tab içerir:
- Users (Kullanıcı yönetimi)
- Tasks (Görev yönetimi)
- Topics (Konu yönetimi)
- Organization (Organizasyon ayarları)

---

## 8. İlgili Dosyalar Listesi

### Backend (Legacy Server)
| Dosya | Açıklama |
|-------|----------|
| `legacy_server/src/types/index.ts` | Rol enum tanımı |
| `legacy_server/src/middleware/roles.ts` | Rol middleware'ları |
| `legacy_server/src/middleware/auth.ts` | Auth middleware |
| `legacy_server/src/routes/users.ts` | Kullanıcı route'ları |
| `legacy_server/src/routes/adminTasks.ts` | Admin task route'ları |
| `legacy_server/src/routes/adminTopics.ts` | Admin topic route'ları |
| `legacy_server/src/routes/memberTasks.ts` | Member task route'ları |
| `legacy_server/src/routes/organization.ts` | Organizasyon route'ları |
| `legacy_server/src/services/userService.ts` | Kullanıcı servisi |
| `legacy_server/src/services/taskService.ts` | Task servisi |
| `legacy_server/src/services/topicService.ts` | Topic servisi |
| `legacy_server/prisma/schema.prisma` | Database şeması |

### Backend Functions (Firebase)
| Dosya | Açıklama |
|-------|----------|
| `backend/functions/src/utils/validation.ts` | Rol enum ve validation |
| `backend/functions/src/utils/auth.ts` | Auth utility'ler |
| `backend/functions/src/auth/loginUser.ts` | Login function |
| `backend/functions/src/users/createUser.ts` | Kullanıcı oluşturma |

### Frontend (Flutter)
| Dosya | Açıklama |
|-------|----------|
| `frontend/flutter/lib/core/utils/constants.dart` | UserRole enum |
| `frontend/flutter/lib/core/router/app_router.dart` | Rol tabanlı routing |
| `frontend/flutter/lib/data/models/user.dart` | User model |
| `frontend/flutter/lib/data/repositories/admin_repository.dart` | Admin işlemleri |
| `frontend/flutter/lib/features/admin/presentation/admin_screen.dart` | Admin UI |

---

*Bu rapor 2025-12-02 tarihinde oluşturulmuştur.*
