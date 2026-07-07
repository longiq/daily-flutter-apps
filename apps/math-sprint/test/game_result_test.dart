import 'package:flutter_test/flutter_test.dart';
import 'package:math_sprint/models/game_result.dart';

void main() {
  group('GameResult', () {
    test('toJson/fromJson giữ nguyên dữ liệu', () {
      final r = GameResult(
        modeId: 'mixed_medium',
        modeName: 'Hỗn hợp',
        score: 180,
        correct: 18,
        wrong: 3,
        bestCombo: 9,
        playedAt: DateTime(2026, 7, 1, 10, 30),
      );
      final back = GameResult.fromJson(r.toJson());
      expect(back.modeId, r.modeId);
      expect(back.score, r.score);
      expect(back.correct, r.correct);
      expect(back.wrong, r.wrong);
      expect(back.bestCombo, r.bestCombo);
      expect(back.playedAt, r.playedAt);
    });

    test('accuracy tính đúng', () {
      final r = GameResult(
        modeId: 'm',
        modeName: 'm',
        score: 0,
        correct: 8,
        wrong: 2,
        bestCombo: 0,
        playedAt: DateTime(2026, 1, 1),
      );
      expect(r.total, 10);
      expect(r.accuracy, closeTo(0.8, 1e-9));
    });

    test('accuracy = 0 khi chưa trả lời câu nào', () {
      final r = GameResult(
        modeId: 'm',
        modeName: 'm',
        score: 0,
        correct: 0,
        wrong: 0,
        bestCombo: 0,
        playedAt: DateTime(2026, 1, 1),
      );
      expect(r.accuracy, 0);
    });
  });
}
