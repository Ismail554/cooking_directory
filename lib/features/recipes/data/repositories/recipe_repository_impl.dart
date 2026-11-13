import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../datasources/recipe_local_datasource.dart';
import '../datasources/recipe_remote_datasource.dart';
import '../models/recipe_model.dart';
import '../services/recipe_csv_converter.dart';
import '../services/recipe_file_exporter.dart';

extension RecipeRepositorySyncX on RecipeRepository {
  Future<void> deleteRecipe(String id) async {
    final self = this;
    if (self is RecipeRepositoryImpl) await self.deleteRecipeImpl(id);
  }

  Future<void> pushRecipesToCloud(List<Recipe> recipes) async {
    final self = this;
    if (self is RecipeRepositoryImpl) await self.pushRecipesToCloudImpl(recipes);
  }

  Stream<List<Recipe>> watchRemoteRecipes() {
    final self = this;
    if (self is RecipeRepositoryImpl) return self.watchRemoteRecipesImpl();
    return const Stream<List<Recipe>>.empty();
  }
}

/// Concrete implementation of [RecipeRepository] orchestrating local + Realtime DB
/// + Cloud Firestore data sources, CSV formatting, and device file export.
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
    final results = await Future.wait([
      _localDataSource.getSeedRecipes(),
      _remoteDataSource.fetchRemoteRecipes(),
    ]);
    final Map<String, Recipe> merged = {
      for (final m in results[0]) m.id: m.toEntity(),
    };
    for (final m in results[1]) {
      final remote = m.toEntity();
      final local = merged[remote.id];
      merged[remote.id] = (remote.imageUrl.isEmpty && local != null && local.imageUrl.isNotEmpty)
          ? remote.copyWith(imageUrl: local.imageUrl)
          : remote;
    }
    return merged.values.toList();
  }

  @override
  Future<Recipe> addRecipe(Recipe recipe) async {
    final model = RecipeModel.fromEntity(recipe);
    await Future.wait([
      _localDataSource.saveRecipe(model),
      _remoteDataSource.saveRemoteRecipe(model),
    ]);
    return model.toEntity();
  }

  Future<void> deleteRecipeImpl(String id) async {
    await Future.wait([
      _localDataSource.deleteRecipe(id),
      _remoteDataSource.deleteRemoteRecipe(id),
    ]);
  }

  Future<void> pushRecipesToCloudImpl(List<Recipe> recipes) async {
    final models = recipes.map(RecipeModel.fromEntity).toList();
    await _remoteDataSource.saveRemoteRecipes(models);
  }

  Stream<List<Recipe>> watchRemoteRecipesImpl() {
    return _remoteDataSource
        .watchRemoteRecipes()
        .map((models) => models.map((m) => m.toEntity()).toList());
  }

  @override
  Future<List<Recipe>> importRecipesFromCsv(String csvContent) async {
    final parsed = _csvConverter.parseFromCsv(csvContent);
    final models = parsed.map((r) => RecipeModel.fromEntity(r)).toList();
    await Future.wait([
      _localDataSource.saveRecipes(models),
      _remoteDataSource.saveRemoteRecipes(models),
    ]);
    return parsed;
  }

  @override
  Future<String> exportRecipesToCsv(List<Recipe> recipes) async {
    final csvContent = _csvConverter.convertToCsv(recipes);
    return _fileExporter.exportCsvFile(csvContent);
  }
}
