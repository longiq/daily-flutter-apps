import 'package:flutter_test/flutter_test.dart';
import 'package:mindvault/services/offline_ai.dart';

void main() {
  group('OfflineAi.summarize', () {
    test('văn bản ngắn (ít hơn maxSentences) trả về nguyên văn', () {
      const text = 'Một câu ngắn.';
      expect(OfflineAi.summarize(text), text);
    });

    test('văn bản dài rút gọn còn ít câu hơn bản gốc', () {
      const text = 'Flutter là framework UI của Google. '
          'Nó dùng ngôn ngữ Dart. '
          'Provider giúp quản lý state đơn giản. '
          'Có thể build cả iOS và Android. '
          'Hot reload giúp phát triển nhanh hơn nhiều.';
      final summary = OfflineAi.summarize(text, maxSentences: 2);
      final originalSentences =
          text.split('.').where((s) => s.trim().isNotEmpty).length;
      final summarySentences =
          summary.split('.').where((s) => s.trim().isNotEmpty).length;
      expect(summarySentences, lessThan(originalSentences));
      expect(summary, isNotEmpty);
    });
  });

  group('OfflineAi.answer', () {
    test('chọn đoạn khớp nhiều từ khóa câu hỏi nhất', () {
      final chunks = [
        'Con mèo thích ngủ trên ghế sofa.',
        'Provider là cách quản lý state phổ biến trong Flutter.',
      ];
      final result =
          OfflineAi.answer('quản lý state Flutter provider', chunks);
      expect(result, contains('Provider là cách quản lý state'));
    });

    test('không có đoạn ngữ cảnh nào thì báo không tìm thấy', () {
      expect(
          OfflineAi.answer('câu hỏi bất kỳ', []), contains('Không tìm thấy'));
    });
  });
}
