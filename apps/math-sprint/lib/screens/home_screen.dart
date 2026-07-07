import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'achievements_screen.dart';
import 'mode_select_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';

/// Màn hình chính: tiêu đề, điểm cao nhất, các lối vào.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final stats = context.watch<GameProvider>().stats;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),
              Icon(Icons.bolt, size: 88, color: scheme.primary),
              const SizedBox(height: 8),
              Text(
                'Math Sprint',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Giải toán nhanh nhất có thể!',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _mini('Điểm cao', '${stats.bestScore}'),
                      _mini('Số ván', '${stats.totalGames}'),
                      _mini('Combo', '${stats.bestCombo}'),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const ModeSelectScreen()),
                ),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Chơi ngay'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _go(context, const StatsScreen()),
                      icon: const Icon(Icons.bar_chart),
                      label: const Text('Thống kê'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _go(context, const AchievementsScreen()),
                      icon: const Icon(Icons.emoji_events_outlined),
                      label: const Text('Thành tích'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => _go(context, const SettingsScreen()),
                icon: const Icon(Icons.settings_outlined),
                label: const Text('Cài đặt'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _go(BuildContext context, Widget screen) => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => screen));

  Widget _mini(String label, String value) => Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      );
}
