import 'package:flutter/material.dart';
import '../services/category_data.dart';
import '../utils/currency_utils.dart';

/// Biểu đồ thanh ngang đơn giản (không dùng thư viện ngoài) hiển thị chi
/// tiêu theo danh mục, sắp xếp giảm dần.
class SpendingBarChart extends StatelessWidget {
  final Map<String, double> byCategory;
  final int maxItems;

  const SpendingBarChart({
    super.key,
    required this.byCategory,
    this.maxItems = 5,
  });

  @override
  Widget build(BuildContext context) {
    if (byCategory.isEmpty) {
      return const SizedBox.shrink();
    }
    final entries = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = entries.take(maxItems).toList();
    final maxVal = top.first.value <= 0 ? 1.0 : top.first.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: top.map((e) {
        final cat = CategoryData.byId(e.key);
        final ratio = (e.value / maxVal).clamp(0.05, 1.0);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(cat.icon, size: 14, color: cat.color),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(cat.name, style: const TextStyle(fontSize: 13)),
                  ),
                  Text(
                    CurrencyUtils.format(e.value),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LayoutBuilder(
                builder: (context, constraints) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      height: 8,
                      width: constraints.maxWidth,
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: ratio,
                          child: Container(color: cat.color),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
