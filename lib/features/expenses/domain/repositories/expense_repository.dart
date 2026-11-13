import '../entities/expense.dart';

/// Repository contract for managing food & kitchen expenses asynchronously.
abstract class ExpenseRepository {
  Future<List<Expense>> getAllExpenses();
  Future<Expense> addExpense(Expense expense);
  Future<void> pushExpensesToCloud(List<Expense> expenses);
  Future<void> deleteExpense(String id);
  Stream<List<Expense>> watchRemoteExpenses();
}
