import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../datasources/recipe_local_datasource.dart';
import '../services/recipe_csv_converter.dart';
import '../services/recipe_file_exporter.dart';

/// Concrete implementation of [RecipeRepository] orchestrating data sources,
/// CSV formatting, and device file export.
class RecipeRepositoryImpl implements RecipeRepository {
  final RecipeLocalDataSource _localDataSource;
  final RecipeCsvConverter _csvConverter;
  final RecipeFileExporter _fileExporter;

  RecipeRepositoryImpl({
    RecipeLocalDataSource? localDataSource,
    RecipeCsvConverter? csvConverter,
    RecipeFileExporter? fileExporter,
  })  : _localDataSource = localDataSource ?? const RecipeLocalDataSourceImpl(),
        _csvConverter = csvConverter ?? const RecipeCsvConverter(),
        _fileExporter = fileExporter ?? const RecipeFileExporter();

  @override
  Future<List<Recipe>> getAllRecipes() async {
    final models = await _localDataSource.getSeedRecipes();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<String> exportRecipesToCsv(List<Recipe> recipes) async {
    final csvContent = _csvConverter.convertToCsv(recipes);
    final filePath = await _fileExporter.exportCsvFile(csvContent);
    return filePath;
  }
}
