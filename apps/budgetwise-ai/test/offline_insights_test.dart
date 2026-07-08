import 'package:flutter_test/flutter_test.dart';
import 'package:budgetwise_ai/models/budget.dart';
import 'package:budgetwise_ai/models/category.dart';
import 'package:budgetwise_ai/models/transaction.dart';
import 'package:budgetwise_ai/services/offline_insights.dart';

Transaction _tx({
  required double amount,
  required String categoryId,
  TxType type = TxType.expense,
  DateTime? date,
}) {
  return Transaction(
    id: 'id-$amount-$categoryId-${date?.millisecondsSinceEpoch ?? 0}',
    amount: amount,
    categoryId: categoryId,
    type: type,
    date: date ?? DateTime(2026, 7, 1),
  );
}

void main() {
  group('OfflineInsights.generate', () {
    test('trả về thông báo khi chưa có giao dịch nào', () {
      final result = OfflineInsights.generate(
        currentMonthTx: [],
        prevMonthTx: [],
        budgets: [],
      );
      expect(result.length, 1);
      expect(result.first, contains('Chưa có giao dịch'));
    });

    test('nhận diện đúng danh mục chi nhiều nhất', () {
      final tx = [
        _tx(amount: 500000, categoryId: 'food'),
        _tx(amount: 100000, categoryId: 'transport'),
      ];
      final result = OfflineInsights.generate(
        currentMonthTx: tx,
        prevMonthTx: [],
        budgets: [],
      );
      expect(result.any((s) => s.contains('Ăn uống')), isTrue);
    });

    test('cảnh báo khi chi tiêu vượt ngân sách danh mục', () {
      final tx = [_tx(amount: 3000000, categoryId: 'food')];
      final budgets = [const Budget(categoryId: 'food', monthlyLimit: 2000000)];
      final result = OfflineInsights.generate(
        currentMonthTx: tx,
        prevMonthTx: [],
        budgets: budgets,
      );
      expect(result.any((s) => s.contains('Vượt ngân sách')), isTrue);
    });

    test('phát hiện chi tiêu tăng mạnh so với tháng trước', () {
      final current = [_tx(amount: 2000000, categoryId: 'food')];
      final prev = [_tx(amount: 1000000, categoryId: 'food')];
      final result = OfflineInsights.generate(
        currentMonthTx: current,
        prevMonthTx: prev,
        budgets: [],
      );
      expect(result.any((s) => s.contains('tăng')), isTrue);
    });

    test('báo âm khi chi tiêu vượt thu nhập', () {
      final tx = [
        _tx(amount: 500000, categoryId: 'salary', type: TxType.income),
        _tx(amount: 800000, categoryId: 'food'),
      ];
      final result = OfflineInsights.generate(
        currentMonthTx: tx,
        prevMonthTx: [],
        budgets: [],
      );
      expect(result.any((s) => s.contains('nhiều hơn thu nhập')), isTrue);
    });
  });

  group('OfflineInsights.buildSummary', () {
    test('tóm tắt chứa tổng thu, tổng chi và số dư', () {
      final tx = [
        _tx(amount: 1000000, categoryId: 'salary', type: TxType.income),
        _tx(amount: 200000, categoryId: 'food'),
      ];
      final summary = OfflineInsights.buildSummary(monthTx: tx, budgets: []);
      expect(summary, contains('Tổng thu'));
      expect(summary, contains('Tổng chi'));
      expect(summary, contains('Số dư'));
    });
  });
}
