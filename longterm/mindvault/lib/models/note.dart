/// Một ghi chú trong MindVault.
class Note {
  final String id;
  final String title;
  final String body;
  final List<String> tags;
  final DateTime updatedAt;

  const Note({
    required this.id,
    required this.title,
    required this.body,
    this.tags = const [],
    required this.updatedAt,
  });

  Note copyWith({
    String? title,
    String? body,
    List<String>? tags,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      tags: tags ?? this.tags,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'tags': tags,
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'] as String,
        title: (json['title'] ?? '') as String,
        body: (json['body'] ?? '') as String,
        tags: (json['tags'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  /// Khớp với chuỗi tìm kiếm (tiêu đề, nội dung, hoặc tag).
  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return title.toLowerCase().contains(q) ||
        body.toLowerCase().contains(q) ||
        tags.any((t) => t.toLowerCase().contains(q));
  }
}
