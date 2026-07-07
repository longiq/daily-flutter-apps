import 'package:flutter_test/flutter_test.dart';
import 'package:mindvault/services/auto_tagger.dart';

void main() {
  group('AutoTagger.offlineSuggest', () {
    test('nhận diện chủ đề công việc qua từ khóa "họp"/"deadline"', () {
      final tags = AutoTagger.offlineSuggest(
        'Họp với sếp',
        'Chuẩn bị báo cáo trước deadline thứ 6, bàn về dự án mới.',
      );
      expect(tags, contains('công-việc'));
    });

    test('nhận diện chủ đề lập trình qua từ khóa "flutter"/"bug"', () {
      final tags = AutoTagger.offlineSuggest(
        'Fix bug app',
        'Flutter bị lỗi khi build, cần code lại phần provider.',
      );
      expect(tags, contains('lập-trình'));
    });

    test('không đề xuất lại tag đã tồn tại', () {
      final tags = AutoTagger.offlineSuggest(
        'Họp dự án',
        'Bàn về deadline dự án với sếp.',
        existingTags: ['công-việc'],
      );
      expect(tags, isNot(contains('công-việc')));
    });

    test('giới hạn số lượng tag theo maxTags', () {
      final tags = AutoTagger.offlineSuggest(
        'Họp deadline dự án sếp công ty báo cáo',
        'code lập trình flutter bug app học bài tập thi khóa học sách đọc',
        maxTags: 3,
      );
      expect(tags.length, lessThanOrEqualTo(3));
    });

    test('văn bản không khớp từ điển vẫn trả về gợi ý từ tần suất từ', () {
      final tags = AutoTagger.offlineSuggest(
        'Ramen Tokyo',
        'Ramen Tokyo ngon tuyệt, quán ramen này nổi tiếng ở Tokyo.',
      );
      expect(tags, isNotEmpty);
    });
  });

  group('AutoTagger.parseTagsResponse', () {
    test('parse danh sách cách nhau bằng dấu phẩy', () {
      final tags = AutoTagger.parseTagsResponse('công-việc, họp, deadline');
      expect(tags, ['công-việc', 'họp', 'deadline']);
    });

    test('bỏ số thứ tự và dấu gạch đầu dòng', () {
      final tags =
          AutoTagger.parseTagsResponse('1. công-việc\n- họp\n* deadline');
      expect(tags, ['công-việc', 'họp', 'deadline']);
    });

    test('bỏ câu giải thích dài dòng, giữ tag ngắn hợp lệ', () {
      final tags = AutoTagger.parseTagsResponse(
          'Dựa trên nội dung ghi chú, đây là các tag phù hợp\ncông-việc, họp');
      expect(tags, contains('công-việc'));
      expect(tags, contains('họp'));
      expect(
          tags.any((t) => t.split(' ').length > 4),
          isFalse); // câu dài bị loại
    });

    test('giới hạn số tag theo maxTags và loại trùng lặp', () {
      final tags = AutoTagger.parseTagsResponse('a, b, a, c, d, e', maxTags: 3);
      expect(tags, ['a', 'b', 'c']);
    });
  });
}
