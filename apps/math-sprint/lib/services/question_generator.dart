import 'dart:math';
import '../models/game_mode.dart';
import '../models/question.dart';

/// Sinh câu hỏi toán ngẫu nhiên theo chế độ. Hoàn toàn offline.
class QuestionGenerator {
  final Random _random;

  QuestionGenerator([Random? random]) : _random = random ?? Random();

  Question next(GameMode mode) {
    final op = mode.operations[_random.nextInt(mode.operations.length)];
    final maxN = mode.difficulty.maxOperand;
    late int left, right, answer;

    switch (op) {
      case Operation.add:
        left = _randInt(1, maxN);
        right = _randInt(1, maxN);
        answer = left + right;
        break;
      case Operation.subtract:
        left = _randInt(1, maxN);
        right = _randInt(1, left); // đảm bảo không âm
        answer = left - right;
        break;
      case Operation.multiply:
        final m = max(2, maxN ~/ 5);
        left = _randInt(2, m);
        right = _randInt(2, m);
        answer = left * right;
        break;
      case Operation.divide:
        final m = max(2, maxN ~/ 5);
        right = _randInt(2, m);
        answer = _randInt(2, m);
        left = right * answer; // chia hết
        break;
    }

    return Question(
      left: left,
      right: right,
      operation: op,
      answer: answer,
      options: _buildOptions(answer),
    );
  }

  int _randInt(int minInclusive, int maxInclusive) =>
      minInclusive + _random.nextInt(maxInclusive - minInclusive + 1);

  /// Tạo 4 đáp án gồm đáp án đúng và 3 đáp án nhiễu gần đúng, không trùng.
  List<int> _buildOptions(int answer) {
    final options = <int>{answer};
    var guard = 0;
    while (options.length < 4 && guard < 50) {
      guard++;
      final delta = _randInt(1, 6) * (_random.nextBool() ? 1 : -1);
      final candidate = answer + delta;
      if (candidate >= 0) options.add(candidate);
    }
    // Phòng trường hợp hiếm không đủ 4 đáp án.
    var filler = answer + 7;
    while (options.length < 4) {
      options.add(filler);
      filler++;
    }
    final list = options.toList()..shuffle(_random);
    return list;
  }
}
