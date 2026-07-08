import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../providers/transaction_provider.dart';
import '../services/category_data.dart';
import '../widgets/budget_progress_bar.dart';
import '../widgets/empty_state.dart';

/// Tab "Ngân sách": đặt hạn mức chi tiêu hằng tháng cho từng danh mục và
/// theo dõi tiến độ so với hạn mức trong tháng đang chọn.
class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  Future<void> _editBudget(
    BuildContext context,
    TransactionProvider provider,
    Category category,
  ) async {
    final current = provider.budgetFor(category.id)?.monthlyLimit;
    final controller = TextEditingController(
      text: current == null ? '' : current.round().toString(),
    );
    final result = await showDialog<double?>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hạn mức: ${category.name}'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: false),
          decoration: const InputDecoration(
            labelText: 'Số tiền/tháng (VNĐ)',
            prefixIcon: Icon(Icons.payments_outlined),
          ),
        ),
        actions: [
          if (current != null)
            TextButton(
              onPressed: () => Navigator.of(context).pop(0.0),
              child: const Text('Xóa hạn mức'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              final n = double.tryParse(controller.text.replaceAll(',', ''));
              Navigator.of(context).pop(n);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );

    if (result == null) return;
    if (result <= 0) {
      await provider.removeBudget(category.id);
    } else {
      await provider.setBudget(category.id, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        if (!provider.loaded) {
          return const Center(child: CircularProgressIndicator());
        }
        final monthKey = provider.selectedMonthKey;
        final byCategory = provider.expenseByCategory(monthKey);
        final withBudget = CategoryData.expenseCategories
            .where((c) => provider.budgetFor(c.id) != null)
            .toList();
        final withoutBudget = CategoryData.expenseCategories
            .where((c) => provider.budgetFor(c.id) == null)
            .toList();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (withBudget.isEmpty)
              const EmptyState(
                icon: Icons.pie_chart_outline,
                title: 'Chưa đặt ngân sách nào',
                subtitle:
                    'Chọn danh mục bên dưới để đặt hạn mức chi tiêu hằng tháng.',
              )
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  child: Column(
                    children: withBudget.map((c) {
                      final budget = provider.budgetFor(c.id)!;
                      return BudgetProgressBar(
                        category: c,
                        spent: byCategory[c.id] ?? 0,
                        limit: budget.monthlyLimit,
                        onEdit: () => _editBudget(context, provider, c),
                      );
                    }).toList(),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            if (withoutBudget.isNotEmpty) ...[
              Text(
                'Đặt ngân sách cho danh mục khác',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: withoutBudget.map((c) {
                  return ActionChip(
                    avatar: Icon(c.icon, size: 16, color: c.color),
                    label: Text(c.name),
                    onPressed: () => _editBudget(context, provider, c),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 80),
          ],
        );
      },
    );
  }
}
