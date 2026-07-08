import 'package:flutter/foundation.dart';
import '../models/budget.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../services/budget_repository.dart';
import '../services/transaction_repository.dart';

/// Nguồn dữ liệu trung tâm cho toàn app: danh sách giao dịch, ngân sách,
/// và tháng đang được chọn để xem (mặc định tháng hiện tại).
class TransactionProvider extends ChangeNotifier {
  final TransactionRepository _txRepo;
  final BudgetRepository _budgetRepo;
  int _idCounter = 0;

  TransactionProvider({
    TransactionRepository? txRepo,
    BudgetRepository? budgetRepo,
  })  : _txRepo = txRepo ?? TransactionRepository(),
        _budgetRepo = budgetRepo ?? BudgetRepository();

  List<Transaction> _transactions = [];
  List<Budget> _budgets = [];
  bool loaded = false;
  DateTime selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  List<Transaction> get all => List.unmodifiable(_transactions);
  List<Budget> get budgets => List.unmodifiable(_budgets);

  Future<void> load() async {
    _transactions = await _txRepo.loadAll();
    _budgets = await _budgetRepo.loadAll();
    loaded = true;
    notifyListeners();
  }

  static String monthKeyOf(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}';

  String get selectedMonthKey => monthKeyOf(selectedMonth);

  String get previousMonthKey {
    final prev = DateTime(selectedMonth.year, selectedMonth.month - 1);
    return monthKeyOf(prev);
  }

  void setSelectedMonth(DateTime month) {
    selectedMonth = DateTime(month.year, month.month);
    notifyListeners();
  }

  void goToPreviousMonth() {
    setSelectedMonth(DateTime(selectedMonth.year, selectedMonth.month - 1));
  }

  void goToNextMonth() {
    setSelectedMonth(DateTime(selectedMonth.year, selectedMonth.month + 1));
  }

  List<Transaction> transactionsForMonth(String monthKey) {
    final list = _transactions.where((t) => t.monthKey == monthKey).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  List<Transaction> get currentMonthTx => transactionsForMonth(selectedMonthKey);
  List<Transaction> get previousMonthTx => transactionsForMonth(previousMonthKey);

  double totalExpense(String monthKey) => transactionsForMonth(monthKey)
      .where((t) => t.type == TxType.expense)
      .fold(0.0, (s, t) => s + t.amount);

  double totalIncome(String monthKey) => transactionsForMonth(monthKey)
      .where((t) => t.type == TxType.income)
      .fold(0.0, (s, t) => s + t.amount);

  double balance(String monthKey) => totalIncome(monthKey) - totalExpense(monthKey);

  Map<String, double> expenseByCategory(String monthKey) {
    final map = <String, double>{};
    for (final t in transactionsForMonth(monthKey)) {
      if (t.type != TxType.expense) continue;
      map[t.categoryId] = (map[t.categoryId] ?? 0) + t.amount;
    }
    return map;
  }

  List<Transaction> search({
    required String monthKey,
    String query = '',
    TxType? type,
    String? categoryId,
  }) {
    return transactionsForMonth(monthKey).where((t) {
      final matchesQuery =
          query.trim().isEmpty || t.note.toLowerCase().contains(query.trim().toLowerCase());
      final matchesType = type == null || t.type == type;
      final matchesCategory = categoryId == null || t.categoryId == categoryId;
      return matchesQuery && matchesType && matchesCategory;
    }).toList();
  }

  Future<Transaction> addTransaction({
    required double amount,
    required String categoryId,
    required TxType type,
    required DateTime date,
    String note = '',
  }) async {
    final tx = Transaction(
      id: '${DateTime.now().microsecondsSinceEpoch}-${_idCounter++}',
      amount: amount,
      categoryId: categoryId,
      type: type,
      date: date,
      note: note,
    );
    _transactions.add(tx);
    notifyListeners();
    await _txRepo.saveAll(_transactions);
    return tx;
  }

  Future<void> updateTransaction(Transaction updated) async {
    final idx = _transactions.indexWhere((t) => t.id == updated.id);
    if (idx == -1) return;
    _transactions[idx] = updated;
    notifyListeners();
    await _txRepo.saveAll(_transactions);
  }

  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
    await _txRepo.saveAll(_transactions);
  }

  Budget? budgetFor(String categoryId) {
    try {
      return _budgets.firstWhere((b) => b.categoryId == categoryId);
    } catch (_) {
      return null;
    }
  }

  Future<void> setBudget(String categoryId, double limit) async {
    final idx = _budgets.indexWhere((b) => b.categoryId == categoryId);
    if (idx == -1) {
      _budgets.add(Budget(categoryId: categoryId, monthlyLimit: limit));
    } else {
      _budgets[idx] = _budgets[idx].copyWith(monthlyLimit: limit);
    }
    notifyListeners();
    await _budgetRepo.saveAll(_budgets);
  }

  Future<void> removeBudget(String categoryId) async {
    _budgets.removeWhere((b) => b.categoryId == categoryId);
    notifyListeners();
    await _budgetRepo.saveAll(_budgets);
  }
}
