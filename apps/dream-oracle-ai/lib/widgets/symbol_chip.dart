import 'package:flutter/material.dart';

/// Chip hiển thị 1 biểu tượng giấc mơ đã nhận diện.
class SymbolChip extends StatelessWidget {
  final String label;

  const SymbolChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Chip(
      label: Text(label),
      avatar: const Icon(Icons.auto_awesome, size: 16),
      backgroundColor: scheme.secondaryContainer,
      labelStyle: TextStyle(color: scheme.onSecondaryContainer),
      side: BorderSide.none,
    );
  }
}
