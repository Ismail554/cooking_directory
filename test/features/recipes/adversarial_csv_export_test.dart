import 'package:csv/csv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cooking_directory/features/recipes/data/services/recipe_csv_converter.dart';
import 'package:cooking_directory/features/recipes/domain/entities/recipe.dart';
import 'package:cooking_directory/features/recipes/domain/repositories/recipe_repository.dart';
import 'package:cooking_directory/features/recipes/domain/usecases/export_recipes_to_csv_usecase.dart';

class StubRepo implements RecipeRepository {
  List<Recipe> recipes = [];
  @override
  Future<List<Recipe>> getAllRecipes() async => recipes;
  @override
  Future<String> exportRecipesToCsv(List<Recipe> recipes) async => '/tmp/test.csv';
  @override
  Future<Recipe> addRecipe(Recipe recipe) async => recipe;
  @override
  Future<List<Recipe>> importRecipesFromCsv(String csvContent) async => [];
}

void main() {
  const converter = RecipeCsvConverter();

  Recipe createRecipe({
    String id = 'r_adv_1',
    String title = 'Adversarial Recipe',
    String description = 'Testing RFC 4180',
    String category = 'Test',
    int prepTime = 5,
    int cookTime = 10,
    int servings = 1,
    int calories = 100,
    String difficulty = 'Medium',
    List<String> ingredients = const ['Ingredient 1'],
    List<String> steps = const ['Step 1'],
    DateTime? createdAt,
  }) {
    return Recipe(
      id: id,
      title: title,
      description: description,
      category: category,
      prepTimeMinutes: prepTime,
      cookTimeMinutes: cookTime,
      servings: servings,
      calories: calories,
      difficulty: difficulty,
      ingredients: ingredients,
      steps: steps,
      createdAt: createdAt ?? DateTime.utc(2026, 11, 10, 12, 0, 0),
    );
  }

  group('Adversarial CSV: RFC 4180 Escaping & Complex Characters', () {
    test('handles quotes, double quotes, commas, newlines and tabs in fields', () {
      final trickyRecipe = createRecipe(
        title: 'Recipe with "Quotes", \'Singles\', and ,commas,',
        description: 'Line 1\r\nLine 2 with "nested quote" and ,comma,\nLine 3\tTabbed',
        ingredients: [
          '1 cup "whole" milk, chilled',
          '2 tbsp olive oil; extra virgin, cold-pressed',
          'Salt & Pepper, to taste',
        ],
        steps: [
          'Step 1: Chop "onions",\nsauté with oil',
          'Step 2: Add milk;\r\nstir carefully',
        ],
      );

      final csv = converter.convertToCsv([trickyRecipe]);
      final rows = const CsvToListConverter(eol: '\r\n').convert(csv);

      expect(rows.length, 2);
      final row = rows[1];
      expect(row.length, 12);
      expect(row[1], 'Recipe with "Quotes", \'Singles\', and ,commas,');
      expect(row[2], 'Line 1\r\nLine 2 with "nested quote" and ,comma,\nLine 3\tTabbed');
      expect(row[9], '1 cup "whole" milk, chilled; 2 tbsp olive oil; extra virgin, cold-pressed; Salt & Pepper, to taste');
      expect(row[10], '1. Step 1: Chop "onions",\nsauté with oil; 2. Step 2: Add milk;\r\nstir carefully');
    });

    test('handles international Unicode, emojis, RTL and special symbols', () {
      final unicodeRecipe = createRecipe(
        title: 'Crêpe Suzette & 寿司 🍣 و كبسة (Kabsa) — 100% Délicieux!',
        description: 'Spices: 🌶️, Cardamom (هيل), 50% & 1/2 tsp ± 0.05',
        ingredients: ['100g farine/طحين', '2 eggs 🥚', '1 pincée de sel'],
        steps: ['Mélanger les ingrédients', 'خلط جيداً', 'Bake at 200°C / 392°F'],
      );

      final csv = converter.convertToCsv([unicodeRecipe]);
      final rows = const CsvToListConverter(eol: '\r\n').convert(csv);

      expect(rows.length, 2);
      final row = rows[1];
      expect(row[1], contains('Crêpe Suzette & 寿司 🍣'));
      expect(row[2], contains('🌶️, Cardamom (هيل)'));
      expect(row[9], contains('100g farine/طحين; 2 eggs 🥚; 1 pincée de sel'));
      expect(row[10], contains('1. Mélanger les ingrédients; 2. خلط جيداً; 3. Bake at 200°C / 392°F'));
    });
  });

  group('Adversarial CSV: Boundary & Edge Case Collections', () {
    test('handles empty ingredients and empty steps without misaligning columns', () {
      final bareRecipe = createRecipe(
        ingredients: [],
        steps: [],
      );

      final csv = converter.convertToCsv([bareRecipe]);
      final rows = const CsvToListConverter(eol: '\r\n').convert(csv);

      expect(rows.length, 2);
      final row = rows[1];
      expect(row.length, 12);
      expect(row[9], '');
      expect(row[10], '');
      expect(row[11], '2026-11-10T12:00:00.000Z');
    });

    test('handles single item ingredients and steps without trailing delimiters', () {
      final singleRecipe = createRecipe(
        ingredients: ['Only 1 item'],
        steps: ['Just one step'],
      );

      final csv = converter.convertToCsv([singleRecipe]);
      final rows = const CsvToListConverter(eol: '\r\n').convert(csv);

      final row = rows[1];
      expect(row[9], 'Only 1 item');
      expect(row[10], '1. Just one step');
    });

    test('handles extreme numerical values (zero, large values)', () {
      final extremeRecipe = createRecipe(
        prepTime: 0,
        cookTime: 1440,
        servings: 100,
        calories: 999999,
      );

      final csv = converter.convertToCsv([extremeRecipe]);
      final rows = const CsvToListConverter(eol: '\r\n').convert(csv);

      final row = rows[1];
      expect(row[4], 0);
      expect(row[5], 1440);
      expect(row[6], 100);
      expect(row[7], 999999);
    });

    test('handles large batch of 500 recipes efficiently and maintains row integrity', () {
      final batch = List.generate(
        500,
        (i) => createRecipe(
          id: 'batch_$i',
          title: 'Batch Recipe $i',
          ingredients: ['Ing A', 'Ing B, with comma'],
          steps: ['Step 1', 'Step 2'],
        ),
      );

      final stopwatch = Stopwatch()..start();
      final csv = converter.convertToCsv(batch);
      final rows = const CsvToListConverter(eol: '\r\n').convert(csv);
      stopwatch.stop();

      expect(rows.length, 501);
      expect(rows.first, RecipeCsvConverter.headers);
      expect(rows.last[0], 'batch_499');
      expect(stopwatch.elapsedMilliseconds, lessThan(3000));
    });
  });

  group('Adversarial UseCase: Empty and Error Scenarios', () {
    test('throws StateError with exact message when repository returns empty list', () async {
      final repo = StubRepo()..recipes = [];
      final useCase = ExportRecipesToCsvUseCase(repo);

      expect(
        () => useCase(),
        throwsA(isA<StateError>().having((e) => e.message, 'message', 'No recipes available to export')),
      );
    });

    test('throws StateError when explicit recipes parameter is empty list', () async {
      final repo = StubRepo()..recipes = [createRecipe()];
      final useCase = ExportRecipesToCsvUseCase(repo);

      expect(
        () => useCase(recipes: []),
        throwsA(isA<StateError>().having((e) => e.message, 'message', 'No recipes available to export')),
      );
    });
  });
}
