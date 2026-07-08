import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:budgetwise_ai/models/category.dart';
import 'package:budgetwise_ai/providers/transaction_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('TransactionProvider', () {
    test('addTransaction thêm giao dịch và tính đúng tổng chi', () async {
      final provider = TransactionProvider();
      await provider.load();

      final now = DateTime.now();
      await provider.addTransaction(
        amount: 100000,
        categoryId: 'food',
        type: TxType.expense,
        date: now,
      );
      await provider.addTransaction(
        amount: 50000,
        categoryId: 'transport',
        type: TxType.expense,
        date: now,
      );

      final monthKey = TransactionProvider.monthKeyOf(now);
      expect(provider.totalExpense(monthKey), 150000);
      expect(provider.all.length, 2);
    });

    test('totalIncome và balance tính đúng khi có cả thu và chi', () async {
      final provider = TransactionProvider();
      await provider.load();
      final now = DateTime.now();

      await provider.addTransaction(
        amount: 1000000,
        categoryId: 'salary',
        type: TxType.income,
        date: now,
      );
      await provider.addTransaction(
        amount: 300000,
        categoryId: 'food',
        type: TxType.expense,
        date: now,
      );

      final monthKey = TransactionProvider.monthKeyOf(now);
      expect(provider.totalIncome(monthKey), 1000000);
      expect(provider.balance(monthKey), 700000);
    });

    test('deleteTransaction xóa đúng giao dịch theo id', () async {
      final provider = TransactionProvider();
      await provider.load();

      final tx = await provider.addTransaction(
        amount: 20000,
        categoryId: 'food',
        type: TxType.expense,
        date: DateTime.now(),
      );
      expect(provider.all.length, 1);

      await provider.deleteTransaction(tx.id);
      expect(provider.all, isEmpty);
    });

    test('setBudget rồi budgetFor trả về đúng hạn mức', () async {
      final provider = TransactionProvider();
      await provider.load();

      await provider.setBudget('food', 2000000);
      expect(provider.budgetFor('food')?.monthlyLimit, 2000000);

      await provider.setBudget('food', 2500000);
      expect(provider.budgetFor('food')?.monthlyLimit, 2500000);
      expect(provider.budgets.length, 1);
    });

    test('goToNextMonth/goToPreviousMonth đổi đúng selectedMonthKey', () async {
      final provider = TransactionProvider();
      await provider.load();
      provider.setSelectedMonth(DateTime(2026, 6));

      provider.goToNextMonth();
      expect(provider.selectedMonthKey, '2026-07');

      provider.goToPreviousMonth();
      provider.goToPreviousMonth();
      expect(provider.selectedMonthKey, '2026-05');
    });

    test('expenseByCategory chỉ tính giao dịch chi, không tính thu', () async {
      final provider = TransactionProvider();
      await provider.load();
      final now = DateTime.now();

      await provider.addTransaction(
        amount: 200000,
        categoryId: 'food',
        type: TxType.expense,
        date: now,
      );
      await provider.addTransaction(
        amount: 5000000,
        categoryId: 'salary',
        type: TxType.income,
        date: now,
      );

      final monthKey = TransactionProvider.monthKeyOf(now);
      final byCategory = provider.expenseByCategory(monthKey);
      expect(byCategory['food'], 200000);
      expect(byCategory.containsKey('salary'), isFalse);
    });
  });
}
