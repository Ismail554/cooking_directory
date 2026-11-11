import '../entities/recipe.dart';
import '../repositories/recipe_repository.dart';

/// Use case that orchestrates exporting recipes to an RFC 4180 CSV file.
class ExportRecipesToCsvUseCase {
  final RecipeRepository _repository;

  const ExportRecipesToCsvUseCase(this._repository);

  /// Executes the export operation.
  /// If [recipes] is omitted, all recipes are fetched from the repository.
  /// Throws [StateError] if no recipes are available for export.
  Future<String> call({List<Recipe>? recipes}) async {
    final candidateRecipes = recipes ?? await _repository.getAllRecipes();

    if (candidateRecipes.isEmpty) {
      throw StateError('No recipes available to export');
    }

    return await _repository.exportRecipesToCsv(candidateRecipes);
  }
}
