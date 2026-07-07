import 'package:flutter/foundation.dart';

import '../models/enums.dart';
import '../models/match_record.dart';
import '../models/move.dart';
import '../services/ai_service.dart';
import '../services/win_checker.dart';
import 'stats_provider.dart';

/// Quản lý trạng thái 1 ván Caro: bàn cờ, lượt đi, thắng/thua/hoà, AI.
///
/// Quy ước: người chơi (hoặc người 1) luôn là quân Đen và đi trước.
/// Ở chế độ đấu máy, AI luôn là quân Trắng.
class GameProvider extends ChangeNotifier {
  GameProvider({AiService? aiService}) : _ai = aiService ?? AiService() {
    _initBoard(15);
  }

  final AiService _ai;
  StatsProvider? _stats;

  late List<List<Player?>> board;
  int boardSize = 15;
  Player currentPlayer = Player.black;
  GameMode mode = GameMode.vsAi;
  Difficulty difficulty = Difficulty.medium;
  GameStatus status = GameStatus.playing;
  final List<Move> moveHistory = [];
  List<BoardPoint>? winningLine;
  bool aiThinking = false;

  static const Player humanPlayer = Player.black;
  static const Player aiPlayer = Player.white;

  /// Gắn StatsProvider để tự động lưu kết quả ván đấu (gọi từ main.dart).
  void attachStats(StatsProvider stats) {
    _stats = stats;
  }

  void _initBoard(int size) {
    boardSize = size;
    board = List.generate(size, (_) => List<Player?>.filled(size, null));
  }

  void startNewGame({
    required GameMode mode,
    required int boardSize,
    Difficulty difficulty = Difficulty.medium,
  }) {
    this.mode = mode;
    this.difficulty = difficulty;
    _initBoard(boardSize);
    currentPlayer = Player.black;
    status = GameStatus.playing;
    moveHistory.clear();
    winningLine = null;
    aiThinking = false;
    notifyListeners();
  }

  void restart() {
    startNewGame(mode: mode, boardSize: boardSize, difficulty: difficulty);
  }

  bool get isHumanTurn => mode == GameMode.vsPlayer || currentPlayer == humanPlayer;

  void placeStone(int row, int col) {
    if (status.isOver || aiThinking) return;
    if (board[row][col] != null) return;
    if (mode == GameMode.vsAi && currentPlayer != humanPlayer) return;

    _applyMove(row, col, currentPlayer);

    if (!status.isOver && mode == GameMode.vsAi && currentPlayer == aiPlayer) {
      _scheduleAiMove();
    }
  }

  void _applyMove(int row, int col, Player player) {
    board[row][col] = player;
    moveHistory.add(Move(row: row, col: col, player: player));

    final line = WinChecker.findWinningLine(board, row, col, player);
    if (line != null) {
      winningLine = line;
      status = player == Player.black ? GameStatus.blackWin : GameStatus.whiteWin;
      _finishGame();
    } else if (WinChecker.isBoardFull(board)) {
      status = GameStatus.draw;
      _finishGame();
    } else {
      currentPlayer = player.opponent;
    }
    notifyListeners();
  }

  void _scheduleAiMove() async {
    aiThinking = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 450));
    // Ván có thể đã bị huỷ/restart trong lúc chờ.
    if (status.isOver) {
      aiThinking = false;
      notifyListeners();
      return;
    }
    final move = _ai.computeMove(
      board: board,
      boardSize: boardSize,
      difficulty: difficulty,
      aiPlayer: aiPlayer,
    );
    aiThinking = false;
    _applyMove(move.row, move.col, aiPlayer);
  }

  void _finishGame() {
    final record = MatchRecord(
      playedAt: DateTime.now(),
      mode: mode,
      difficulty: mode == GameMode.vsAi ? difficulty : null,
      boardSize: boardSize,
      movesCount: moveHistory.length,
      result: status,
    );
    _stats?.recordMatch(record);
  }

  /// Hoàn tác nước đi gần nhất. Ở chế độ đấu máy, hoàn tác cả nước của máy
  /// lẫn nước của người để đến lượt người chơi lại.
  void undoLastMove() {
    if (moveHistory.isEmpty || status.isOver || aiThinking) return;

    final stepsToUndo = mode == GameMode.vsAi ? 2 : 1;
    for (var i = 0; i < stepsToUndo && moveHistory.isNotEmpty; i++) {
      final last = moveHistory.removeLast();
      board[last.row][last.col] = null;
      currentPlayer = last.player;
    }
    winningLine = null;
    notifyListeners();
  }

  bool get canUndo => moveHistory.isNotEmpty && !status.isOver && !aiThinking;
}
