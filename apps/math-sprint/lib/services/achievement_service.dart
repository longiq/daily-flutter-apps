import '../models/achievement.dart';

/// Xét các thành tích vừa đạt được dựa trên thống kê người chơi.
class AchievementService {
  /// Trả về danh sách thành tích MỚI mở khoá (chưa có trong [already]).
  List<Achievement> evaluate(PlayerStats stats, Set<String> already) {
    final newly = <Achievement>[];
    for (final a in Achievement.all) {
      if (!already.contains(a.id) && a.condition(stats)) {
        newly.add(a);
      }
    }
    return newly;
  }

  /// Tập id tất cả thành tích đang thoả điều kiện.
  Set<String> allUnlocked(PlayerStats stats) => Achievement.all
      .where((a) => a.condition(stats))
      .map((a) => a.id)
      .toSet();
}
