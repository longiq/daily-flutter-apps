import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_result.dart';
import '../providers/game_provider.dart';
import '../widgets/stat_card.dart';

/// Thống kê tổng quan và lịch sử các ván gần đây.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final stats = game.stats;
    final history = game.history;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê'),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Xoá lịch sử',
              onPressed: () => _confirmClear(context),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              StatCard(
                  icon: Icons.sports_esports,
                  label: 'Tổng số ván',
                  value: '${stats.totalGames}'),
              StatCard(
                  icon: Icons.star,
                  label: 'Điểm cao nhất',
                  value: '${stats.bestScore}'),
              StatCard(
                  icon: Icons.check_circle,
                  label: 'Câu đúng',
                  value: '${stats.totalCorrect}'),
              StatCard(
                  icon: Icons.whatshot,
                  label: 'Combo tốt nhất',
                  value: '${stats.bestCombo}'),
            ],
          ),
          const SizedBox(height: 16),
          Text('Lịch sử gần đây',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (history.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('Chưa có ván nào. Chơi thử đi!')),
            )
          else
            ...history.take(20).map((r) => _historyTile(context, r)),
        ],
      ),
    );
  }

  Widget _historyTile(BuildContext context, GameResult r) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text('${r.score}')),
        title: Text(r.modeName),
        subtitle: Text(
            '${r.correct} đúng • ${r.wrong} sai • ${_fmt(r.playedAt)}'),
        trailing: Text('x${r.bestCombo}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  String _fmt(DateTime dt) =>
      '${dt.day}/${dt.month} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  void _confirmClear(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xoá lịch sử?'),
        content: const Text(
            'Toàn bộ ván chơi và thành tích sẽ bị xoá. Không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            onPressed: () {
              context.read<GameProvider>().clearHistory();
              Navigator.of(ctx).pop();
            },
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
  }
}
