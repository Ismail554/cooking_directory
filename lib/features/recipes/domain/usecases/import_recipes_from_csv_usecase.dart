import '../entities/recipe.dart';
import '../repositories/recipe_repository.dart';

/// Use case that validates and imports recipes from raw CSV string.
class ImportRecipesFromCsvUseCase {
  final RecipeRepository _repository;

  ImportRecipesFromCsvUseCase(this._repository);

  Future<List<Recipe>> call(String csvContent) async {
    if (csvContent.trim().isEmpty) {
      throw StateError('CSV content is empty');
    }
    final imported = await _repository.importRecipesFromCsv(csvContent);
    if (imported.isEmpty) {
      throw StateError('No valid recipes found in CSV content');
    }
    return imported;
  }
}

