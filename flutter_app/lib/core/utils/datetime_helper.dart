import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

/// TekTech DateTimeHelper
/// 
/// Localized date/time formatting utilities
/// - Relative time (today, yesterday, N days ago)
/// - Date formatting (short, medium, long)
/// - Locale-aware formatting
class DateTimeHelper {
  /// Format date with locale
  static String formatDate(
    DateTime date,
    Locale locale, {
    DateFormat? format,
  }) {
    final formatter = format ?? DateFormat.yMd(locale.toString());
    return formatter.format(date);
  }

  /// Format date and time
  static String formatDateTime(DateTime dateTime, Locale locale) {
    final formatter = DateFormat.yMd(locale.toString()).add_jm();
    return formatter.format(dateTime);
  }

  /// Format time only
  static String formatTime(DateTime dateTime, Locale locale) {
    final formatter = DateFormat.jm(locale.toString());
    return formatter.format(dateTime);
  }

  /// Format date as "dd MMM" (e.g., "15 Oca" or "15 Jan")
  static String formatShortDate(DateTime date, Locale locale) {
    final formatter = DateFormat('dd MMM', locale.toString());
    return formatter.format(date);
  }

  /// Format date as "dd MMMM yyyy" (e.g., "15 Ocak 2024")
  static String formatLongDate(DateTime date, Locale locale) {
    final formatter = DateFormat('dd MMMM yyyy', locale.toString());
    return formatter.format(date);
  }

  /// Get relative time string (today, yesterday, N days ago/remaining)
  static String getRelativeTime(
    DateTime dateTime,
    BuildContext context, {
    bool isFuture = false,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    final difference = targetDate.difference(today).inDays;

    // Use l10n when available
    // final l10n = AppLocalizations.of(context);

    if (difference == 0) {
      return 'Bugün'; // l10n.today
    } else if (difference == 1) {
      return 'Yarın'; // l10n.tomorrow
    } else if (difference == -1) {
      return 'Dün'; // l10n.yesterday
    } else if (difference > 0) {
      return '$difference gün kaldı'; // l10n.daysRemaining(difference)
    } else {
      return '${-difference} gün önce'; // l10n.daysAgo(-difference)
    }
  }

  /// Get days remaining until date
  static int getDaysRemaining(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
    
    return targetDate.difference(today).inDays;
  }

  /// Check if date is in the past
  static bool isPast(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);
    
    return targetDate.isBefore(today);
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Parse ISO 8601 date string
  static DateTime? parseIso8601(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    
    try {
      // Handle both full ISO and date-only formats
      if (dateString.length >= 19) {
        return DateTime.parse(dateString.substring(0, 19));
      } else {
        return DateTime.parse(dateString);
      }
    } catch (e) {
      return null;
    }
  }

  /// Format ISO 8601 date string with locale
  static String? formatIso8601(
    String? dateString,
    Locale locale, {
    bool shortFormat = true,
  }) {
    final date = parseIso8601(dateString);
    if (date == null) return null;
    
    return shortFormat 
        ? formatShortDate(date, locale)
        : formatLongDate(date, locale);
  }
}
