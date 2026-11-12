import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../datasources/recipe_local_datasource.dart';
import '../datasources/recipe_remote_datasource.dart';
import '../models/recipe_model.dart';
import '../services/recipe_csv_converter.dart';
import '../services/recipe_file_exporter.dart';

/// Concrete implementation of [RecipeRepository] orchestrating data sources,
/// CSV formatting, and device file export.
class RecipeRepositoryImpl implements RecipeRepository {
  final RecipeLocalDataSource _localDataSource;
  final RecipeRemoteDataSource _remoteDataSource;
  final RecipeCsvConverter _csvConverter;
  final RecipeFileExporter _fileExporter;

  RecipeRepositoryImpl({
    RecipeLocalDataSource? localDataSource,
    RecipeRemoteDataSource? remoteDataSource,
    RecipeCsvConverter? csvConverter,
    RecipeFileExporter? fileExporter,
  })  : _localDataSource = localDataSource ?? const RecipeLocalDataSourceImpl(),
        _remoteDataSource = remoteDataSource ?? RecipeRemoteDataSourceImpl(),
        _csvConverter = csvConverter ?? const RecipeCsvConverter(),
        _fileExporter = fileExporter ?? const RecipeFileExporter();

  @override
  Future<List<Recipe>> getAllRecipes() async {
    final localModels = await _localDataSource.getSeedRecipes();
    final remoteModels = await _remoteDataSource.fetchRemoteRecipes();

    final Map<String, Recipe> merged = {};
    for (final m in localModels) {
      merged[m.id] = m.toEntity();
    }
    for (final m in remoteModels) {
      merged[m.id] = m.toEntity();
    }

    return merged.values.toList();
  }

  @override
  Future<Recipe> addRecipe(Recipe recipe) async {
    final model = RecipeModel.fromEntity(recipe);
    await _localDataSource.saveRecipe(model);
    await _remoteDataSource.saveRemoteRecipe(model);
    return model.toEntity();
  }

  @override
  Future<List<Recipe>> importRecipesFromCsv(String csvContent) async {
    final parsed = _csvConverter.parseFromCsv(csvContent);
    final models = parsed.map((r) => RecipeModel.fromEntity(r)).toList();
    await _localDataSource.saveRecipes(models);
    await _remoteDataSource.saveRemoteRecipes(models);
    return parsed;
  }

  @override
  Future<String> exportRecipesToCsv(List<Recipe> recipes) async {
    final csvContent = _csvConverter.convertToCsv(recipes);
    final filePath = await _fileExporter.exportCsvFile(csvContent);
    return filePath;
  }
}
