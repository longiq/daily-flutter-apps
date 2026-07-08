import 'dart:convert';
import 'package:http/http.dart' as http;
import 'cloud_ai_service.dart';
import 'models.dart';

/// Dịch vụ sinh flashcard. Thử Cloud AI (proxy, xem PROJECT_NOTES.md) trước,
/// rồi Ollama local, rồi fallback offline.
///
/// Cắm Ollama:
///   1) Cài Ollama: https://ollama.com  -> `ollama pull llama3.2`
///   2) Chạy: `ollama serve` (mặc định http://localhost:11434)
///   3) Trên Android emulator dùng host 10.0.2.2 thay cho localhost.
class AiService {
  /// localhost cho iOS sim / desktop; 10.0.2.2 cho Android emulator.
  final String baseUrl;
  final String model;
  final String cloudUrl;
  final String cloudKey;
  final bool useCloud;

  AiService({
    this.baseUrl = 'http://localhost:11434',
    this.model = 'llama3.2',
    // ai-proxy đã deploy trên Render (xem PROJECT_NOTES.md) — dùng làm lớp
    // AI chính, không cần người dùng thật cài Ollama.
    this.cloudUrl = 'https://ai-proxy-2f7q.onrender.com',
    this.cloudKey = '8e34b4144c818525228575f447ece54d',
    this.useCloud = true,
  });

  static String _buildPrompt(String text, int count) => '''
Bạn là trợ lý tạo flashcard học tập. Dựa vào nội dung dưới đây, tạo $count thẻ
gồm câu hỏi (q) và câu trả lời (a) ngắn gọn. Chỉ trả về JSON hợp lệ dạng:
[{"q":"...","a":"..."}]
Không thêm giải thích.

Nội dung:
$text
''';

  /// Sinh flashcard từ [text]: thử Cloud AI trước, rồi Ollama, rồi fallback
  /// offline nếu cả hai đều lỗi/không có mạng.
  Future<List<Flashcard>> generate(String text, {int count = 8}) async {
    if (useCloud && cloudUrl.isNotEmpty) {
      try {
        final cloud = CloudAiService(baseUrl: cloudUrl, proxyKey: cloudKey);
        final raw = await cloud.generate(_buildPrompt(text, count));
        if (raw != null) {
          final cards = _parseCards(raw);
          if (cards.isNotEmpty) return cards;
        }
      } catch (_) {
        // rơi xuống thử Ollama.
      }
    }
    try {
      return await _callOllama(text, count);
    } catch (_) {
      return _offlineFallback(text, count);
    }
  }

  Future<List<Flashcard>> _callOllama(String text, int count) async {
    final prompt = _buildPrompt(text, count);

    final res = await http
        .post(
          Uri.parse('$baseUrl/api/generate'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'model': model,
            'prompt': prompt,
            'stream': false,
            'format': 'json',
          }),
        )
        .timeout(const Duration(seconds: 60));

    if (res.statusCode != 200) {
      throw Exception('Ollama lỗi ${res.statusCode}');
    }

    final body = jsonDecode(utf8.decode(res.bodyBytes));
    final raw = (body['response'] ?? '').toString();
    return _parseCards(raw);
  }

  List<Flashcard> _parseCards(String raw) {
    // Tìm mảng JSON trong chuỗi trả về.
    final start = raw.indexOf('[');
    final end = raw.lastIndexOf(']');
    if (start == -1 || end == -1 || end <= start) {
      throw const FormatException('Không tìm thấy JSON');
    }
    final list = jsonDecode(raw.substring(start, end + 1)) as List<dynamic>;
    final cards = list
        .map((e) => Flashcard(
              question: (e['q'] ?? '').toString().trim(),
              answer: (e['a'] ?? '').toString().trim(),
            ))
        .where((c) => c.question.isNotEmpty && c.answer.isNotEmpty)
        .toList();
    if (cards.isEmpty) throw const FormatException('Rỗng');
    return cards;
  }

  /// Tạo thẻ offline: tách câu, biến mỗi câu thành 1 thẻ cloze đơn giản.
  /// Đảm bảo app dùng được ngay cả khi chưa cắm Ollama.
  List<Flashcard> _offlineFallback(String text, int count) {
    final sentences = text
        .split(RegExp(r'[.!?\n]'))
        .map((s) => s.trim())
        .where((s) => s.split(' ').length >= 4)
        .toList();

    final cards = <Flashcard>[];
    for (final s in sentences) {
      if (cards.length >= count) break;
      final words = s.split(' ');
      // Chọn từ dài nhất làm "ẩn số".
      var keyIdx = 0;
      for (var i = 0; i < words.length; i++) {
        if (words[i].length > words[keyIdx].length) keyIdx = i;
      }
      final answer = words[keyIdx];
      words[keyIdx] = '_____';
      cards.add(Flashcard(question: words.join(' '), answer: answer));
    }
    if (cards.isEmpty) {
      cards.add(Flashcard(
        question: 'Chưa có Ollama. Nhập đủ nội dung rồi thử lại.',
        answer: 'Xem README để cắm Ollama local.',
      ));
    }
    return cards;
  }
}
