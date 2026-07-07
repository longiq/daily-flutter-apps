import 'ollama_service.dart';
import 'stopwords_vi.dart';
import 'text_utils.dart';

/// Gợi ý tag tự động cho ghi chú. Hai chế độ:
/// - [ollamaSuggest]: nhờ Ollama sinh 3-5 tag ngắn gọn (cần mạng/model).
/// - [offlineSuggest]: chạy hoàn toàn local, không cần mạng — kết hợp một
///   từ điển chủ đề nhỏ (category dictionary) với trích từ khóa theo tần
///   suất, cùng cách tiếp cận "không cần AI" như [OfflineAi].
class AutoTagger {
  /// Từ khóa → tag chủ đề. Chỉ cần một từ khóa xuất hiện trong ghi chú là
  /// tag tương ứng được đề xuất. Dùng để bắt các chủ đề thường gặp trong
  /// ghi chú cá nhân mà đếm tần suất từ đơn thuần khó nhận ra.
  static const Map<String, String> _categoryKeywords = {
    'họp': 'công-việc',
    'deadline': 'công-việc',
    'dự án': 'công-việc',
    'sếp': 'công-việc',
    'công ty': 'công-việc',
    'báo cáo': 'công-việc',
    'code': 'lập-trình',
    'lập trình': 'lập-trình',
    'flutter': 'lập-trình',
    'bug': 'lập-trình',
    'app': 'lập-trình',
    'học': 'học-tập',
    'bài tập': 'học-tập',
    'thi': 'học-tập',
    'khóa học': 'học-tập',
    'sách': 'sách',
    'đọc': 'sách',
    'tiền': 'tài-chính',
    'chi tiêu': 'tài-chính',
    'lương': 'tài-chính',
    'tiết kiệm': 'tài-chính',
    'đầu tư': 'tài-chính',
    'mua': 'mua-sắm',
    'chợ': 'mua-sắm',
    'siêu thị': 'mua-sắm',
    'sức khỏe': 'sức-khỏe',
    'bác sĩ': 'sức-khỏe',
    'tập gym': 'sức-khỏe',
    'ngủ': 'sức-khỏe',
    'ăn': 'ẩm-thực',
    'nấu': 'ẩm-thực',
    'món': 'ẩm-thực',
    'du lịch': 'du-lịch',
    'chuyến đi': 'du-lịch',
    'vé máy bay': 'du-lịch',
    'gia đình': 'gia-đình',
    'bố mẹ': 'gia-đình',
    'con': 'gia-đình',
    'ý tưởng': 'ý-tưởng',
    'phim': 'giải-trí',
    'nhạc': 'giải-trí',
    'game': 'giải-trí',
  };

  /// Gợi ý tag offline: không cần mạng, không cần model AI.
  /// Kết hợp từ điển chủ đề + top từ khóa xuất hiện nhiều nhất.
  static List<String> offlineSuggest(
    String title,
    String body, {
    List<String> existingTags = const [],
    int maxTags = 5,
  }) {
    final text = '$title $body'.toLowerCase();
    final existing = existingTags.map((t) => t.toLowerCase()).toSet();
    final suggestions = <String>[];

    // 1) Khớp từ điển chủ đề trước (chất lượng cao hơn tần suất thuần túy).
    for (final entry in _categoryKeywords.entries) {
      if (text.contains(entry.key)) {
        final tag = entry.value;
        if (!existing.contains(tag) && !suggestions.contains(tag)) {
          suggestions.add(tag);
        }
      }
      if (suggestions.length >= maxTags) break;
    }

    // 2) Bổ sung bằng từ khóa tần suất cao nếu chưa đủ maxTags.
    if (suggestions.length < maxTags) {
      final freq = TextUtils.termFrequency('$title $title $body');
      final candidates = freq.entries
          .where((e) =>
              e.key.length >= 3 &&
              !StopwordsVi.isStopword(e.key) &&
              !existing.contains(e.key) &&
              !suggestions.contains(e.key))
          .toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      for (final c in candidates) {
        if (suggestions.length >= maxTags) break;
        suggestions.add(c.key);
      }
    }

    return suggestions.take(maxTags).toList();
  }

  /// Nhờ Ollama sinh tag; trả AiResult thô (chưa parse) để nơi gọi tự
  /// quyết định fallback offline khi `fromOllama == false`.
  static Future<AiResult> ollamaSuggest(
      OllamaService ollama, String title, String body) {
    final prompt =
        'Đọc ghi chú sau và đề xuất 3-5 tag ngắn gọn (1-2 từ mỗi tag, '
        'tiếng Việt không dấu cách dùng gạch nối, không giải thích thêm). '
        'Chỉ trả về danh sách tag cách nhau bằng dấu phẩy, không có gì khác.\n'
        'Tiêu đề: $title\nNội dung:\n$body';
    return ollama.generate(prompt);
  }

  /// Parse chuỗi trả lời từ Ollama thành danh sách tag sạch: cắt theo dấu
  /// phẩy/xuống dòng, bỏ khoảng trắng/dấu câu thừa, giới hạn độ dài và số
  /// lượng. Ollama đôi khi trả về câu văn thay vì chỉ danh sách — hàm này
  /// cố gắng khoan dung với định dạng lộn xộn đó.
  static List<String> parseTagsResponse(String text, {int maxTags = 5}) {
    final raw = text.split(RegExp(r'[,\n]'));
    final tags = <String>[];
    for (var t in raw) {
      var tag = t
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'^[\-\*\d\.\)\s]+'), '') // bỏ "- ", "1. "...
          .replaceAll(RegExp(r'[.!?:;]+$'), '') // bỏ dấu câu cuối
          .trim();
      if (tag.isEmpty || tag.length > 30) continue;
      // Loại các câu dài dòng nhiều từ (thường là Ollama giải thích thay vì
      // trả tag thực sự) — tag hợp lệ tối đa ~4 từ.
      if (tag.split(RegExp(r'\s+')).length > 4) continue;
      if (!tags.contains(tag)) tags.add(tag);
      if (tags.length >= maxTags) break;
    }
    return tags;
  }
}
