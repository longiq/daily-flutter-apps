import 'package:flutter/material.dart';

/// Các phép toán có thể bật trong một chế độ chơi.
enum Operation { add, subtract, multiply, divide }

extension OperationSymbol on Operation {
  String get symbol {
    switch (this) {
      case Operation.add:
        return '+';
      case Operation.subtract:
        return '−';
      case Operation.multiply:
        return '×';
      case Operation.divide:
        return '÷';
    }
  }

  String get label {
    switch (this) {
      case Operation.add:
        return 'Cộng';
      case Operation.subtract:
        return 'Trừ';
      case Operation.multiply:
        return 'Nhân';
      case Operation.divide:
        return 'Chia';
    }
  }
}

/// Độ khó ảnh hưởng tới khoảng số được sinh ra.
enum Difficulty { easy, medium, hard }

extension DifficultyInfo on Difficulty {
  String get label {
    switch (this) {
      case Difficulty.easy:
        return 'Dễ';
      case Difficulty.medium:
        return 'Vừa';
      case Difficulty.hard:
        return 'Khó';
    }
  }

  /// Giá trị lớn nhất của toán hạng.
  int get maxOperand {
    switch (this) {
      case Difficulty.easy:
        return 10;
      case Difficulty.medium:
        return 25;
      case Difficulty.hard:
        return 50;
    }
  }

  /// Hệ số điểm thưởng theo độ khó.
  int get scoreMultiplier {
    switch (this) {
      case Difficulty.easy:
        return 1;
      case Difficulty.medium:
        return 2;
      case Difficulty.hard:
        return 3;
    }
  }
}

/// Một chế độ chơi: tập phép toán + độ khó + thời lượng.
class GameMode {
  final String id;
  final String name;
  final String description;
  final List<Operation> operations;
  final Difficulty difficulty;
  final int durationSeconds;
  final IconData icon;

  const GameMode({
    required this.id,
    required this.name,
    required this.description,
    required this.operations,
    required this.difficulty,
    this.durationSeconds = 60,
    this.icon = Icons.bolt,
  });

  /// Danh sách chế độ mặc định của app.
  static const List<GameMode> presets = [
    GameMode(
      id: 'add_easy',
      name: 'Khởi động',
      description: 'Chỉ cộng, số nhỏ — làm nóng tay.',
      operations: [Operation.add],
      difficulty: Difficulty.easy,
      icon: Icons.add_circle_outline,
    ),
    GameMode(
      id: 'mixed_medium',
      name: 'Hỗn hợp',
      description: 'Cộng trừ nhân, số vừa.',
      operations: [Operation.add, Operation.subtract, Operation.multiply],
      difficulty: Difficulty.medium,
      icon: Icons.calculate_outlined,
    ),
    GameMode(
      id: 'all_hard',
      name: 'Thử thách',
      description: 'Đủ 4 phép, số lớn — dành cho cao thủ.',
      operations: [
        Operation.add,
        Operation.subtract,
        Operation.multiply,
        Operation.divide,
      ],
      difficulty: Difficulty.hard,
      icon: Icons.local_fire_department_outlined,
    ),
    GameMode(
      id: 'multiply_focus',
      name: 'Bảng cửu chương',
      description: 'Luyện nhân chia tốc độ.',
      operations: [Operation.multiply, Operation.divide],
      difficulty: Difficulty.medium,
      durationSeconds: 45,
      icon: Icons.grid_4x4_outlined,
    ),
  ];

  static GameMode byId(String id) =>
      presets.firstWhere((m) => m.id == id, orElse: () => presets.first);
}
