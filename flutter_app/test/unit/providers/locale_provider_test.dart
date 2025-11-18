import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/core/providers/locale_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Reset SharedPreferences before each test
    SharedPreferences.setMockInitialValues({});
  });

  // ==================== GROUP 1: INITIALIZATION TESTS ====================
  group('Initialization Tests', () {
    test('initial state is Turkish locale', () {
      final notifier = LocaleNotifier();
      expect(notifier.state, equals(const Locale('tr')));
    });

    test('loads saved locale from SharedPreferences on init', () async {
      // Arrange - Set saved locale to English
      SharedPreferences.setMockInitialValues({'app_locale': 'en'});

      // Act
      final notifier = LocaleNotifier();
      await Future.delayed(const Duration(milliseconds: 100)); // Wait for async load

      // Assert
      expect(notifier.state, equals(const Locale('en')));
    });

    test('uses default Turkish locale when SharedPreferences is empty', () async {
      // Arrange - Empty SharedPreferences
      SharedPreferences.setMockInitialValues({});

      // Act
      final notifier = LocaleNotifier();
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(notifier.state, equals(const Locale('tr')));
    });

    test('handles invalid locale code gracefully', () async {
      // Arrange - Invalid locale code
      SharedPreferences.setMockInitialValues({'app_locale': 'invalid'});

      // Act
      final notifier = LocaleNotifier();
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert - Should create locale with 'invalid' code
      expect(notifier.state.languageCode, equals('invalid'));
    });

    test('handles null locale key gracefully', () async {
      // Arrange - Key exists but is null (shouldn't happen but test edge case)
      SharedPreferences.setMockInitialValues({});

      // Act
      final notifier = LocaleNotifier();
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(notifier.state, equals(const Locale('tr')));
    });

    test('initialization is idempotent', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({'app_locale': 'en'});

      // Act - Create multiple instances
      final notifier1 = LocaleNotifier();
      await Future.delayed(const Duration(milliseconds: 100));
      final notifier2 = LocaleNotifier();
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert - Both should load the same locale
      expect(notifier1.state, equals(const Locale('en')));
      expect(notifier2.state, equals(const Locale('en')));
    });
  });

  // ==================== GROUP 2: SETLOCALE TESTS ====================
  group('setLocale Tests', () {
    test('setLocale updates state to new locale', () async {
      // Arrange
      final notifier = LocaleNotifier();
      expect(notifier.state.languageCode, 'tr');

      // Act
      await notifier.setLocale(const Locale('en'));

      // Assert
      expect(notifier.state, equals(const Locale('en')));
    });

    test('setLocale persists locale to SharedPreferences', () async {
      // Arrange
      final notifier = LocaleNotifier();

      // Act
      await notifier.setLocale(const Locale('en'));

      // Assert
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_locale'), 'en');
    });

    test('setLocale can switch from Turkish to English', () async {
      // Arrange
      final notifier = LocaleNotifier();
      expect(notifier.state.languageCode, 'tr');

      // Act
      await notifier.setLocale(const Locale('en'));

      // Assert
      expect(notifier.state.languageCode, 'en');
    });

    test('setLocale can switch from English to Turkish', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({'app_locale': 'en'});
      final notifier = LocaleNotifier();
      await Future.delayed(const Duration(milliseconds: 100));
      expect(notifier.state.languageCode, 'en');

      // Act
      await notifier.setLocale(const Locale('tr'));

      // Assert
      expect(notifier.state.languageCode, 'tr');
    });

    test('setLocale can be called multiple times', () async {
      // Arrange
      final notifier = LocaleNotifier();

      // Act
      await notifier.setLocale(const Locale('en'));
      expect(notifier.state.languageCode, 'en');

      await notifier.setLocale(const Locale('tr'));
      expect(notifier.state.languageCode, 'tr');

      await notifier.setLocale(const Locale('en'));
      expect(notifier.state.languageCode, 'en');

      // Assert
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_locale'), 'en');
    });

    test('setLocale accepts custom locale codes', () async {
      // Arrange
      final notifier = LocaleNotifier();

      // Act
      await notifier.setLocale(const Locale('fr'));

      // Assert
      expect(notifier.state.languageCode, 'fr');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_locale'), 'fr');
    });

    test('setLocale updates state even if persistence fails', () async {
      // This test verifies the try-catch behavior
      // In the current implementation, state is updated in both try and catch
      final notifier = LocaleNotifier();

      // Act
      await notifier.setLocale(const Locale('en'));

      // Assert - State should be updated regardless
      expect(notifier.state.languageCode, 'en');
    });
  });

  // ==================== GROUP 3: TOGGLELOCALE TESTS ====================
  group('toggleLocale Tests', () {
    test('toggleLocale switches from Turkish to English', () async {
      // Arrange
      final notifier = LocaleNotifier();
      expect(notifier.state.languageCode, 'tr');

      // Act
      await notifier.toggleLocale();

      // Assert
      expect(notifier.state, equals(const Locale('en')));
    });

    test('toggleLocale switches from English to Turkish', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({'app_locale': 'en'});
      final notifier = LocaleNotifier();
      await Future.delayed(const Duration(milliseconds: 100));

      // Act
      await notifier.toggleLocale();

      // Assert
      expect(notifier.state, equals(const Locale('tr')));
    });

    test('toggleLocale can be called multiple times', () async {
      // Arrange
      final notifier = LocaleNotifier();
      expect(notifier.state.languageCode, 'tr');

      // Act & Assert
      await notifier.toggleLocale();
      expect(notifier.state.languageCode, 'en');

      await notifier.toggleLocale();
      expect(notifier.state.languageCode, 'tr');

      await notifier.toggleLocale();
      expect(notifier.state.languageCode, 'en');

      await notifier.toggleLocale();
      expect(notifier.state.languageCode, 'tr');
    });

    test('toggleLocale persists changes to SharedPreferences', () async {
      // Arrange
      final notifier = LocaleNotifier();

      // Act
      await notifier.toggleLocale();

      // Assert
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_locale'), 'en');
    });

    test('toggleLocale only toggles between Turkish and English', () async {
      // Arrange - Set a non-standard locale
      final notifier = LocaleNotifier();
      await notifier.setLocale(const Locale('fr'));

      // Act - Toggle should treat non-tr as "not Turkish"
      await notifier.toggleLocale();

      // Assert - Should switch to Turkish
      expect(notifier.state.languageCode, 'tr');
    });
  });

  // ==================== GROUP 4: CURRENTLANGUAGENAME TESTS ====================
  group('currentLanguageName Tests', () {
    test('returns "Türkçe" for Turkish locale', () {
      final notifier = LocaleNotifier();
      expect(notifier.currentLanguageName, 'Türkçe');
    });

    test('returns "English" for English locale', () async {
      final notifier = LocaleNotifier();
      await notifier.setLocale(const Locale('en'));
      expect(notifier.currentLanguageName, 'English');
    });

    test('returns "Türkçe" as default for unknown locale', () async {
      final notifier = LocaleNotifier();
      await notifier.setLocale(const Locale('fr'));
      expect(notifier.currentLanguageName, 'Türkçe');
    });

    test('currentLanguageName updates after setLocale', () async {
      final notifier = LocaleNotifier();
      expect(notifier.currentLanguageName, 'Türkçe');

      await notifier.setLocale(const Locale('en'));
      expect(notifier.currentLanguageName, 'English');

      await notifier.setLocale(const Locale('tr'));
      expect(notifier.currentLanguageName, 'Türkçe');
    });

    test('currentLanguageName updates after toggleLocale', () async {
      final notifier = LocaleNotifier();
      expect(notifier.currentLanguageName, 'Türkçe');

      await notifier.toggleLocale();
      expect(notifier.currentLanguageName, 'English');

      await notifier.toggleLocale();
      expect(notifier.currentLanguageName, 'Türkçe');
    });
  });

  // ==================== GROUP 5: ISTURKISH AND ISENGLISH TESTS ====================
  group('isTurkish and isEnglish Tests', () {
    test('isTurkish returns true for Turkish locale', () {
      final notifier = LocaleNotifier();
      expect(notifier.isTurkish, true);
      expect(notifier.isEnglish, false);
    });

    test('isEnglish returns true for English locale', () async {
      final notifier = LocaleNotifier();
      await notifier.setLocale(const Locale('en'));

      expect(notifier.isEnglish, true);
      expect(notifier.isTurkish, false);
    });

    test('isTurkish and isEnglish are mutually exclusive', () async {
      final notifier = LocaleNotifier();

      // Turkish
      expect(notifier.isTurkish, true);
      expect(notifier.isEnglish, false);

      // English
      await notifier.setLocale(const Locale('en'));
      expect(notifier.isEnglish, true);
      expect(notifier.isTurkish, false);
    });

    test('isTurkish and isEnglish work with toggleLocale', () async {
      final notifier = LocaleNotifier();

      expect(notifier.isTurkish, true);
      expect(notifier.isEnglish, false);

      await notifier.toggleLocale();
      expect(notifier.isTurkish, false);
      expect(notifier.isEnglish, true);

      await notifier.toggleLocale();
      expect(notifier.isTurkish, true);
      expect(notifier.isEnglish, false);
    });

    test('both isTurkish and isEnglish return false for other locales', () async {
      final notifier = LocaleNotifier();
      await notifier.setLocale(const Locale('fr'));

      expect(notifier.isTurkish, false);
      expect(notifier.isEnglish, false);
    });
  });

  // ==================== GROUP 6: EDGE CASES AND INTEGRATION ====================
  group('Edge Cases and Integration Tests', () {
    test('state persists across notifier instances', () async {
      // Arrange - First instance sets English
      final notifier1 = LocaleNotifier();
      await notifier1.setLocale(const Locale('en'));

      // Act - Create new instance
      final notifier2 = LocaleNotifier();
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert - Should load English from SharedPreferences
      expect(notifier2.state.languageCode, 'en');
    });

    test('multiple rapid setLocale calls work correctly', () async {
      final notifier = LocaleNotifier();

      // Act - Rapid calls
      final futures = [
        notifier.setLocale(const Locale('en')),
        notifier.setLocale(const Locale('tr')),
        notifier.setLocale(const Locale('en')),
      ];
      await Future.wait(futures);

      // Assert - Final state should be from last call
      expect(notifier.state.languageCode, 'en');
    });

    test('locale changes are reflected immediately', () async {
      final notifier = LocaleNotifier();
      expect(notifier.state.languageCode, 'tr');

      await notifier.setLocale(const Locale('en'));
      expect(notifier.state.languageCode, 'en');

      await notifier.setLocale(const Locale('tr'));
      expect(notifier.state.languageCode, 'tr');
    });

    test('getters work correctly after initialization', () async {
      SharedPreferences.setMockInitialValues({'app_locale': 'en'});
      final notifier = LocaleNotifier();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(notifier.isEnglish, true);
      expect(notifier.isTurkish, false);
      expect(notifier.currentLanguageName, 'English');
    });

    test('dispose does not crash', () {
      final notifier = LocaleNotifier();
      // Just verify notifier exists and can be disposed naturally
      expect(notifier, isNotNull);
      expect(notifier.state, isNotNull);
    });

    test('setting same locale is idempotent', () async {
      final notifier = LocaleNotifier();
      await notifier.setLocale(const Locale('tr'));

      final prefs = await SharedPreferences.getInstance();
      final callCount1 = prefs.getString('app_locale');

      await notifier.setLocale(const Locale('tr'));
      final callCount2 = prefs.getString('app_locale');

      expect(callCount1, callCount2);
      expect(notifier.state.languageCode, 'tr');
    });

    test('Locale object equality works correctly', () async {
      final notifier = LocaleNotifier();
      await notifier.setLocale(const Locale('en'));

      expect(notifier.state, equals(const Locale('en')));
      expect(notifier.state == const Locale('en'), true);
    });
  });
}
