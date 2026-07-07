import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

/// Cài đặt giao diện và thông tin app.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Chế độ tối'),
                  subtitle: const Text('Giao diện nền đen dịu mắt'),
                  value: settings.darkMode,
                  onChanged: (v) =>
                      context.read<SettingsProvider>().toggleDarkMode(v),
                ),
                const Divider(height: 0),
                SwitchListTile(
                  secondary: const Icon(Icons.volume_up_outlined),
                  title: const Text('Âm thanh'),
                  subtitle: const Text('Phản hồi khi trả lời (nếu có)'),
                  value: settings.soundEnabled,
                  onChanged: (v) =>
                      context.read<SettingsProvider>().toggleSound(v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: const [
                ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Phiên bản'),
                  trailing: Text('1.0.0'),
                ),
                Divider(height: 0),
                ListTile(
                  leading: Icon(Icons.school_outlined),
                  title: Text('Cách chơi'),
                  subtitle: Text(
                      'Chọn đáp án đúng nhanh nhất. Chuỗi đúng liên tiếp tạo combo, càng cao điểm thưởng càng lớn. Hết giờ là kết thúc.'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Math Sprint • Luyện toán mỗi ngày',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
