import 'package:flutter/material.dart';
import '../data/symbol_dictionary_data.dart';
import '../widgets/empty_state.dart';

/// Duyệt/tìm kiếm từ điển biểu tượng giấc mơ offline.
class SymbolDictionaryScreen extends StatefulWidget {
  const SymbolDictionaryScreen({super.key});

  @override
  State<SymbolDictionaryScreen> createState() => _SymbolDictionaryScreenState();
}

class _SymbolDictionaryScreenState extends State<SymbolDictionaryScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final results = SymbolDictionaryData.search(_query);
    return Scaffold(
      appBar: AppBar(title: const Text('Từ điển giấc mơ')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                hintText: 'Tìm biểu tượng: rắn, nước, bay...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? const EmptyState(
                    icon: Icons.search_off,
                    title: 'Không tìm thấy',
                    message: 'Thử từ khóa khác.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: results.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final s = results[i];
                      return Card(
                        child: ListTile(
                          title: Text(
                            s.keyword[0].toUpperCase() + s.keyword.substring(1),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(s.meaning),
                          trailing: Chip(
                            label: Text(s.category),
                            visualDensity: VisualDensity.compact,
                          ),
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
