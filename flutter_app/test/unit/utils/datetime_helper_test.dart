import 'package:flutter/material.dart';
import 'package:flutter_app/core/utils/datetime_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateTimeHelper - Days Remaining', () {
    test('getDaysRemaining should return positive number for future date', () {
      // Arrange
      final futureDate = DateTime.now().add(const Duration(days: 7));

      // Act
      final result = DateTimeHelper.getDaysRemaining(futureDate);

      // Assert
      expect(result, 7);
    });

    test('getDaysRemaining should return 0 for today', () {
      // Arrange
      final today = DateTime.now();

      // Act
      final result = DateTimeHelper.getDaysRemaining(today);

      // Assert
      expect(result, 0);
    });

    test('getDaysRemaining should return negative number for past date', () {
      // Arrange
      final pastDate = DateTime.now().subtract(const Duration(days: 3));

      // Act
      final result = DateTimeHelper.getDaysRemaining(pastDate);

      // Assert
      expect(result, -3);
    });
  });

  group('DateTimeHelper - Date Checks', () {
    test('isPast should return true for past date', () {
      // Arrange
      final pastDate = DateTime.now().subtract(const Duration(days: 1));

      // Act
      final result = DateTimeHelper.isPast(pastDate);

      // Assert
      expect(result, true);
    });

    test('isPast should return false for today', () {
      // Arrange
      final today = DateTime.now();

      // Act
      final result = DateTimeHelper.isPast(today);

      // Assert
      expect(result, false);
    });

    test('isPast should return false for future date', () {
      // Arrange
      final futureDate = DateTime.now().add(const Duration(days: 1));

      // Act
      final result = DateTimeHelper.isPast(futureDate);

      // Assert
      expect(result, false);
    });

    test('isToday should return true for current date', () {
      // Arrange
      final today = DateTime.now();

      // Act
      final result = DateTimeHelper.isToday(today);

      // Assert
      expect(result, true);
    });

    test('isToday should return false for yesterday', () {
      // Arrange
      final yesterday = DateTime.now().subtract(const Duration(days: 1));

      // Act
      final result = DateTimeHelper.isToday(yesterday);

      // Assert
      expect(result, false);
    });

    test('isTomorrow should return true for next day', () {
      // Arrange
      final tomorrow = DateTime.now().add(const Duration(days: 1));

      // Act
      final result = DateTimeHelper.isTomorrow(tomorrow);

      // Assert
      expect(result, true);
    });

    test('isTomorrow should return false for today', () {
      // Arrange
      final today = DateTime.now();

      // Act
      final result = DateTimeHelper.isTomorrow(today);

      // Assert
      expect(result, false);
    });

    test('isYesterday should return true for previous day', () {
      // Arrange
      final yesterday = DateTime.now().subtract(const Duration(days: 1));

      // Act
      final result = DateTimeHelper.isYesterday(yesterday);

      // Assert
      expect(result, true);
    });

    test('isYesterday should return false for today', () {
      // Arrange
      final today = DateTime.now();

      // Act
      final result = DateTimeHelper.isYesterday(today);

      // Assert
      expect(result, false);
    });
  });

  group('DateTimeHelper - ISO 8601 Parsing', () {
    test('parseIso8601 should parse full ISO 8601 date string', () {
      // Arrange
      const dateString = '2025-12-31T23:59:59.000Z';

      // Act
      final result = DateTimeHelper.parseIso8601(dateString);

      // Assert
      expect(result, isNotNull);
      expect(result!.year, 2025);
      expect(result.month, 12);
      expect(result.day, 31);
    });

    test('parseIso8601 should parse date-only string', () {
      // Arrange
      const dateString = '2025-06-15';

      // Act
      final result = DateTimeHelper.parseIso8601(dateString);

      // Assert
      expect(result, isNotNull);
      expect(result!.year, 2025);
      expect(result.month, 6);
      expect(result.day, 15);
    });

    test('parseIso8601 should return null for null input', () {
      // Act
      final result = DateTimeHelper.parseIso8601(null);

      // Assert
      expect(result, null);
    });

    test('parseIso8601 should return null for empty string', () {
      // Act
      final result = DateTimeHelper.parseIso8601('');

      // Assert
      expect(result, null);
    });

    test('parseIso8601 should return null for invalid date string', () {
      // Act
      final result = DateTimeHelper.parseIso8601('invalid-date');

      // Assert
      expect(result, null);
    });
  });

  group('DateTimeHelper - Date Formatting', () {
    test('formatDate should format date with English locale', () {
      // Arrange
      final date = DateTime(2025, 1, 15);
      const locale = Locale('en', 'US');

      // Act
      final result = DateTimeHelper.formatDate(date, locale);

      // Assert
      expect(result, isNotEmpty);
      expect(result, contains('1'));
      expect(result, contains('15'));
      expect(result, contains('2025'));
    });

    test('formatShortDate should format as "dd MMM"', () {
      // Arrange
      final date = DateTime(2025, 6, 15);
      const locale = Locale('en', 'US');

      // Act
      final result = DateTimeHelper.formatShortDate(date, locale);

      // Assert
      expect(result, contains('15'));
      expect(result, contains('Jun'));
    });

    test('formatLongDate should format as "dd MMMM yyyy"', () {
      // Arrange
      final date = DateTime(2025, 6, 15);
      const locale = Locale('en', 'US');

      // Act
      final result = DateTimeHelper.formatLongDate(date, locale);

      // Assert
      expect(result, contains('15'));
      expect(result, contains('June'));
      expect(result, contains('2025'));
    });

    test('formatTime should format time only', () {
      // Arrange
      final dateTime = DateTime(2025, 1, 15, 14, 30);
      const locale = Locale('en', 'US');

      // Act
      final result = DateTimeHelper.formatTime(dateTime, locale);

      // Assert
      expect(result, isNotEmpty);
      // Time format varies by locale, just check it's not empty
    });

    test('formatDateTime should format date and time', () {
      // Arrange
      final dateTime = DateTime(2025, 1, 15, 14, 30);
      const locale = Locale('en', 'US');

      // Act
      final result = DateTimeHelper.formatDateTime(dateTime, locale);

      // Assert
      expect(result, isNotEmpty);
      expect(result, contains('15'));
      expect(result, contains('2025'));
    });
  });

  group('DateTimeHelper - ISO 8601 Format', () {
    test('formatIso8601 should format valid ISO string (short)', () {
      // Arrange
      const dateString = '2025-06-15T10:30:00.000Z';
      const locale = Locale('en', 'US');

      // Act
      final result = DateTimeHelper.formatIso8601(dateString, locale);

      // Assert
      expect(result, isNotNull);
      expect(result, contains('15'));
    });

    test('formatIso8601 should format valid ISO string (long)', () {
      // Arrange
      const dateString = '2025-06-15T10:30:00.000Z';
      const locale = Locale('en', 'US');

      // Act
      final result = DateTimeHelper.formatIso8601(
        dateString,
        locale,
        shortFormat: false,
      );

      // Assert
      expect(result, isNotNull);
      expect(result, contains('15'));
      expect(result, contains('2025'));
    });

    test('formatIso8601 should return null for null input', () {
      // Arrange
      const locale = Locale('en', 'US');

      // Act
      final result = DateTimeHelper.formatIso8601(null, locale);

      // Assert
      expect(result, null);
    });

    test('formatIso8601 should return null for invalid date string', () {
      // Arrange
      const locale = Locale('en', 'US');

      // Act
      final result = DateTimeHelper.formatIso8601('invalid-date', locale);

      // Assert
      expect(result, null);
    });
  });
}

