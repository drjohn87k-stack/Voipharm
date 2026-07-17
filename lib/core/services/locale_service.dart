import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// Tracks the current app language (Arabic / English) and drives
/// the whole-app [Locale] + text direction (RTL for Arabic, LTR for English).
/// Persisted across launches via SharedPreferences.
class LocaleService extends ChangeNotifier {
  LocaleService._();
  static final LocaleService instance = LocaleService._();

  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  bool get isArabic => _locale.languageCode == 'ar';

  /// Text direction for the whole MaterialApp.
  TextDirection get textDirection =>
      isArabic ? TextDirection.rtl : TextDirection.ltr;

  /// Load the saved locale on startup.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(AppConstants.prefLocale) ?? 'en';
    _locale = Locale(code);
    notifyListeners();
  }

  /// Switch between Arabic and English and persist the choice.
  Future<void> setLocale(Locale locale) async {
    if (_locale.languageCode == locale.languageCode) return;
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefLocale, locale.languageCode);
    notifyListeners();
  }

  Future<void> toggle() async {
    final next = isArabic ? const Locale('en') : const Locale('ar');
    await setLocale(next);
  }
}
