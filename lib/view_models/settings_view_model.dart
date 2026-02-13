import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsViewModel extends ChangeNotifier {
  double _arabicFontSize = 26.0;
  double get arabicFontSize => _arabicFontSize;

  double _translationFontSize = 16.0;
  double get translationFontSize => _translationFontSize;

  SettingsViewModel() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _arabicFontSize = prefs.getDouble('arabicFontSize') ?? 26.0;
    _translationFontSize = prefs.getDouble('translationFontSize') ?? 16.0;
    notifyListeners();
  }

  Future<void> setArabicFontSize(double size) async {
    _arabicFontSize = size;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('arabicFontSize', size);
  }

  Future<void> setTranslationFontSize(double size) async {
    _translationFontSize = size;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('translationFontSize', size);
  }
}
