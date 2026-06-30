import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const OddColorTapApp());

class OddColorTapApp extends StatelessWidget {
  const OddColorTapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Odd Color Tap',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C5CE7)),
        fontFamily: 'Roboto',
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const int _startTime = 30; // seconds
  final Random _rng = Random();

  int _level = 1;
  int _score = 0;
  int _best = 0;
  int _timeLeft = _startTime;
  bool _playing = false;

  int _gridSize = 2; // grid is gridSize x gridSize
  int _oddIndex = 0;
  late Color _baseColor;
  late Color _oddColor;

  // a simple in-app frame timer using Future loop
  bool _ticking = false;

  void _startGame() {
    setState(() {
      _level = 1;
      _score = 0;
      _timeLeft = _startTime;
      _playing = true;
      _newRound();
    });
    _runTimer();
  }

  Future<void> _runTimer() async {
    if (_ticking) return;
    _ticking = true;
    while (_playing && _timeLeft > 0) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      if (!_playing) break;
      setState(() => _timeLeft--);
    }
    _ticking = false;
    if (_timeLeft <= 0 && _playing) _gameOver();
  }

  void _newRound() {
    // grid grows every 3 levels, capped at 6x6
    _gridSize = (2 + (_level ~/ 3)).clamp(2, 6);
    final total = _gridSize * _gridSize;
    _oddIndex = _rng.nextInt(total);

    // pick a pleasant random base color
    final hue = _rng.nextDouble() * 360;
    _baseColor = HSLColor.fromAHSL(1, hue, 0.55, 0.55).toColor();

    // color difference shrinks as level rises -> harder
    final diff = (0.30 - _level * 0.012).clamp(0.04, 0.30);
    final lighter = _rng.nextBool();
    final l = (0.55 + (lighter ? diff : -diff)).clamp(0.1, 0.9);
    _oddColor = HSLColor.fromAHSL(1, hue, 0.55, l).toColor();
  }

  void _onTileTap(int index) {
    if (!_playing) return;
    if (index == _oddIndex) {
      setState(() {
        _score += _level * 10;
        _level++;
        _timeLeft = (_timeLeft + 2).clamp(0, 60); // reward time
        _newRound();
      });
    } else {
      setState(() {
        _timeLeft = (_timeLeft - 3).clamp(0, 60); // penalty
      });
      if (_timeLeft <= 0) _gameOver();
    }
  }

  void _gameOver() {
    setState(() {
      _playing = false;
      if (_score > _best) _best = _score;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              Expanded(child: _playing ? _buildGrid() : _buildMenu()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _stat('LEVEL', '$_level'),
        _stat('SCORE', '$_score'),
        _stat('TIME', '$_timeLeft', warn: _timeLeft <= 5),
      ],
    );
  }

  Widget _stat(String label, String value, {bool warn = false}) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: warn ? Colors.redAccent : Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildGrid() {
    final total = _gridSize * _gridSize;
    return Center(
      child: AspectRatio(
        aspectRatio: 1,
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: total,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _gridSize,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemBuilder: (context, i) {
            return GestureDetector(
              onTap: () => _onTileTap(i),
              child: Container(
                decoration: BoxDecoration(
                  color: i == _oddIndex ? _oddColor : _baseColor,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMenu() {
    final gameOver = _score > 0 || _best > 0;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Odd Color Tap',
              style: TextStyle(
                  color: Colors.white, fontSize: 34, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Tap the tile with a different color!',
              style: TextStyle(color: Colors.white54, fontSize: 15)),
          const SizedBox(height: 32),
          if (gameOver) ...[
            Text('Last score: $_score',
                style: const TextStyle(color: Colors.white, fontSize: 18)),
            Text('Best: $_best',
                style: const TextStyle(color: Colors.amber, fontSize: 18)),
            const SizedBox(height: 24),
          ],
          FilledButton(
            onPressed: _startGame,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              backgroundColor: const Color(0xFF6C5CE7),
            ),
            child: Text(gameOver ? 'Play again' : 'Start',
                style: const TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }
}
