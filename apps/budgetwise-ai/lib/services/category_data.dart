import 'package:flutter/material.dart';
import '../models/category.dart';

/// Danh sách danh mục cố định sẵn trong app (không cho tạo thêm để giữ
/// trải nghiệm đơn giản, đủ dùng cho chi tiêu cá nhân hằng ngày).
class CategoryData {
  CategoryData._();

  static const List<Category> expenseCategories = [
    Category(
      id: 'food',
      name: 'Ăn uống',
      icon: Icons.restaurant,
      color: Color(0xFFFF7675),
      type: TxType.expense,
    ),
    Category(
      id: 'transport',
      name: 'Di chuyển',
      icon: Icons.directions_car,
      color: Color(0xFF74B9FF),
      type: TxType.expense,
    ),
    Category(
      id: 'shopping',
      name: 'Mua sắm',
      icon: Icons.shopping_bag,
      color: Color(0xFFA29BFE),
      type: TxType.expense,
    ),
    Category(
      id: 'bills',
      name: 'Hóa đơn',
      icon: Icons.receipt_long,
      color: Color(0xFFFFA502),
      type: TxType.expense,
    ),
    Category(
      id: 'entertainment',
      name: 'Giải trí',
      icon: Icons.movie,
      color: Color(0xFFFD79A8),
      type: TxType.expense,
    ),
    Category(
      id: 'health',
      name: 'Sức khỏe',
      icon: Icons.local_hospital,
      color: Color(0xFF00B894),
      type: TxType.expense,
    ),
    Category(
      id: 'education',
      name: 'Giáo dục',
      icon: Icons.school,
      color: Color(0xFF0984E3),
      type: TxType.expense,
    ),
    Category(
      id: 'other_expense',
      name: 'Khác',
      icon: Icons.category,
      color: Color(0xFF636E72),
      type: TxType.expense,
    ),
  ];

  static const List<Category> incomeCategories = [
    Category(
      id: 'salary',
      name: 'Lương',
      icon: Icons.payments,
      color: Color(0xFF00B894),
      type: TxType.income,
    ),
    Category(
      id: 'bonus',
      name: 'Thưởng',
      icon: Icons.card_giftcard,
      color: Color(0xFFFDCB6E),
      type: TxType.income,
    ),
    Category(
      id: 'freelance',
      name: 'Làm thêm',
      icon: Icons.laptop_mac,
      color: Color(0xFF6C5CE7),
      type: TxType.income,
    ),
    Category(
      id: 'other_income',
      name: 'Khác',
      icon: Icons.attach_money,
      color: Color(0xFF00CEC9),
      type: TxType.income,
    ),
  ];

  static List<Category> get all => [...expenseCategories, ...incomeCategories];

  static Category byId(String id) {
    return all.firstWhere(
      (c) => c.id == id,
      orElse: () => expenseCategories.last,
    );
  }

  static List<Category> byType(TxType type) {
    return type == TxType.expense ? expenseCategories : incomeCategories;
  }
}
