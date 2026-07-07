import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cấu hình AI (Ollama) + giao diện, lưu lại giữa các lần mở app.
class SettingsProvider extends ChangeNotifier {
  static const _keyHost = 'dream_oracle.settings.host';
  static const _keyModel = 'dream_oracle.settings.model';
  static const _keyOffline = 'dream_oracle.settings.forceOffline';
  static const _keyDarkMode = 'dream_oracle.settings.darkMode';

  String _host = 'http://localhost:11434';
  String _model = 'llama3.2';
  bool _forceOffline = false;
  bool _darkMode = false;
  bool _loaded = false;

  String get host => _host;
  String get model => _model;
  bool get forceOffline => _forceOffline;
  bool get darkMode => _darkMode;
  bool get loaded => _loaded;

  SettingsProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _host = prefs.getString(_keyHost) ?? _host;
    _model = prefs.getString(_keyModel) ?? _model;
    _forceOffline = prefs.getBool(_keyOffline) ?? false;
    _darkMode = prefs.getBool(_keyDarkMode) ?? false;
    _loaded = true;
    notifyListeners();
  }

  Future<void> updateHost(String value) async {
    _host = value.trim().isEmpty ? _host : value.trim();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyHost, _host);
  }

  Future<void> updateModel(String value) async {
    _model = value.trim().isEmpty ? _model : value.trim();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyModel, _model);
  }

  Future<void> setForceOffline(bool value) async {
    _forceOffline = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOffline, value);
  }

  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, value);
  }
}
