import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = "themeMode";

  ThemeMode _themeMode = ThemeMode.light;

  ThemeProvider() {
    _loadTheme();
  }

  ThemeMode get currentTheme => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  bool get isSystemMode => _themeMode == ThemeMode.system;

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;

    notifyListeners();

    await _saveTheme();
  }

  /// =========================
  /// TOGGLE THEME
  /// =========================

  Future<void> toggleTheme(bool isDark) async {
    await setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  /// =========================
  /// SET SYSTEM THEME
  /// =========================

  Future<void> setSystemTheme() async {
    await setThemeMode(ThemeMode.system);
  }

  /// =========================
  /// SAVE THEME
  /// =========================

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_themeKey, _themeMode.name);
  }

  /// =========================
  /// LOAD THEME
  /// =========================

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    final savedTheme = prefs.getString(_themeKey);

    if (savedTheme != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (e) => e.name == savedTheme,
        orElse: () => ThemeMode.light,
      );
    }

    notifyListeners();
  }
}
