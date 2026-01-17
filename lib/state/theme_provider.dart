import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeBox = 'theme_prefs';
  static const String _darkModeKey = 'dark_mode';

  late Box<dynamic> _box;
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  /// Initialize theme provider and load saved preferences
  Future<void> init() async {
    _box = await Hive.openBox(_themeBox);
    _isDarkMode = _box.get(_darkModeKey, defaultValue: false) as bool;
  }

  /// Toggle dark mode and persist preference
  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await _box.put(_darkModeKey, _isDarkMode);
    notifyListeners();
  }

  /// Set dark mode explicitly
  Future<void> setDarkMode(bool isDark) async {
    _isDarkMode = isDark;
    await _box.put(_darkModeKey, _isDarkMode);
    notifyListeners();
  }
}
