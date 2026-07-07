import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dream_provider.dart';
import '../widgets/empty_state.dart';

/// Thống kê đơn giản: streak, tổng số giấc mơ, mood/biểu tượng phổ biến.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DreamProvider>();

    if (provider.totalDreams == 0) {
      return Scaffold(
        appBar: AppBar(title: const Text('Thống kê')),
        body: const EmptyState(
          icon: Icons.bar_chart_outlined,
          title: 'Chưa có dữ liệu',
          message: 'Ghi vài giấc mơ để xem thống kê ở đây.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Thống kê')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.local_fire_department,
                  label: 'Streak',
                  value: '${provider.currentStreak} ngày',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.nightlight_round,
                  label: 'Tổng giấc mơ',
                  value: '${provider.totalDreams}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _StatCard(
            icon: Icons.auto_awesome,
            label: 'Đã diễn giải',
            value: '${provider.interpretedCount}/${provider.totalDreams}',
          ),
          const SizedBox(height: 24),
          Text('Cảm xúc phổ biến', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...provider.moodFrequency.take(5).map(
                (e) => _FrequencyRow(
                  label: e.key,
                  count: e.value,
                  max: provider.moodFrequency.first.value,
                ),
              ),
          const SizedBox(height: 24),
          Text('Biểu tượng thường gặp', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (provider.symbolFrequency.isEmpty)
            Text(
              'Chưa có biểu tượng nào được nhận diện. Hãy diễn giải thêm vài giấc mơ.',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else
            ...provider.symbolFrequency.take(8).map(
                  (e) => _FrequencyRow(
                    label: e.key,
                    count: e.value,
                    max: provider.symbolFrequency.first.value,
                  ),
                ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: scheme.primary),
            const SizedBox(height: 8),
            Text(value,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _FrequencyRow extends StatelessWidget {
  final String label;
  final int count;
  final int max;

  const _FrequencyRow({required this.label, required this.count, required this.max});

  @override
  Widget build(BuildContext context) {
    final ratio = max == 0 ? 0.0 : count / max;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 32, child: Text(label, style: const TextStyle(fontSize: 18))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: ratio.clamp(0.0, 1.0),
                minHeight: 10,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('$count'),
        ],
      ),
    );
  }
}
