import 'package:flutter_test/flutter_test.dart';
import 'package:budgetwise_ai/models/category.dart';
import 'package:budgetwise_ai/models/transaction.dart';

void main() {
  group('Transaction', () {
    test('toJson/fromJson round-trip giữ nguyên dữ liệu', () {
      final tx = Transaction(
        id: 'tx1',
        amount: 150000,
        categoryId: 'food',
        type: TxType.expense,
        date: DateTime(2026, 7, 8),
        note: 'Ăn trưa',
      );
      final json = tx.toJson();
      final restored = Transaction.fromJson(json);

      expect(restored.id, tx.id);
      expect(restored.amount, tx.amount);
      expect(restored.categoryId, tx.categoryId);
      expect(restored.type, tx.type);
      expect(restored.note, tx.note);
      expect(restored.date, tx.date);
    });

    test('fromJson dùng expense làm mặc định khi type lạ', () {
      final json = {
        'id': 'tx2',
        'amount': 1000,
        'categoryId': 'other_expense',
        'type': 'khong_hop_le',
        'note': '',
        'date': DateTime(2026, 1, 1).toIso8601String(),
      };
      final restored = Transaction.fromJson(json);
      expect(restored.type, TxType.expense);
    });

    test('monthKey trả về đúng định dạng yyyy-MM', () {
      final tx = Transaction(
        id: 'tx3',
        amount: 1,
        categoryId: 'other_expense',
        type: TxType.expense,
        date: DateTime(2026, 3, 15),
      );
      expect(tx.monthKey, '2026-03');
    });

    test('copyWith chỉ thay đổi field được truyền vào', () {
      final tx = Transaction(
        id: 'tx4',
        amount: 500,
        categoryId: 'food',
        type: TxType.expense,
        date: DateTime(2026, 5, 1),
        note: 'gốc',
      );
      final updated = tx.copyWith(amount: 700);
      expect(updated.amount, 700);
      expect(updated.categoryId, 'food');
      expect(updated.note, 'gốc');
    });
  });
}
