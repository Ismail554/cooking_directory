import '../entities/recipe.dart';

abstract class RecipeRepository {
  /// Retrieves all recipes from local and remote data sources.
  Future<List<Recipe>> getAllRecipes();

  /// Saves a new recipe to local storage and syncs with Firestore.
  Future<Recipe> addRecipe(Recipe recipe);

  /// Imports multiple recipes parsed from CSV and stores them.
  Future<List<Recipe>> importRecipesFromCsv(String csvContent);

  /// Converts the provided recipes into CSV format and exports to device.
  Future<String> exportRecipesToCsv(List<Recipe> recipes);
}
