import 'package:flutter/material.dart';
import 'settings_service.dart';

/// Provider untuk state management theme
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  /// Load settings from SharedPreferences
  Future<void> loadSettings() async {
    _isDarkMode = await SettingsService.getDarkMode();
    notifyListeners();
  }

  /// Toggle dark mode
  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await SettingsService.setDarkMode(_isDarkMode);
    notifyListeners();
  }

  /// Set dark mode explicitly
  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    await SettingsService.setDarkMode(value);
    notifyListeners();
  }
}
