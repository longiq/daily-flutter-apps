import 'dart:math';

import '../models/enums.dart';
import '../models/move.dart';
import 'win_checker.dart';

/// AI đối thủ cho chế độ "Đấu với máy".
///
/// Không dùng minimax đầy đủ (bàn 15x15 quá lớn để duyệt hết), thay vào đó
/// dùng heuristic theo pattern (số quân liên tiếp + đầu mở) cộng thêm bước
/// nhìn trước 1 nước cho độ khó "Khó".
class AiService {
  final Random _rand = Random();

  Move computeMove({
    required List<List<Player?>> board,
    required int boardSize,
    required Difficulty difficulty,
    required Player aiPlayer,
  }) {
    final human = aiPlayer.opponent;
    final candidates = _candidateCells(board, boardSize);
    if (candidates.isEmpty) {
      final center = boardSize ~/ 2;
      return Move(row: center, col: center, player: aiPlayer);
    }

    // 1. Nếu có nước thắng ngay lập tức, đi luôn.
    for (final cell in candidates) {
      board[cell.row][cell.col] = aiPlayer;
      final wins = WinChecker.checkWin(board, cell.row, cell.col, aiPlayer);
      board[cell.row][cell.col] = null;
      if (wins) {
        return Move(row: cell.row, col: cell.col, player: aiPlayer);
      }
    }

    // 2. Nếu đối thủ sắp thắng ở lượt sau, chặn ngay.
    for (final cell in candidates) {
      board[cell.row][cell.col] = human;
      final oppWins = WinChecker.checkWin(board, cell.row, cell.col, human);
      board[cell.row][cell.col] = null;
      if (oppWins) {
        return Move(row: cell.row, col: cell.col, player: aiPlayer);
      }
    }

    // 3. Chấm điểm heuristic cho từng ô ứng viên.
    final blockWeight = switch (difficulty) {
      Difficulty.easy => 0.4,
      Difficulty.medium => 0.85,
      Difficulty.hard => 1.0,
    };

    final scored = <_ScoredCell>[];
    for (final cell in candidates) {
      final offense = _evaluatePlacement(board, cell.row, cell.col, aiPlayer, boardSize);
      final defense = _evaluatePlacement(board, cell.row, cell.col, human, boardSize);
      double score = offense + defense * blockWeight;
      if (difficulty == Difficulty.easy) {
        score += _rand.nextInt(400).toDouble();
      }
      scored.add(_ScoredCell(cell, score));
    }
    scored.sort((a, b) => b.score.compareTo(a.score));

    if (difficulty == Difficulty.hard && scored.length > 1) {
      // Nhìn trước 1 nước: trong top ứng viên, ưu tiên nước khiến đối thủ
      // có điểm phản công thấp nhất ở lượt kế tiếp.
      final topN = scored.take(6).toList();
      _ScoredCell? best;
      double bestCombined = double.negativeInfinity;
      for (final sc in topN) {
        board[sc.cell.row][sc.cell.col] = aiPlayer;
        final oppCandidates = _candidateCells(board, boardSize);
        double oppBest = 0;
        for (final oc in oppCandidates) {
          final v = _evaluatePlacement(board, oc.row, oc.col, human, boardSize).toDouble();
          if (v > oppBest) oppBest = v;
        }
        board[sc.cell.row][sc.cell.col] = null;
        final combined = sc.score - oppBest * 0.5;
        if (best == null || combined > bestCombined) {
          best = sc;
          bestCombined = combined;
        }
      }
      final chosen = best ?? scored.first;
      return Move(row: chosen.cell.row, col: chosen.cell.col, player: aiPlayer);
    }

    // Medium/Easy: chọn ngẫu nhiên trong nhóm điểm cao nhất để đỡ máy móc.
    final topScore = scored.first.score;
    final topTier = scored.where((s) => s.score >= topScore - 50).toList();
    final chosen = topTier[_rand.nextInt(topTier.length)];
    return Move(row: chosen.cell.row, col: chosen.cell.col, player: aiPlayer);
  }

  List<BoardPoint> _candidateCells(List<List<Player?>> board, int boardSize) {
    final occupied = <BoardPoint>[];
    for (int r = 0; r < boardSize; r++) {
      for (int c = 0; c < boardSize; c++) {
        if (board[r][c] != null) occupied.add(BoardPoint(r, c));
      }
    }
    if (occupied.isEmpty) {
      return [BoardPoint(boardSize ~/ 2, boardSize ~/ 2)];
    }
    final seen = <BoardPoint>{};
    final result = <BoardPoint>[];
    const radius = 2;
    for (final o in occupied) {
      for (int dr = -radius; dr <= radius; dr++) {
        for (int dc = -radius; dc <= radius; dc++) {
          final r = o.row + dr;
          final c = o.col + dc;
          if (r < 0 || r >= boardSize || c < 0 || c >= boardSize) continue;
          if (board[r][c] != null) continue;
          final p = BoardPoint(r, c);
          if (seen.add(p)) result.add(p);
        }
      }
    }
    return result;
  }

  /// Điểm nếu [player] đặt quân tại (row, col), tính theo pattern
  /// (số quân liên tiếp + số đầu mở) trên 4 hướng.
  int _evaluatePlacement(
    List<List<Player?>> board,
    int row,
    int col,
    Player player,
    int boardSize,
  ) {
    board[row][col] = player;
    int total = 0;
    const dirs = [
      [0, 1],
      [1, 0],
      [1, 1],
      [1, -1],
    ];
    for (final d in dirs) {
      total += _lineScore(board, row, col, d[0], d[1], player, boardSize);
    }
    board[row][col] = null;
    return total;
  }

  int _lineScore(
    List<List<Player?>> board,
    int row,
    int col,
    int dr,
    int dc,
    Player player,
    int boardSize,
  ) {
    int count = 1;
    int r = row + dr, c = col + dc;
    while (_inBounds(r, c, boardSize) && board[r][c] == player) {
      count++;
      r += dr;
      c += dc;
    }
    final frontOpen = _inBounds(r, c, boardSize) && board[r][c] == null;

    r = row - dr;
    c = col - dc;
    while (_inBounds(r, c, boardSize) && board[r][c] == player) {
      count++;
      r -= dr;
      c -= dc;
    }
    final backOpen = _inBounds(r, c, boardSize) && board[r][c] == null;

    final openEnds = (frontOpen ? 1 : 0) + (backOpen ? 1 : 0);

    if (count >= 5) return 100000;
    if (count == 4) return openEnds == 2 ? 10000 : (openEnds == 1 ? 1000 : 50);
    if (count == 3) return openEnds == 2 ? 500 : (openEnds == 1 ? 100 : 10);
    if (count == 2) return openEnds == 2 ? 50 : (openEnds == 1 ? 20 : 5);
    return openEnds == 2 ? 5 : 1;
  }

  bool _inBounds(int r, int c, int size) => r >= 0 && r < size && c >= 0 && c < size;
}

class _ScoredCell {
  final BoardPoint cell;
  final double score;
  _ScoredCell(this.cell, this.score);
}
