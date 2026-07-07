import '../data/symbol_dictionary_data.dart';
import '../models/symbol_meaning.dart';

/// Kết quả diễn giải: văn bản tổng hợp + danh sách biểu tượng khớp được.
class InterpretationResult {
  final String text;
  final List<String> symbols;

  const InterpretationResult({required this.text, required this.symbols});
}

/// Diễn giải giấc mơ offline dựa trên từ điển biểu tượng — dùng khi
/// không cắm được Ollama (không mạng / chưa cài / lỗi). Đảm bảo app luôn
/// trả lời được kết quả, không bao giờ "đứng hình".
class OfflineInterpreter {
  InterpretationResult interpret(String dreamContent) {
    final matches = SymbolDictionaryData.match(dreamContent);

    if (matches.isEmpty) {
      return const InterpretationResult(
        text:
            'Chưa tìm thấy biểu tượng quen thuộc trong giấc mơ này. Thử mô tả '
            'chi tiết hơn (địa điểm, nhân vật, cảm xúc khi tỉnh dậy) hoặc bật '
            'Ollama trong Cài đặt để có diễn giải AI sâu hơn.',
        symbols: [],
      );
    }

    final buffer = StringBuffer();
    buffer.writeln(
        'Dựa trên từ điển giấc mơ, mình nhận thấy ${matches.length} biểu tượng đáng chú ý:');
    for (final SymbolMeaning m in matches.take(5)) {
      buffer.writeln('\n• "${m.keyword}" (${m.category}): ${m.meaning}');
    }
    buffer.writeln(
        '\nLưu ý: đây là diễn giải mang tính tham khảo/giải trí dựa trên biểu '
        'tượng phổ biến, không thay thế phân tích tâm lý chuyên sâu.');

    return InterpretationResult(
      text: buffer.toString().trim(),
      symbols: matches.map((m) => m.keyword).toList(),
    );
  }
}
