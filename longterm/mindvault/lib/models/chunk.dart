/// Một đoạn nhỏ trích từ ghi chú, dùng cho tìm kiếm ngữ nghĩa đơn giản
/// (mini-RAG) — không cần embedding model, chỉ cần term-frequency.
class NoteChunk {
  final String noteId;
  final String noteTitle;
  final String text;

  const NoteChunk({
    required this.noteId,
    required this.noteTitle,
    required this.text,
  });
}

/// Một đoạn liên quan tìm được, kèm điểm tương đồng (cosine similarity).
class ScoredChunk {
  final NoteChunk chunk;
  final double score;
  const ScoredChunk(this.chunk, this.score);
}
