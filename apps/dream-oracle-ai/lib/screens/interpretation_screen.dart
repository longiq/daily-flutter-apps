import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dream_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/symbol_chip.dart';

/// Hiển thị nội dung giấc mơ + kết quả diễn giải (AI hoặc offline).
class InterpretationScreen extends StatefulWidget {
  final String dreamId;

  const InterpretationScreen({super.key, required this.dreamId});

  @override
  State<InterpretationScreen> createState() => _InterpretationScreenState();
}

class _InterpretationScreenState extends State<InterpretationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dream = context.read<DreamProvider>().findById(widget.dreamId);
      if (dream != null && dream.interpretation == null) {
        _runInterpretation();
      }
    });
  }

  Future<void> _runInterpretation() async {
    final settings = context.read<SettingsProvider>();
    await context.read<DreamProvider>().interpret(
          widget.dreamId,
          host: settings.host,
          model: settings.model,
          forceOffline: settings.forceOffline,
          useCloud: settings.useCloud,
          cloudUrl: settings.cloudUrl,
          cloudKey: settings.cloudKey,
        );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DreamProvider>();
    final dream = provider.findById(widget.dreamId);
    final isInterpreting = provider.interpretingId == widget.dreamId;

    if (dream == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Diễn giải')),
        body: const Center(child: Text('Không tìm thấy giấc mơ này.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(dream.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(dream.moodEmoji, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 8),
                        Text('Nội dung giấc mơ',
                            style: Theme.of(context).textTheme.titleMedium),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(dream.content),
                    if (dream.tags.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        children:
                            dream.tags.map((t) => Chip(label: Text(t))).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.auto_awesome,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text('Diễn giải', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                if (!isInterpreting)
                  TextButton.icon(
                    onPressed: _runInterpretation,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Diễn giải lại'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (isInterpreting)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text('Đang phân tích giấc mơ...'),
                    ],
                  ),
                ),
              )
            else if (dream.interpretation != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dream.interpretation!),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            dream.interpretedByAi
                                ? Icons.smart_toy_outlined
                                : Icons.menu_book_outlined,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            dream.interpretedByAi
                                ? 'Diễn giải bởi AI'
                                : 'Diễn giải offline (từ điển biểu tượng)',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (dream.matchedSymbols.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      dream.matchedSymbols.map((s) => SymbolChip(label: s)).toList(),
                ),
              ],
            ] else
              const Text('Chưa có diễn giải.'),
          ],
        ),
      ),
    );
  }
}
