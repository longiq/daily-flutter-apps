import 'enums.dart';

/// Bản ghi 1 ván đấu đã kết thúc, dùng để lưu lịch sử/thống kê.
class MatchRecord {
  final DateTime playedAt;
  final GameMode mode;
  final Difficulty? difficulty;
  final int boardSize;
  final int movesCount;
  final GameStatus result; // blackWin / whiteWin / draw

  const MatchRecord({
    required this.playedAt,
    required this.mode,
    required this.difficulty,
    required this.boardSize,
    required this.movesCount,
    required this.result,
  });

  /// Kết quả từ góc nhìn người chơi (khi vsAi, người luôn là Đen).
  bool get playerWon => mode == GameMode.vsAi && result == GameStatus.blackWin;
  bool get playerLost => mode == GameMode.vsAi && result == GameStatus.whiteWin;
  bool get isDraw => result == GameStatus.draw;

  Map<String, dynamic> toJson() => {
        'playedAt': playedAt.toIso8601String(),
        'mode': mode.name,
        'difficulty': difficulty?.name,
        'boardSize': boardSize,
        'movesCount': movesCount,
        'result': result.name,
      };

  factory MatchRecord.fromJson(Map<String, dynamic> json) {
    return MatchRecord(
      playedAt: DateTime.tryParse(json['playedAt'] as String? ?? '') ?? DateTime.now(),
      mode: GameMode.values.firstWhere(
        (e) => e.name == json['mode'],
        orElse: () => GameMode.vsAi,
      ),
      difficulty: json['difficulty'] == null
          ? null
          : Difficulty.values.firstWhere(
              (e) => e.name == json['difficulty'],
              orElse: () => Difficulty.medium,
            ),
      boardSize: json['boardSize'] as int? ?? 15,
      movesCount: json['movesCount'] as int? ?? 0,
      result: GameStatus.values.firstWhere(
        (e) => e.name == json['result'],
        orElse: () => GameStatus.draw,
      ),
    );
  }
}
