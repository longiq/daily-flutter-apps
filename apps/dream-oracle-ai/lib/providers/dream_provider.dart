import 'package:flutter/foundation.dart';
import '../data/symbol_dictionary_data.dart';
import '../models/dream_entry.dart';
import '../services/cloud_ai_service.dart';
import '../services/dream_repository.dart';
import '../services/offline_interpreter.dart';
import '../services/ollama_service.dart';

/// Quản lý danh sách giấc mơ: CRUD, lưu local, và điều phối diễn giải AI
/// (Ollama) với fallback offline.
class DreamProvider extends ChangeNotifier {
  final DreamRepository _repo;
  final OfflineInterpreter _offlineInterpreter;
  List<DreamEntry> _dreams = [];
  bool _loading = true;
  String? _interpretingId;

  DreamProvider({
    DreamRepository? repository,
    OfflineInterpreter? offlineInterpreter,
  })  : _repo = repository ?? DreamRepository(),
        _offlineInterpreter = offlineInterpreter ?? OfflineInterpreter() {
    _load();
  }

  List<DreamEntry> get dreams => List.unmodifiable(_dreams);
  bool get loading => _loading;
  String? get interpretingId => _interpretingId;

  Future<void> _load() async {
    _dreams = await _repo.loadAll();
    _loading = false;
    notifyListeners();
  }

  DreamEntry? findById(String id) {
    try {
      return _dreams.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<DreamEntry> addDream({
    required String title,
    required String content,
    required String moodEmoji,
    List<String> tags = const [],
  }) async {
    final entry = DreamEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title.trim().isEmpty ? 'Giấc mơ chưa đặt tên' : title.trim(),
      content: content.trim(),
      moodEmoji: moodEmoji,
      tags: tags,
      createdAt: DateTime.now(),
    );
    _dreams.insert(0, entry);
    notifyListeners();
    await _repo.saveAll(_dreams);
    return entry;
  }

  Future<void> updateDream(DreamEntry updated) async {
    final idx = _dreams.indexWhere((d) => d.id == updated.id);
    if (idx == -1) return;
    _dreams[idx] = updated;
    notifyListeners();
    await _repo.saveAll(_dreams);
  }

  Future<void> deleteDream(String id) async {
    _dreams.removeWhere((d) => d.id == id);
    notifyListeners();
    await _repo.saveAll(_dreams);
  }

  /// Diễn giải giấc mơ [id]. Thử Cloud AI (proxy) trước, rồi Ollama, rồi
  /// (trừ khi [forceOffline]) fallback sang từ điển biểu tượng offline.
  Future<void> interpret(
    String id, {
    required String host,
    required String model,
    required bool forceOffline,
    bool useCloud = false,
    String cloudUrl = '',
    String cloudKey = '',
  }) async {
    final dream = findById(id);
    if (dream == null) return;

    _interpretingId = id;
    notifyListeners();

    String? aiText;
    if (!forceOffline) {
      if (useCloud && cloudUrl.isNotEmpty) {
        final cloud = CloudAiService(baseUrl: cloudUrl, proxyKey: cloudKey);
        aiText = await cloud.generate(OllamaService.buildPrompt(dream.content));
      }
      if (aiText == null) {
        final ollama = OllamaService(baseUrl: host, model: model);
        aiText = await ollama.interpretDream(dream.content);
      }
    }

    String finalText;
    List<String> symbols;
    bool usedAi;

    if (aiText != null && aiText.isNotEmpty) {
      finalText = aiText;
      usedAi = true;
      symbols =
          SymbolDictionaryData.match(dream.content).map((m) => m.keyword).toList();
    } else {
      final result = _offlineInterpreter.interpret(dream.content);
      finalText = result.text;
      symbols = result.symbols;
      usedAi = false;
    }

    final updated = dream.copyWith(
      interpretation: finalText,
      matchedSymbols: symbols,
      interpretedByAi: usedAi,
    );
    await updateDream(updated);

    _interpretingId = null;
    notifyListeners();
  }

  // ---- Thống kê cho StatsScreen ----

  /// Số ngày liên tiếp (tính đến hôm nay) có ghi ít nhất 1 giấc mơ.
  int get currentStreak {
    if (_dreams.isEmpty) return 0;
    final days = _dreams
        .map((d) => DateTime(d.createdAt.year, d.createdAt.month, d.createdAt.day))
        .toSet();
    var streak = 0;
    var cursor = DateTime.now();
    cursor = DateTime(cursor.year, cursor.month, cursor.day);
    while (days.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// Tần suất mood emoji, sắp xếp giảm dần.
  List<MapEntry<String, int>> get moodFrequency {
    final map = <String, int>{};
    for (final d in _dreams) {
      map[d.moodEmoji] = (map[d.moodEmoji] ?? 0) + 1;
    }
    final entries = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  /// Tần suất biểu tượng xuất hiện trong các diễn giải đã lưu.
  List<MapEntry<String, int>> get symbolFrequency {
    final map = <String, int>{};
    for (final d in _dreams) {
      for (final s in d.matchedSymbols) {
        map[s] = (map[s] ?? 0) + 1;
      }
    }
    final entries = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  int get totalDreams => _dreams.length;
  int get interpretedCount => _dreams.where((d) => d.interpretation != null).length;
}
