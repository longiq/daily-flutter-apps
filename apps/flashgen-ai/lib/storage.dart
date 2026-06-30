import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

/// Lưu/đọc danh sách deck bằng SharedPreferences (offline, không cần server).
class DeckStorage {
  static const _key = 'flashgen_decks';

  Future<List<Deck>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      return Deck.decodeList(raw);
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<Deck> decks) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, Deck.encodeList(decks));
  }
}
