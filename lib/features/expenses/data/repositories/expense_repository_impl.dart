import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_local_datasource.dart';
import '../datasources/expense_remote_datasource.dart';
import '../models/expense_model.dart';

/// Concrete implementation of [ExpenseRepository] coordinating local cache
/// and Realtime Database + Cloud Firestore persistence asynchronously.
class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDataSource _localDataSource;
  final ExpenseRemoteDataSource _remoteDataSource;

  ExpenseRepositoryImpl({
    ExpenseLocalDataSource? localDataSource,
    ExpenseRemoteDataSource? remoteDataSource,
  })  : _localDataSource = localDataSource ?? ExpenseLocalDataSourceImpl(),
        _remoteDataSource = remoteDataSource ?? ExpenseRemoteDataSourceImpl();

  @override
  Future<List<Expense>> getAllExpenses() async {
    final results = await Future.wait([
      _localDataSource.getExpenses(),
      _remoteDataSource.fetchRemoteExpenses(),
    ]);
    final localModels = results[0];
    final remoteModels = results[1];

    final Map<String, Expense> merged = {};
    for (final m in localModels) {
      merged[m.id] = m.toEntity();
    }
    for (final m in remoteModels) {
      merged[m.id] = m.toEntity();
    }
    return merged.values.toList();
  }

  @override
  Future<Expense> addExpense(Expense expense) async {
    final model = ExpenseModel.fromEntity(expense);
    await Future.wait([
      _localDataSource.saveExpense(model),
      _remoteDataSource.saveRemoteExpense(model),
    ]);
    return model.toEntity();
  }

  @override
  Future<void> pushExpensesToCloud(List<Expense> expenses) async {
    final models = expenses.map(ExpenseModel.fromEntity).toList();
    await _remoteDataSource.saveRemoteExpenses(models);
  }

  @override
  Future<void> deleteExpense(String id) async {
    await Future.wait([
      _localDataSource.deleteExpense(id),
      _remoteDataSource.deleteRemoteExpense(id),
    ]);
  }

  @override
  Stream<List<Expense>> watchRemoteExpenses() {
    return _remoteDataSource
        .watchRemoteExpenses()
        .map((models) => models.map((m) => m.toEntity()).toList());
  }
}
