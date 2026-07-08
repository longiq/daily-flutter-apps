import 'package:intl/intl.dart';
import '../models/budget.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import 'category_data.dart';

/// Sinh nhận xét/gợi ý tiết kiệm dựa trên quy tắc đơn giản (không cần AI),
/// dùng làm fallback khi Ollama không khả dụng — và cũng dùng để tóm tắt
/// số liệu gửi cho Ollama phân tích sâu hơn.
class OfflineInsights {
  OfflineInsights._();

  static final _currency = NumberFormat.decimalPattern('vi_VN');

  static String _fmt(double v) => '${_currency.format(v.round())}đ';

  /// Tóm tắt số liệu tháng thành đoạn text ngắn để đưa vào prompt AI.
  static String buildSummary({
    required List<Transaction> monthTx,
    required List<Budget> budgets,
  }) {
    final expense = monthTx.where((t) => t.type == TxType.expense);
    final income = monthTx.where((t) => t.type == TxType.income);
    final totalExpense = expense.fold<double>(0, (s, t) => s + t.amount);
    final totalIncome = income.fold<double>(0, (s, t) => s + t.amount);
    final byCategory = groupByCategory(expense.toList());

    final buf = StringBuffer();
    buf.writeln('Tổng thu: ${_fmt(totalIncome)}');
    buf.writeln('Tổng chi: ${_fmt(totalExpense)}');
    buf.writeln('Số dư: ${_fmt(totalIncome - totalExpense)}');
    buf.writeln('Chi tiêu theo danh mục:');
    final sorted = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    for (final e in sorted) {
      final cat = CategoryData.byId(e.key);
      buf.writeln('- ${cat.name}: ${_fmt(e.value)}');
    }
    if (budgets.isNotEmpty) {
      buf.writeln('Hạn mức ngân sách đã đặt:');
      for (final b in budgets) {
        final cat = CategoryData.byId(b.categoryId);
        final spent = byCategory[b.categoryId] ?? 0;
        buf.writeln(
          '- ${cat.name}: đã chi ${_fmt(spent)} / hạn mức ${_fmt(b.monthlyLimit)}',
        );
      }
    }
    return buf.toString();
  }

  /// Gộp tổng số tiền chi tiêu theo categoryId.
  static Map<String, double> groupByCategory(List<Transaction> tx) {
    final map = <String, double>{};
    for (final t in tx) {
      map[t.categoryId] = (map[t.categoryId] ?? 0) + t.amount;
    }
    return map;
  }

  /// Danh sách nhận xét/gợi ý dựa trên quy tắc — luôn hoạt động offline.
  static List<String> generate({
    required List<Transaction> currentMonthTx,
    required List<Transaction> prevMonthTx,
    required List<Budget> budgets,
  }) {
    final insights = <String>[];

    final expense =
        currentMonthTx.where((t) => t.type == TxType.expense).toList();
    final income =
        currentMonthTx.where((t) => t.type == TxType.income).toList();

    if (expense.isEmpty && income.isEmpty) {
      return [
        'Chưa có giao dịch nào trong tháng này. Hãy thêm vài giao dịch để '
            'nhận nhận xét chi tiêu nhé.',
      ];
    }

    final totalExpense = expense.fold<double>(0, (s, t) => s + t.amount);
    final totalIncome = income.fold<double>(0, (s, t) => s + t.amount);

    // 1) Tỷ lệ tiết kiệm.
    if (totalIncome > 0) {
      final saveRate = ((totalIncome - totalExpense) / totalIncome) * 100;
      if (saveRate >= 20) {
        insights.add(
          'Bạn đang tiết kiệm được ${saveRate.toStringAsFixed(0)}% thu nhập '
              'tháng này — rất tốt, hãy duy trì nhé!',
        );
      } else if (saveRate >= 0) {
        insights.add(
          'Tỷ lệ tiết kiệm tháng này khoảng ${saveRate.toStringAsFixed(0)}% '
              'thu nhập. Thử đặt mục tiêu tiết kiệm tối thiểu 20% xem sao.',
        );
      } else {
        insights.add(
          'Bạn đang chi nhiều hơn thu nhập trong tháng này '
              '(âm ${_fmt(totalExpense - totalIncome)}). Nên rà soát lại các '
              'khoản chi không thiết yếu.',
        );
      }
    }

    // 2) Danh mục chi nhiều nhất.
    final byCategory = groupByCategory(expense);
    if (byCategory.isNotEmpty) {
      final sorted = byCategory.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final top = sorted.first;
      final cat = CategoryData.byId(top.key);
      final pct = totalExpense > 0 ? (top.value / totalExpense * 100) : 0;
      insights.add(
        'Danh mục chi nhiều nhất là "${cat.name}" với ${_fmt(top.value)} '
            '(${pct.toStringAsFixed(0)}% tổng chi tiêu).',
      );
    }

    // 3) So sánh với tháng trước.
    final prevExpense = prevMonthTx
        .where((t) => t.type == TxType.expense)
        .fold<double>(0, (s, t) => s + t.amount);
    if (prevExpense > 0) {
      final diffPct = ((totalExpense - prevExpense) / prevExpense) * 100;
      if (diffPct.abs() >= 5) {
        final dir = diffPct > 0 ? 'tăng' : 'giảm';
        insights.add(
          'Chi tiêu tháng này $dir ${diffPct.abs().toStringAsFixed(0)}% so '
              'với tháng trước (${_fmt(prevExpense)} -> ${_fmt(totalExpense)}).',
        );
      } else {
        insights.add('Chi tiêu tháng này khá ổn định so với tháng trước.');
      }
    }

    // 4) Cảnh báo vượt ngân sách.
    for (final b in budgets) {
      final spent = byCategory[b.categoryId] ?? 0;
      if (spent > b.monthlyLimit) {
        final cat = CategoryData.byId(b.categoryId);
        insights.add(
          'Vượt ngân sách danh mục "${cat.name}": đã chi ${_fmt(spent)} / '
              'hạn mức ${_fmt(b.monthlyLimit)}.',
        );
      } else if (b.monthlyLimit > 0 && spent / b.monthlyLimit >= 0.8) {
        final cat = CategoryData.byId(b.categoryId);
        insights.add(
          'Sắp chạm hạn mức danh mục "${cat.name}" '
              '(${(spent / b.monthlyLimit * 100).toStringAsFixed(0)}%).',
        );
      }
    }

    return insights;
  }
}
