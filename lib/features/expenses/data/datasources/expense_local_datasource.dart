import '../../../../core/storage/local_json_store.dart';
import '../models/expense_model.dart';

/// Empty initial expense list so new users start with a clean budget slate.
final List<ExpenseModel> kSeedExpenses = [];

abstract class ExpenseLocalDataSource {
  Future<List<ExpenseModel>> getExpenses();
  Future<void> saveExpense(ExpenseModel expense);
  Future<void> deleteExpense(String id);
}

class ExpenseLocalDataSourceImpl implements ExpenseLocalDataSource {
  const ExpenseLocalDataSourceImpl();

  static String _activeUid = 'guest';
  static final Map<String, List<ExpenseModel>> _cacheByUid = {};

  static void setActiveUid(String? uid) {
    _activeUid = (uid == null || uid.trim().isEmpty) ? 'guest' : uid.trim();
  }

  static String get _fileName => 'expenses_$_activeUid.json';

  Future<List<ExpenseModel>> _ensureLoaded() async {
    final existing = _cacheByUid[_activeUid];
    if (existing != null) return existing;
    final raw = await LocalJsonStore.readList(_fileName);
    final loaded = raw != null && raw.isNotEmpty
        ? raw.map(ExpenseModel.fromJson).toList()
        : List<ExpenseModel>.from(kSeedExpenses);
    _cacheByUid[_activeUid] = loaded;
    return loaded;
  }

  Future<void> _persist(List<ExpenseModel> items) async {
    await LocalJsonStore.writeList(_fileName, items.map((e) => e.toJson()).toList());
  }

  @override
  Future<List<ExpenseModel>> getExpenses() async {
    final list = await _ensureLoaded();
    return List.unmodifiable(list);
  }

  @override
  Future<void> saveExpense(ExpenseModel expense) async {
    final list = await _ensureLoaded();
    final idx = list.indexWhere((e) => e.id == expense.id);
    if (idx >= 0) {
      list[idx] = expense;
    } else {
      list.insert(0, expense);
    }
    await _persist(list);
  }

  @override
  Future<void> deleteExpense(String id) async {
    final list = await _ensureLoaded();
    list.removeWhere((e) => e.id == id);
    await _persist(list);
  }
}

