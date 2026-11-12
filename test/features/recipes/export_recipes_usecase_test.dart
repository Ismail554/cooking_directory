import 'package:flutter_test/flutter_test.dart';
import 'package:cooking_directory/features/recipes/domain/entities/recipe.dart';
import 'package:cooking_directory/features/recipes/domain/repositories/recipe_repository.dart';
import 'package:cooking_directory/features/recipes/domain/usecases/export_recipes_to_csv_usecase.dart';

class MockRecipeRepository implements RecipeRepository {
  List<Recipe> recipesToReturn = [];
  String exportedPathToReturn = '/mock/path/recipes_export_20261110.csv';
  int getAllRecipesCallCount = 0;
  int exportRecipesCallCount = 0;
  List<Recipe>? lastExportedRecipes;
  Exception? errorToThrow;

  @override
  Future<List<Recipe>> getAllRecipes() async {
    getAllRecipesCallCount++;
    if (errorToThrow != null) throw errorToThrow!;
    return recipesToReturn;
  }

  @override
  Future<String> exportRecipesToCsv(List<Recipe> recipes) async {
    exportRecipesCallCount++;
    lastExportedRecipes = recipes;
    if (errorToThrow != null) throw errorToThrow!;
    return exportedPathToReturn;
  }

  @override
  Future<Recipe> addRecipe(Recipe recipe) async => recipe;

  @override
  Future<List<Recipe>> importRecipesFromCsv(String csvContent) async => [];
}

void main() {
  late MockRecipeRepository mockRepository;
  late ExportRecipesToCsvUseCase useCase;

  final sampleRecipe = Recipe(
    id: 'test_1',
    title: 'Test Pasta',
    description: 'Simple garlic pasta',
    category: 'Dinner',
    prepTimeMinutes: 5,
    cookTimeMinutes: 10,
    servings: 2,
    calories: 350,
    difficulty: 'Easy',
    ingredients: const ['Pasta', 'Garlic', 'Olive Oil'],
    steps: const ['Boil pasta', 'Toss with garlic oil'],
    createdAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    mockRepository = MockRecipeRepository();
    useCase = ExportRecipesToCsvUseCase(mockRepository);
  });

  group('ExportRecipesToCsvUseCase', () {
    test('fetches recipes from repository and exports when recipes exist', () async {
      mockRepository.recipesToReturn = [sampleRecipe];

      final resultPath = await useCase();

      expect(resultPath, equals('/mock/path/recipes_export_20261110.csv'));
      expect(mockRepository.getAllRecipesCallCount, 1);
      expect(mockRepository.exportRecipesCallCount, 1);
      expect(mockRepository.lastExportedRecipes?.length, 1);
      expect(mockRepository.lastExportedRecipes?.first.id, 'test_1');
    });

    test('throws StateError when repository has no recipes', () async {
      mockRepository.recipesToReturn = [];

      expect(
        () => useCase(),
        throwsA(isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('No recipes available to export'),
        )),
      );
      expect(mockRepository.getAllRecipesCallCount, 1);
      expect(mockRepository.exportRecipesCallCount, 0);
    });

    test('uses explicitly provided recipes without querying repository', () async {
      mockRepository.recipesToReturn = []; // Repo has 0
      final customRecipes = [sampleRecipe];

      final resultPath = await useCase(recipes: customRecipes);

      expect(resultPath, equals('/mock/path/recipes_export_20261110.csv'));
      expect(mockRepository.getAllRecipesCallCount, 0); // Not called
      expect(mockRepository.exportRecipesCallCount, 1);
      expect(mockRepository.lastExportedRecipes, equals(customRecipes));
    });

    test('throws StateError when explicitly provided recipes list is empty', () async {
      expect(
        () => useCase(recipes: []),
        throwsA(isA<StateError>()),
      );
      expect(mockRepository.getAllRecipesCallCount, 0);
      expect(mockRepository.exportRecipesCallCount, 0);
    });

    test('rethrows exceptions occurring during repository export', () async {
      mockRepository.recipesToReturn = [sampleRecipe];
      mockRepository.errorToThrow = Exception('Disk write failed');

      expect(
        () => useCase(),
        throwsA(isA<Exception>()),
      );
    });
  });
}
