import 'package:flutter/material.dart';
import '../services/storage_service.dart';

/// Quản lý cài đặt giao diện (dark mode, âm thanh).
class SettingsProvider extends ChangeNotifier {
  final StorageService _storage;

  bool _darkMode;
  bool _soundEnabled;

  SettingsProvider(this._storage)
      : _darkMode = _storage.darkMode,
        _soundEnabled = _storage.soundEnabled;

  bool get darkMode => _darkMode;
  bool get soundEnabled => _soundEnabled;

  ThemeMode get themeMode => _darkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> toggleDarkMode([bool? value]) async {
    _darkMode = value ?? !_darkMode;
    await _storage.setDarkMode(_darkMode);
    notifyListeners();
  }

  Future<void> toggleSound([bool? value]) async {
    _soundEnabled = value ?? !_soundEnabled;
    await _storage.setSoundEnabled(_soundEnabled);
    notifyListeners();
  }
}
