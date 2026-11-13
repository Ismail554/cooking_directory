import '../../../../core/storage/local_json_store.dart';
import '../models/expense_model.dart';

/// Default seed expenses totaling $480.00 across culinary categories.
final List<ExpenseModel> kSeedExpenses = [
  ExpenseModel(
    id: 'exp_001',
    title: 'Supermarket Groceries',
    category: 'Groceries',
    dateLabel: 'Today, 2:30 PM',
    amount: 145.80,
    createdAt: DateTime(2026, 11, 12, 14, 30),
  ),
  ExpenseModel(
    id: 'exp_002',
    title: 'Trattoria Pasta Dinner',
    category: 'Dining Out',
    dateLabel: 'Yesterday, 8:15 PM',
    amount: 68.00,
    createdAt: DateTime(2026, 11, 11, 20, 15),
  ),
  ExpenseModel(
    id: 'exp_003',
    title: 'Chef Knife & Whetstone',
    category: 'Kitchen Tools',
    dateLabel: 'Nov 8, 2026',
    amount: 125.00,
    createdAt: DateTime(2026, 11, 8, 12, 0),
  ),
  ExpenseModel(
    id: 'exp_004',
    title: 'Saffron & Olive Oil',
    category: 'Spices',
    dateLabel: 'Nov 5, 2026',
    amount: 34.20,
    createdAt: DateTime(2026, 11, 5, 16, 0),
  ),
  ExpenseModel(
    id: 'exp_005',
    title: 'Artisan Bakery Box',
    category: 'Delivery',
    dateLabel: 'Nov 3, 2026',
    amount: 22.80,
    createdAt: DateTime(2026, 11, 3, 10, 0),
  ),
  ExpenseModel(
    id: 'exp_006',
    title: 'Organic Farm Veggies',
    category: 'Groceries',
    dateLabel: 'Oct 30, 2026',
    amount: 84.20,
    createdAt: DateTime(2026, 10, 30, 9, 0),
  ),
];

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

