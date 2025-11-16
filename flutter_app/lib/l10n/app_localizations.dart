import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// Uygulama başlığı
  ///
  /// In tr, this message translates to:
  /// **'Mini Görev Takipçi'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In tr, this message translates to:
  /// **'Ana Sayfa'**
  String get home;

  /// No description provided for @tasks.
  ///
  /// In tr, this message translates to:
  /// **'Görevler'**
  String get tasks;

  /// No description provided for @myTasks.
  ///
  /// In tr, this message translates to:
  /// **'Görevlerim'**
  String get myTasks;

  /// No description provided for @teamTasks.
  ///
  /// In tr, this message translates to:
  /// **'Ekip Görevleri'**
  String get teamTasks;

  /// No description provided for @completedTasks.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlananlar'**
  String get completedTasks;

  /// No description provided for @admin.
  ///
  /// In tr, this message translates to:
  /// **'Yönetici'**
  String get admin;

  /// No description provided for @profile.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yap'**
  String get logout;

  /// No description provided for @login.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get login;

  /// No description provided for @email.
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get email;

  /// No description provided for @username.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı Adı'**
  String get username;

  /// No description provided for @password.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get password;

  /// No description provided for @usernameOrEmail.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı Adı'**
  String get usernameOrEmail;

  /// No description provided for @forgotPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifremi Unuttum'**
  String get forgotPassword;

  /// No description provided for @rememberMe.
  ///
  /// In tr, this message translates to:
  /// **'Beni Hatırla'**
  String get rememberMe;

  /// No description provided for @taskTitle.
  ///
  /// In tr, this message translates to:
  /// **'Görev Başlığı'**
  String get taskTitle;

  /// No description provided for @taskNote.
  ///
  /// In tr, this message translates to:
  /// **'Not'**
  String get taskNote;

  /// No description provided for @taskPriority.
  ///
  /// In tr, this message translates to:
  /// **'Öncelik'**
  String get taskPriority;

  /// No description provided for @taskStatus.
  ///
  /// In tr, this message translates to:
  /// **'Durum'**
  String get taskStatus;

  /// No description provided for @taskDueDate.
  ///
  /// In tr, this message translates to:
  /// **'Bitiş Tarihi'**
  String get taskDueDate;

  /// No description provided for @taskAssignee.
  ///
  /// In tr, this message translates to:
  /// **'Atanan'**
  String get taskAssignee;

  /// No description provided for @taskTopic.
  ///
  /// In tr, this message translates to:
  /// **'Konu'**
  String get taskTopic;

  /// No description provided for @priorityLow.
  ///
  /// In tr, this message translates to:
  /// **'Düşük'**
  String get priorityLow;

  /// No description provided for @priorityNormal.
  ///
  /// In tr, this message translates to:
  /// **'Normal'**
  String get priorityNormal;

  /// No description provided for @priorityHigh.
  ///
  /// In tr, this message translates to:
  /// **'Yüksek'**
  String get priorityHigh;

  /// No description provided for @statusTodo.
  ///
  /// In tr, this message translates to:
  /// **'Yapılacak'**
  String get statusTodo;

  /// No description provided for @statusInProgress.
  ///
  /// In tr, this message translates to:
  /// **'Devam Ediyor'**
  String get statusInProgress;

  /// No description provided for @statusDone.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlandı'**
  String get statusDone;

  /// No description provided for @createTask.
  ///
  /// In tr, this message translates to:
  /// **'Görev Oluştur'**
  String get createTask;

  /// No description provided for @editTask.
  ///
  /// In tr, this message translates to:
  /// **'Görev Düzenle'**
  String get editTask;

  /// No description provided for @deleteTask.
  ///
  /// In tr, this message translates to:
  /// **'Görevi Sil'**
  String get deleteTask;

  /// No description provided for @updateTask.
  ///
  /// In tr, this message translates to:
  /// **'Görevi Güncelle'**
  String get updateTask;

  /// No description provided for @assignTask.
  ///
  /// In tr, this message translates to:
  /// **'Görev Ata'**
  String get assignTask;

  /// No description provided for @createUser.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı Oluştur'**
  String get createUser;

  /// No description provided for @editUser.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı Düzenle'**
  String get editUser;

  /// No description provided for @deleteUser.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcıyı Sil'**
  String get deleteUser;

  /// No description provided for @users.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcılar'**
  String get users;

  /// No description provided for @userManagement.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı Yönetimi'**
  String get userManagement;

  /// No description provided for @taskManagement.
  ///
  /// In tr, this message translates to:
  /// **'Görev Yönetimi'**
  String get taskManagement;

  /// No description provided for @roleAdmin.
  ///
  /// In tr, this message translates to:
  /// **'Yönetici'**
  String get roleAdmin;

  /// No description provided for @roleMember.
  ///
  /// In tr, this message translates to:
  /// **'Üye'**
  String get roleMember;

  /// No description provided for @roleGuest.
  ///
  /// In tr, this message translates to:
  /// **'Misafir'**
  String get roleGuest;

  /// No description provided for @save.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In tr, this message translates to:
  /// **'İptal'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In tr, this message translates to:
  /// **'Düzenle'**
  String get edit;

  /// No description provided for @create.
  ///
  /// In tr, this message translates to:
  /// **'Oluştur'**
  String get create;

  /// No description provided for @search.
  ///
  /// In tr, this message translates to:
  /// **'Ara'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In tr, this message translates to:
  /// **'Filtrele'**
  String get filter;

  /// No description provided for @sort.
  ///
  /// In tr, this message translates to:
  /// **'Sırala'**
  String get sort;

  /// No description provided for @refresh.
  ///
  /// In tr, this message translates to:
  /// **'Yenile'**
  String get refresh;

  /// No description provided for @retry.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar Dene'**
  String get retry;

  /// No description provided for @close.
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get close;

  /// No description provided for @ok.
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get ok;

  /// No description provided for @yes.
  ///
  /// In tr, this message translates to:
  /// **'Evet'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In tr, this message translates to:
  /// **'Hayır'**
  String get no;

  /// No description provided for @emptyTasksTitle.
  ///
  /// In tr, this message translates to:
  /// **'Görev Bulunamadı'**
  String get emptyTasksTitle;

  /// No description provided for @emptyTasksMessage.
  ///
  /// In tr, this message translates to:
  /// **'Henüz hiç göreviniz yok'**
  String get emptyTasksMessage;

  /// No description provided for @emptyUsersTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı Bulunamadı'**
  String get emptyUsersTitle;

  /// No description provided for @emptyUsersMessage.
  ///
  /// In tr, this message translates to:
  /// **'Henüz kullanıcı eklenmemiş'**
  String get emptyUsersMessage;

  /// No description provided for @loading.
  ///
  /// In tr, this message translates to:
  /// **'Yükleniyor...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In tr, this message translates to:
  /// **'Hata'**
  String get error;

  /// No description provided for @success.
  ///
  /// In tr, this message translates to:
  /// **'Başarılı'**
  String get success;

  /// No description provided for @errorNetworkTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı Hatası'**
  String get errorNetworkTitle;

  /// No description provided for @errorNetworkMessage.
  ///
  /// In tr, this message translates to:
  /// **'İnternet bağlantınızı kontrol edin'**
  String get errorNetworkMessage;

  /// No description provided for @errorUnauthorizedTitle.
  ///
  /// In tr, this message translates to:
  /// **'Oturum Süresi Doldu'**
  String get errorUnauthorizedTitle;

  /// No description provided for @errorUnauthorizedMessage.
  ///
  /// In tr, this message translates to:
  /// **'Lütfen tekrar giriş yapın'**
  String get errorUnauthorizedMessage;

  /// No description provided for @errorServerTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sunucu Hatası'**
  String get errorServerTitle;

  /// No description provided for @errorServerMessage.
  ///
  /// In tr, this message translates to:
  /// **'Bir hata oluştu, lütfen daha sonra tekrar deneyin'**
  String get errorServerMessage;

  /// No description provided for @errorUnknownTitle.
  ///
  /// In tr, this message translates to:
  /// **'Beklenmeyen Hata'**
  String get errorUnknownTitle;

  /// No description provided for @errorUnknownMessage.
  ///
  /// In tr, this message translates to:
  /// **'Bir şeyler ters gitti'**
  String get errorUnknownMessage;

  /// No description provided for @taskCreatedSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Görev oluşturuldu'**
  String get taskCreatedSuccess;

  /// No description provided for @taskUpdatedSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Görev güncellendi'**
  String get taskUpdatedSuccess;

  /// No description provided for @taskDeletedSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Görev silindi'**
  String get taskDeletedSuccess;

  /// No description provided for @userCreatedSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı oluşturuldu'**
  String get userCreatedSuccess;

  /// No description provided for @userUpdatedSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı güncellendi'**
  String get userUpdatedSuccess;

  /// No description provided for @userDeletedSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı silindi'**
  String get userDeletedSuccess;

  /// No description provided for @confirmDeleteTask.
  ///
  /// In tr, this message translates to:
  /// **'Bu görevi silmek istediğinizden emin misiniz?'**
  String get confirmDeleteTask;

  /// No description provided for @confirmDeleteUser.
  ///
  /// In tr, this message translates to:
  /// **'Bu kullanıcıyı silmek istediğinizden emin misiniz?'**
  String get confirmDeleteUser;

  /// No description provided for @confirmLogout.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış yapmak istediğinizden emin misiniz?'**
  String get confirmLogout;

  /// No description provided for @validation_required.
  ///
  /// In tr, this message translates to:
  /// **'Bu alan zorunludur'**
  String get validation_required;

  /// No description provided for @validation_email.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir e-posta adresi girin'**
  String get validation_email;

  /// No description provided for @validation_minLength.
  ///
  /// In tr, this message translates to:
  /// **'En az {min} karakter olmalıdır'**
  String validation_minLength(int min);

  /// No description provided for @validation_maxLength.
  ///
  /// In tr, this message translates to:
  /// **'En fazla {max} karakter olabilir'**
  String validation_maxLength(int max);

  /// No description provided for @daysRemaining.
  ///
  /// In tr, this message translates to:
  /// **'{count} gün kaldı'**
  String daysRemaining(int count);

  /// No description provided for @daysAgo.
  ///
  /// In tr, this message translates to:
  /// **'{count} gün önce'**
  String daysAgo(int count);

  /// No description provided for @today.
  ///
  /// In tr, this message translates to:
  /// **'Bugün'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In tr, this message translates to:
  /// **'Dün'**
  String get yesterday;

  /// No description provided for @tomorrow.
  ///
  /// In tr, this message translates to:
  /// **'Yarın'**
  String get tomorrow;

  /// No description provided for @syncInProgress.
  ///
  /// In tr, this message translates to:
  /// **'Senkronize ediliyor...'**
  String get syncInProgress;

  /// No description provided for @syncCompleted.
  ///
  /// In tr, this message translates to:
  /// **'Senkronizasyon tamamlandı'**
  String get syncCompleted;

  /// No description provided for @syncFailed.
  ///
  /// In tr, this message translates to:
  /// **'Senkronizasyon başarısız'**
  String get syncFailed;

  /// No description provided for @offlineMode.
  ///
  /// In tr, this message translates to:
  /// **'Çevrimdışı Mod'**
  String get offlineMode;

  /// No description provided for @loginErrorTitle.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Hatası'**
  String get loginErrorTitle;

  /// No description provided for @loginErrorMessage.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı adı veya şifre hatalı'**
  String get loginErrorMessage;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
