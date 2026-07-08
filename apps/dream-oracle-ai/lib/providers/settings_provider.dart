import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cấu hình AI (Cloud proxy + Ollama) + giao diện, lưu lại giữa các lần mở app.
class SettingsProvider extends ChangeNotifier {
  static const _keyHost = 'dream_oracle.settings.host';
  static const _keyModel = 'dream_oracle.settings.model';
  static const _keyOffline = 'dream_oracle.settings.forceOffline';
  static const _keyDarkMode = 'dream_oracle.settings.darkMode';
  static const _keyCloudUrl = 'dream_oracle.settings.cloudUrl';
  static const _keyCloudKey = 'dream_oracle.settings.cloudKey';
  static const _keyUseCloud = 'dream_oracle.settings.useCloud';

  String _host = 'http://localhost:11434';
  String _model = 'llama3.2';
  bool _forceOffline = false;
  bool _darkMode = false;
  bool _loaded = false;

  // ai-proxy đã deploy trên Render (xem PROJECT_NOTES.md) — dùng làm lớp AI
  // chính, không cần người dùng thật cài Ollama.
  String _cloudUrl = 'https://ai-proxy-2f7q.onrender.com';
  String _cloudKey = '8e34b4144c818525228575f447ece54d';
  bool _useCloud = true;

  String get host => _host;
  String get model => _model;
  bool get forceOffline => _forceOffline;
  bool get darkMode => _darkMode;
  bool get loaded => _loaded;
  String get cloudUrl => _cloudUrl;
  String get cloudKey => _cloudKey;
  bool get useCloud => _useCloud;

  SettingsProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _host = prefs.getString(_keyHost) ?? _host;
    _model = prefs.getString(_keyModel) ?? _model;
    _forceOffline = prefs.getBool(_keyOffline) ?? false;
    _darkMode = prefs.getBool(_keyDarkMode) ?? false;
    _cloudUrl = prefs.getString(_keyCloudUrl) ?? _cloudUrl;
    _cloudKey = prefs.getString(_keyCloudKey) ?? _cloudKey;
    _useCloud = prefs.getBool(_keyUseCloud) ?? _useCloud;
    _loaded = true;
    notifyListeners();
  }

  Future<void> setCloudConfig({
    required String url,
    required String key,
    required bool enabled,
  }) async {
    _cloudUrl = url.trim().isEmpty ? _cloudUrl : url.trim();
    _cloudKey = key.trim();
    _useCloud = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCloudUrl, _cloudUrl);
    await prefs.setString(_keyCloudKey, _cloudKey);
    await prefs.setBool(_keyUseCloud, _useCloud);
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
