import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../services/category_data.dart';
import '../utils/currency_utils.dart';

/// 1 dòng giao dịch trong danh sách (Home / Transactions).
class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cat = CategoryData.byId(transaction.categoryId);
    final isIncome = transaction.type == TxType.income;
    final dateStr = DateFormat('dd/MM/yyyy').format(transaction.date);

    final tile = ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      leading: CircleAvatar(
        backgroundColor: cat.color.withOpacity(0.18),
        child: Icon(cat.icon, color: cat.color, size: 20),
      ),
      title: Text(
        cat.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        transaction.note.isEmpty ? dateStr : '$dateStr • ${transaction.note}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        CurrencyUtils.formatSigned(transaction.amount, isIncome: isIncome),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isIncome ? const Color(0xFF00B894) : const Color(0xFFE17055),
        ),
      ),
    );

    if (onDelete == null) return tile;

    return Dismissible(
      key: ValueKey(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.delete_outline,
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
      ),
      onDismissed: (_) => onDelete!(),
      child: tile,
    );
  }
}
