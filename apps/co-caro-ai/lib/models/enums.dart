/// Người chơi trên bàn cờ Caro (Gomoku).
enum Player {
  black,
  white;

  Player get opponent => this == Player.black ? Player.white : Player.black;

  String get label => this == Player.black ? 'Đen (X)' : 'Trắng (O)';

  String get symbol => this == Player.black ? 'X' : 'O';
}

/// Chế độ chơi.
enum GameMode {
  vsAi,
  vsPlayer;

  String get label => this == GameMode.vsAi ? 'Đấu với máy' : '2 người chơi';
}

/// Độ khó khi đấu với máy.
enum Difficulty {
  easy,
  medium,
  hard;

  String get label {
    switch (this) {
      case Difficulty.easy:
        return 'Dễ';
      case Difficulty.medium:
        return 'Trung bình';
      case Difficulty.hard:
        return 'Khó';
    }
  }
}

/// Trạng thái ván đấu hiện tại.
enum GameStatus {
  playing,
  blackWin,
  whiteWin,
  draw;

  bool get isOver => this != GameStatus.playing;
}
