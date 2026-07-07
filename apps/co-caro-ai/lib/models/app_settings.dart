import 'enums.dart';

/// Cài đặt người dùng, lưu bền vững qua shared_preferences.
class AppSettings {
  final bool darkMode;
  final bool soundEnabled;
  final int defaultBoardSize;
  final Difficulty defaultDifficulty;
  final bool adsRemoved;

  const AppSettings({
    this.darkMode = false,
    this.soundEnabled = true,
    this.defaultBoardSize = 15,
    this.defaultDifficulty = Difficulty.medium,
    this.adsRemoved = false,
  });

  AppSettings copyWith({
    bool? darkMode,
    bool? soundEnabled,
    int? defaultBoardSize,
    Difficulty? defaultDifficulty,
    bool? adsRemoved,
  }) {
    return AppSettings(
      darkMode: darkMode ?? this.darkMode,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      defaultBoardSize: defaultBoardSize ?? this.defaultBoardSize,
      defaultDifficulty: defaultDifficulty ?? this.defaultDifficulty,
      adsRemoved: adsRemoved ?? this.adsRemoved,
    );
  }

  Map<String, dynamic> toJson() => {
        'darkMode': darkMode,
        'soundEnabled': soundEnabled,
        'defaultBoardSize': defaultBoardSize,
        'defaultDifficulty': defaultDifficulty.name,
        'adsRemoved': adsRemoved,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      darkMode: json['darkMode'] as bool? ?? false,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      defaultBoardSize: json['defaultBoardSize'] as int? ?? 15,
      defaultDifficulty: Difficulty.values.firstWhere(
        (e) => e.name == json['defaultDifficulty'],
        orElse: () => Difficulty.medium,
      ),
      adsRemoved: json['adsRemoved'] as bool? ?? false,
    );
  }
}
