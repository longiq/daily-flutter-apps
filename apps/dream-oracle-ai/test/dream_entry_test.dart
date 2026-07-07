import 'package:flutter_test/flutter_test.dart';
import 'package:dream_oracle_ai/models/dream_entry.dart';

void main() {
  group('DreamEntry', () {
    test('toJson/fromJson giữ nguyên dữ liệu', () {
      final entry = DreamEntry(
        id: '123',
        title: 'Bay qua thành phố',
        content: 'Tôi mơ thấy mình bay qua thành phố về đêm.',
        moodEmoji: '🤩',
        tags: const ['bay', 'đêm'],
        createdAt: DateTime(2026, 7, 3, 8, 0),
        interpretation: 'Khao khát tự do.',
        matchedSymbols: const ['bay'],
        interpretedByAi: true,
      );

      final back = DreamEntry.fromJson(entry.toJson());

      expect(back.id, entry.id);
      expect(back.title, entry.title);
      expect(back.content, entry.content);
      expect(back.moodEmoji, entry.moodEmoji);
      expect(back.tags, entry.tags);
      expect(back.createdAt, entry.createdAt);
      expect(back.interpretation, entry.interpretation);
      expect(back.matchedSymbols, entry.matchedSymbols);
      expect(back.interpretedByAi, entry.interpretedByAi);
    });

    test('fromJson dùng giá trị mặc định khi thiếu field', () {
      final back = DreamEntry.fromJson({'id': 'abc'});
      expect(back.id, 'abc');
      expect(back.title, '');
      expect(back.moodEmoji, '😐');
      expect(back.tags, isEmpty);
      expect(back.interpretation, isNull);
      expect(back.interpretedByAi, isFalse);
    });

    test('copyWith chỉ thay đổi field được truyền vào', () {
      final entry = DreamEntry(
        id: '1',
        title: 'A',
        content: 'B',
        moodEmoji: '😐',
        tags: const [],
        createdAt: DateTime(2026, 1, 1),
      );
      final updated = entry.copyWith(interpretation: 'Giải thích', interpretedByAi: true);
      expect(updated.id, entry.id);
      expect(updated.title, entry.title);
      expect(updated.interpretation, 'Giải thích');
      expect(updated.interpretedByAi, isTrue);
    });
  });
}
