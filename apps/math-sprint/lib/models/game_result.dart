/// Kết quả một ván chơi, dùng để lưu lịch sử và tính thống kê.
class GameResult {
  final String modeId;
  final String modeName;
  final int score;
  final int correct;
  final int wrong;
  final int bestCombo;
  final DateTime playedAt;

  const GameResult({
    required this.modeId,
    required this.modeName,
    required this.score,
    required this.correct,
    required this.wrong,
    required this.bestCombo,
    required this.playedAt,
  });

  int get total => correct + wrong;

  double get accuracy => total == 0 ? 0 : correct / total;

  Map<String, dynamic> toJson() => {
        'modeId': modeId,
        'modeName': modeName,
        'score': score,
        'correct': correct,
        'wrong': wrong,
        'bestCombo': bestCombo,
        'playedAt': playedAt.toIso8601String(),
      };

  factory GameResult.fromJson(Map<String, dynamic> json) => GameResult(
        modeId: json['modeId'] as String? ?? 'unknown',
        modeName: json['modeName'] as String? ?? 'Không rõ',
        score: json['score'] as int? ?? 0,
        correct: json['correct'] as int? ?? 0,
        wrong: json['wrong'] as int? ?? 0,
        bestCombo: json['bestCombo'] as int? ?? 0,
        playedAt: DateTime.tryParse(json['playedAt'] as String? ?? '') ??
            DateTime.now(),
      );
}
