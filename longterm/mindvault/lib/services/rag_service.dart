import 'dart:math';
import '../models/chunk.dart';
import 'note_repository.dart';
import 'offline_ai.dart';
import 'ollama_service.dart';
import 'text_utils.dart';

/// Kết quả trả lời cho màn "Hỏi vault của bạn".
class AskResult {
  final String answer;
  final List<ScoredChunk> sources;
  final bool fromOllama;

  const AskResult({
    required this.answer,
    required this.sources,
    required this.fromOllama,
  });
}

/// Mini-RAG chạy hoàn toàn local: chia ghi chú thành đoạn nhỏ, tìm đoạn
/// liên quan bằng term-frequency + cosine similarity (không cần embedding
/// model, không cần mạng), rồi nếu có Ollama thì sinh câu trả lời từ ngữ
/// cảnh đó — nếu không có Ollama thì fallback [OfflineAi.answer].
class RagService {
  final NoteRepository repo;
  final OllamaService ollama;

  RagService({required this.repo, required this.ollama});

  static const _chunkSize = 240;
  static const _topK = 3;

  List<NoteChunk> _buildChunks() {
    final chunks = <NoteChunk>[];
    for (final note in repo.notes) {
      final text = '${note.title}\n${note.body}'.trim();
      if (text.isEmpty) continue;
      for (final piece in _splitIntoChunks(text, _chunkSize)) {
        chunks.add(
            NoteChunk(noteId: note.id, noteTitle: note.title, text: piece));
      }
    }
    return chunks;
  }

  /// Gom câu lại thành đoạn khoảng [size] ký tự, không cắt giữa câu.
  static List<String> _splitIntoChunks(String text, int size) {
    final sentences = TextUtils.splitSentences(text);
    final chunks = <String>[];
    final buf = StringBuffer();
    for (final s in sentences) {
      if (buf.length + s.length > size && buf.isNotEmpty) {
        chunks.add(buf.toString().trim());
        buf.clear();
      }
      buf.write('$s ');
    }
    if (buf.isNotEmpty) chunks.add(buf.toString().trim());
    return chunks.where((c) => c.isNotEmpty).toList();
  }

  static double _cosine(Map<String, int> a, Map<String, int> b) {
    final keys = {...a.keys, ...b.keys};
    double dot = 0, na = 0, nb = 0;
    for (final k in keys) {
      final va = (a[k] ?? 0).toDouble();
      final vb = (b[k] ?? 0).toDouble();
      dot += va * vb;
      na += va * va;
      nb += vb * vb;
    }
    if (na == 0 || nb == 0) return 0;
    return dot / (sqrt(na) * sqrt(nb));
  }

  /// Tìm top-k đoạn liên quan nhất tới [query] trong toàn bộ vault.
  List<ScoredChunk> search(String query, {int topK = _topK}) {
    final chunks = _buildChunks();
    if (chunks.isEmpty) return [];
    final qTf = TextUtils.termFrequency(query);
    final scored = chunks
        .map((c) =>
            ScoredChunk(c, _cosine(qTf, TextUtils.termFrequency(c.text))))
        .where((s) => s.score > 0)
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    return scored.take(topK).toList();
  }

  /// Hỏi-đáp trên vault: tìm ngữ cảnh liên quan rồi sinh câu trả lời
  /// (Ollama nếu có, offline fallback nếu không).
  Future<AskResult> ask(String question) async {
    final results = search(question);
    if (results.isEmpty) {
      return const AskResult(
        answer: 'Vault chưa có ghi chú nào liên quan tới câu hỏi này.',
        sources: [],
        fromOllama: false,
      );
    }
    final contextTexts = results.map((r) => r.chunk.text).toList();
    if (await ollama.isAvailable()) {
      final res = await ollama.answerWithContext(question, contextTexts);
      if (res.fromOllama) {
        return AskResult(answer: res.text, sources: results, fromOllama: true);
      }
    }
    return AskResult(
      answer: OfflineAi.answer(question, contextTexts),
      sources: results,
      fromOllama: false,
    );
  }
}
