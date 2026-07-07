import 'enums.dart';

/// Một nước đi trên bàn cờ.
class Move {
  final int row;
  final int col;
  final Player player;

  const Move({required this.row, required this.col, required this.player});

  @override
  bool operator ==(Object other) =>
      other is Move && other.row == row && other.col == col && other.player == player;

  @override
  int get hashCode => Object.hash(row, col, player);

  @override
  String toString() => 'Move(${row},${col},${player.symbol})';
}

/// Toạ độ đơn giản dùng để đánh dấu đường thắng.
class BoardPoint {
  final int row;
  final int col;

  const BoardPoint(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      other is BoardPoint && other.row == row && other.col == col;

  @override
  int get hashCode => Object.hash(row, col);
}
