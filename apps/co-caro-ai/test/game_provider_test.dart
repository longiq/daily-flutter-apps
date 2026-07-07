import 'package:flutter_test/flutter_test.dart';
import 'package:co_caro_ai/models/enums.dart';
import 'package:co_caro_ai/providers/game_provider.dart';

void main() {
  group('GameProvider (2 người chơi)', () {
    late GameProvider game;

    setUp(() {
      game = GameProvider();
      game.startNewGame(mode: GameMode.vsPlayer, boardSize: 9);
    });

    test('Đen đi trước', () {
      expect(game.currentPlayer, Player.black);
    });

    test('đổi lượt sau mỗi nước đi hợp lệ', () {
      game.placeStone(0, 0);
      expect(game.currentPlayer, Player.white);
      game.placeStone(0, 1);
      expect(game.currentPlayer, Player.black);
    });

    test('không cho đi vào ô đã có quân', () {
      game.placeStone(3, 3);
      final movesBefore = game.moveHistory.length;
      game.placeStone(3, 3);
      expect(game.moveHistory.length, movesBefore);
    });

    test('phát hiện thắng và dừng ván khi đủ 5 quân liên tiếp', () {
      // Đen: (0,0)(0,1)(0,2)(0,3)(0,4); Trắng xen kẽ ở hàng khác.
      game.placeStone(0, 0); // black
      game.placeStone(1, 0); // white
      game.placeStone(0, 1); // black
      game.placeStone(1, 1); // white
      game.placeStone(0, 2); // black
      game.placeStone(1, 2); // white
      game.placeStone(0, 3); // black
      game.placeStone(1, 3); // white
      game.placeStone(0, 4); // black -> thắng

      expect(game.status, GameStatus.blackWin);
      expect(game.winningLine, isNotNull);
      expect(game.winningLine!.length, greaterThanOrEqualTo(5));
    });

    test('không cho đi tiếp sau khi ván đã kết thúc', () {
      game.placeStone(0, 0);
      game.placeStone(1, 0);
      game.placeStone(0, 1);
      game.placeStone(1, 1);
      game.placeStone(0, 2);
      game.placeStone(1, 2);
      game.placeStone(0, 3);
      game.placeStone(1, 3);
      game.placeStone(0, 4); // black thắng

      final historyLenAfterWin = game.moveHistory.length;
      game.placeStone(5, 5);
      expect(game.moveHistory.length, historyLenAfterWin);
    });

    test('undoLastMove hoàn tác đúng 1 nước ở chế độ 2 người', () {
      game.placeStone(2, 2); // black
      game.placeStone(2, 3); // white
      expect(game.moveHistory.length, 2);

      game.undoLastMove();

      expect(game.moveHistory.length, 1);
      expect(game.board[2][3], isNull);
      expect(game.currentPlayer, Player.white);
    });

    test('restart đưa ván về trạng thái ban đầu', () {
      game.placeStone(0, 0);
      game.restart();
      expect(game.moveHistory, isEmpty);
      expect(game.status, GameStatus.playing);
      expect(game.currentPlayer, Player.black);
    });
  });
}
