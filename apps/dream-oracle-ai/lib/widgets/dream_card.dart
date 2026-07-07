import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/dream_entry.dart';

/// Thẻ tóm tắt 1 giấc mơ trong danh sách ở HomeScreen.
class DreamCard extends StatelessWidget {
  final DreamEntry dream;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const DreamCard({
    super.key,
    required this.dream,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dateStr = DateFormat('dd/MM/yyyy').format(dream.createdAt);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dream.moodEmoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dream.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dream.content,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: scheme.onSurfaceVariant),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 12, color: scheme.outline),
                        const SizedBox(width: 4),
                        Text(dateStr,
                            style: Theme.of(context).textTheme.bodySmall),
                        if (dream.interpretation != null) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.auto_awesome, size: 12, color: scheme.primary),
                          const SizedBox(width: 4),
                          Text('Đã diễn giải',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: scheme.primary)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
                tooltip: 'Xóa',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
