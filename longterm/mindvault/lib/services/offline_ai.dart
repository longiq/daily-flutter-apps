import 'text_utils.dart';

/// Fallback AI khi không có/không kết nối được Ollama: dùng thuật toán
/// trích xuất đơn giản (không cần mạng, không cần model) để app luôn hữu
/// dụng ngay cả khi tắt Ollama hoặc offline hoàn toàn.
class OfflineAi {
  /// Tóm tắt bằng cách chọn ra các câu "quan trọng" nhất theo tần suất từ
  /// (câu chứa nhiều từ hay lặp lại trong toàn văn bản = câu chủ đề).
  static String summarize(String text, {int maxSentences = 2}) {
    final sentences = TextUtils.splitSentences(text);
    if (sentences.length <= maxSentences) return text.trim();

    final freq = TextUtils.termFrequency(text);
    final scored = sentences.map((s) {
      final words = TextUtils.words(s);
      final score = words.isEmpty
          ? 0.0
          : words.map((w) => freq[w] ?? 0).reduce((a, b) => a + b) /
              words.length;
      return MapEntry(s, score);
    }).toList();

    scored.sort((a, b) => b.value.compareTo(a.value));
    final top = scored.take(maxSentences).map((e) => e.key).toList();
    // Giữ lại thứ tự xuất hiện gốc cho tự nhiên hơn khi ghép lại.
    top.sort((a, b) => sentences.indexOf(a).compareTo(sentences.indexOf(b)));
    return top.join(' ').trim();
  }

  /// Trả lời đơn giản khi không có Ollama: tìm đoạn khớp nhiều từ khóa của
  /// câu hỏi nhất trong các đoạn ngữ cảnh đã tìm được (RAG).
  static String answer(String question, List<String> chunks) {
    if (chunks.isEmpty) {
      return 'Không tìm thấy nội dung liên quan trong ghi chú.';
    }
    final qWords = TextUtils.words(question).toSet();
    String best = chunks.first;
    int bestScore = -1;
    for (final c in chunks) {
      final cWords = TextUtils.words(c).toSet();
      final score = qWords.intersection(cWords).length;
      if (score > bestScore) {
        bestScore = score;
        best = c;
      }
    }
    return 'Không có Ollama nên đây là đoạn liên quan nhất tìm được:\n\n$best';
  }
}
