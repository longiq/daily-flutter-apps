import 'dart:async';
import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../models/game_mode.dart';
import '../models/game_result.dart';
import '../models/question.dart';
import '../services/achievement_service.dart';
import '../services/question_generator.dart';
import '../services/storage_service.dart';

enum GameStatus { idle, running, finished }

/// Điều khiển vòng đời một ván chơi: thời gian, điểm, combo, lưu kết quả.
class GameProvider extends ChangeNotifier {
  final StorageService _storage;
  final QuestionGenerator _generator;
  final AchievementService _achievements;

  GameProvider(
    this._storage, {
    QuestionGenerator? generator,
    AchievementService? achievements,
  })  : _generator = generator ?? QuestionGenerator(),
        _achievements = achievements ?? AchievementService() {
    _history = _storage.loadHistory();
  }

  GameStatus _status = GameStatus.idle;
  GameMode _mode = GameMode.presets.first;
  Question? _question;
  Timer? _timer;

  int _remaining = 0;
  int _score = 0;
  int _correct = 0;
  int _wrong = 0;
  int _combo = 0;
  int _bestCombo = 0;
  int? _lastChoice;
  bool? _lastCorrect;

  List<GameResult> _history = [];
  List<Achievement> _newAchievements = [];

  // ----- Getter -----
  GameStatus get status => _status;
  GameMode get mode => _mode;
  Question? get question => _question;
  int get remaining => _remaining;
  int get score => _score;
  int get correct => _correct;
  int get wrong => _wrong;
  int get combo => _combo;
  int get bestCombo => _bestCombo;
  int? get lastChoice => _lastChoice;
  bool? get lastCorrect => _lastCorrect;
  List<GameResult> get history => List.unmodifiable(_history);
  List<Achievement> get newAchievements => List.unmodifiable(_newAchievements);

  PlayerStats get stats => PlayerStats.fromHistory(_history);
  Set<String> get unlockedIds => _achievements.allUnlocked(stats);

  /// Điểm thưởng cho combo: mỗi 5 chuỗi đúng tăng thêm.
  int get comboBonus => _combo ~/ 5;

  void start(GameMode mode) {
    _timer?.cancel();
    _mode = mode;
    _status = GameStatus.running;
    _remaining = mode.durationSeconds;
    _score = 0;
    _correct = 0;
    _wrong = 0;
    _combo = 0;
    _bestCombo = 0;
    _lastChoice = null;
    _lastCorrect = null;
    _newAchievements = [];
    _question = _generator.next(_mode);
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _remaining--;
      if (_remaining <= 0) {
        _remaining = 0;
        _finish();
      }
      notifyListeners();
    });
  }

  /// Người chơi chọn 1 đáp án.
  void answer(int choice) {
    final q = _question;
    if (_status != GameStatus.running || q == null) return;

    _lastChoice = choice;
    if (q.isCorrect(choice)) {
      _lastCorrect = true;
      _correct++;
      _combo++;
      if (_combo > _bestCombo) _bestCombo = _combo;
      _score += (10 * _mode.difficulty.scoreMultiplier) + comboBonus;
    } else {
      _lastCorrect = false;
      _wrong++;
      _combo = 0;
    }
    _question = _generator.next(_mode);
    notifyListeners();
  }

  void quit() {
    _timer?.cancel();
    if (_status == GameStatus.running) {
      _finish();
    } else {
      _status = GameStatus.idle;
      notifyListeners();
    }
  }

  Future<void> _finish() async {
    _timer?.cancel();
    _status = GameStatus.finished;
    final result = GameResult(
      modeId: _mode.id,
      modeName: _mode.name,
      score: _score,
      correct: _correct,
      wrong: _wrong,
      bestCombo: _bestCombo,
      playedAt: DateTime.now(),
    );
    await _storage.addResult(result);
    _history = _storage.loadHistory();

    final already = _storage.loadUnlocked();
    _newAchievements = _achievements.evaluate(stats, already);
    if (_newAchievements.isNotEmpty) {
      already.addAll(_newAchievements.map((a) => a.id));
      await _storage.saveUnlocked(already);
    }
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await _storage.clearHistory();
    await _storage.saveUnlocked({});
    _history = [];
    notifyListeners();
  }

  void reset() {
    _status = GameStatus.idle;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
