import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

/// Lưu trữ ghi chú bằng shared_preferences (JSON). Là ChangeNotifier để
/// UI tự rebuild khi dữ liệu đổi (dùng với provider).
class NoteRepository extends ChangeNotifier {
  static const _key = 'mindvault_notes_v1';

  final List<Note> _notes = [];
  List<Note> get notes =>
      List.unmodifiable(_notes..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)));

  /// Đọc dữ liệu đã lưu khi app khởi động.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    _notes.clear();
    if (raw != null && raw.isNotEmpty) {
      final list = jsonDecode(raw) as List<dynamic>;
      _notes.addAll(
          list.map((e) => Note.fromJson(e as Map<String, dynamic>)));
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _key, jsonEncode(_notes.map((n) => n.toJson()).toList()));
  }

  /// Thêm mới hoặc cập nhật (theo id).
  Future<void> save(Note note) async {
    final i = _notes.indexWhere((n) => n.id == note.id);
    if (i >= 0) {
      _notes[i] = note;
    } else {
      _notes.add(note);
    }
    await _persist();
    notifyListeners();
  }

  Future<void> delete(String id) async {
    _notes.removeWhere((n) => n.id == id);
    await _persist();
    notifyListeners();
  }

  List<Note> search(String query) =>
      notes.where((n) => n.matches(query)).toList();

  /// Tạo id đơn giản theo thời gian (đủ dùng cho local, tránh thêm dependency).
  static String newId() =>
      DateTime.now().microsecondsSinceEpoch.toString();
}
