import 'package:flutter/material.dart';

import '../models/enums.dart';
import '../models/move.dart';
import 'cell_widget.dart';

/// Vẽ toàn bộ bàn cờ dạng lưới vuông, tự co giãn theo chiều rộng màn hình.
class BoardWidget extends StatelessWidget {
  const BoardWidget({
    super.key,
    required this.board,
    required this.boardSize,
    required this.winningLine,
    required this.lastMove,
    required this.onCellTap,
    required this.enabled,
  });

  final List<List<Player?>> board;
  final int boardSize;
  final List<BoardPoint>? winningLine;
  final Move? lastMove;
  final void Function(int row, int col) onCellTap;
  final bool enabled;

  bool _isWinningCell(int row, int col) {
    final line = winningLine;
    if (line == null) return false;
    return line.any((p) => p.row == row && p.col == col);
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: boardSize * boardSize,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: boardSize,
            ),
            itemBuilder: (context, index) {
              final row = index ~/ boardSize;
              final col = index % boardSize;
              final isLast = lastMove != null && lastMove!.row == row && lastMove!.col == col;
              return CellWidget(
                player: board[row][col],
                isWinning: _isWinningCell(row, col),
                isLastMove: isLast,
                onTap: enabled ? () => onCellTap(row, col) : null,
              );
            },
          );
        },
      ),
    );
  }
}
