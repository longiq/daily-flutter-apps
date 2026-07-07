import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mindvault/models/note.dart';
import 'package:mindvault/services/note_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Note makeNote(String id, String title, List<String> tags) => Note(
        id: id,
        title: title,
        body: 'nội dung của $title',
        tags: tags,
        updatedAt: DateTime(2026, 7, 4),
      );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('NoteRepository.allTags', () {
    test('trả về tag không trùng lặp, sắp xếp A-Z', () async {
      final repo = NoteRepository();
      await repo.load();
      await repo.save(makeNote('1', 'Note A', ['flutter', 'dev']));
      await repo.save(makeNote('2', 'Note B', ['dev', 'ollama']));

      expect(repo.allTags, ['dev', 'flutter', 'ollama']);
    });

    test('vault rỗng trả về danh sách rỗng', () async {
      final repo = NoteRepository();
      await repo.load();
      expect(repo.allTags, isEmpty);
    });
  });

  group('NoteRepository.search với tags', () {
    late NoteRepository repo;

    setUp(() async {
      repo = NoteRepository();
      await repo.load();
      await repo.save(makeNote('1', 'Họp dự án', ['công-việc', 'flutter']));
      await repo.save(makeNote('2', 'Đọc sách', ['sách']));
      await repo.save(makeNote('3', 'Fix bug Flutter', ['công-việc', 'flutter', 'bug']));
    });

    test('tags rỗng = không lọc, trả toàn bộ khớp query', () {
      final result = repo.search('');
      expect(result.length, 3);
    });

    test('lọc theo 1 tag trả về đúng các note chứa tag đó', () {
      final result = repo.search('', tags: {'flutter'});
      expect(result.map((n) => n.id).toSet(), {'1', '3'});
    });

    test('lọc AND theo nhiều tag: note phải chứa tất cả tag', () {
      final result = repo.search('', tags: {'công-việc', 'bug'});
      expect(result.map((n) => n.id).toList(), ['3']);
    });

    test('kết hợp query + tags cùng lúc', () {
      final result = repo.search('họp', tags: {'flutter'});
      expect(result.map((n) => n.id).toList(), ['1']);
    });

    test('tag không tồn tại trả về danh sách rỗng', () {
      final result = repo.search('', tags: {'không-tồn-tại'});
      expect(result, isEmpty);
    });
  });
}
