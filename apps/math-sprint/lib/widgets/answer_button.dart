import 'package:flutter/material.dart';

/// Nút đáp án với phản hồi màu khi đúng/sai.
class AnswerButton extends StatelessWidget {
  final int value;
  final VoidCallback onTap;
  final bool? isCorrect; // null = chưa chọn
  final bool selected;

  const AnswerButton({
    super.key,
    required this.value,
    required this.onTap,
    this.isCorrect,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Color bg = scheme.surfaceContainerHighest;
    Color fg = scheme.onSurface;

    if (selected && isCorrect == true) {
      bg = Colors.green.shade600;
      fg = Colors.white;
    } else if (selected && isCorrect == false) {
      bg = scheme.error;
      fg = scheme.onError;
    }

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          height: 72,
          alignment: Alignment.center,
          child: Text(
            '$value',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }
}
