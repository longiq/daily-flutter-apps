import 'package:flutter_test/flutter_test.dart';
import 'package:budgetwise_ai/models/category.dart';
import 'package:budgetwise_ai/services/category_data.dart';

void main() {
  group('CategoryData', () {
    test('byId trả về đúng danh mục theo id', () {
      final cat = CategoryData.byId('food');
      expect(cat.name, 'Ăn uống');
      expect(cat.type, TxType.expense);
    });

    test('byId trả về danh mục "Khác" khi id không tồn tại', () {
      final cat = CategoryData.byId('id-khong-ton-tai');
      expect(cat.id, 'other_expense');
    });

    test('byType trả về đúng danh sách theo loại', () {
      final expense = CategoryData.byType(TxType.expense);
      final income = CategoryData.byType(TxType.income);
      expect(expense.every((c) => c.type == TxType.expense), isTrue);
      expect(income.every((c) => c.type == TxType.income), isTrue);
    });

    test('all gồm đủ danh mục chi và thu, không trùng id', () {
      final ids = CategoryData.all.map((c) => c.id).toList();
      expect(ids.length, ids.toSet().length);
      expect(
        CategoryData.all.length,
        CategoryData.expenseCategories.length + CategoryData.incomeCategories.length,
      );
    });
  });
}
