import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/datasources/recipe_seed_data.dart';
import '../../data/repositories/recipe_repository_impl.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../../domain/usecases/import_recipes_from_csv_usecase.dart';

class RecipeProvider extends ChangeNotifier {
  final RecipeRepository _repository;
  final ImportRecipesFromCsvUseCase _importUseCase;
  StreamSubscription<List<Recipe>>? _realtimeSub;

  List<Recipe> _recipes = kSeedRecipes.map((e) => e.toEntity()).toList();
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = false;
  bool _isSaving = false;
  bool _realtimeSyncEnabled = true;
  String? _errorMessage;

  RecipeProvider({
    RecipeRepository? repository,
  })  : _repository = repository ?? RecipeRepositoryImpl(),
        _importUseCase = ImportRecipesFromCsvUseCase(
          repository ?? RecipeRepositoryImpl(),
        ) {
    loadRecipes();
  }

  List<Recipe> get allRecipes => _recipes;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isRealtimeSyncEnabled => _realtimeSyncEnabled;
  String? get errorMessage => _errorMessage;

  List<Recipe> get filteredRecipes {
    return _recipes.where((recipe) {
      final matchesCategory = _selectedCategory == 'All' ||
          recipe.category.toLowerCase() == _selectedCategory.toLowerCase();
      final q = _searchQuery.trim().toLowerCase();
      final matchesSearch = q.isEmpty ||
          recipe.title.toLowerCase().contains(q) ||
          recipe.subtitle.toLowerCase().contains(q) ||
          recipe.description.toLowerCase().contains(q) ||
          recipe.ingredients.any((i) => i.toLowerCase().contains(q));
      return matchesCategory && matchesSearch;
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
    _realtimeSub = _repository.watchRemoteRecipes().listen((remoteList) {
      if (remoteList.isEmpty) return;
      final Map<String, Recipe> merged = {
        for (final r in _recipes) r.id: r,
        for (final r in remoteList) r.id: r,
      };
      _recipes = merged.values.toList();
      notifyListeners();
    }, onError: (_) {});
  }

  void stopRealtimeSync() {
    _realtimeSub?.cancel();
    _realtimeSub = null;
  }

  Future<void> pushLocalToCloud() async {
    await _repository.pushRecipesToCloud(_recipes);
  }

  Future<void> loadRecipes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final fetched = await _repository.getAllRecipes();
      if (fetched.isNotEmpty) _recipes = fetched;
      if (_realtimeSyncEnabled) startRealtimeSync();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Recipe> getRecipeById(String? id, {String? title}) async {
    if (_recipes.isEmpty) await loadRecipes();
    final list = _recipes.isNotEmpty
        ? _recipes
        : kSeedRecipes.map((e) => e.toEntity()).toList();
    return list.firstWhere(
      (r) => r.id == id || (id == null && title != null && r.title == title),
      orElse: () => list.first,
    );
  }

  Future<bool> addRecipe(Recipe recipe) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final saved = _realtimeSyncEnabled
          ? await _repository.addRecipe(recipe)
          : recipe;
      _recipes.removeWhere((r) => r.id == saved.id);
      _recipes.insert(0, saved);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> deleteRecipe(String id) async {
    _recipes.removeWhere((r) => r.id == id);
    notifyListeners();
    if (_realtimeSyncEnabled) {
      await _repository.deleteRecipe(id);
    }
  }

  Future<int> importFromCsv(String csvContent) async {
    _isLoading = true;
    notifyListeners();
    try {
      final imported = await _importUseCase(csvContent);
      for (final r in imported) {
        _recipes.removeWhere((existing) => existing.id == r.id);
        _recipes.insert(0, r);
      }
      _errorMessage = null;
      return imported.length;
    } catch (e) {
      _errorMessage =
          e.toString().replaceFirst(RegExp(r'^(Exception|StateError):\s*'), '');
      return 0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String recipeId) async {
    final idx = _recipes.indexWhere((r) => r.id == recipeId);
    if (idx < 0) return;
    final current = _recipes[idx];
    final updated = current.copyWith(isFavorite: !current.isFavorite);
    _recipes[idx] = updated;
    notifyListeners();
    if (!_realtimeSyncEnabled) return;
    try {
      await _repository.addRecipe(updated);
    } catch (_) {
      _recipes[idx] = current;
      notifyListeners();
    }
  }

  void setCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    notifyListeners();
  }

  @override
  void dispose() {
    stopRealtimeSync();
    super.dispose();
  }
}
