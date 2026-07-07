import 'package:flutter_test/flutter_test.dart';
import 'package:math_sprint/models/achievement.dart';
import 'package:math_sprint/models/game_result.dart';
import 'package:math_sprint/services/achievement_service.dart';

void main() {
  final service = AchievementService();

  GameResult result({int score = 0, int correct = 0, int combo = 0}) =>
      GameResult(
        modeId: 'm',
        modeName: 'm',
        score: score,
        correct: correct,
        wrong: 0,
        bestCombo: combo,
        playedAt: DateTime(2026, 1, 1),
      );

  test('mở "first_game" sau ván đầu tiên', () {
    final stats = PlayerStats.fromHistory([result()]);
    final newly = service.evaluate(stats, {});
    expect(newly.any((a) => a.id == 'first_game'), isTrue);
  });

  test('không mở lại thành tích đã có', () {
    final stats = PlayerStats.fromHistory([result()]);
    final newly = service.evaluate(stats, {'first_game'});
    expect(newly.any((a) => a.id == 'first_game'), isFalse);
  });

  test('mở "score_200" khi đạt 200 điểm', () {
    final stats = PlayerStats.fromHistory([result(score: 220)]);
    expect(service.allUnlocked(stats).contains('score_200'), isTrue);
  });

  test('PlayerStats tổng hợp đúng nhiều ván', () {
    final stats = PlayerStats.fromHistory([
      result(score: 100, correct: 10, combo: 5),
      result(score: 250, correct: 20, combo: 12),
    ]);
    expect(stats.totalGames, 2);
    expect(stats.totalCorrect, 30);
    expect(stats.bestScore, 250);
    expect(stats.bestCombo, 12);
  });
}
