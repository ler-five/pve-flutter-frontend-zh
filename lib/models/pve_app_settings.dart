import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persisted user preferences for appearance and language.
///
/// Keeping both in one [ChangeNotifier] lets `MaterialApp` rebuild whenever
/// either the theme mode or the locale changes. Values fall back to the system
/// defaults, which is what most apps do.
class PveAppSettings extends ChangeNotifier {
  static const _themeKey = 'settings.themeMode';
  static const _localeKey = 'settings.locale';

  final SharedPreferences _prefs;

  PveAppSettings(this._prefs);

  /// Raw stored value: `system` (default), `light` or `dark`.
  String get themeModeKey => _prefs.getString(_themeKey) ?? 'system';

  /// Raw stored locale code: `system` (default), `en`, `zh` or `zh_Hant`.
  String get localeKey => _prefs.getString(_localeKey) ?? 'system';

  ThemeMode get themeMode {
    switch (themeModeKey) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Locale? get locale {
    final code = localeKey;
    if (code == 'system' || code.isEmpty) return null;
    final parts = code.split('_');
    if (parts.length > 1) {
      return Locale.fromSubtags(
        languageCode: parts[0],
        scriptCode: parts[1],
      );
    }
    return Locale(parts[0]);
  }

  Future<void> setThemeModeKey(String key) async {
    await _prefs.setString(_themeKey, key);
    notifyListeners();
  }

  Future<void> setLocaleKey(String key) async {
    await _prefs.setString(_localeKey, key);
    notifyListeners();
  }
}
