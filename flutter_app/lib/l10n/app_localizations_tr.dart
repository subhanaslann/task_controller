// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Mini Görev Takipçi';

  @override
  String get home => 'Ana Sayfa';

  @override
  String get tasks => 'Görevler';

  @override
  String get myTasks => 'Görevlerim';

  @override
  String get teamTasks => 'Ekip Görevleri';

  @override
  String get completedTasks => 'Tamamlananlar';

  @override
  String get admin => 'Yönetici';

  @override
  String get profile => 'Profil';

  @override
  String get settings => 'Ayarlar';

  @override
  String get logout => 'Çıkış Yap';

  @override
  String get login => 'Giriş Yap';

  @override
  String get email => 'E-posta';

  @override
  String get username => 'Kullanıcı Adı';

  @override
  String get password => 'Şifre';

  @override
  String get usernameOrEmail => 'Kullanıcı Adı';

  @override
  String get forgotPassword => 'Şifremi Unuttum';

  @override
  String get rememberMe => 'Beni Hatırla';

  @override
  String get taskTitle => 'Görev Başlığı';

  @override
  String get taskNote => 'Not';

  @override
  String get taskPriority => 'Öncelik';

  @override
  String get taskStatus => 'Durum';

  @override
  String get taskDueDate => 'Bitiş Tarihi';

  @override
  String get taskAssignee => 'Atanan';

  @override
  String get taskTopic => 'Konu';

  @override
  String get priorityLow => 'Düşük';

  @override
  String get priorityNormal => 'Normal';

  @override
  String get priorityHigh => 'Yüksek';

  @override
  String get statusTodo => 'Yapılacak';

  @override
  String get statusInProgress => 'Devam Ediyor';

  @override
  String get statusDone => 'Tamamlandı';

  @override
  String get createTask => 'Görev Oluştur';

  @override
  String get editTask => 'Görev Düzenle';

  @override
  String get deleteTask => 'Görevi Sil';

  @override
  String get updateTask => 'Görevi Güncelle';

  @override
  String get assignTask => 'Görev Ata';

  @override
  String get createUser => 'Kullanıcı Oluştur';

  @override
  String get editUser => 'Kullanıcı Düzenle';

  @override
  String get deleteUser => 'Kullanıcıyı Sil';

  @override
  String get users => 'Kullanıcılar';

  @override
  String get userManagement => 'Kullanıcı Yönetimi';

  @override
  String get taskManagement => 'Görev Yönetimi';

  @override
  String get roleAdmin => 'Yönetici';

  @override
  String get roleMember => 'Üye';

  @override
  String get roleGuest => 'Misafir';

  @override
  String get save => 'Kaydet';

  @override
  String get cancel => 'İptal';

  @override
  String get delete => 'Sil';

  @override
  String get edit => 'Düzenle';

  @override
  String get create => 'Oluştur';

  @override
  String get search => 'Ara';

  @override
  String get filter => 'Filtrele';

  @override
  String get sort => 'Sırala';

  @override
  String get refresh => 'Yenile';

  @override
  String get retry => 'Tekrar Dene';

  @override
  String get close => 'Kapat';

  @override
  String get ok => 'Tamam';

  @override
  String get yes => 'Evet';

  @override
  String get no => 'Hayır';

  @override
  String get emptyTasksTitle => 'Görev Bulunamadı';

  @override
  String get emptyTasksMessage => 'Henüz hiç göreviniz yok';

  @override
  String get emptyUsersTitle => 'Kullanıcı Bulunamadı';

  @override
  String get emptyUsersMessage => 'Henüz kullanıcı eklenmemiş';

  @override
  String get loading => 'Yükleniyor...';

  @override
  String get error => 'Hata';

  @override
  String get success => 'Başarılı';

  @override
  String get errorNetworkTitle => 'Bağlantı Hatası';

  @override
  String get errorNetworkMessage => 'İnternet bağlantınızı kontrol edin';

  @override
  String get errorUnauthorizedTitle => 'Oturum Süresi Doldu';

  @override
  String get errorUnauthorizedMessage => 'Lütfen tekrar giriş yapın';

  @override
  String get errorServerTitle => 'Sunucu Hatası';

  @override
  String get errorServerMessage =>
      'Bir hata oluştu, lütfen daha sonra tekrar deneyin';

  @override
  String get errorUnknownTitle => 'Beklenmeyen Hata';

  @override
  String get errorUnknownMessage => 'Bir şeyler ters gitti';

  @override
  String get taskCreatedSuccess => 'Görev oluşturuldu';

  @override
  String get taskUpdatedSuccess => 'Görev güncellendi';

  @override
  String get taskDeletedSuccess => 'Görev silindi';

  @override
  String get userCreatedSuccess => 'Kullanıcı oluşturuldu';

  @override
  String get userUpdatedSuccess => 'Kullanıcı güncellendi';

  @override
  String get userDeletedSuccess => 'Kullanıcı silindi';

  @override
  String get confirmDeleteTask =>
      'Bu görevi silmek istediğinizden emin misiniz?';

  @override
  String get confirmDeleteUser =>
      'Bu kullanıcıyı silmek istediğinizden emin misiniz?';

  @override
  String get confirmLogout => 'Çıkış yapmak istediğinizden emin misiniz?';

  @override
  String get validation_required => 'Bu alan zorunludur';

  @override
  String get validation_email => 'Geçerli bir e-posta adresi girin';

  @override
  String validation_minLength(int min) {
    return 'En az $min karakter olmalıdır';
  }

  @override
  String validation_maxLength(int max) {
    return 'En fazla $max karakter olabilir';
  }

  @override
  String daysRemaining(int count) {
    return '$count gün kaldı';
  }

  @override
  String daysAgo(int count) {
    return '$count gün önce';
  }

  @override
  String get today => 'Bugün';

  @override
  String get yesterday => 'Dün';

  @override
  String get tomorrow => 'Yarın';

  @override
  String get syncInProgress => 'Senkronize ediliyor...';

  @override
  String get syncCompleted => 'Senkronizasyon tamamlandı';

  @override
  String get syncFailed => 'Senkronizasyon başarısız';

  @override
  String get offlineMode => 'Çevrimdışı Mod';

  @override
  String get loginErrorTitle => 'Giriş Hatası';

  @override
  String get loginErrorMessage => 'Kullanıcı adı veya şifre hatalı';

  @override
  String get companyName => 'Şirket Adı';

  @override
  String get teamName => 'Ekip Adı';

  @override
  String get yourName => 'Adınız';

  @override
  String get emailAddress => 'E-posta Adresi';

  @override
  String get createYourTeam => 'Ekibinizi Oluşturun';

  @override
  String get createTeam => 'Ekip Oluştur';

  @override
  String get alreadyHaveAccount => 'Zaten hesabınız var mı?';

  @override
  String get dontHaveTeam => 'Ekibiniz yok mu? Buradan kayıt olun';

  @override
  String get teamCreatedSuccess => 'Ekip başarıyla oluşturuldu! Hoş geldiniz!';

  @override
  String get emailAlreadyRegistered =>
      'Bu e-posta zaten kayıtlı. Lütfen giriş yapın.';

  @override
  String get registrationFailed =>
      'Kayıt başarısız oldu. Lütfen tekrar deneyin.';

  @override
  String get weak => 'Zayıf';

  @override
  String get fair => 'Orta';

  @override
  String get good => 'İyi';

  @override
  String get strong => 'Güçlü';

  @override
  String get allTasks => 'Tümü';

  @override
  String get highPriority => 'Yüksek Öncelik';

  @override
  String get overdue => 'Gecikmiş';

  @override
  String get tryChangingFilters => 'Filtreleri değiştirmeyi deneyin';

  @override
  String get taskDeleted => 'Görev silindi';

  @override
  String get failedToUpdateTask => 'Görev güncellenemedi';

  @override
  String get failedToDeleteTask => 'Görev silinemedi';

  @override
  String get taskMovedToActive => 'Görev aktif görevlere taşındı';

  @override
  String get failedToUndo => 'Geri alma başarısız';

  @override
  String get appearance => 'Görünüm';

  @override
  String get language => 'Dil';

  @override
  String get account => 'Hesap';

  @override
  String get about => 'Hakkında';

  @override
  String get theme => 'Tema';

  @override
  String get light => 'Açık';

  @override
  String get dark => 'Koyu';

  @override
  String get systemDefault => 'Sistem Varsayılanı';

  @override
  String get english => 'English';

  @override
  String get turkish => 'Türkçe';

  @override
  String get appVersion => 'Uygulama Sürümü';

  @override
  String get license => 'Lisans';

  @override
  String get mitLicense => 'MIT Lisansı';

  @override
  String get signOutOfYourAccount => 'Hesabınızdan çıkış yapın';

  @override
  String get avatarUpdateComingSoon => 'Avatar güncelleme yakında geliyor!';

  @override
  String get chooseTheme => 'Tema Seçin';

  @override
  String get chooseLanguage => 'Dil Seçin';

  @override
  String get adminPanel => 'Yönetici Paneli';

  @override
  String get exitAdminMode => 'Yönetici Modundan Çık';

  @override
  String get userManagementTab => 'Kullanıcılar';

  @override
  String get taskManagementTab => 'Görevler';

  @override
  String get topicsManagementTab => 'Konular';

  @override
  String get organizationTab => 'Organizasyon';

  @override
  String get userUpdated => 'Kullanıcı güncellendi';

  @override
  String get userCreated => 'Kullanıcı oluşturuldu';

  @override
  String get topicUpdated => 'Konu güncellendi';

  @override
  String get topicCreated => 'Konu oluşturuldu';

  @override
  String get allTopics => 'Tüm Konular';

  @override
  String get allStatuses => 'Tüm Durumlar';

  @override
  String get noProjects => 'Proje Yok';

  @override
  String get noVisibleProjects => 'Görünür proje atanmamış.';

  @override
  String get noActiveProjects => 'Aktif proje bulunamadı.';

  @override
  String get addTaskToMyself => 'Kendime Görev Ekle';

  @override
  String get noTasksInProject => 'Bu projede görev yok';

  @override
  String get noAccess => 'Erişim Yok';

  @override
  String get noAccessMessage =>
      'Henüz hiçbir görev grubuna erişiminiz yok.\\nYöneticinizle iletişime geçin.';

  @override
  String get assignedTo => 'Atanan';

  @override
  String get unassigned => 'Atanmamış';

  @override
  String get confirmTitle => 'Onayla';

  @override
  String get confirmMessage => 'Emin misiniz?';

  @override
  String get confirm => 'Onayla';

  @override
  String deleteConfirmation(Object item) {
    return '$item silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.';
  }

  @override
  String get logoutConfirmation => 'Çıkış yapmak istediğinizden emin misiniz?';

  @override
  String get pleasSelectDueDate => 'Lütfen bir bitiş tarihi seçin';

  @override
  String get taskAddedSuccess => 'Görev başarıyla eklendi';

  @override
  String get loadingFailed => 'Veri yüklenemedi';

  @override
  String get dataLoadedSuccess => 'Veri başarıyla yüklendi';

  @override
  String get pullToRefresh => 'Yenilemek için çekin';

  @override
  String get releaseToRefresh => 'Yenilemek için bırakın';

  @override
  String get refreshing => 'Yenileniyor...';

  @override
  String get lastUpdated => 'Son güncelleme';

  @override
  String get filterBy => 'Filtrele';

  @override
  String get sortBy => 'Sırala';

  @override
  String get ascending => 'Artan';

  @override
  String get descending => 'Azalan';

  @override
  String get clearFilters => 'Filtreleri Temizle';

  @override
  String get applyFilters => 'Filtreleri Uygula';

  @override
  String get noFiltersApplied => 'Filtre uygulanmadı';

  @override
  String get sortByDate => 'Tarih';

  @override
  String get sortByPriority => 'Öncelik';

  @override
  String get sortByStatus => 'Durum';

  @override
  String get sortByTitle => 'Başlık';

  @override
  String get filterByPriority => 'Önceliğe Göre Filtrele';

  @override
  String get filterByStatus => 'Duruma Göre Filtrele';

  @override
  String get filterByAssignee => 'Atanana Göre Filtrele';

  @override
  String get filterByTopic => 'Konuya Göre Filtrele';

  @override
  String get viewOptions => 'Görünüm Seçenekleri';

  @override
  String get listView => 'Liste Görünümü';

  @override
  String get gridView => 'Izgara Görünümü';

  @override
  String get compactView => 'Kompakt Görünüm';

  @override
  String get markAsRead => 'Okundu Olarak İşaretle';

  @override
  String get markAsUnread => 'Okunmadı Olarak İşaretle';

  @override
  String get archive => 'Arşivle';

  @override
  String get unarchive => 'Arşivden Çıkar';

  @override
  String get duplicate => 'Çoğalt';

  @override
  String get share => 'Paylaş';

  @override
  String get advancedFilters => 'Gelişmiş Filtreler';

  @override
  String get quickFilters => 'Hızlı Filtreler';

  @override
  String get savedFilters => 'Kaydedilmiş Filtreler';

  @override
  String get createFilter => 'Filtre Oluştur';

  @override
  String get saveFilter => 'Filtreyi Kaydet';

  @override
  String get filterName => 'Filtre Adı';
}
