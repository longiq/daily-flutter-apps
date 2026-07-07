import 'dart:convert';
import 'package:http/http.dart' as http;
import 'offline_interpreter.dart';

/// Gọi Ollama local để diễn giải giấc mơ bằng AI.
///
/// Cắm Ollama:
///   1) Cài Ollama: https://ollama.com  -> `ollama pull llama3.2`
///   2) Chạy: `ollama serve` (mặc định http://localhost:11434)
///   3) Trên Android emulator dùng host 10.0.2.2 thay cho localhost.
///
/// Nếu gọi lỗi (không mạng, chưa bật Ollama, timeout...), service này
/// KHÔNG throw ra ngoài — trả về null để nơi gọi tự fallback sang
/// [OfflineInterpreter], đảm bảo app luôn hoạt động được.
class OllamaService {
  final String baseUrl;
  final String model;

  OllamaService({
    this.baseUrl = 'http://localhost:11434',
    this.model = 'llama3.2',
  });

  /// Trả về text diễn giải hoặc null nếu gọi thất bại.
  Future<String?> interpretDream(String dreamContent) async {
    try {
      final prompt = '''
Bạn là một người diễn giải giấc mơ giàu kinh nghiệm, nói tiếng Việt, giọng
điệu ấm áp và gợi mở (không phán xét, không khẳng định tuyệt đối).
Hãy đọc giấc mơ dưới đây và:
1) Nêu 2-4 biểu tượng/chi tiết đáng chú ý nhất và ý nghĩa tâm lý phổ biến.
2) Đưa ra 1 nhận định tổng thể ngắn gọn về trạng thái cảm xúc/tâm lý có thể
   liên quan.
3) Kết thúc bằng 1 câu nhắc rằng đây chỉ mang tính tham khảo.
Trả lời bằng tiếng Việt, súc tích, dưới 200 từ, không dùng markdown.

Giấc mơ:
$dreamContent
''';

      final res = await http
          .post(
            Uri.parse('$baseUrl/api/generate'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'model': model,
              'prompt': prompt,
              'stream': false,
            }),
          )
          .timeout(const Duration(seconds: 45));

      if (res.statusCode != 200) return null;

      final body = jsonDecode(utf8.decode(res.bodyBytes));
      final text = (body['response'] ?? '').toString().trim();
      return text.isEmpty ? null : text;
    } catch (_) {
      return null;
    }
  }

  /// Kiểm tra Ollama có đang chạy và trả lời được không (dùng ở Cài đặt).
  Future<bool> testConnection() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/api/tags'))
          .timeout(const Duration(seconds: 5));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
