# TekTech Stil Rehberi

**Version:** 1.0  
**Last Updated:** 2025  
**Design System:** Material 3 Tabanlı

---

## 📋 İçindekiler

1. [Renk Paleti](#renk-paleti)
2. [Tipografi](#tipografi)
3. [Spacing & Layout](#spacing--layout)
4. [Bileşenler](#bileşenler)
5. [Kullanım Örnekleri](#kullanım-örnekleri)
6. [Erişilebilirlik](#erişilebilirlik)

---

## 🎨 Renk Paleti

### Primary - Indigo 600
```kotlin
val Indigo600 = Color(0xFF4F46E5)  // Ana marka rengi
val Indigo500 = Color(0xFF6366F1)
val Indigo400 = Color(0xFF818CF8)
val Indigo100 = Color(0xFFE0E7FF)
```

**Kullanım:**
- Primary butonlar
- Bağlantılar
- Aktif durumlar
- Focus state'ler

### Secondary - Green 500
```kotlin
val Green500 = Color(0xFF22C55E)   // İkincil aksiyonlar
val Green100 = Color(0xFFDCFCE7)
```

**Kullanım:**
- Secondary butonlar
- Başarı durumları
- Pozitif geri bildirimler

### Error - Red 500
```kotlin
val Red500 = Color(0xFFEF4444)     // Hata durumları
val Red100 = Color(0xFFFEE2E2)
```

**Kullanım:**
- Destructive butonlar
- Hata mesajları
- Kritik uyarılar

### Neutral - Gray Scale
```kotlin
val Gray900 = Color(0xFF111827)    // Başlıklar
val Gray700 = Color(0xFF374151)    // Gövde metni
val Gray400 = Color(0xFF9CA3AF)    // Placeholder
val Gray200 = Color(0xFFE5E7EB)    // Border
val Gray50 = Color(0xFFF9FAFB)     // Arka plan
```

### Dark Theme
```kotlin
val DarkBackground = Color(0xFF0B0B0C)     // Almost black
val DarkSurface = Color(0xFF18181B)        // Zinc 900
val DarkSurfaceVariant = Color(0xFF222426) // Custom
```

---

## ✍️ Tipografi

### Font Family
**Default:** System font (Roboto/San Francisco)

### Type Scale

```kotlin
// Display - Hero sections
displayLarge    = 57sp / Bold / -0.25sp
displayMedium   = 45sp / Bold / 0sp
displaySmall    = 36sp / SemiBold / 0sp

// Headline - Section titles
headlineLarge   = 32sp / Bold / 0sp
headlineMedium  = 28sp / SemiBold / 0sp
headlineSmall   = 24sp / SemiBold / 0sp

// Title - Card titles
titleLarge      = 22sp / SemiBold / 0sp
titleMedium     = 16sp / Medium / 0.15sp
titleSmall      = 14sp / Medium / 0.1sp

// Body - Main content
bodyLarge       = 16sp / Normal / 0.5sp
bodyMedium      = 14sp / Normal / 0.25sp
bodySmall       = 12sp / Normal / 0.4sp

// Label - Buttons & chips
labelLarge      = 14sp / Medium / 0.1sp
labelMedium     = 12sp / Medium / 0.5sp
labelSmall      = 11sp / Medium / 0.5sp
```

### Kullanım Örnekleri

```kotlin
// Başlıklar
Text(
  text = "Hoş Geldiniz",
  style = MaterialTheme.typography.headlineLarge
)

// Görev başlığı
Text(
  text = "API Entegrasyonu",
  style = MaterialTheme.typography.titleMedium
)

// Açıklama metni
Text(
  text = "Backend servisleri ile entegrasyon",
  style = MaterialTheme.typography.bodyMedium
)
```

---

## 📏 Spacing & Layout

### 8dp Grid System
```kotlin
spacing4  = 4.dp   // spacingXs
spacing8  = 8.dp   // spacingSm
spacing12 = 12.dp
spacing16 = 16.dp  // spacingMd
spacing20 = 20.dp
spacing24 = 24.dp  // spacingLg
spacing32 = 32.dp  // spacingXl
```

### Component Spacing
```kotlin
cardPadding     = 20.dp
screenPadding   = 16.dp
buttonPadding   = 16.dp
chipPadding     = 12.dp
```

### Corner Radius
```kotlin
radius4  = 4.dp
radius8  = 8.dp   // Small
radius12 = 12.dp  // Medium (buttons)
radius16 = 16.dp  // Large (cards)
radius24 = 24.dp  // Extra Large
radius28 = 28.dp  // Dialog
```

### Elevation
```kotlin
elevation0 = 0.dp  // Flat
elevation1 = 1.dp  // Low (cards)
elevation2 = 2.dp  // Medium
elevation4 = 4.dp  // High
```

### Touch Targets
```kotlin
minTouchTarget = 48.dp  // WCAG AA minimum
```

---

## 🧩 Bileşenler

### 1. AppButton

**5 Varyant:**

```kotlin
// Primary - Ana aksiyonlar
AppButton(
  text = "Kaydet",
  onClick = { },
  variant = ButtonVariant.PRIMARY
)

// Secondary - İkincil aksiyonlar  
AppButton(
  text = "İptal",
  onClick = { },
  variant = ButtonVariant.SECONDARY
)

// Tertiary - Outlined
AppButton(
  text = "Düzenle",
  onClick = { },
  variant = ButtonVariant.TERTIARY
)

// Destructive - Tehlikeli işlemler
AppButton(
  text = "Sil",
  onClick = { },
  variant = ButtonVariant.DESTRUCTIVE
)

// Ghost - Minimal
AppButton(
  text = "Vazgeç",
  onClick = { },
  variant = ButtonVariant.GHOST
)
```

**Durumlar:**
- Normal
- Pressed (97% scale animasyon)
- Disabled (38% opacity)
- Loading (spinner)

**Boyutlar:**
```kotlin
ButtonSize.SMALL   // 40dp
ButtonSize.MEDIUM  // 48dp (default)
ButtonSize.LARGE   // 56dp
```

---

### 2. AppTextField

```kotlin
AppTextField(
  value = text,
  onValueChange = { text = it },
  label = "Başlık",
  helperText = "Görev başlığını girin",
  isRequired = true,
  leadingIcon = Icons.Default.Edit
)

// Password field
AppTextField(
  value = password,
  onValueChange = { password = it },
  label = "Şifre",
  isPassword = true  // Otomatik visibility toggle
)

// Multiline
AppTextArea(
  value = note,
  onValueChange = { note = it },
  label = "Not",
  minLines = 3,
  maxLines = 5
)
```

---

### 3. TaskCard

```kotlin
TaskCard(
  task = task,
  onStatusChange = { newStatus ->
    // Status güncelle
  },
  onClick = {
    // Task detayı göster
  },
  showNote = true  // Guest için false
)
```

**Özellikler:**
- Sol priority stripe (4dp, animasyonlu)
- Topic badge
- Status & Priority badges
- Due date + icon
- User avatar (initials)
- 120ms smooth animation

---

### 4. EmptyState

```kotlin
// Generic
EmptyState(
  title = "Görev yok",
  message = "Henüz görev eklenmemiş",
  actionText = "Görev Ekle",
  onActionClick = { }
)

// Hazır varyantlar
NoTasksEmptyState(onCreateClick = { })
NoCompletedTasksEmptyState()
NoSearchResultsEmptyState(searchQuery = "test")
```

---

### 5. AppDialog

```kotlin
// Confirmation (destructive)
ConfirmDialog(
  onDismiss = { },
  title = "Silmek istediğinize emin misiniz?",
  message = "Bu işlem geri alınamaz",
  onConfirm = { }
)

// Alert (info)
AlertDialog(
  onDismiss = { },
  title = "Başarılı",
  message = "Görev oluşturuldu"
)

// Custom content
CustomDialog(
  onDismiss = { },
  title = "Filtrele",
  content = {
    // Custom Composable
  },
  onConfirm = { }
)
```

---

### 6. AppSnackbar

```kotlin
// Success
SuccessSnackbar(
  message = "Görev kaydedildi",
  onDismiss = { }
)

// Error with action
ErrorSnackbar(
  message = "Bağlantı hatası",
  actionLabel = "Tekrar Dene",
  onActionClick = { retry() },
  onDismiss = { }
)

// Types: SUCCESS, ERROR, WARNING, INFO
AppSnackbar(
  message = "Bilgilendirme",
  type = SnackbarType.INFO,
  onDismiss = { }
)
```

---

### 7. FilterBar

```kotlin
val filters = listOf(
  Filter("high", "Yüksek Öncelik"),
  Filter("todo", "Yapılacak"),
  Filter("done", "Tamamlanan")
)

FilterBar(
  searchQuery = query,
  onSearchChange = { query = it },
  filters = filters,
  selectedFilters = selected,
  onFilterToggle = { id -> toggleFilter(id) },
  onClearAll = { clearFilters() }
)
```

---

### 8. Status & Priority Badges

```kotlin
// Status
StatusBadge(status = TaskStatus.IN_PROGRESS)
StatusBadgeInteractive(
  status = status,
  onStatusChange = { newStatus -> }
)

// Priority
PriorityBadge(priority = Priority.HIGH)
```

**Status Renkleri:**
- TODO: Gray
- DOING: Cyan
- DONE: Green

**Priority Renkleri:**
- LOW: Gray
- NORMAL: Cyan
- HIGH: Red

---

### 9. Form Controls

```kotlin
// Checkbox
AppCheckbox(
  checked = isChecked,
  onCheckedChange = { isChecked = it },
  label = "Beni hatırla"
)

// Switch with description
AppSwitch(
  checked = enabled,
  onCheckedChange = { enabled = it },
  label = "Bildirimleri aç",
  description = "E-posta bildirimleri alın"
)
```

---

## 💡 Kullanım Örnekleri

### Form Ekranı

```kotlin
@Composable
fun TaskFormScreen() {
  var title by remember { mutableStateOf("") }
  var note by remember { mutableStateOf("") }
  var priority by remember { mutableStateOf(Priority.NORMAL) }
  
  Column(
    modifier = Modifier
      .fillMaxSize()
      .padding(Spacing.screenPadding),
    verticalArrangement = Arrangement.spacedBy(Spacing.spacing16)
  ) {
    AppTextField(
      value = title,
      onValueChange = { title = it },
      label = "Başlık",
      isRequired = true
    )
    
    AppTextArea(
      value = note,
      onValueChange = { note = it },
      label = "Not"
    )
    
    Row(
      modifier = Modifier.fillMaxWidth(),
      horizontalArrangement = Arrangement.spacedBy(Spacing.spacing12)
    ) {
      AppButton(
        text = "Kaydet",
        onClick = { save() },
        modifier = Modifier.weight(1f),
        variant = ButtonVariant.PRIMARY
      )
      
      AppButton(
        text = "İptal",
        onClick = { cancel() },
        modifier = Modifier.weight(1f),
        variant = ButtonVariant.GHOST
      )
    }
  }
}
```

---

## ♿ Erişilebilirlik

### WCAG AA Standartları

**Kontrast Oranları:**
- Normal metin: 4.5:1 minimum
- Büyük metin (18sp+): 3:1 minimum
- UI bileşenleri: 3:1 minimum

**Touch Targets:**
- Minimum boyut: 48x48dp
- Tüm interaktif elementlerde uygulanır

**Semantik Etiketler:**
```kotlin
// Butonlar
contentDescription = "Görevi sil"

// İkonlar
Icon(
  imageVector = Icons.Default.Add,
  contentDescription = "Yeni görev ekle"
)

// Checkbox/Switch
modifier = Modifier.semantics { 
  role = Role.Checkbox 
}
```

**Klavye Navigasyonu:**
- Tab order mantıklı
- Enter/Space ile aktivasyon
- Esc ile dialog kapatma

**Ekran Okuyucu:**
- Tüm interaktif elementler etiketli
- Durum değişiklikleri announce edilir
- Hata mesajları açıklayıcı

---

## 🎯 Best Practices

### DO ✅

```kotlin
// Consistent spacing kullan
Column(verticalArrangement = Arrangement.spacedBy(Spacing.spacing16))

// Design tokens kullan
modifier = Modifier.padding(Spacing.screenPadding)

// Semantic color kullan
color = MaterialTheme.colorScheme.primary

// AppButton kullan (native Button değil)
AppButton(text = "Kaydet", onClick = { })
```

### DON'T ❌

```kotlin
// Hard-coded değerler
modifier = Modifier.padding(23.dp)  // ❌

// Rastgele renkler
color = Color(0xFFFF5733)  // ❌

// Native butonlar
Button(onClick = { }) { }  // ❌ AppButton kullan

// Accessibility eksik
Icon(imageVector = icon, contentDescription = null)  // ❌
```

---

## 📦 Bileşen Listesi (Özet)

✅ **Temel Bileşenler:**
- AppButton (5 varyant)
- AppTextField + AppTextArea
- TaskCard
- StatusBadge + StatusBadgeInteractive
- PriorityBadge
- UserAvatar
- EmptyState (3 varyant)

✅ **Dialog & Feedback:**
- AppDialog
- ConfirmDialog
- AlertDialog
- CustomDialog
- AppSnackbar (4 tip)

✅ **Navigasyon & Filters:**
- FilterBar
- SearchBar
- SectionHeader
- AppDivider

✅ **Form Controls:**
- AppCheckbox
- AppSwitch

✅ **Utility:**
- LoadingPlaceholder
- ErrorState
- LoadingState

---

## 🚀 Başlangıç

```kotlin
import com.example.minitasktracker.core.ui.components.*
import com.example.minitasktracker.core.ui.theme.*

@Composable
fun MyScreen() {
  // Tema otomatik aktif
  // MaterialTheme.colorScheme kullan
  // Spacing, Sizes, Radius token'larını kullan
  
  Column(modifier = Modifier.padding(Spacing.screenPadding)) {
    AppButton(
      text = "Başla",
      onClick = { },
      variant = ButtonVariant.PRIMARY
    )
  }
}
```

---

**Son Güncelleme:** 2025  
**Tasarım Sistemi:** TekTech v1.0  
**Framework:** Jetpack Compose + Material 3
