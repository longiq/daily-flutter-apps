import 'package:flutter/material.dart';

import '../models/enums.dart';
import '../theme/app_theme.dart';

/// Một ô trên bàn cờ Caro: có thể trống, chứa quân Đen/Trắng, được highlight
/// nếu nằm trong đường thắng.
class CellWidget extends StatelessWidget {
  const CellWidget({
    super.key,
    required this.player,
    required this.isWinning,
    required this.isLastMove,
    required this.onTap,
  });

  final Player? player;
  final bool isWinning;
  final bool isLastMove;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: isWinning
              ? AppTheme.accent.withOpacity(0.35)
              : (isDark ? AppTheme.boardDark : AppTheme.boardLight),
          border: Border.all(
            color: isDark ? Colors.black45 : Colors.brown.shade300,
            width: 0.5,
          ),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Center(
          child: player == null
              ? null
              : _Stone(player: player!, highlighted: isLastMove),
        ),
      ),
    );
  }
}

class _Stone extends StatelessWidget {
  const _Stone({required this.player, required this.highlighted});

  final Player player;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final isBlack = player == Player.black;
    return FractionallySizedBox(
      widthFactor: 0.72,
      heightFactor: 0.72,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isBlack ? const Color(0xFF212121) : const Color(0xFFFAFAFA),
          border: highlighted
              ? Border.all(color: AppTheme.accent, width: 2)
              : Border.all(color: Colors.black26, width: 0.5),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 1, offset: Offset(0, 1)),
          ],
        ),
      ),
    );
  }
}
