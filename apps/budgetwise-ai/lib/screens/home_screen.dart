import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/currency_utils.dart';
import '../widgets/empty_state.dart';
import '../widgets/spending_bar_chart.dart';
import '../widgets/transaction_tile.dart';
import 'transactions_screen.dart';

/// Tab "Tổng quan": chọn tháng, số dư/thu/chi, biểu đồ chi theo danh mục,
/// và 5 giao dịch gần nhất.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        if (!provider.loaded) {
          return const Center(child: CircularProgressIndicator());
        }
        final monthKey = provider.selectedMonthKey;
        final income = provider.totalIncome(monthKey);
        final expense = provider.totalExpense(monthKey);
        final balance = income - expense;
        final byCategory = provider.expenseByCategory(monthKey);
        final recent = provider.currentMonthTx.take(5).toList();
        final monthLabel = DateFormat('MM/yyyy').format(provider.selectedMonth);

        return RefreshIndicator(
          onRefresh: provider.load,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: provider.goToPreviousMonth,
                  ),
                  Text(
                    'Tháng $monthLabel',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: provider.goToNextMonth,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _BalanceCard(income: income, expense: expense, balance: balance),
              const SizedBox(height: 20),
              if (byCategory.isNotEmpty) ...[
                Text(
                  'Chi tiêu theo danh mục',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: SpendingBarChart(byCategory: byCategory),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Giao dịch gần đây',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const TransactionsScreen(),
                      ),
                    ),
                    child: const Text('Xem tất cả'),
                  ),
                ],
              ),
              if (recent.isEmpty)
                const EmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: 'Chưa có giao dịch',
                  subtitle: 'Nhấn nút + để thêm giao dịch đầu tiên trong tháng.',
                )
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: recent
                          .map((t) => TransactionTile(transaction: t))
                          .toList(),
                    ),
                  ),
                ),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final double income;
  final double expense;
  final double balance;

  const _BalanceCard({
    required this.income,
    required this.expense,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Số dư tháng này',
              style: TextStyle(color: scheme.onPrimaryContainer, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              CurrencyUtils.format(balance),
              style: TextStyle(
                color: scheme.onPrimaryContainer,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    label: 'Thu nhập',
                    value: income,
                    color: const Color(0xFF00B894),
                    icon: Icons.arrow_downward,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MiniStat(
                    label: 'Chi tiêu',
                    value: expense,
                    color: const Color(0xFFE17055),
                    icon: Icons.arrow_upward,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final IconData icon;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11)),
                Text(
                  CurrencyUtils.format(value),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
