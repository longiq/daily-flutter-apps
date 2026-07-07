import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mindvault/models/note.dart';
import 'package:mindvault/services/ai_settings.dart';
import 'package:mindvault/services/note_repository.dart';
import 'package:mindvault/services/ollama_service.dart';
import 'package:mindvault/services/rag_service.dart';

void main() {
  late NoteRepository repo;
  late RagService rag;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repo = NoteRepository();
    await repo.load();
    await repo.save(Note(
      id: '1',
      title: 'Flutter Provider',
      body: 'Provider là state management đơn giản cho Flutter. '
          'Dùng ChangeNotifier để cập nhật UI khi dữ liệu đổi.',
      updatedAt: DateTime.now(),
    ));
    await repo.save(Note(
      id: '2',
      title: 'Công thức phở bò',
      body: 'Ninh xương bò 6 tiếng, nêm quế hồi thảo quả, ăn kèm rau thơm.',
      updatedAt: DateTime.now(),
    ));

    // Tắt AI để test ask() luôn đi qua nhánh offline fallback, ổn định
    // (không phụ thuộc việc máy chạy test có cài Ollama hay không).
    final settings = AiSettings();
    await settings.update(enabled: false);
    rag = RagService(repo: repo, ollama: OllamaService(settings: settings));
  });

  group('RagService.search', () {
    test('tìm đúng ghi chú liên quan theo nội dung', () {
      final results = rag.search('state management Flutter');
      expect(results, isNotEmpty);
      expect(results.first.chunk.noteTitle, 'Flutter Provider');
    });

    test('không khớp từ nào thì trả về danh sách rỗng', () {
      final results = rag.search('xyz không tồn tại zzz');
      expect(results, isEmpty);
    });

    test('vault rỗng thì search luôn trả rỗng', () async {
      final emptySettings = AiSettings();
      final emptyRepo = NoteRepository();
      await emptyRepo.load();
      final emptyRag = RagService(
          repo: emptyRepo, ollama: OllamaService(settings: emptySettings));
      expect(emptyRag.search('bất kỳ'), isEmpty);
    });
  });

  group('RagService.ask (AI tắt -> luôn offline fallback)', () {
    test('trả lời offline kèm nguồn khi tìm thấy ghi chú liên quan', () async {
      final result = await rag.ask('cách nấu phở');
      expect(result.fromOllama, isFalse);
      expect(result.sources, isNotEmpty);
      expect(result.sources.first.chunk.noteTitle, 'Công thức phở bò');
    });

    test('không tìm thấy gì liên quan thì báo rõ, không có nguồn', () async {
      final result = await rag.ask('lượng tử vật lý thiên hà');
      expect(result.sources, isEmpty);
      expect(result.answer, contains('chưa có'));
    });
  });
}
