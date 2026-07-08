import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cấu hình app: theme, kết nối Ollama, trạng thái Premium (mô phỏng) và
/// bộ đếm lượt dùng AI miễn phí trong tháng.
class SettingsProvider extends ChangeNotifier {
  static const _kDarkMode = 'bw_dark_mode';
  static const _kOllamaHost = 'bw_ollama_host';
  static const _kOllamaModel = 'bw_ollama_model';
  static const _kOllamaEnabled = 'bw_ollama_enabled';
  static const _kPremium = 'bw_premium';
  static const _kAiUsesMonth = 'bw_ai_uses_month'; // "yyyy-MM:count"

  static const int freeAiLimitPerMonth = 3;

  bool darkMode = false;
  String ollamaHost = 'http://localhost:11434';
  String ollamaModel = 'llama3.2';
  bool ollamaEnabled = true;
  bool isPremium = false;
  String _aiUsesRaw = '';

  bool _loaded = false;
  bool get loaded => _loaded;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    darkMode = prefs.getBool(_kDarkMode) ?? false;
    ollamaHost = prefs.getString(_kOllamaHost) ?? ollamaHost;
    ollamaModel = prefs.getString(_kOllamaModel) ?? ollamaModel;
    ollamaEnabled = prefs.getBool(_kOllamaEnabled) ?? true;
    isPremium = prefs.getBool(_kPremium) ?? false;
    _aiUsesRaw = prefs.getString(_kAiUsesMonth) ?? '';
    _loaded = true;
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    darkMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDarkMode, value);
  }

  Future<void> setOllamaConfig({
    required String host,
    required String model,
    required bool enabled,
  }) async {
    ollamaHost = host;
    ollamaModel = model;
    ollamaEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kOllamaHost, host);
    await prefs.setString(_kOllamaModel, model);
    await prefs.setBool(_kOllamaEnabled, enabled);
  }

  Future<void> setPremium(bool value) async {
    isPremium = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPremium, value);
  }

  String _currentMonthKey() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}';
  }

  int get aiUsesThisMonth {
    final parts = _aiUsesRaw.split(':');
    if (parts.length != 2) return 0;
    if (parts[0] != _currentMonthKey()) return 0;
    return int.tryParse(parts[1]) ?? 0;
  }

  bool get canUseAi => isPremium || aiUsesThisMonth < freeAiLimitPerMonth;

  int get remainingFreeAi =>
      (freeAiLimitPerMonth - aiUsesThisMonth).clamp(0, freeAiLimitPerMonth);

  Future<void> recordAiUse() async {
    final count = aiUsesThisMonth + 1;
    _aiUsesRaw = '${_currentMonthKey()}:$count';
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAiUsesMonth, _aiUsesRaw);
  }
}
