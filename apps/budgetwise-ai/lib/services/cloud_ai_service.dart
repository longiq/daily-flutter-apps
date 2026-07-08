import 'dart:convert';
import 'package:http/http.dart' as http;

/// Gọi AI qua backend proxy chung (ai-proxy, deploy trên Render) — lớp AI
/// "chính", ưu tiên dùng trước vì không cần người dùng tự cài gì cả, chạy
/// được ở bất kỳ đâu có mạng (kể cả khi không có Ollama/máy tính bật).
///
/// KHÔNG throw ra ngoài khi lỗi — trả về null để nơi gọi tự fallback sang
/// OllamaService rồi tới offline rule-based, đúng pattern 3 lớp.
class CloudAiService {
  /// URL của ai-proxy trên Render, vd: https://ai-proxy-xxxx.onrender.com
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
    int maxOutputTokens = 4096,
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

  /// Kiểm tra proxy có sống không (dùng ở màn Cài đặt).
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
