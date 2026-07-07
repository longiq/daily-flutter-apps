import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/enums.dart';
import '../providers/settings_provider.dart';
import '../providers/stats_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final settings = settingsProvider.settings;

    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Chế độ tối (Dark mode)'),
            secondary: const Icon(Icons.dark_mode_outlined),
            value: settings.darkMode,
            onChanged: (v) => settingsProvider.setDarkMode(v),
          ),
          SwitchListTile(
            title: const Text('Âm thanh'),
            secondary: const Icon(Icons.volume_up_outlined),
            value: settings.soundEnabled,
            onChanged: (v) => settingsProvider.setSoundEnabled(v),
          ),
          const Divider(),
          ListTile(
            title: const Text('Độ khó mặc định'),
            subtitle: Text(settings.defaultDifficulty.label),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<Difficulty>(
              segments: const [
                ButtonSegment(value: Difficulty.easy, label: Text('Dễ')),
                ButtonSegment(value: Difficulty.medium, label: Text('Trung bình')),
                ButtonSegment(value: Difficulty.hard, label: Text('Khó')),
              ],
              selected: {settings.defaultDifficulty},
              onSelectionChanged: (s) => settingsProvider.setDefaultDifficulty(s.first),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Cỡ bàn cờ mặc định'),
            subtitle: Text('${settings.defaultBoardSize}x${settings.defaultBoardSize}'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 9, label: Text('9x9')),
                ButtonSegment(value: 13, label: Text('13x13')),
                ButtonSegment(value: 15, label: Text('15x15')),
              ],
              selected: {settings.defaultBoardSize},
              onSelectionChanged: (s) => settingsProvider.setDefaultBoardSize(s.first),
            ),
          ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Xoá lịch sử ván đấu'),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Xoá lịch sử?'),
                  content: const Text('Toàn bộ thống kê và lịch sử ván đấu sẽ bị xoá.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: const Text('Huỷ'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.of(dialogContext).pop(true),
                      child: const Text('Xoá'),
                    ),
                  ],
                ),
              );
              if (confirm == true && context.mounted) {
                await context.read<StatsProvider>().clearHistory();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã xoá lịch sử.')),
                  );
                }
              }
            },
          ),
          ListTile(
            leading: Icon(
              settings.adsRemoved ? Icons.check_circle : Icons.workspace_premium_outlined,
              color: settings.adsRemoved ? Colors.green : null,
            ),
            title: const Text('Gỡ quảng cáo (Premium)'),
            subtitle: Text(settings.adsRemoved ? 'Đã kích hoạt' : 'Mua 1 lần, chơi không quảng cáo'),
            trailing: settings.adsRemoved
                ? null
                : FilledButton(
                    onPressed: () => settingsProvider.setAdsRemoved(true),
                    child: const Text('Mua'),
                  ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Lưu ý: nút "Mua" ở trên là giả lập demo, chưa nối với App Store/Google Play. '
              'Khi publish cần tích hợp in_app_purchase thật.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
