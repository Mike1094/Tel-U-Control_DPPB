import 'package:shared_preferences/shared_preferences.dart';

/// Service untuk mengelola pengaturan aplikasi
class SettingsService {
  static const String _darkModeKey = 'dark_mode';
  static const String _autoLoginKey = 'auto_login';

  /// Get dark mode setting
  static Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }

  /// Set dark mode setting
  static Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }

  /// Get auto login setting
  static Future<bool> getAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoLoginKey) ?? true; // Default true
  }

  /// Set auto login setting
  static Future<void> setAutoLogin(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoLoginKey, value);
  }

  /// Enable auto login (called after successful login)
  /// Always enables auto-login after a successful login
  static Future<void> enableAutoLoginOnLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoLoginKey, true);
  }
}
