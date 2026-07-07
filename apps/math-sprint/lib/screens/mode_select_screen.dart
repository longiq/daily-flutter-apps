import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_mode.dart';
import '../providers/game_provider.dart';
import 'game_screen.dart';

/// Chọn chế độ chơi trước khi bắt đầu.
class ModeSelectScreen extends StatelessWidget {
  const ModeSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Chọn chế độ')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: GameMode.presets.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final mode = GameMode.presets[i];
          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: scheme.primaryContainer,
                child: Icon(mode.icon, color: scheme.onPrimaryContainer),
              ),
              title: Text(mode.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${mode.description}\n'
                  '${mode.difficulty.label} • ${mode.durationSeconds}s',
                ),
              ),
              isThreeLine: true,
              trailing: const Icon(Icons.play_circle_fill),
              onTap: () {
                context.read<GameProvider>().start(mode);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const GameScreen()),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
