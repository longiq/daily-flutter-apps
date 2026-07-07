import 'game_mode.dart';

/// Một câu hỏi toán với 4 đáp án lựa chọn.
class Question {
  final int left;
  final int right;
  final Operation operation;
  final int answer;
  final List<int> options;

  const Question({
    required this.left,
    required this.right,
    required this.operation,
    required this.answer,
    required this.options,
  });

  String get prompt => '$left ${operation.symbol} $right';

  bool isCorrect(int choice) => choice == answer;
}
