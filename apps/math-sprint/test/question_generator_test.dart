import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:math_sprint/models/game_mode.dart';
import 'package:math_sprint/services/question_generator.dart';

void main() {
  group('QuestionGenerator', () {
    final gen = QuestionGenerator(Random(42));

    test('đáp án cộng luôn đúng và có 4 lựa chọn không trùng', () {
      const mode = GameMode(
        id: 't',
        name: 't',
        description: '',
        operations: [Operation.add],
        difficulty: Difficulty.easy,
      );
      for (var i = 0; i < 200; i++) {
        final q = gen.next(mode);
        expect(q.answer, q.left + q.right);
        expect(q.options.length, 4);
        expect(q.options.toSet().length, 4, reason: 'không được trùng');
        expect(q.options.contains(q.answer), isTrue);
      }
    });

    test('phép trừ không cho kết quả âm', () {
      const mode = GameMode(
        id: 't',
        name: 't',
        description: '',
        operations: [Operation.subtract],
        difficulty: Difficulty.medium,
      );
      for (var i = 0; i < 200; i++) {
        final q = gen.next(mode);
        expect(q.answer >= 0, isTrue);
        expect(q.answer, q.left - q.right);
      }
    });

    test('phép chia luôn chia hết', () {
      const mode = GameMode(
        id: 't',
        name: 't',
        description: '',
        operations: [Operation.divide],
        difficulty: Difficulty.hard,
      );
      for (var i = 0; i < 200; i++) {
        final q = gen.next(mode);
        expect(q.right != 0, isTrue);
        expect(q.left % q.right, 0);
        expect(q.answer, q.left ~/ q.right);
      }
    });
  });
}
