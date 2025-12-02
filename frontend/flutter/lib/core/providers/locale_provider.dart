import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Language provider for managing app locale
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  static const String _localeKey = 'app_locale';
  
  LocaleNotifier() : super(const Locale('tr')) {
    _loadLocale();
  }

  /// Load saved locale from SharedPreferences
  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localeCode = prefs.getString(_localeKey) ?? 'tr';
      state = Locale(localeCode);
    } catch (e) {
      // Fallback to Turkish if loading fails
      state = const Locale('tr');
    }
  }

  /// Change app locale
  Future<void> setLocale(Locale locale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
      state = locale;
    } catch (e) {
      // If saving fails, still update the state
      state = locale;
    }
  }

  /// Toggle between Turkish and English
  Future<void> toggleLocale() async {
    final newLocale = state.languageCode == 'tr' 
        ? const Locale('en') 
        : const Locale('tr');
    await setLocale(newLocale);
  }

  /// Get current language name
  String get currentLanguageName {
    switch (state.languageCode) {
      case 'tr':
        return 'Türkçe';
      case 'en':
        return 'English';
      default:
        return 'Türkçe';
    }
  }

  /// Check if current locale is Turkish
  bool get isTurkish => state.languageCode == 'tr';

  /// Check if current locale is English
  bool get isEnglish => state.languageCode == 'en';
}
