import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ai_settings.dart';

/// Kết quả gọi AI: có văn bản trả về hay không, kèm lý do lỗi (nếu có) để
/// nơi gọi tự quyết định dùng fallback offline. Không bao giờ throw ra UI.
class AiResult {
  final String text;
  final bool fromOllama;
  final String? error;

  const AiResult({required this.text, required this.fromOllama, this.error});
}

/// Gọi Ollama local qua REST API (http://host/api/generate, /api/tags).
/// Nếu không kết nối được (chưa cài Ollama, chưa bật, offline...) thì trả
/// lỗi trong [AiResult] để nơi gọi tự chuyển sang [OfflineAi] fallback.
class OllamaService {
  final http.Client _client;
  final AiSettings settings;
  static const _timeout = Duration(seconds: 20);
  static const _pingTimeout = Duration(seconds: 2);

  OllamaService({required this.settings, http.Client? client})
      : _client = client ?? http.Client();

  Uri _uri(String path) => Uri.parse('${settings.host}$path');

  /// Kiểm tra Ollama có đang chạy và có thể trả lời không (health check nhanh).
  Future<bool> isAvailable() async {
    if (!settings.enabled) return false;
    try {
      final res = await _client.get(_uri('/api/tags')).timeout(_pingTimeout);
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Gọi model sinh văn bản từ prompt qua /api/generate (non-stream).
  Future<AiResult> generate(String prompt) async {
    if (!settings.enabled) {
      return const AiResult(
        text: '',
        fromOllama: false,
        error: 'AI đang tắt trong Cài đặt',
      );
    }
    try {
      final res = await _client
          .post(
            _uri('/api/generate'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'model': settings.model,
              'prompt': prompt,
              'stream': false,
            }),
          )
          .timeout(_timeout);
      if (res.statusCode != 200) {
        return AiResult(
          text: '',
          fromOllama: false,
          error: 'Ollama lỗi HTTP ${res.statusCode}',
        );
      }
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final text = (data['response'] as String?)?.trim() ?? '';
      if (text.isEmpty) {
        return const AiResult(
          text: '',
          fromOllama: false,
          error: 'Ollama trả về nội dung rỗng',
        );
      }
      return AiResult(text: text, fromOllama: true);
    } catch (e) {
      return AiResult(
        text: '',
        fromOllama: false,
        error: 'Không kết nối được Ollama ($e)',
      );
    }
  }

  /// Tóm tắt một ghi chú (tiêu đề + nội dung).
  Future<AiResult> summarize(String title, String body) {
    final prompt = 'Tóm tắt ngắn gọn (2-3 câu, tiếng Việt) ghi chú sau.\n'
        'Tiêu đề: $title\nNội dung:\n$body';
    return generate(prompt);
  }

  /// Trả lời câu hỏi dựa trên các đoạn ghi chú liên quan đã tìm được (RAG).
  Future<AiResult> answerWithContext(
      String question, List<String> contextChunks) {
    final context = contextChunks
        .asMap()
        .entries
        .map((e) => '[${e.key + 1}] ${e.value}')
        .join('\n\n');
    final prompt =
        'Bạn là trợ lý trả lời dựa trên ghi chú cá nhân của người dùng.\n'
        'Chỉ dùng thông tin trong NGỮ CẢNH dưới đây; nếu không đủ thông tin '
        'thì nói rõ là không tìm thấy trong ghi chú. Trả lời ngắn gọn, '
        'tiếng Việt.\n\nNGỮ CẢNH:\n$context\n\nCÂU HỎI: $question';
    return generate(prompt);
  }

  void dispose() => _client.close();
}
