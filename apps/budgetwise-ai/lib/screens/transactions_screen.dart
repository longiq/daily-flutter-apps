import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../providers/transaction_provider.dart';
import '../services/category_data.dart';
import '../widgets/empty_state.dart';
import '../widgets/transaction_tile.dart';
import 'add_transaction_screen.dart';

/// Tab "Giao dịch": danh sách đầy đủ của tháng đang chọn, có tìm kiếm và
/// lọc theo loại/danh mục, vuốt để xóa, chạm để sửa.
class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _query = '';
  TxType? _typeFilter;
  String? _categoryFilter;

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        if (!provider.loaded) {
          return const Center(child: CircularProgressIndicator());
        }
        final results = provider.search(
          monthKey: provider.selectedMonthKey,
          query: _query,
          type: _typeFilter,
          categoryId: _categoryFilter,
        );

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Tìm theo ghi chú...',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _FilterChip(
                    label: 'Tất cả',
                    selected: _typeFilter == null,
                    onSelected: () => setState(() {
                      _typeFilter = null;
                      _categoryFilter = null;
                    }),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Chi tiêu',
                    selected: _typeFilter == TxType.expense,
                    onSelected: () => setState(() {
                      _typeFilter = TxType.expense;
                      _categoryFilter = null;
                    }),
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Thu nhập',
                    selected: _typeFilter == TxType.income,
                    onSelected: () => setState(() {
                      _typeFilter = TxType.income;
                      _categoryFilter = null;
                    }),
                  ),
                  if (_typeFilter != null) ...[
                    const SizedBox(width: 12),
                    ...CategoryData.byType(_typeFilter!).map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _FilterChip(
                          label: c.name,
                          selected: _categoryFilter == c.id,
                          onSelected: () => setState(() {
                            _categoryFilter =
                                _categoryFilter == c.id ? null : c.id;
                          }),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: results.isEmpty
                  ? const EmptyState(
                      icon: Icons.filter_alt_off_outlined,
                      title: 'Không có giao dịch phù hợp',
                      subtitle: 'Thử đổi bộ lọc hoặc thêm giao dịch mới.',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: results.length,
                      itemBuilder: (context, i) {
                        final tx = results[i];
                        return TransactionTile(
                          transaction: tx,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  AddTransactionScreen(existing: tx),
                            ),
                          ),
                          onDelete: () => context
                              .read<TransactionProvider>()
                              .deleteTransaction(tx.id),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}
