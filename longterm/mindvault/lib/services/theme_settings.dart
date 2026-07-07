import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cấu hình giao diện (sáng/tối/theo hệ thống), lưu local bằng
/// shared_preferences. Mặc định theo hệ thống — giữ hành vi cũ nếu
/// người dùng chưa từng đổi.
class ThemeSettings extends ChangeNotifier {
  static const _keyMode = 'mindvault_theme_mode';

  ThemeMode _mode = ThemeMode.system;

  ThemeMode get mode => _mode;

  /// Đọc cấu hình đã lưu (gọi khi app khởi động).
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_keyMode);
    _mode = _parse(saved) ?? ThemeMode.system;
    notifyListeners();
  }

  /// Đổi chế độ hiển thị và lưu lại.
  Future<void> setMode(ThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMode, _serialize(mode));
  }

  static ThemeMode? _parse(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return null;
    }
  }

  static String _serialize(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
