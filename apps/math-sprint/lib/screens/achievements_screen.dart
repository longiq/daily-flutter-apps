import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/achievement.dart';
import '../providers/game_provider.dart';

/// Danh sách thành tích, đánh dấu cái đã mở khoá.
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final unlocked = context.watch<GameProvider>().unlockedIds;
    final total = Achievement.all.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Thành tích')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Đã mở khoá ${unlocked.length}/$total',
                style: Theme.of(context).textTheme.titleMedium),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: Achievement.all.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final a = Achievement.all[i];
                final got = unlocked.contains(a.id);
                return Card(
                  color: got
                      ? scheme.primaryContainer
                      : scheme.surfaceContainerHighest.withOpacity(0.4),
                  child: ListTile(
                    leading: Icon(
                      got ? a.icon : Icons.lock_outline,
                      color: got
                          ? scheme.onPrimaryContainer
                          : scheme.onSurfaceVariant,
                    ),
                    title: Text(a.title,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: got
                                ? scheme.onPrimaryContainer
                                : scheme.onSurfaceVariant)),
                    subtitle: Text(a.description),
                    trailing: got
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
