import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dream_oracle_ai/providers/dream_provider.dart';

Future<void> _flush() => Future<void>.delayed(Duration.zero);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('DreamProvider', () {
    test('addDream thêm giấc mơ mới vào đầu danh sách', () async {
      final provider = DreamProvider();
      await _flush();

      await provider.addDream(
        title: 'Giấc mơ 1',
        content: 'Nội dung 1',
        moodEmoji: '😊',
      );
      await provider.addDream(
        title: 'Giấc mơ 2',
        content: 'Nội dung 2',
        moodEmoji: '😨',
      );

      expect(provider.dreams.length, 2);
      expect(provider.dreams.first.title, 'Giấc mơ 2');
    });

    test('deleteDream xóa đúng giấc mơ theo id', () async {
      final provider = DreamProvider();
      await _flush();

      final entry = await provider.addDream(
        title: 'Sẽ bị xóa',
        content: 'Nội dung',
        moodEmoji: '😐',
      );
      expect(provider.dreams.length, 1);

      await provider.deleteDream(entry.id);
      expect(provider.dreams, isEmpty);
    });

    test('findById trả về null khi không tồn tại', () async {
      final provider = DreamProvider();
      await _flush();
      expect(provider.findById('khong-ton-tai'), isNull);
    });

    test('currentStreak = 0 khi chưa có giấc mơ nào', () async {
      final provider = DreamProvider();
      await _flush();
      expect(provider.currentStreak, 0);
    });
  });
}
