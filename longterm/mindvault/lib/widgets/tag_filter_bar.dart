import 'package:flutter/material.dart';

/// Hàng chip lọc theo tag, cuộn ngang, hiển thị trên HomeScreen khi vault
/// đã có ít nhất một tag. Nhiều tag có thể được chọn cùng lúc (lọc AND —
/// xem [NoteRepository.search]).
class TagFilterBar extends StatelessWidget {
  final List<String> allTags;
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  final VoidCallback onClear;

  const TagFilterBar({
    super.key,
    required this.allTags,
    required this.selected,
    required this.onToggle,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    if (allTags.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: allTags.length + (selected.isNotEmpty ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          if (selected.isNotEmpty && i == 0) {
            return ActionChip(
              avatar: const Icon(Icons.close, size: 16),
              label: const Text('Bỏ lọc'),
              onPressed: onClear,
            );
          }
          final tag = allTags[i - (selected.isNotEmpty ? 1 : 0)];
          final isSelected = selected.contains(tag);
          return AnimatedScale(
            scale: isSelected ? 1.06 : 1.0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            child: FilterChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (_) => onToggle(tag),
            ),
          );
        },
      ),
    );
  }
}
