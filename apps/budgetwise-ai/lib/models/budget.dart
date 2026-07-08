/// Hạn mức ngân sách hàng tháng cho 1 danh mục chi tiêu.
///
/// Ngân sách không gắn với tháng cụ thể — luôn áp dụng cho tháng hiện tại
/// (đơn giản hoá: "hạn mức mỗi tháng là X", tự động lặp lại).
class Budget {
  final String categoryId;
  final double monthlyLimit;

  const Budget({required this.categoryId, required this.monthlyLimit});

  Budget copyWith({String? categoryId, double? monthlyLimit}) {
    return Budget(
      categoryId: categoryId ?? this.categoryId,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
    );
  }

  Map<String, dynamic> toJson() => {
        'categoryId': categoryId,
        'monthlyLimit': monthlyLimit,
      };

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      categoryId: json['categoryId'] as String,
      monthlyLimit: (json['monthlyLimit'] as num).toDouble(),
    );
  }
}
