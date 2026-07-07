import 'package:flutter/material.dart';

import '../models/match_record.dart';
import '../services/storage_service.dart';

/// Thống kê + lịch sử các ván đã chơi (đấu với máy).
class StatsProvider extends ChangeNotifier {
  StatsProvider({StorageService? storage}) : _storage = storage ?? StorageService();

  final StorageService _storage;
  List<MatchRecord> _history = [];
  bool _loaded = false;

  List<MatchRecord> get history => List.unmodifiable(_history);
  bool get isLoaded => _loaded;

  int get totalGames => _history.length;
  int get wins => _history.where((m) => m.playerWon).length;
  int get losses => _history.where((m) => m.playerLost).length;
  int get draws => _history.where((m) => m.isDraw).length;

  double get winRate => totalGames == 0 ? 0 : wins / totalGames;

  Future<void> load() async {
    _history = await _storage.loadHistory();
    _loaded = true;
    notifyListeners();
  }

  Future<void> recordMatch(MatchRecord record) async {
    await _storage.addMatchRecord(record);
    _history.insert(0, record);
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await _storage.clearHistory();
    _history = [];
    notifyListeners();
  }
}
