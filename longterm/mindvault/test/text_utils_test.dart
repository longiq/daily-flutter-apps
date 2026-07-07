import 'package:flutter_test/flutter_test.dart';
import 'package:mindvault/services/text_utils.dart';

void main() {
  group('TextUtils.splitSentences', () {
    test('tách câu theo dấu chấm/chấm hỏi/chấm than', () {
      final s = TextUtils.splitSentences('Câu một. Câu hai! Câu ba?');
      expect(s, ['Câu một.', 'Câu hai!', 'Câu ba?']);
    });

    test('văn bản không có dấu câu vẫn trả về 1 câu', () {
      expect(
          TextUtils.splitSentences('không có dấu câu'), ['không có dấu câu']);
    });
  });

  group('TextUtils.words / termFrequency', () {
    test('bỏ dấu câu, chữ thường, bỏ từ quá ngắn', () {
      final w = TextUtils.words('Xin chào, Flutter! Dart là 1 ngôn ngữ.');
      expect(w, contains('xin'));
      expect(w, contains('chào'));
      expect(w, contains('flutter'));
      expect(w, isNot(contains('1'))); // số đơn ký tự, bị lọc vì minLength 2
    });

    test('termFrequency đếm đúng số lần xuất hiện', () {
      final freq = TextUtils.termFrequency('mèo mèo chó mèo');
      expect(freq['mèo'], 3);
      expect(freq['chó'], 1);
    });
  });
}
