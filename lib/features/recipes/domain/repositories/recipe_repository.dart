import '../entities/recipe.dart';

abstract class RecipeRepository {
  /// Retrieves all recipes from the local/remote data sources.
  Future<List<Recipe>> getAllRecipes();

  /// Converts the provided recipes into CSV format, saves the file locally,
  /// triggers the system share/save dialog, and returns the generated file path.
  Future<String> exportRecipesToCsv(List<Recipe> recipes);
}
