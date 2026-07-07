import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dream_entry.dart';

/// Lưu trữ nhật ký giấc mơ local bằng SharedPreferences (JSON list).
class DreamRepository {
  static const _key = 'dream_oracle.dreams.v1';

  Future<List<DreamEntry>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final dreams = list
          .map((e) => DreamEntry.fromJson(e as Map<String, dynamic>))
          .toList();
      dreams.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return dreams;
    } catch (_) {
      return [];
    }
  }

  Future<void> saveAll(List<DreamEntry> dreams) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(dreams.map((d) => d.toJson()).toList());
    await prefs.setString(_key, raw);
  }
}
