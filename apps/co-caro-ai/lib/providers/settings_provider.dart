import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../models/enums.dart';
import '../services/storage_service.dart';

/// Quản lý cài đặt người dùng (theme, âm thanh, cỡ bàn mặc định, độ khó...).
class SettingsProvider extends ChangeNotifier {
  SettingsProvider({StorageService? storage}) : _storage = storage ?? StorageService();

  final StorageService _storage;
  AppSettings _settings = const AppSettings();
  bool _loaded = false;

  AppSettings get settings => _settings;
  bool get isLoaded => _loaded;
  ThemeMode get themeMode => _settings.darkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> load() async {
    _settings = await _storage.loadSettings();
    _loaded = true;
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _settings = _settings.copyWith(darkMode: value);
    notifyListeners();
    await _storage.saveSettings(_settings);
  }

  Future<void> setSoundEnabled(bool value) async {
    _settings = _settings.copyWith(soundEnabled: value);
    notifyListeners();
    await _storage.saveSettings(_settings);
  }

  Future<void> setDefaultBoardSize(int size) async {
    _settings = _settings.copyWith(defaultBoardSize: size);
    notifyListeners();
    await _storage.saveSettings(_settings);
  }

  Future<void> setDefaultDifficulty(Difficulty difficulty) async {
    _settings = _settings.copyWith(defaultDifficulty: difficulty);
    notifyListeners();
    await _storage.saveSettings(_settings);
  }

  /// Giả lập mua IAP "Gỡ quảng cáo" (chưa tích hợp store thật).
  Future<void> setAdsRemoved(bool value) async {
    _settings = _settings.copyWith(adsRemoved: value);
    notifyListeners();
    await _storage.saveSettings(_settings);
  }
}
