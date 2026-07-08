import 'category.dart';

/// Một giao dịch thu hoặc chi.
class Transaction {
  final String id;
  final double amount;
  final String categoryId;
  final TxType type;
  final String note;
  final DateTime date;

  const Transaction({
    required this.id,
    required this.amount,
    required this.categoryId,
    required this.type,
    required this.date,
    this.note = '',
  });

  /// Khóa tháng dạng "yyyy-MM", dùng để nhóm/lọc theo tháng.
  String get monthKey =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}';

  Transaction copyWith({
    String? id,
    double? amount,
    String? categoryId,
    TxType? type,
    String? note,
    DateTime? date,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      note: note ?? this.note,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'categoryId': categoryId,
        'type': type.name,
        'note': note,
        'date': date.toIso8601String(),
      };

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      categoryId: json['categoryId'] as String,
      type: TxType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => TxType.expense,
      ),
      note: json['note'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
    );
  }
}
