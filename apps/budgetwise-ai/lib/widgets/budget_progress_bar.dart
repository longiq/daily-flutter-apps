import 'package:flutter/material.dart';
import '../models/category.dart';
import '../utils/currency_utils.dart';

/// Thanh tiến trình "đã chi / hạn mức" cho 1 danh mục ngân sách.
class BudgetProgressBar extends StatelessWidget {
  final Category category;
  final double spent;
  final double limit;
  final VoidCallback? onEdit;

  const BudgetProgressBar({
    super.key,
    required this.category,
    required this.spent,
    required this.limit,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = limit <= 0 ? 0.0 : (spent / limit).clamp(0.0, 1.5);
    final over = spent > limit;
    final scheme = Theme.of(context).colorScheme;
    final barColor = over
        ? scheme.error
        : ratio >= 0.8
            ? const Color(0xFFFFA502)
            : category.color;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(category.icon, size: 18, color: category.color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  category.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '${CurrencyUtils.format(spent)} / ${CurrencyUtils.format(limit)}',
                style: TextStyle(
                  fontSize: 12,
                  color: over ? scheme.error : scheme.onSurfaceVariant,
                  fontWeight: over ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (onEdit != null)
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  onPressed: onEdit,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: scheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(barColor),
            ),
          ),
          if (over)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Đã vượt ngân sách!',
                style: TextStyle(color: scheme.error, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
