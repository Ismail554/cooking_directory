import '../../domain/entities/expense.dart';

/// Data Transfer Object for [Expense] supporting Firestore & JSON serialization.
class ExpenseModel extends Expense {
  const ExpenseModel({
    required super.id,
    required super.title,
    required super.category,
    required super.dateLabel,
    required super.amount,
    required super.createdAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Expense',
      category: json['category'] as String? ?? 'Groceries',
      dateLabel: json['dateLabel'] as String? ?? 'Today',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'dateLabel': dateLabel,
      'amount': amount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ExpenseModel.fromEntity(Expense expense) {
    return ExpenseModel(
      id: expense.id,
      title: expense.title,
      category: expense.category,
      dateLabel: expense.dateLabel,
      amount: expense.amount,
      createdAt: expense.createdAt,
    );
  }

  Expense toEntity() => this;
}

