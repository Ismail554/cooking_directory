import '../../../../core/storage/local_json_store.dart';
import '../models/recipe_model.dart';
import 'recipe_seed_data.dart';

abstract class RecipeLocalDataSource {
  Future<List<RecipeModel>> getSeedRecipes();
  Future<void> saveRecipe(RecipeModel recipe);
  Future<void> saveRecipes(List<RecipeModel> recipes);
  Future<void> deleteRecipe(String id);
}

class RecipeLocalDataSourceImpl implements RecipeLocalDataSource {
  const RecipeLocalDataSourceImpl();

  static String _activeUid = 'guest';
  static final Map<String, List<RecipeModel>> _cacheByUid = {};

  static void setActiveUid(String? uid) {
    _activeUid = (uid == null || uid.trim().isEmpty) ? 'guest' : uid.trim();
  }

  static String get _fileName => 'recipes_$_activeUid.json';

  Future<List<RecipeModel>> _ensureLoaded() async {
    final existing = _cacheByUid[_activeUid];
    if (existing != null) return existing;
    final raw = await LocalJsonStore.readList(_fileName);
    final loaded = raw != null
        ? raw.map(RecipeModel.fromJson).toList()
        : List<RecipeModel>.from(kSeedRecipes);
    _cacheByUid[_activeUid] = loaded;
    return loaded;
  }

  Future<void> _persist(List<RecipeModel> items) async {
    await LocalJsonStore.writeList(_fileName, items.map((e) => e.toJson()).toList());
  }

  @override
  Future<List<RecipeModel>> getSeedRecipes() async {
    final list = await _ensureLoaded();
    return List.unmodifiable(list);
  }

  @override
  Future<void> saveRecipe(RecipeModel recipe) async {
    final list = await _ensureLoaded();
    final idx = list.indexWhere((r) => r.id == recipe.id);
    if (idx >= 0) {
      list[idx] = recipe;
    } else {
      list.insert(0, recipe);
    }
    await _persist(list);
  }

  @override
  Future<void> saveRecipes(List<RecipeModel> recipes) async {
    final list = await _ensureLoaded();
    for (final recipe in recipes) {
      final idx = list.indexWhere((r) => r.id == recipe.id);
      if (idx >= 0) {
        list[idx] = recipe;
      } else {
        list.insert(0, recipe);
      }
    }
    await _persist(list);
  }

  @override
  Future<void> deleteRecipe(String id) async {
    final list = await _ensureLoaded();
    list.removeWhere((r) => r.id == id);
    await _persist(list);
  }
}
