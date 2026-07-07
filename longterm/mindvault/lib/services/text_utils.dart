/// Các hàm xử lý văn bản dùng chung cho tóm tắt & tìm kiếm (không cần AI,
/// không cần mạng). Dùng chung bởi [OfflineAi] và [RagService].
class TextUtils {
  static final RegExp _letterOrDigit = RegExp(r'[\p{L}\p{N}]', unicode: true);

  /// Tách văn bản thành câu, dựa theo dấu ./!/?/xuống dòng.
  /// Không dùng lookbehind regex (Dart hỗ trợ hạn chế) — duyệt từng ký tự.
  static List<String> splitSentences(String text) {
    final result = <String>[];
    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      final ch = text[i];
      buffer.write(ch);
      if (ch == '.' || ch == '!' || ch == '?' || ch == '\n') {
        final s = buffer.toString().trim();
        if (s.isNotEmpty) result.add(s);
        buffer.clear();
      }
    }
    final rest = buffer.toString().trim();
    if (rest.isNotEmpty) result.add(rest);
    return result;
  }

  /// Tách thành các từ: bỏ dấu câu, chữ thường, bỏ từ ngắn hơn [minLength].
  static List<String> words(String text, {int minLength = 2}) {
    final buffer = StringBuffer();
    for (final rune in text.toLowerCase().runes) {
      final ch = String.fromCharCode(rune);
      buffer.write(_letterOrDigit.hasMatch(ch) ? ch : ' ');
    }
    return buffer
        .toString()
        .split(RegExp(r'\s+'))
        .where((w) => w.length >= minLength)
        .toList();
  }

  /// Đếm tần suất từng từ trong văn bản.
  static Map<String, int> termFrequency(String text, {int minLength = 2}) {
    final freq = <String, int>{};
    for (final w in words(text, minLength: minLength)) {
      freq[w] = (freq[w] ?? 0) + 1;
    }
    return freq;
  }
}
