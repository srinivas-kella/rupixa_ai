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

  /// =========================
  /// TOGGLE THEME
  /// =========================

  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

    notifyListeners();

    await _saveTheme();
  }

  /// =========================
  /// SET SYSTEM THEME
  /// =========================

  Future<void> setSystemTheme() async {
    _themeMode = ThemeMode.system;

    notifyListeners();

    await _saveTheme();
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
