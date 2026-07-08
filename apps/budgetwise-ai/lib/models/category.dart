import 'package:flutter/material.dart';

/// Loại giao dịch: chi tiêu hoặc thu nhập.
enum TxType { expense, income }

/// Một danh mục thu/chi (định nghĩa sẵn trong [CategoryData], không cho
/// người dùng tự tạo để giữ app đơn giản — nhưng đủ đa dạng cho nhu cầu
/// thường ngày).
class Category {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final TxType type;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });
}
