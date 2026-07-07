import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/enums.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/board_widget.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _dialogShown = false;

  String _statusText(GameProvider game) {
    if (game.aiThinking) return 'Máy đang suy nghĩ...';
    switch (game.status) {
      case GameStatus.playing:
        final turnLabel = game.currentPlayer == GameProvider.humanPlayer && game.mode == GameMode.vsAi
            ? 'Lượt của bạn'
            : 'Lượt: ${game.currentPlayer.label}';
        return turnLabel;
      case GameStatus.blackWin:
        return game.mode == GameMode.vsAi ? 'Bạn thắng! 🎉' : 'Đen thắng! 🎉';
      case GameStatus.whiteWin:
        return game.mode == GameMode.vsAi ? 'Máy thắng!' : 'Trắng thắng! 🎉';
      case GameStatus.draw:
        return 'Hoà!';
    }
  }

  void _maybeShowResultDialog(GameProvider game) {
    if (!game.status.isOver || _dialogShown) return;
    _dialogShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(_statusText(game)),
          content: Text('Số nước đi: ${game.moveHistory.length}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Về trang chủ'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _dialogShown = false;
                game.restart();
              },
              child: const Text('Chơi lại'),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, _) {
        _maybeShowResultDialog(game);
        final lastMove = game.moveHistory.isEmpty ? null : game.moveHistory.last;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Cờ Caro AI'),
            actions: [
              IconButton(
                icon: const Icon(Icons.undo_rounded),
                tooltip: 'Hoàn tác',
                onPressed: game.canUndo ? () => game.undoLastMove() : null,
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Chơi lại',
                onPressed: () {
                  _dialogShown = false;
                  game.restart();
                },
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (game.aiThinking)
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      Text(
                        _statusText(game),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: BoardWidget(
                        board: game.board,
                        boardSize: game.boardSize,
                        winningLine: game.winningLine,
                        lastMove: lastMove,
                        enabled: !game.status.isOver && !game.aiThinking,
                        onCellTap: (r, c) => game.placeStone(r, c),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      _LegendDot(color: const Color(0xFF212121), label: 'Đen'),
                      const SizedBox(width: 16),
                      _LegendDot(color: const Color(0xFFFAFAFA), label: 'Trắng', border: true),
                      const Spacer(),
                      Text(
                        '${game.boardSize}x${game.boardSize} · ${game.mode.label}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.primary,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label, this.border = false});

  final Color color;
  final String label;
  final bool border;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: border ? Border.all(color: Colors.black26) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
