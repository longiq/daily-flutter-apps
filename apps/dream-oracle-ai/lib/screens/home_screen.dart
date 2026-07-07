import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dream_provider.dart';
import '../widgets/dream_card.dart';
import '../widgets/empty_state.dart';
import 'edit_dream_screen.dart';
import 'interpretation_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';
import 'symbol_dictionary_screen.dart';

/// Màn chính: danh sách nhật ký giấc mơ + tìm kiếm + điều hướng.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DreamProvider>();
    final dreams = _query.trim().isEmpty
        ? provider.dreams
        : provider.dreams.where((d) {
            final q = _query.toLowerCase();
            return d.title.toLowerCase().contains(q) ||
                d.content.toLowerCase().contains(q) ||
                d.tags.any((t) => t.toLowerCase().contains(q));
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('🌙 Dream Oracle AI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book_outlined),
            tooltip: 'Từ điển giấc mơ',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SymbolDictionaryScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart_outlined),
            tooltip: 'Thống kê',
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const StatsScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Cài đặt',
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: const InputDecoration(
                      hintText: 'Tìm giấc mơ, tag...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                Expanded(
                  child: dreams.isEmpty
                      ? EmptyState(
                          icon: Icons.nightlight_round,
                          title: provider.dreams.isEmpty
                              ? 'Chưa có giấc mơ nào'
                              : 'Không tìm thấy kết quả',
                          message: provider.dreams.isEmpty
                              ? 'Nhấn nút + để ghi lại giấc mơ đầu tiên của bạn.'
                              : 'Thử từ khóa khác.',
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                          itemCount: dreams.length,
                          itemBuilder: (context, i) {
                            final dream = dreams[i];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: DreamCard(
                                dream: dream,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        InterpretationScreen(dreamId: dream.id),
                                  ),
                                ),
                                onDelete: () => _confirmDelete(context, dream.id),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const EditDreamScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Ghi giấc mơ'),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa giấc mơ?'),
        content: const Text('Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              context.read<DreamProvider>().deleteDream(id);
              Navigator.pop(ctx);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
