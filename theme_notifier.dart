import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_themes.dart';

class ThemeNotifier extends ChangeNotifier {
  static const _prefKey = 'selectedTheme';
  AppTheme _current = AppTheme.purple;

  ThemeNotifier() {
    _loadFromPrefs();
  }

  AppTheme get current => _current;
  ThemeData get themeData => appThemeData[_current]!;

  void setTheme(AppTheme theme) {
    _current = theme;
    _saveToPrefs(theme);
    notifyListeners();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_prefKey);
    if (name != null) {
      _current = AppTheme.values.firstWhere(
        (e) => e.toString() == name,
        orElse: () => AppTheme.dark,
      );
      notifyListeners();
    }
  }

  Future<void> _saveToPrefs(AppTheme theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, theme.toString());
  }
}
