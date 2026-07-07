import 'package:flutter_test/flutter_test.dart';
import 'package:co_caro_ai/models/enums.dart';
import 'package:co_caro_ai/models/match_record.dart';

void main() {
  group('MatchRecord', () {
    test('toJson/fromJson round-trip giữ nguyên dữ liệu', () {
      final record = MatchRecord(
        playedAt: DateTime(2026, 7, 6, 10, 30),
        mode: GameMode.vsAi,
        difficulty: Difficulty.hard,
        boardSize: 15,
        movesCount: 42,
        result: GameStatus.blackWin,
      );

      final decoded = MatchRecord.fromJson(record.toJson());

      expect(decoded.mode, GameMode.vsAi);
      expect(decoded.difficulty, Difficulty.hard);
      expect(decoded.boardSize, 15);
      expect(decoded.movesCount, 42);
      expect(decoded.result, GameStatus.blackWin);
      expect(decoded.playedAt, record.playedAt);
    });

    test('playerWon chỉ đúng khi vsAi và blackWin', () {
      final win = MatchRecord(
        playedAt: DateTime.now(),
        mode: GameMode.vsAi,
        difficulty: Difficulty.easy,
        boardSize: 9,
        movesCount: 10,
        result: GameStatus.blackWin,
      );
      final loss = MatchRecord(
        playedAt: DateTime.now(),
        mode: GameMode.vsAi,
        difficulty: Difficulty.easy,
        boardSize: 9,
        movesCount: 10,
        result: GameStatus.whiteWin,
      );
      final vsPlayerWin = MatchRecord(
        playedAt: DateTime.now(),
        mode: GameMode.vsPlayer,
        difficulty: null,
        boardSize: 9,
        movesCount: 10,
        result: GameStatus.blackWin,
      );

      expect(win.playerWon, isTrue);
      expect(loss.playerWon, isFalse);
      expect(loss.playerLost, isTrue);
      // vsPlayer không tính playerWon/playerLost vì không có "AI" đối đầu.
      expect(vsPlayerWin.playerWon, isFalse);
    });

    test('fromJson xử lý difficulty null (chế độ 2 người)', () {
      final record = MatchRecord(
        playedAt: DateTime(2026, 1, 1),
        mode: GameMode.vsPlayer,
        difficulty: null,
        boardSize: 13,
        movesCount: 5,
        result: GameStatus.draw,
      );
      final decoded = MatchRecord.fromJson(record.toJson());
      expect(decoded.difficulty, isNull);
      expect(decoded.isDraw, isTrue);
    });
  });
}
