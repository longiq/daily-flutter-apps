import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cấu hình kết nối Ollama, lưu local bằng shared_preferences.
/// Mặc định trỏ tới Ollama chạy trên máy (localhost) — đúng cho Mac mini M4
/// dùng Ollama local, không cần cấu hình gì thêm để chạy thử.
class AiSettings extends ChangeNotifier {
  static const _keyHost = 'mindvault_ollama_host';
  static const _keyModel = 'mindvault_ollama_model';
  static const _keyEnabled = 'mindvault_ai_enabled';

  static const defaultHost = 'http://localhost:11434';
  static const defaultModel = 'llama3.2';

  String _host = defaultHost;
  String _model = defaultModel;
  bool _enabled = true;

  String get host => _host;
  String get model => _model;
  bool get enabled => _enabled;

  /// Đọc cấu hình đã lưu (gọi khi app khởi động).
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _host = prefs.getString(_keyHost) ?? defaultHost;
    _model = prefs.getString(_keyModel) ?? defaultModel;
    _enabled = prefs.getBool(_keyEnabled) ?? true;
    notifyListeners();
  }

  /// Cập nhật một hoặc nhiều field, chỉ ghi field nào được truyền.
  Future<void> update({String? host, String? model, bool? enabled}) async {
    final prefs = await SharedPreferences.getInstance();
    if (host != null && host.trim().isNotEmpty) {
      _host = host.trim();
      await prefs.setString(_keyHost, _host);
    }
    if (model != null && model.trim().isNotEmpty) {
      _model = model.trim();
      await prefs.setString(_keyModel, _model);
    }
    if (enabled != null) {
      _enabled = enabled;
      await prefs.setBool(_keyEnabled, _enabled);
    }
    notifyListeners();
  }
}
