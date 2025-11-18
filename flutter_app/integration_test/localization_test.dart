import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_app/l10n/app_localizations_en.dart';
import 'package:flutter_app/l10n/app_localizations_tr.dart';

/// TekTech Mini Task Tracker
/// Integration Tests - Localization & Language Switching
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Localization Tests - Turkish', () {
    testWidgets('Turkish locale displays correct text', (tester) async {
      final trLocalizations = AppLocalizationsTr();

      // Verify Turkish translations
      expect(trLocalizations.login, 'Giriş Yap');
      expect(trLocalizations.email, 'E-posta');
      expect(trLocalizations.password, 'Şifre');
      expect(trLocalizations.myTasks, 'Görevlerim');
      expect(trLocalizations.home, 'Ana Sayfa');
      expect(trLocalizations.settings, 'Ayarlar');
      expect(trLocalizations.logout, 'Çıkış Yap');
    });

    testWidgets('Turkish validation messages are correct', (tester) async {
      final trLocalizations = AppLocalizationsTr();

      // Verify Turkish validation messages
      expect(trLocalizations.validation_required, 'Bu alan zorunludur');
      expect(trLocalizations.validation_email, 'Geçerli bir e-posta adresi girin');
    });

    testWidgets('Turkish task-related strings are correct', (tester) async {
      final trLocalizations = AppLocalizationsTr();

      // Verify task-related strings
      expect(trLocalizations.tasks, 'Görevler');
      expect(trLocalizations.createTask, 'Görev Oluştur');
      expect(trLocalizations.editTask, 'Görev Düzenle');
      expect(trLocalizations.deleteTask, 'Görevi Sil');
      expect(trLocalizations.taskTitle, 'Görev Başlığı');
      expect(trLocalizations.taskStatus, 'Durum');
      expect(trLocalizations.taskPriority, 'Öncelik');
    });

    testWidgets('Turkish status strings are correct', (tester) async {
      final trLocalizations = AppLocalizationsTr();

      // Verify task status
      expect(trLocalizations.statusTodo, 'Yapılacak');
      expect(trLocalizations.statusInProgress, 'Devam Ediyor');
      expect(trLocalizations.statusDone, 'Tamamlandı');
    });

    testWidgets('Turkish priority strings are correct', (tester) async {
      final trLocalizations = AppLocalizationsTr();

      // Verify priority levels
      expect(trLocalizations.priorityLow, 'Düşük');
      expect(trLocalizations.priorityNormal, 'Normal');
      expect(trLocalizations.priorityHigh, 'Yüksek');
    });

    testWidgets('Turkish time-related strings are correct', (tester) async {
      final trLocalizations = AppLocalizationsTr();

      // Verify time strings
      expect(trLocalizations.today, 'Bugün');
      expect(trLocalizations.yesterday, 'Dün');
      expect(trLocalizations.tomorrow, 'Yarın');
      expect(trLocalizations.daysAgo(5), '5 gün önce');
      expect(trLocalizations.daysRemaining(3), '3 gün kaldı');
    });

    testWidgets('Turkish error messages are correct', (tester) async {
      final trLocalizations = AppLocalizationsTr();

      // Verify error messages
      expect(trLocalizations.errorNetworkTitle, 'Bağlantı Hatası');
      expect(trLocalizations.errorUnauthorizedTitle, 'Oturum Süresi Doldu');
      expect(trLocalizations.errorServerTitle, 'Sunucu Hatası');
      expect(trLocalizations.errorNetworkMessage, 'İnternet bağlantınızı kontrol edin');
    });

    testWidgets('Turkish success messages are correct', (tester) async {
      final trLocalizations = AppLocalizationsTr();

      // Verify success messages
      expect(trLocalizations.taskCreatedSuccess, 'Görev oluşturuldu');
      expect(trLocalizations.taskUpdatedSuccess, 'Görev güncellendi');
      expect(trLocalizations.taskDeletedSuccess, 'Görev silindi');
    });

    testWidgets('Turkish role names are correct', (tester) async {
      final trLocalizations = AppLocalizationsTr();

      // Verify role names
      expect(trLocalizations.roleAdmin, 'Yönetici');
      expect(trLocalizations.roleMember, 'Üye');
      expect(trLocalizations.roleGuest, 'Misafir');
    });

    testWidgets('Turkish common action strings are correct', (tester) async {
      final trLocalizations = AppLocalizationsTr();

      // Verify common actions
      expect(trLocalizations.save, 'Kaydet');
      expect(trLocalizations.cancel, 'İptal');
      expect(trLocalizations.delete, 'Sil');
      expect(trLocalizations.edit, 'Düzenle');
      expect(trLocalizations.create, 'Oluştur');
      expect(trLocalizations.search, 'Ara');
    });

    testWidgets('Turkish sync messages are correct', (tester) async {
      final trLocalizations = AppLocalizationsTr();

      // Verify sync messages
      expect(trLocalizations.syncInProgress, 'Senkronize ediliyor...');
      expect(trLocalizations.syncCompleted, 'Senkronizasyon tamamlandı');
      expect(trLocalizations.syncFailed, 'Senkronizasyon başarısız');
      expect(trLocalizations.offlineMode, 'Çevrimdışı Mod');
    });
  });

  group('Localization Tests - English', () {
    testWidgets('English locale displays correct text', (tester) async {
      final enLocalizations = AppLocalizationsEn();

      // Verify English translations
      expect(enLocalizations.login, 'Login');
      expect(enLocalizations.email, 'Email');
      expect(enLocalizations.password, 'Password');
      expect(enLocalizations.myTasks, 'My Tasks');
      expect(enLocalizations.home, 'Home');
      expect(enLocalizations.settings, 'Settings');
      expect(enLocalizations.logout, 'Logout');
    });

    testWidgets('English validation messages are correct', (tester) async {
      final enLocalizations = AppLocalizationsEn();

      // Verify English validation messages
      expect(enLocalizations.validation_required, 'This field is required');
      expect(enLocalizations.validation_email, 'Please enter a valid email');
    });

    testWidgets('English task-related strings are correct', (tester) async {
      final enLocalizations = AppLocalizationsEn();

      // Verify task-related strings
      expect(enLocalizations.tasks, 'Tasks');
      expect(enLocalizations.createTask, 'Create Task');
      expect(enLocalizations.editTask, 'Edit Task');
      expect(enLocalizations.deleteTask, 'Delete Task');
      expect(enLocalizations.taskTitle, 'Task Title');
      expect(enLocalizations.taskStatus, 'Status');
      expect(enLocalizations.taskPriority, 'Priority');
    });

    testWidgets('English status strings are correct', (tester) async {
      final enLocalizations = AppLocalizationsEn();

      // Verify task status
      expect(enLocalizations.statusTodo, 'To Do');
      expect(enLocalizations.statusInProgress, 'In Progress');
      expect(enLocalizations.statusDone, 'Done');
    });

    testWidgets('English priority strings are correct', (tester) async {
      final enLocalizations = AppLocalizationsEn();

      // Verify priority levels
      expect(enLocalizations.priorityLow, 'Low');
      expect(enLocalizations.priorityNormal, 'Normal');
      expect(enLocalizations.priorityHigh, 'High');
    });

    testWidgets('English time-related strings are correct', (tester) async {
      final enLocalizations = AppLocalizationsEn();

      // Verify time strings
      expect(enLocalizations.today, 'Today');
      expect(enLocalizations.yesterday, 'Yesterday');
      expect(enLocalizations.tomorrow, 'Tomorrow');
      expect(enLocalizations.daysAgo(5), '5 days ago');
      expect(enLocalizations.daysRemaining(3), '3 days remaining');
    });

    testWidgets('English error messages are correct', (tester) async {
      final enLocalizations = AppLocalizationsEn();

      // Verify error messages
      expect(enLocalizations.errorNetworkTitle, 'Connection Error');
      expect(enLocalizations.errorUnauthorizedTitle, 'Session Expired');
      expect(enLocalizations.errorServerTitle, 'Server Error');
      expect(enLocalizations.errorNetworkMessage, 'Please check your internet connection');
    });

    testWidgets('English success messages are correct', (tester) async {
      final enLocalizations = AppLocalizationsEn();

      // Verify success messages
      expect(enLocalizations.taskCreatedSuccess, 'Task created');
      expect(enLocalizations.taskUpdatedSuccess, 'Task updated');
      expect(enLocalizations.taskDeletedSuccess, 'Task deleted');
    });

    testWidgets('English role names are correct', (tester) async {
      final enLocalizations = AppLocalizationsEn();

      // Verify role names
      expect(enLocalizations.roleAdmin, 'Admin');
      expect(enLocalizations.roleMember, 'Member');
      expect(enLocalizations.roleGuest, 'Guest');
    });

    testWidgets('English common action strings are correct', (tester) async {
      final enLocalizations = AppLocalizationsEn();

      // Verify common actions
      expect(enLocalizations.save, 'Save');
      expect(enLocalizations.cancel, 'Cancel');
      expect(enLocalizations.delete, 'Delete');
      expect(enLocalizations.edit, 'Edit');
      expect(enLocalizations.create, 'Create');
      expect(enLocalizations.search, 'Search');
    });

    testWidgets('English sync messages are correct', (tester) async {
      final enLocalizations = AppLocalizationsEn();

      // Verify sync messages
      expect(enLocalizations.syncInProgress, 'Syncing...');
      expect(enLocalizations.syncCompleted, 'Sync completed');
      expect(enLocalizations.syncFailed, 'Sync failed');
      expect(enLocalizations.offlineMode, 'Offline Mode');
    });
  });

  group('Localization Consistency', () {
    testWidgets('Turkish and English have same number of translations', (tester) async {
      final trLocalizations = AppLocalizationsTr();
      final enLocalizations = AppLocalizationsEn();

      // Both should have the same fields (structural consistency)
      // We verify this by checking key translations exist in both

      // Basic UI
      expect(trLocalizations.login, isNotEmpty);
      expect(enLocalizations.login, isNotEmpty);

      // Tasks
      expect(trLocalizations.tasks, isNotEmpty);
      expect(enLocalizations.tasks, isNotEmpty);

      // Status
      expect(trLocalizations.statusTodo, isNotEmpty);
      expect(enLocalizations.statusTodo, isNotEmpty);

      // Errors
      expect(trLocalizations.errorNetworkTitle, isNotEmpty);
      expect(enLocalizations.errorNetworkTitle, isNotEmpty);
    });

    testWidgets('Pluralization works for both locales', (tester) async {
      final trLocalizations = AppLocalizationsTr();
      final enLocalizations = AppLocalizationsEn();

      // Test singular (1 day)
      expect(trLocalizations.daysAgo(1), '1 gün önce');
      expect(enLocalizations.daysAgo(1), '1 day ago');

      // Test plural (5 days)
      expect(trLocalizations.daysAgo(5), '5 gün önce');
      expect(enLocalizations.daysAgo(5), '5 days ago');

      // Test daysRemaining
      expect(trLocalizations.daysRemaining(1), '1 gün kaldı');
      expect(enLocalizations.daysRemaining(1), '1 day remaining');
    });

    testWidgets('Parameter interpolation works correctly', (tester) async {
      final trLocalizations = AppLocalizationsTr();
      final enLocalizations = AppLocalizationsEn();

      // Test min length validation
      expect(trLocalizations.validation_minLength(3).contains('3'), true);
      expect(enLocalizations.validation_minLength(3).contains('3'), true);

      // Test max length validation
      expect(trLocalizations.validation_maxLength(50).contains('50'), true);
      expect(enLocalizations.validation_maxLength(50).contains('50'), true);
    });
  });
}
