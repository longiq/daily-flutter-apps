import 'dart:convert';
import 'package:http/http.dart' as http;

/// Gọi Ollama local để AI phân tích chi tiêu và gợi ý tiết kiệm.
///
/// Cắm Ollama:
///   1) Cài Ollama: https://ollama.com  -> `ollama pull llama3.2`
///   2) Chạy: `ollama serve` (mặc định http://localhost:11434)
///   3) Trên Android emulator dùng host 10.0.2.2 thay cho localhost.
///
/// Nếu gọi lỗi (không mạng, chưa bật Ollama, timeout...), service này
/// KHÔNG throw ra ngoài — trả về null để nơi gọi tự fallback sang
/// [OfflineInsights], đảm bảo app luôn hoạt động được kể cả offline.
class OllamaService {
  final String baseUrl;
  final String model;

  OllamaService({
    this.baseUrl = 'http://localhost:11434',
    this.model = 'llama3.2',
  });

  /// [summary] là bản tóm tắt số liệu chi tiêu tháng (đã tính sẵn ở
  /// OfflineInsights/TransactionProvider) để AI phân tích và đưa lời khuyên.
  Future<String?> analyzeSpending(String summary) async {
    try {
      final prompt = '''
Bạn là một cố vấn tài chính cá nhân am hiểu, nói tiếng Việt, giọng điệu thân
thiện và thực tế (không giáo điều).
Dưới đây là số liệu thu chi tháng này của người dùng:

$summary

Hãy:
1) Nhận xét ngắn gọn về tình hình chi tiêu (danh mục nào đáng chú ý).
2) Đưa ra đúng 3 gợi ý tiết kiệm cụ thể, khả thi, dựa trên số liệu trên.
3) Kết thúc bằng 1 câu động viên ngắn.
Trả lời bằng tiếng Việt, súc tích, dưới 180 từ, không dùng markdown, không
dùng gạch đầu dòng ký hiệu đặc biệt (dùng số 1. 2. 3. bình thường).
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
