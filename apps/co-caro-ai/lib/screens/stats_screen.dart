import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/enums.dart';
import '../models/match_record.dart';
import '../providers/stats_provider.dart';
import '../widgets/stat_card.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  String _resultLabel(MatchRecord r) {
    if (r.mode == GameMode.vsPlayer) {
      switch (r.result) {
        case GameStatus.blackWin:
          return 'Đen thắng';
        case GameStatus.whiteWin:
          return 'Trắng thắng';
        case GameStatus.draw:
          return 'Hoà';
        case GameStatus.playing:
          return '-';
      }
    }
    if (r.playerWon) return 'Bạn thắng';
    if (r.playerLost) return 'Bạn thua';
    return 'Hoà';
  }

  String _formatDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)} ${two(d.hour)}:${two(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Thống kê')),
      body: stats.totalGames == 0
          ? const Center(child: Text('Chưa có ván đấu nào. Hãy chơi thử!'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(child: StatCard(label: 'Tổng ván', value: '${stats.totalGames}')),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatCard(
                        label: 'Thắng',
                        value: '${stats.wins}',
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatCard(label: 'Thua', value: '${stats.losses}', color: Colors.red),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatCard(label: 'Hoà', value: '${stats.draws}', color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                StatCard(
                  label: 'Tỉ lệ thắng',
                  value: '${(stats.winRate * 100).toStringAsFixed(0)}%',
                ),
                const SizedBox(height: 24),
                Text(
                  'Lịch sử gần đây',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...stats.history.take(20).map(
                      (r) => Card(
                        child: ListTile(
                          leading: Icon(
                            r.mode == GameMode.vsAi ? Icons.smart_toy_outlined : Icons.people_outline,
                          ),
                          title: Text(_resultLabel(r)),
                          subtitle: Text(
                            '${r.mode.label}${r.difficulty != null ? ' · ${r.difficulty!.label}' : ''} '
                            '· ${r.boardSize}x${r.boardSize} · ${r.movesCount} nước',
                          ),
                          trailing: Text(_formatDate(r.playedAt)),
                        ),
                      ),
                    ),
              ],
            ),
    );
  }
}
