import 'package:flutter/material.dart';

/// Hiển thị chuỗi combo hiện tại; càng cao càng "nóng".
class ComboIndicator extends StatelessWidget {
  final int combo;

  const ComboIndicator({super.key, required this.combo});

  @override
  Widget build(BuildContext context) {
    if (combo < 2) return const SizedBox(height: 28);
    final hot = combo >= 10;
    final color = hot ? Colors.deepOrange : Theme.of(context).colorScheme.primary;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(hot ? Icons.local_fire_department : Icons.bolt,
            color: color, size: 22),
        const SizedBox(width: 4),
        Text(
          'Combo x$combo',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}
