import 'package:flutter_test/flutter_test.dart';
import 'package:co_caro_ai/models/enums.dart';
import 'package:co_caro_ai/services/win_checker.dart';

List<List<Player?>> _emptyBoard(int size) =>
    List.generate(size, (_) => List<Player?>.filled(size, null));

void main() {
  group('WinChecker', () {
    test('phát hiện thắng hàng ngang', () {
      final board = _emptyBoard(15);
      for (int c = 0; c < 5; c++) {
        board[7][c] = Player.black;
      }
      expect(WinChecker.checkWin(board, 7, 4, Player.black), isTrue);
    });

    test('phát hiện thắng hàng dọc', () {
      final board = _emptyBoard(15);
      for (int r = 0; r < 5; r++) {
        board[r][3] = Player.white;
      }
      expect(WinChecker.checkWin(board, 4, 3, Player.white), isTrue);
    });

    test('phát hiện thắng đường chéo xuôi', () {
      final board = _emptyBoard(15);
      for (int i = 0; i < 5; i++) {
        board[i][i] = Player.black;
      }
      expect(WinChecker.checkWin(board, 4, 4, Player.black), isTrue);
    });

    test('phát hiện thắng đường chéo ngược', () {
      final board = _emptyBoard(15);
      for (int i = 0; i < 5; i++) {
        board[i][4 - i] = Player.white;
      }
      expect(WinChecker.checkWin(board, 2, 2, Player.white), isTrue);
    });

    test('4 quân liên tiếp chưa thắng', () {
      final board = _emptyBoard(15);
      for (int c = 0; c < 4; c++) {
        board[0][c] = Player.black;
      }
      expect(WinChecker.checkWin(board, 0, 3, Player.black), isFalse);
    });

    test('không nhầm quân của đối thủ xen giữa', () {
      final board = _emptyBoard(15);
      board[0][0] = Player.black;
      board[0][1] = Player.black;
      board[0][2] = Player.white; // chặn giữa
      board[0][3] = Player.black;
      board[0][4] = Player.black;
      expect(WinChecker.checkWin(board, 0, 1, Player.black), isFalse);
    });

    test('isBoardFull trả về true khi đầy bàn', () {
      final board = List.generate(2, (_) => List<Player?>.filled(2, Player.black));
      expect(WinChecker.isBoardFull(board), isTrue);
    });

    test('isBoardFull trả về false khi còn ô trống', () {
      final board = _emptyBoard(3);
      board[0][0] = Player.black;
      expect(WinChecker.isBoardFull(board), isFalse);
    });

    test('6 quân liên tiếp (overline) vẫn tính thắng', () {
      final board = _emptyBoard(15);
      for (int c = 0; c < 6; c++) {
        board[0][c] = Player.black;
      }
      expect(WinChecker.checkWin(board, 0, 0, Player.black), isTrue);
    });
  });
}
