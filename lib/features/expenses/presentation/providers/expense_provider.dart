import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/datasources/expense_local_datasource.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';

/// State management provider for food & grocery expenses with Realtime DB
/// and Cloud Firestore streaming sync and user controls.
class ExpenseProvider extends ChangeNotifier {
  final ExpenseRepository _repository;
  StreamSubscription<List<Expense>>? _realtimeSub;

  List<Expense> _expenses =
      kSeedExpenses.map((e) => e.toEntity()).toList();
  String _selectedCategory = 'All';
  DateTime? _selectedDate;
  bool _isLoading = false;
  bool _isSaving = false;
  bool _realtimeSyncEnabled = true;
  String? _errorMessage;

  ExpenseProvider({
    ExpenseRepository? repository,
  }) : _repository = repository ?? ExpenseRepositoryImpl() {
    loadExpenses();
  }

  List<Expense> get allExpenses => List.unmodifiable(_expenses);
  String get selectedCategory => _selectedCategory;
  DateTime? get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isRealtimeSyncEnabled => _realtimeSyncEnabled;
  String? get errorMessage => _errorMessage;

  double get totalSpent =>
      _expenses.fold<double>(0.0, (sum, item) => sum + item.amount);

  List<Expense> get filteredExpenses {
    return _expenses.where((e) {
      final catMatch = _selectedCategory == 'All' ||
          e.category.toLowerCase() == _selectedCategory.toLowerCase();
      if (!catMatch) return false;
      if (_selectedDate == null) return true;
      return e.createdAt.year == _selectedDate!.year &&
          e.createdAt.month == _selectedDate!.month &&
          e.createdAt.day == _selectedDate!.day;
    }).toList();
  }

  void setRealtimeSyncEnabled(bool enabled) {
    _realtimeSyncEnabled = enabled;
    if (enabled) {
      startRealtimeSync();
    } else {
      stopRealtimeSync();
    }
    notifyListeners();
  }

  void startRealtimeSync() {
    stopRealtimeSync();
    if (!_realtimeSyncEnabled) return;
    _realtimeSub = _repository.watchRemoteExpenses().listen((remoteList) {
      if (remoteList.isEmpty) return;
      final Map<String, Expense> merged = {
        for (final e in _expenses) e.id: e,
        for (final e in remoteList) e.id: e,
      };
      _expenses = merged.values.toList();
      notifyListeners();
    }, onError: (_) {});
  }

  void stopRealtimeSync() {
    _realtimeSub?.cancel();
    _realtimeSub = null;
  }

  Future<void> pushLocalToCloud() async {
    await _repository.pushExpensesToCloud(_expenses);
  }

  Future<void> loadExpenses({bool showLoading = false}) async {
    if (showLoading) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }
    try {
      final fetched = await _repository.getAllExpenses();
      if (fetched.isNotEmpty) _expenses = fetched;
      if (_realtimeSyncEnabled) startRealtimeSync();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addExpense(Expense expense) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final saved = _realtimeSyncEnabled
          ? await _repository.addExpense(expense)
          : expense;
      _expenses.removeWhere((e) => e.id == saved.id);
      _expenses.insert(0, saved);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> deleteExpense(String id) async {
    final previous = List<Expense>.from(_expenses);
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();
    if (!_realtimeSyncEnabled) return;
    try {
      await _repository.deleteExpense(id);
    } catch (e) {
      _expenses = previous;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void setCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    notifyListeners();
  }

  void setSelectedDate(DateTime? date) {
    _selectedDate = date;
    notifyListeners();
  }

  @override
  void dispose() {
    stopRealtimeSync();
    super.dispose();
  }
}
