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

  /// Tìm kiếm theo [query], có thể kết hợp lọc theo [tags]: ghi chú chỉ
  /// khớp nếu chứa TẤT CẢ tag trong [tags] (AND) — dùng để thu hẹp dần khi
  /// người dùng chọn nhiều chip lọc cùng lúc. [tags] rỗng = không lọc.
  List<Note> search(String query, {Set<String> tags = const {}}) {
    return notes.where((n) {
      if (!n.matches(query)) return false;
      if (tags.isEmpty) return true;
      final noteTags = n.tags.toSet();
      return tags.every(noteTags.contains);
    }).toList();
  }

  /// Toàn bộ tag đang được dùng trong vault, không trùng lặp, sắp xếp A-Z.
  List<String> get allTags {
    final set = <String>{};
    for (final n in _notes) {
      set.addAll(n.tags);
    }
    final list = set.toList()..sort();
    return list;
  }

  /// Tạo id đơn giản theo thời gian (đủ dùng cho local, tránh thêm dependency).
  static String newId() =>
      DateTime.now().microsecondsSinceEpoch.toString();
}
