/// Domain entity representing a culinary or grocery expense entry.
class Expense {
  final String id;
  final String title;
  final String category;
  final String dateLabel;
  final double amount;
  final DateTime createdAt;

  const Expense({
    required this.id,
    required this.title,
    required this.category,
    required this.dateLabel,
    required this.amount,
    required this.createdAt,
  });

  Expense copyWith({
    String? id,
    String? title,
    String? category,
    String? dateLabel,
    double? amount,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      dateLabel: dateLabel ?? this.dateLabel,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Expense && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

