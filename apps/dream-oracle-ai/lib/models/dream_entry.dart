/// Một mục nhật ký giấc mơ.
class DreamEntry {
  final String id;
  final String title;
  final String content;
  final String moodEmoji;
  final List<String> tags;
  final DateTime createdAt;
  final String? interpretation;
  final List<String> matchedSymbols;
  final bool interpretedByAi;

  DreamEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.moodEmoji,
    required this.tags,
    required this.createdAt,
    this.interpretation,
    this.matchedSymbols = const [],
    this.interpretedByAi = false,
  });

  DreamEntry copyWith({
    String? title,
    String? content,
    String? moodEmoji,
    List<String>? tags,
    String? interpretation,
    List<String>? matchedSymbols,
    bool? interpretedByAi,
  }) {
    return DreamEntry(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      moodEmoji: moodEmoji ?? this.moodEmoji,
      tags: tags ?? this.tags,
      createdAt: createdAt,
      interpretation: interpretation ?? this.interpretation,
      matchedSymbols: matchedSymbols ?? this.matchedSymbols,
      interpretedByAi: interpretedByAi ?? this.interpretedByAi,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'moodEmoji': moodEmoji,
        'tags': tags,
        'createdAt': createdAt.toIso8601String(),
        'interpretation': interpretation,
        'matchedSymbols': matchedSymbols,
        'interpretedByAi': interpretedByAi,
      };

  factory DreamEntry.fromJson(Map<String, dynamic> json) {
    return DreamEntry(
      id: json['id'] as String,
      title: (json['title'] ?? '') as String,
      content: (json['content'] ?? '') as String,
      moodEmoji: (json['moodEmoji'] ?? '😐') as String,
      tags: (json['tags'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      interpretation: json['interpretation'] as String?,
      matchedSymbols: (json['matchedSymbols'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      interpretedByAi: (json['interpretedByAi'] ?? false) as bool,
    );
  }
}
