import 'package:flutter_test/flutter_test.dart';
import 'package:dream_oracle_ai/services/offline_interpreter.dart';

void main() {
  group('OfflineInterpreter', () {
    final interpreter = OfflineInterpreter();

    test('nhận diện biểu tượng khớp trong nội dung giấc mơ', () {
      final result = interpreter
          .interpret('Tôi mơ thấy một con rắn lớn bò qua dòng nước trong vắt.');
      expect(result.symbols, contains('rắn'));
      expect(result.symbols, contains('nước'));
      expect(result.text, contains('rắn'));
    });

    test('không phân biệt hoa/thường khi khớp từ khóa', () {
      final result = interpreter.interpret('Tôi thấy mình đang BAY trên bầu trời.');
      expect(result.symbols, contains('bay'));
    });

    test('trả về thông báo mặc định khi không có biểu tượng nào khớp', () {
      final result = interpreter.interpret('xyz abc không liên quan gì cả');
      expect(result.symbols, isEmpty);
      expect(result.text, isNotEmpty);
    });
  });
}
