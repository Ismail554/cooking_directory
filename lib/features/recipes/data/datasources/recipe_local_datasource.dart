import '../models/recipe_model.dart';
import 'recipe_seed_data.dart';

abstract class RecipeLocalDataSource {
  /// Fetches seed and stored local recipes.
  Future<List<RecipeModel>> getSeedRecipes();

  /// Adds a new recipe to local storage.
  Future<void> saveRecipe(RecipeModel recipe);

  /// Adds multiple recipes to local storage.
  Future<void> saveRecipes(List<RecipeModel> recipes);
}

class RecipeLocalDataSourceImpl implements RecipeLocalDataSource {
  const RecipeLocalDataSourceImpl();

  static final List<RecipeModel> _inMemoryRecipes = List.from(kSeedRecipes);

  @override
  Future<List<RecipeModel>> getSeedRecipes() async {
    return List.unmodifiable(_inMemoryRecipes);
  }

  @override
  Future<void> saveRecipe(RecipeModel recipe) async {
    final idx = _inMemoryRecipes.indexWhere((r) => r.id == recipe.id);
    if (idx >= 0) {
      _inMemoryRecipes[idx] = recipe;
    } else {
      _inMemoryRecipes.insert(0, recipe);
    }
  }

  @override
  Future<void> saveRecipes(List<RecipeModel> recipes) async {
    for (final recipe in recipes) {
      await saveRecipe(recipe);
    }
  }
}
