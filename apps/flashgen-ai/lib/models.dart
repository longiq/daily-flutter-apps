import 'dart:convert';

/// Một thẻ học gồm câu hỏi và câu trả lời.
class Flashcard {
  final String question;
  final String answer;

  Flashcard({required this.question, required this.answer});

  Map<String, dynamic> toJson() => {'q': question, 'a': answer};

  factory Flashcard.fromJson(Map<String, dynamic> j) =>
      Flashcard(question: j['q'] ?? '', answer: j['a'] ?? '');
}

/// Một bộ thẻ (deck) do người dùng tạo.
class Deck {
  final String id;
  String title;
  final List<Flashcard> cards;
  final DateTime createdAt;

  Deck({
    required this.id,
    required this.title,
    required this.cards,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'createdAt': createdAt.toIso8601String(),
        'cards': cards.map((c) => c.toJson()).toList(),
      };

  factory Deck.fromJson(Map<String, dynamic> j) => Deck(
        id: j['id'],
        title: j['title'] ?? 'Bộ thẻ',
        createdAt:
            DateTime.tryParse(j['createdAt'] ?? '') ?? DateTime.now(),
        cards: (j['cards'] as List<dynamic>? ?? [])
            .map((e) => Flashcard.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  static String encodeList(List<Deck> decks) =>
      jsonEncode(decks.map((d) => d.toJson()).toList());

  static List<Deck> decodeList(String raw) {
    final data = jsonDecode(raw) as List<dynamic>;
    return data.map((e) => Deck.fromJson(e as Map<String, dynamic>)).toList();
  }
}
