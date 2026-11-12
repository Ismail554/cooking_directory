import 'package:flutter/foundation.dart';
import '../../data/repositories/recipe_repository_impl.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../../domain/usecases/import_recipes_from_csv_usecase.dart';

class RecipeProvider extends ChangeNotifier {
  final RecipeRepository _repository;
  final ImportRecipesFromCsvUseCase _importUseCase;

  List<Recipe> _recipes = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = false;
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

  Future<void> loadRecipes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _recipes = await _repository.getAllRecipes();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addRecipe(Recipe recipe) async {
    try {
      final saved = await _repository.addRecipe(recipe);
      _recipes.removeWhere((r) => r.id == saved.id);
      _recipes.insert(0, saved);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
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
      notifyListeners();
      return imported.length;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst(RegExp(r'^(Exception|StateError):\s*'), '');
      notifyListeners();
      return 0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleFavorite(String recipeId) {
    final idx = _recipes.indexWhere((r) => r.id == recipeId);
    if (idx >= 0) {
      final current = _recipes[idx];
      _recipes[idx] = current.copyWith(isFavorite: !current.isFavorite);
      _repository.addRecipe(_recipes[idx]);
      notifyListeners();
    }
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}

