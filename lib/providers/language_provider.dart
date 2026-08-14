import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('ko', '');
  
  Locale get locale => _locale;
  
  LanguageProvider() {
    _loadLocale();
  }
  
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'ko';
    _locale = Locale(languageCode);
    notifyListeners();
  }
  
  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    notifyListeners();
  }
  
  void toggleLanguage() {
    if (_locale.languageCode == 'ko') {
      setLocale(const Locale('en', ''));
    } else {
      setLocale(const Locale('ko', ''));
    }
  }
}

