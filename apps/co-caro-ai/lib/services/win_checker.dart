import '../models/enums.dart';
import '../models/move.dart';

/// Kiểm tra thắng/thua/hoà cho bàn cờ Caro (5 quân liên tiếp trở lên).
class WinChecker {
  static const int winLength = 5;

  static const List<List<int>> _directions = [
    [0, 1], // ngang
    [1, 0], // dọc
    [1, 1], // chéo xuôi
    [1, -1], // chéo ngược
  ];

  /// Trả về danh sách toạ độ tạo thành đường thắng đi qua (row, col) nếu có,
  /// null nếu nước đi vừa rồi chưa tạo ra 5 quân liên tiếp.
  static List<BoardPoint>? findWinningLine(
    List<List<Player?>> board,
    int row,
    int col,
    Player player,
  ) {
    final size = board.length;
    for (final dir in _directions) {
      final dr = dir[0];
      final dc = dir[1];
      final line = <BoardPoint>[BoardPoint(row, col)];

      // đi về phía trước
      int r = row + dr, c = col + dc;
      while (_inBounds(r, c, size) && board[r][c] == player) {
        line.add(BoardPoint(r, c));
        r += dr;
        c += dc;
      }
      // đi về phía sau
      r = row - dr;
      c = col - dc;
      while (_inBounds(r, c, size) && board[r][c] == player) {
        line.add(BoardPoint(r, c));
        r -= dr;
        c -= dc;
      }

      if (line.length >= winLength) {
        return line;
      }
    }
    return null;
  }

  static bool checkWin(List<List<Player?>> board, int row, int col, Player player) {
    return findWinningLine(board, row, col, player) != null;
  }

  static bool isBoardFull(List<List<Player?>> board) {
    for (final row in board) {
      for (final cell in row) {
        if (cell == null) return false;
      }
    }
    return true;
  }

  static bool _inBounds(int r, int c, int size) => r >= 0 && r < size && c >= 0 && c < size;
}
