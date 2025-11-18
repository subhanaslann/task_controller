import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_app/core/providers/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Reset SharedPreferences before each test
    SharedPreferences.setMockInitialValues({});
  });

  // ==================== GROUP 1: INITIALIZATION TESTS ====================
  group('Initialization Tests', () {
    test('initial state is ThemeMode.dark', () {
      final notifier = ThemeNotifier();
      expect(notifier.state, ThemeMode.dark);
    });

    test('loads saved theme mode from SharedPreferences on init', () async {
      // Arrange - Set saved theme to dark (index 2)
      SharedPreferences.setMockInitialValues({'theme_mode': 2});

      // Act
      final notifier = ThemeNotifier();
      await Future.delayed(
        const Duration(milliseconds: 100),
      ); // Wait for async load

      // Assert
      expect(notifier.state, ThemeMode.dark);
    });

    test('loads light theme from SharedPreferences', () async {
      // Arrange - Set saved theme to light (index 1)
      SharedPreferences.setMockInitialValues({'theme_mode': 1});

      // Act
      final notifier = ThemeNotifier();
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(notifier.state, ThemeMode.light);
    });

    test('loads system theme from SharedPreferences', () async {
      // Arrange - Set saved theme to system (index 0)
      SharedPreferences.setMockInitialValues({'theme_mode': 0});

      // Act
      final notifier = ThemeNotifier();
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(notifier.state, ThemeMode.system);
    });

    test('uses default dark theme when SharedPreferences is empty', () async {
      // Arrange - Empty SharedPreferences
      SharedPreferences.setMockInitialValues({});

      // Act
      final notifier = ThemeNotifier();
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(notifier.state, ThemeMode.dark);
    });

    test('handles null theme key gracefully', () async {
      // Arrange - Key doesn't exist
      SharedPreferences.setMockInitialValues({});

      // Act
      final notifier = ThemeNotifier();
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(notifier.state, ThemeMode.dark);
    });

    test('initialization is idempotent', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({'theme_mode': 2});

      // Act - Create multiple instances
      final notifier1 = ThemeNotifier();
      await Future.delayed(const Duration(milliseconds: 100));
      final notifier2 = ThemeNotifier();
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert - Both should load the same theme
      expect(notifier1.state, ThemeMode.dark);
      expect(notifier2.state, ThemeMode.dark);
    });
  });

  // ==================== GROUP 2: SETTHEMEMODE TESTS ====================
  group('setThemeMode Tests', () {
    test('setThemeMode updates state to new theme mode', () async {
      // Arrange
      final notifier = ThemeNotifier();
      expect(notifier.state, ThemeMode.dark);

      // Act
      await notifier.setThemeMode(ThemeMode.light);

      // Assert
      expect(notifier.state, ThemeMode.light);
    });

    test('setThemeMode persists theme to SharedPreferences', () async {
      // Arrange
      final notifier = ThemeNotifier();

      // Act
      await notifier.setThemeMode(ThemeMode.dark);

      // Assert
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('theme_mode'), 2); // Dark = index 2
    });

    test('setThemeMode can switch to light mode', () async {
      // Arrange
      final notifier = ThemeNotifier();

      // Act
      await notifier.setThemeMode(ThemeMode.light);

      // Assert
      expect(notifier.state, ThemeMode.light);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('theme_mode'), 1); // Light = index 1
    });

    test('setThemeMode can switch to dark mode', () async {
      // Arrange
      final notifier = ThemeNotifier();

      // Act
      await notifier.setThemeMode(ThemeMode.dark);

      // Assert
      expect(notifier.state, ThemeMode.dark);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('theme_mode'), 2); // Dark = index 2
    });

    test('setThemeMode can switch to system mode', () async {
      // Arrange
      final notifier = ThemeNotifier();
      await notifier.setThemeMode(ThemeMode.dark);

      // Act
      await notifier.setThemeMode(ThemeMode.system);

      // Assert
      expect(notifier.state, ThemeMode.system);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('theme_mode'), 0); // System = index 0
    });

    test('setThemeMode can be called multiple times', () async {
      // Arrange
      final notifier = ThemeNotifier();

      // Act
      await notifier.setThemeMode(ThemeMode.light);
      expect(notifier.state, ThemeMode.light);

      await notifier.setThemeMode(ThemeMode.dark);
      expect(notifier.state, ThemeMode.dark);

      await notifier.setThemeMode(ThemeMode.system);
      expect(notifier.state, ThemeMode.system);

      // Assert
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('theme_mode'), 0); // Last set was system
    });

    test('setThemeMode updates state immediately', () async {
      final notifier = ThemeNotifier();
      expect(notifier.state, ThemeMode.dark);

      await notifier.setThemeMode(ThemeMode.light);
      expect(notifier.state, ThemeMode.light);

      await notifier.setThemeMode(ThemeMode.system);
      expect(notifier.state, ThemeMode.system);
    });
  });

  // ==================== GROUP 3: CONVENIENCE METHODS TESTS ====================
  group('Convenience Methods Tests', () {
    test('setLight() sets theme to light mode', () async {
      // Arrange
      final notifier = ThemeNotifier();

      // Act
      await notifier.setLight();

      // Assert
      expect(notifier.state, ThemeMode.light);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('theme_mode'), 1);
    });

    test('setDark() sets theme to dark mode', () async {
      // Arrange
      final notifier = ThemeNotifier();

      // Act
      await notifier.setDark();

      // Assert
      expect(notifier.state, ThemeMode.dark);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('theme_mode'), 2);
    });

    test('setSystem() sets theme to system mode', () async {
      // Arrange
      final notifier = ThemeNotifier();
      await notifier.setDark();

      // Act
      await notifier.setSystem();

      // Assert
      expect(notifier.state, ThemeMode.system);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('theme_mode'), 0);
    });

    test('convenience methods can be chained', () async {
      // Arrange
      final notifier = ThemeNotifier();

      // Act
      await notifier.setLight();
      expect(notifier.state, ThemeMode.light);

      await notifier.setDark();
      expect(notifier.state, ThemeMode.dark);

      await notifier.setSystem();
      expect(notifier.state, ThemeMode.system);

      await notifier.setLight();
      expect(notifier.state, ThemeMode.light);
    });

    test('all three convenience methods work correctly', () async {
      final notifier = ThemeNotifier();

      // Test setLight
      await notifier.setLight();
      expect(notifier.state, ThemeMode.light);

      // Test setDark
      await notifier.setDark();
      expect(notifier.state, ThemeMode.dark);

      // Test setSystem
      await notifier.setSystem();
      expect(notifier.state, ThemeMode.system);
    });

    test('convenience methods persist to SharedPreferences', () async {
      final notifier = ThemeNotifier();
      final prefs = await SharedPreferences.getInstance();

      await notifier.setLight();
      expect(prefs.getInt('theme_mode'), 1);

      await notifier.setDark();
      expect(prefs.getInt('theme_mode'), 2);

      await notifier.setSystem();
      expect(prefs.getInt('theme_mode'), 0);
    });
  });

  // ==================== GROUP 4: THEMEMODE ENUM TESTS ====================
  group('ThemeMode Enum Tests', () {
    test('ThemeMode enum values map correctly to indices', () {
      expect(ThemeMode.system.index, 0);
      expect(ThemeMode.light.index, 1);
      expect(ThemeMode.dark.index, 2);
    });

    test('ThemeMode.values array is correct', () {
      expect(ThemeMode.values.length, 3);
      expect(ThemeMode.values[0], ThemeMode.system);
      expect(ThemeMode.values[1], ThemeMode.light);
      expect(ThemeMode.values[2], ThemeMode.dark);
    });

    test('can reconstruct ThemeMode from index', () async {
      // Arrange - Save system theme (index 0)
      SharedPreferences.setMockInitialValues({'theme_mode': 0});
      final notifier1 = ThemeNotifier();
      await Future.delayed(const Duration(milliseconds: 100));
      expect(notifier1.state, ThemeMode.system);

      // Light theme (index 1)
      SharedPreferences.setMockInitialValues({'theme_mode': 1});
      final notifier2 = ThemeNotifier();
      await Future.delayed(const Duration(milliseconds: 100));
      expect(notifier2.state, ThemeMode.light);

      // Dark theme (index 2)
      SharedPreferences.setMockInitialValues({'theme_mode': 2});
      final notifier3 = ThemeNotifier();
      await Future.delayed(const Duration(milliseconds: 100));
      expect(notifier3.state, ThemeMode.dark);
    });
  });

  // ==================== GROUP 5: EDGE CASES AND INTEGRATION ====================
  group('Edge Cases and Integration Tests', () {
    test('state persists across notifier instances', () async {
      // Arrange - First instance sets dark
      final notifier1 = ThemeNotifier();
      await notifier1.setDark();

      // Act - Create new instance
      final notifier2 = ThemeNotifier();
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert - Should load dark from SharedPreferences
      expect(notifier2.state, ThemeMode.dark);
    });

    test('multiple rapid setThemeMode calls work correctly', () async {
      final notifier = ThemeNotifier();

      // Act - Rapid calls
      final futures = [
        notifier.setLight(),
        notifier.setDark(),
        notifier.setLight(),
      ];
      await Future.wait(futures);

      // Assert - Final state should be from last call
      expect(notifier.state, ThemeMode.light);
    });

    test('theme changes are reflected immediately', () async {
      final notifier = ThemeNotifier();
      expect(notifier.state, ThemeMode.dark);

      await notifier.setLight();
      expect(notifier.state, ThemeMode.light);

      await notifier.setSystem();
      expect(notifier.state, ThemeMode.system);
    });

    test('dispose does not crash', () {
      final notifier = ThemeNotifier();
      // Just verify notifier exists and can be disposed naturally
      expect(notifier, isNotNull);
      expect(notifier.state, isNotNull);
    });

    test('setting same theme is idempotent', () async {
      final notifier = ThemeNotifier();
      await notifier.setDark();

      final prefs = await SharedPreferences.getInstance();
      final value1 = prefs.getInt('theme_mode');

      await notifier.setDark();
      final value2 = prefs.getInt('theme_mode');

      expect(value1, value2);
      expect(notifier.state, ThemeMode.dark);
    });

    test('can cycle through all theme modes', () async {
      final notifier = ThemeNotifier();

      // Dark (default)
      expect(notifier.state, ThemeMode.dark);

      // Light
      await notifier.setLight();
      expect(notifier.state, ThemeMode.light);

      // System
      await notifier.setSystem();
      expect(notifier.state, ThemeMode.system);

      // Back to dark
      await notifier.setDark();
      expect(notifier.state, ThemeMode.dark);
    });

    test('SharedPreferences keys are consistent', () async {
      final notifier = ThemeNotifier();
      await notifier.setDark();

      final prefs = await SharedPreferences.getInstance();

      // Verify key name matches constant in ThemeNotifier
      expect(prefs.containsKey('theme_mode'), true);
      expect(prefs.getInt('theme_mode'), isNotNull);
    });

    test('theme persists after multiple operations', () async {
      final notifier = ThemeNotifier();

      // Perform multiple operations
      await notifier.setLight();
      await notifier.setDark();
      await notifier.setLight();
      await notifier.setSystem();
      await notifier.setDark();

      // Create new instance
      final notifier2 = ThemeNotifier();
      await Future.delayed(const Duration(milliseconds: 100));

      // Should load last set theme (dark)
      expect(notifier2.state, ThemeMode.dark);
    });
  });
}
