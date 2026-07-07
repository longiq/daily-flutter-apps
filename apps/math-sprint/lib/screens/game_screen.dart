import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/answer_button.dart';
import '../widgets/combo_indicator.dart';
import 'result_screen.dart';

/// Màn hình chơi: hiển thị câu hỏi, đáp án, đồng hồ, điểm, combo.
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _navigated = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final game = context.watch<GameProvider>();

    // Khi hết giờ → chuyển sang màn kết quả (chỉ 1 lần).
    if (game.status == GameStatus.finished && !_navigated) {
      _navigated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ResultScreen()),
        );
      });
    }

    final q = game.question;
    final progress =
        game.mode.durationSeconds == 0 ? 0.0 : game.remaining / game.mode.durationSeconds;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) _confirmQuit(context);
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => _confirmQuit(context),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text('${game.remaining}s',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: game.remaining <= 10
                                      ? scheme.error
                                      : scheme.onSurface)),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: progress.clamp(0.0, 1.0),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _chip(context, Icons.star, 'Điểm', '${game.score}'),
                    _chip(context, Icons.check, 'Đúng', '${game.correct}'),
                  ],
                ),
                ComboIndicator(combo: game.combo),
                const Spacer(),
                if (q != null)
                  Text(
                    q.prompt,
                    style: const TextStyle(
                        fontSize: 56, fontWeight: FontWeight.w800),
                  ),
                const Spacer(),
                if (q != null)
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.0,
                    children: q.options
                        .map((opt) => AnswerButton(
                              value: opt,
                              onTap: () =>
                                  context.read<GameProvider>().answer(opt),
                            ))
                        .toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(
      BuildContext context, IconData icon, String label, String value) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: scheme.primary),
        const SizedBox(width: 6),
        Text('$label: ',
            style: TextStyle(color: scheme.onSurfaceVariant)),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _confirmQuit(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Kết thúc ván?'),
        content: const Text('Điểm hiện tại sẽ được lưu lại.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Tiếp tục'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<GameProvider>().quit();
            },
            child: const Text('Kết thúc'),
          ),
        ],
      ),
    );
  }
}
