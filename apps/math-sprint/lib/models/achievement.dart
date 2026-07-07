import 'package:flutter/material.dart';
import 'game_result.dart';

/// Tổng hợp số liệu mọi ván để xét điều kiện mở khoá thành tích.
class PlayerStats {
  final int totalGames;
  final int totalCorrect;
  final int bestScore;
  final int bestCombo;

  const PlayerStats({
    required this.totalGames,
    required this.totalCorrect,
    required this.bestScore,
    required this.bestCombo,
  });

  factory PlayerStats.fromHistory(List<GameResult> history) {
    if (history.isEmpty) {
      return const PlayerStats(
          totalGames: 0, totalCorrect: 0, bestScore: 0, bestCombo: 0);
    }
    var correct = 0;
    var best = 0;
    var combo = 0;
    for (final r in history) {
      correct += r.correct;
      if (r.score > best) best = r.score;
      if (r.bestCombo > combo) combo = r.bestCombo;
    }
    return PlayerStats(
      totalGames: history.length,
      totalCorrect: correct,
      bestScore: best,
      bestCombo: combo,
    );
  }
}

/// Một thành tích mở khoá khi đạt điều kiện.
class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final bool Function(PlayerStats stats) condition;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.condition,
  });

  static final List<Achievement> all = [
    Achievement(
      id: 'first_game',
      title: 'Lần đầu',
      description: 'Chơi ván đầu tiên.',
      icon: Icons.flag_outlined,
      condition: (s) => s.totalGames >= 1,
    ),
    Achievement(
      id: 'ten_games',
      title: 'Chăm chỉ',
      description: 'Chơi đủ 10 ván.',
      icon: Icons.fitness_center_outlined,
      condition: (s) => s.totalGames >= 10,
    ),
    Achievement(
      id: 'hundred_correct',
      title: 'Trăm câu đúng',
      description: 'Tích luỹ 100 câu trả lời đúng.',
      icon: Icons.check_circle_outline,
      condition: (s) => s.totalCorrect >= 100,
    ),
    Achievement(
      id: 'score_200',
      title: 'Tốc độ',
      description: 'Đạt 200 điểm trong một ván.',
      icon: Icons.speed_outlined,
      condition: (s) => s.bestScore >= 200,
    ),
    Achievement(
      id: 'combo_10',
      title: 'Combo x10',
      description: 'Đạt chuỗi 10 câu đúng liên tiếp.',
      icon: Icons.whatshot_outlined,
      condition: (s) => s.bestCombo >= 10,
    ),
    Achievement(
      id: 'combo_20',
      title: 'Bất bại',
      description: 'Đạt chuỗi 20 câu đúng liên tiếp.',
      icon: Icons.military_tech_outlined,
      condition: (s) => s.bestCombo >= 20,
    ),
  ];
}
