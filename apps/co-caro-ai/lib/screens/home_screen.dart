import 'package:flutter/material.dart';

import 'how_to_play_screen.dart';
import 'mode_select_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.grid_4x4_rounded, size: 88, color: theme.colorScheme.primary),
                  const SizedBox(height: 12),
                  Text(
                    'Cờ Caro AI',
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Gomoku 5 quân liên tiếp - đấu máy hoặc 2 người',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Chơi mới'),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ModeSelectScreen()),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.bar_chart_rounded),
                      label: const Text('Thống kê'),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const StatsScreen()),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.menu_book_rounded),
                      label: const Text('Hướng dẫn chơi'),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const HowToPlayScreen()),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      icon: const Icon(Icons.settings_outlined),
                      label: const Text('Cài đặt'),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const _AdBannerPlaceholder(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Chỗ đặt banner ads thật (google_mobile_ads) khi tích hợp SDK sau này.
class _AdBannerPlaceholder extends StatelessWidget {
  const _AdBannerPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '[ Banner quảng cáo ]',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
