import 'package:flutter_test/flutter_test.dart';
import 'package:dream_oracle_ai/data/symbol_dictionary_data.dart';

void main() {
  group('SymbolDictionaryData', () {
    test('match tìm đúng biểu tượng xuất hiện trong văn bản', () {
      final results = SymbolDictionaryData.match('Đêm qua tôi mơ thấy lửa cháy khắp nhà.');
      final keywords = results.map((s) => s.keyword).toList();
      expect(keywords, contains('lửa'));
      expect(keywords, contains('nhà'));
    });

    test('match trả về rỗng khi không có biểu tượng nào khớp', () {
      final results = SymbolDictionaryData.match('không có gì đặc biệt xảy ra');
      expect(results, isEmpty);
    });

    test('search theo từ khóa rỗng trả về toàn bộ danh sách', () {
      expect(SymbolDictionaryData.search('').length, SymbolDictionaryData.all.length);
    });

    test('search lọc theo category', () {
      final results = SymbolDictionaryData.search('Động vật');
      expect(results, isNotEmpty);
      expect(results.every((s) => s.category == 'Động vật'), isTrue);
    });
  });
}
