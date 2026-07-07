import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';
import '../models/match_record.dart';

/// Lớp bọc shared_preferences: lưu cài đặt + lịch sử ván đấu.
class StorageService {
  static const _settingsKey = 'co_caro_ai.settings';
  static const _historyKey = 'co_caro_ai.history';
  static const _maxHistory = 50;

  Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_settingsKey);
    if (raw == null) return const AppSettings();
    try {
      return AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const AppSettings();
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  Future<List<MatchRecord>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_historyKey);
    if (raw == null) return [];
    return raw
        .map((s) {
          try {
            return MatchRecord.fromJson(jsonDecode(s) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<MatchRecord>()
        .toList();
  }

  Future<void> addMatchRecord(MatchRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await loadHistory();
    current.insert(0, record);
    final trimmed = current.take(_maxHistory).toList();
    final encoded = trimmed.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList(_historyKey, encoded);
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}
