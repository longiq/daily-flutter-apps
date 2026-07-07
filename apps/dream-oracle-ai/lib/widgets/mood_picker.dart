import 'package:flutter/material.dart';

/// Chọn 1 emoji thể hiện cảm xúc khi tỉnh dậy sau giấc mơ.
class MoodPicker extends StatelessWidget {
  static const moods = ['😴', '😊', '😨', '😢', '😡', '😐', '🤩', '😵'];

  final String selected;
  final ValueChanged<String> onChanged;

  const MoodPicker({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: moods.map((m) {
        final isSelected = m == selected;
        return GestureDetector(
          onTap: () => onChanged(m),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceContainerHigh,
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                  : null,
            ),
            child: Text(m, style: const TextStyle(fontSize: 22)),
          ),
        );
      }).toList(),
    );
  }
}
