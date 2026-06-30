import 'package:flutter_test/flutter_test.dart';
import 'package:mindvault/models/note.dart';

void main() {
  group('Note', () {
    final note = Note(
      id: '1',
      title: 'Flutter',
      body: 'Học state management với Provider',
      tags: ['dev', 'flutter'],
      updatedAt: DateTime.parse('2026-06-30T06:00:00.000'),
    );

    test('toJson/fromJson round-trip giữ nguyên dữ liệu', () {
      final copy = Note.fromJson(note.toJson());
      expect(copy.id, note.id);
      expect(copy.title, note.title);
      expect(copy.body, note.body);
      expect(copy.tags, note.tags);
      expect(copy.updatedAt, note.updatedAt);
    });

    test('matches tìm theo tiêu đề, nội dung và tag', () {
      expect(note.matches('flutter'), isTrue); // tiêu đề + tag
      expect(note.matches('provider'), isTrue); // nội dung
      expect(note.matches('DEV'), isTrue); // tag, không phân biệt hoa thường
      expect(note.matches('python'), isFalse);
      expect(note.matches(''), isTrue); // rỗng = khớp tất cả
    });

    test('copyWith chỉ đổi field được truyền', () {
      final updated = note.copyWith(title: 'Dart');
      expect(updated.title, 'Dart');
      expect(updated.body, note.body);
      expect(updated.id, note.id);
    });
  });
}
