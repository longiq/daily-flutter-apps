import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/achievement.dart';
import '../providers/game_provider.dart';
import 'game_screen.dart';

/// Màn hình kết quả sau khi hết giờ.
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final game = context.watch<GameProvider>();
    final accuracy =
        (game.correct + game.wrong) == 0 ? 0.0 : game.correct / (game.correct + game.wrong);
    final isBest = game.score >= game.stats.bestScore && game.score > 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 8),
              if (isBest)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: scheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.celebration, size: 18),
                      const SizedBox(width: 6),
                      Text('Kỷ lục mới!',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: scheme.onTertiaryContainer)),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              Text('${game.score}',
                  style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w800,
                      color: scheme.primary)),
              Text('điểm', style: TextStyle(color: scheme.onSurfaceVariant)),
              const SizedBox(height: 24),
              Row(
                children: [
                  _box(context, 'Đúng', '${game.correct}', Colors.green),
                  _box(context, 'Sai', '${game.wrong}', scheme.error),
                  _box(context, 'Combo', '${game.bestCombo}',
                      Colors.deepOrange),
                ],
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.percent),
                  title: const Text('Độ chính xác'),
                  trailing: Text('${(accuracy * 100).round()}%',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                ),
              ),
              if (game.newAchievements.isNotEmpty) ...[
                const SizedBox(height: 12),
                _achievementBanner(context, game.newAchievements),
              ],
              const Spacer(),
              FilledButton.icon(
                onPressed: () {
                  context.read<GameProvider>().start(game.mode);
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const GameScreen()),
                  );
                },
                icon: const Icon(Icons.replay),
                label: const Text('Chơi lại'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  context.read<GameProvider>().reset();
                  Navigator.of(context)
                      .popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.home),
                label: const Text('Về trang chủ'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _box(
      BuildContext context, String label, String value, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: color)),
              const SizedBox(height: 4),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }

  Widget _achievementBanner(
      BuildContext context, List<Achievement> newOnes) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.emoji_events),
                const SizedBox(width: 8),
                Text('Mở khoá thành tích!',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: scheme.onSecondaryContainer)),
              ],
            ),
            const SizedBox(height: 8),
            ...newOnes.map((a) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Icon(a.icon, size: 18),
                      const SizedBox(width: 8),
                      Text(a.title),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
