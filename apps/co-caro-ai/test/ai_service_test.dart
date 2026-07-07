import 'package:flutter_test/flutter_test.dart';
import 'package:co_caro_ai/models/enums.dart';
import 'package:co_caro_ai/services/ai_service.dart';
import 'package:co_caro_ai/services/win_checker.dart';

List<List<Player?>> _emptyBoard(int size) =>
    List.generate(size, (_) => List<Player?>.filled(size, null));

void main() {
  group('AiService', () {
    final ai = AiService();

    test('AI ăn ngay khi có nước thắng (4 quân mở 1 đầu)', () {
      final board = _emptyBoard(15);
      // AI (white) đã có 4 quân liên tiếp, chỉ cần đi thêm 1 để thắng.
      board[7][3] = Player.white;
      board[7][4] = Player.white;
      board[7][5] = Player.white;
      board[7][6] = Player.white;

      final move = ai.computeMove(
        board: board,
        boardSize: 15,
        difficulty: Difficulty.medium,
        aiPlayer: Player.white,
      );

      board[move.row][move.col] = Player.white;
      expect(WinChecker.checkWin(board, move.row, move.col, Player.white), isTrue);
    });

    test('AI chặn khi đối thủ sắp thắng (4 quân mở)', () {
      final board = _emptyBoard(15);
      // Người chơi (black) có 4 quân mở 2 đầu -> AI bắt buộc phải chặn.
      board[7][4] = Player.black;
      board[7][5] = Player.black;
      board[7][6] = Player.black;
      board[7][7] = Player.black;

      final move = ai.computeMove(
        board: board,
        boardSize: 15,
        difficulty: Difficulty.medium,
        aiPlayer: Player.white,
      );

      expect(move.row == 7 && (move.col == 3 || move.col == 8), isTrue);
    });

    test('bàn trống thì AI đi vào trung tâm', () {
      final board = _emptyBoard(15);
      final move = ai.computeMove(
        board: board,
        boardSize: 15,
        difficulty: Difficulty.medium,
        aiPlayer: Player.white,
      );
      expect(move.row, 7);
      expect(move.col, 7);
    });

    test('AI luôn trả về ô còn trống', () {
      final board = _emptyBoard(9);
      board[4][4] = Player.black;
      board[4][5] = Player.white;
      board[3][4] = Player.black;

      final move = ai.computeMove(
        board: board,
        boardSize: 9,
        difficulty: Difficulty.hard,
        aiPlayer: Player.white,
      );

      expect(board[move.row][move.col], isNull);
    });
  });
}
