import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_result.dart';

/// Lưu/đọc dữ liệu bền vững qua shared_preferences.
class StorageService {
  static const _kHistory = 'ms_history';
  static const _kDarkMode = 'ms_dark_mode';
  static const _kSound = 'ms_sound';
  static const _kUnlocked = 'ms_unlocked';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // ----- Lịch sử ván chơi -----
  List<GameResult> loadHistory() {
    final raw = _prefs.getStringList(_kHistory) ?? const [];
    final results = <GameResult>[];
    for (final item in raw) {
      try {
        results.add(GameResult.fromJson(
            jsonDecode(item) as Map<String, dynamic>));
      } catch (_) {
        // bỏ qua bản ghi hỏng
      }
    }
    return results;
  }

  Future<void> addResult(GameResult result, {int maxKept = 50}) async {
    final history = loadHistory()..insert(0, result);
    final trimmed = history.take(maxKept).toList();
    await _prefs.setStringList(
      _kHistory,
      trimmed.map((r) => jsonEncode(r.toJson())).toList(),
    );
  }

  Future<void> clearHistory() async => _prefs.remove(_kHistory);

  // ----- Cài đặt -----
  bool get darkMode => _prefs.getBool(_kDarkMode) ?? false;
  Future<void> setDarkMode(bool v) => _prefs.setBool(_kDarkMode, v);

  bool get soundEnabled => _prefs.getBool(_kSound) ?? true;
  Future<void> setSoundEnabled(bool v) => _prefs.setBool(_kSound, v);

  // ----- Thành tích đã mở khoá -----
  Set<String> loadUnlocked() =>
      (_prefs.getStringList(_kUnlocked) ?? const []).toSet();

  Future<void> saveUnlocked(Set<String> ids) =>
      _prefs.setStringList(_kUnlocked, ids.toList());
}
