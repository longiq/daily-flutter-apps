// TEMPLATE — copy file này vào lib/services/cloud_ai_service.dart của app
// Flutter cần dùng, rồi chỉnh chỗ có [CHỈNH_Ở_ĐÂY]. File này KHÔNG tự chạy —
// nó chỉ là bản mẫu dùng chung cho mọi app AI.
//
// Gọi tới backend proxy (xem ../ai-proxy/) thay vì gọi thẳng Gemini API, để
// API key thật không bị nhúng vào app build ra.
//
// Cần thêm dependency (đã có sẵn ở hầu hết app AI hiện tại): http: ^1.2.1

import 'dart:convert';
import 'package:http/http.dart' as http;

/// Gọi AI qua backend proxy chung (deploy trên Render) — đây là lớp AI
/// "chính", ưu tiên dùng trước vì không cần người dùng tự cài gì cả, chạy
/// được ở bất kỳ đâu có mạng (kể cả khi không có Ollama/máy tính bật).
///
/// KHÔNG throw ra ngoài khi lỗi — trả về null để nơi gọi tự fallback sang
/// OllamaService (nếu có) rồi tới offline rule-based, đúng pattern 3 lớp
/// đã dùng trong các app khác (OllamaService + Offline*).
class CloudAiService {
  /// URL của ai-proxy trên Render, vd: https://ai-proxy-xxxx.onrender.com
  /// [CHỈNH_Ở_ĐÂY] — thay bằng URL thật sau khi deploy (Bước 3 trong
  /// ../ai-proxy/README.md). Có thể đưa vào SettingsProvider để người dùng
  /// tự đổi được (giống ollamaHost hiện tại), thay vì hard-code.
  final String baseUrl;

  /// Khớp với PROXY_SECRET đã set trên Render. Để '' nếu proxy không bật
  /// kiểm tra secret.
  final String proxyKey;

  CloudAiService({
    required this.baseUrl,
    this.proxyKey = '',
  });

  /// Sinh text từ [prompt]. Trả về null nếu lỗi mạng, hết quota, proxy
  /// chưa "thức" kịp (Render free tier ngủ sau ~15 phút không dùng), v.v.
  Future<String?> generate(
    String prompt, {
    double temperature = 0.7,
    int maxOutputTokens = 800,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/api/generate'),
            headers: {
              'Content-Type': 'application/json',
              if (proxyKey.isNotEmpty) 'x-proxy-key': proxyKey,
            },
            body: jsonEncode({
              'prompt': prompt,
              'temperature': temperature,
              'maxOutputTokens': maxOutputTokens,
            }),
          )
          // Render free tier có thể "đánh thức" mất ~30-50s nếu đang ngủ —
          // để timeout dài hơn OllamaService bình thường (thường 45s).
          .timeout(const Duration(seconds: 60));

      if (res.statusCode != 200) return null;

      final body = jsonDecode(utf8.decode(res.bodyBytes));
      final text = (body['text'] ?? '').toString().trim();
      return text.isEmpty ? null : text;
    } catch (_) {
      return null;
    }
  }

  /// Kiểm tra proxy có sống không (dùng ở màn Cài đặt, giống
  /// OllamaService.testConnection).
  Future<bool> testConnection() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 60));
      if (res.statusCode != 200) return false;
      final body = jsonDecode(utf8.decode(res.bodyBytes));
      return body['hasApiKey'] == true;
    } catch (_) {
      return false;
    }
  }
}
