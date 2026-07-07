import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/enums.dart';
import '../providers/game_provider.dart';
import '../providers/settings_provider.dart';
import 'game_screen.dart';

class ModeSelectScreen extends StatefulWidget {
  const ModeSelectScreen({super.key});

  @override
  State<ModeSelectScreen> createState() => _ModeSelectScreenState();
}

class _ModeSelectScreenState extends State<ModeSelectScreen> {
  GameMode _mode = GameMode.vsAi;
  late Difficulty _difficulty;
  late int _boardSize;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>().settings;
    _difficulty = settings.defaultDifficulty;
    _boardSize = settings.defaultBoardSize;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chọn chế độ')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Chế độ chơi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          SegmentedButton<GameMode>(
            segments: const [
              ButtonSegment(value: GameMode.vsAi, label: Text('Đấu với máy'), icon: Icon(Icons.smart_toy_outlined)),
              ButtonSegment(value: GameMode.vsPlayer, label: Text('2 người chơi'), icon: Icon(Icons.people_outline)),
            ],
            selected: {_mode},
            onSelectionChanged: (s) => setState(() => _mode = s.first),
          ),
          const SizedBox(height: 24),
          if (_mode == GameMode.vsAi) ...[
            const Text('Độ khó', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            SegmentedButton<Difficulty>(
              segments: const [
                ButtonSegment(value: Difficulty.easy, label: Text('Dễ')),
                ButtonSegment(value: Difficulty.medium, label: Text('Trung bình')),
                ButtonSegment(value: Difficulty.hard, label: Text('Khó')),
              ],
              selected: {_difficulty},
              onSelectionChanged: (s) => setState(() => _difficulty = s.first),
            ),
            const SizedBox(height: 24),
          ],
          const Text('Cỡ bàn cờ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 9, label: Text('9x9')),
              ButtonSegment(value: 13, label: Text('13x13')),
              ButtonSegment(value: 15, label: Text('15x15')),
            ],
            selected: {_boardSize},
            onSelectionChanged: (s) => setState(() => _boardSize = s.first),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Bắt đầu'),
            onPressed: () {
              context.read<GameProvider>().startNewGame(
                    mode: _mode,
                    boardSize: _boardSize,
                    difficulty: _difficulty,
                  );
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const GameScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
