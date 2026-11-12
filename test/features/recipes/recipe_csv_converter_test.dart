import 'package:csv/csv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cooking_directory/features/recipes/data/services/recipe_csv_converter.dart';
import 'package:cooking_directory/features/recipes/domain/entities/recipe.dart';

void main() {
  late RecipeCsvConverter converter;

  setUp(() {
    converter = const RecipeCsvConverter();
  });

  Recipe createTestRecipe({
    String id = 'rec_1',
    String title = 'Garlic Butter Shrimp',
    String subtitle = 'Quick skillet seafood',
    String description = 'Quick, savory shrimp sautéed in rich garlic butter sauce, finished with parsley.',
    String category = 'Seafood',
    int prepTimeMinutes = 10,
    int cookTimeMinutes = 8,
    int servings = 2,
    int calories = 310,
    String difficulty = 'Easy',
    List<String> ingredients = const [
      '500g large raw shrimp, peeled',
      '4 cloves garlic, finely minced',
      '3 tbsp unsalted butter',
      '1 tbsp lemon juice',
    ],
    List<String> steps = const [
      'Melt butter in a skillet over medium heat.',
      'Add minced garlic and sauté until fragrant, about 1 minute.',
      'Add shrimp and cook for 2 minutes per side until pink.',
      'Drizzle with lemon juice and serve immediately.',
    ],
    DateTime? createdAt,
  }) {
    return Recipe(
      id: id,
      title: title,
      subtitle: subtitle,
      description: description,
      category: category,
      prepTimeMinutes: prepTimeMinutes,
      cookTimeMinutes: cookTimeMinutes,
      servings: servings,
      calories: calories,
      difficulty: difficulty,
      ingredients: ingredients,
      steps: steps,
      createdAt: createdAt ?? DateTime(2026, 4, 1, 12, 0),
    );
  }

  group('RecipeCsvConverter RFC 4180 compliance', () {
    test('outputs correct RFC 4180 header row', () {
      final csvString = converter.convertToCsv([]);
      final rows = const CsvToListConverter(eol: '\r\n').convert(csvString);

      expect(rows.length, 1);
      expect(rows.first, RecipeCsvConverter.headers);
      expect(rows.first.length, 12);
    });

    test('serializes single recipe with all 12 columns aligned', () {
      final recipe = createTestRecipe();
      final csvString = converter.convertToCsv([recipe]);
      final rows = const CsvToListConverter(eol: '\r\n').convert(csvString);

      expect(rows.length, 2);
      final dataRow = rows[1];
      expect(dataRow.length, 12);
      expect(dataRow[0], recipe.id);
      expect(dataRow[1], recipe.title);
      expect(dataRow[2], recipe.description);
      expect(dataRow[3], recipe.category);
      expect(dataRow[4], recipe.prepTimeMinutes);
      expect(dataRow[5], recipe.cookTimeMinutes);
      expect(dataRow[6], recipe.servings);
      expect(dataRow[7], recipe.calories);
      expect(dataRow[8], recipe.difficulty);
      expect(dataRow[9], contains('500g large raw shrimp, peeled; 4 cloves garlic'));
      expect(dataRow[10], contains('1. Melt butter'));
      expect(dataRow[11], recipe.createdAt.toIso8601String());
    });

    test('safely escapes fields containing commas, quotes, and special chars', () {
      final recipe = createTestRecipe(
        title: 'Spaghetti "Carbonara", Rome Style',
        description: 'Authentic Roman pasta with guanciale, pecorino, and black pepper.',
        ingredients: ['200g guanciale, diced', '4 egg yolks, beaten'],
      );

      final csvString = converter.convertToCsv([recipe]);
      final rows = const CsvToListConverter(eol: '\r\n').convert(csvString);

      expect(rows.length, 2);
      final dataRow = rows[1];
      expect(dataRow[1], 'Spaghetti "Carbonara", Rome Style');
      expect(dataRow[2], 'Authentic Roman pasta with guanciale, pecorino, and black pepper.');
      expect(dataRow[9], '200g guanciale, diced; 4 egg yolks, beaten');
    });
  });

  group('RecipeCsvConverter Import & Parsing', () {
    test('parses 7-column sample template correctly', () {
      final sampleCsv = RecipeCsvConverter.generateSampleCsv();
      final recipes = converter.parseFromCsv(sampleCsv);

      expect(recipes.length, 2);
      expect(recipes[0].title, "Grandma's Carbonara");
      expect(recipes[0].subtitle, 'Classic Roman Pasta');
      expect(recipes[0].servings, 4);
      expect(recipes[0].ingredients.length, 4);
      expect(recipes[0].steps.length, 3);
      expect(recipes[0].steps[0], 'Boil pasta in salted water');

      expect(recipes[1].title, 'Lemon Herb Salmon');
      expect(recipes[1].servings, 2);
    });

    test('round-trips 12-column exported recipes back through parseFromCsv', () {
      final original = [createTestRecipe(id: 'rt_1', title: 'Roundtrip Recipe')];
      final exportedCsv = converter.convertToCsv(original);
      final imported = converter.parseFromCsv(exportedCsv);

      expect(imported.length, 1);
      expect(imported.first.id, 'rt_1');
      expect(imported.first.title, 'Roundtrip Recipe');
      expect(imported.first.ingredients.length, original.first.ingredients.length);
    });

    test('returns empty list for blank or header-only CSV', () {
      expect(converter.parseFromCsv(''), isEmpty);
      expect(converter.parseFromCsv('   \n  '), isEmpty);
      expect(converter.parseFromCsv('Title,Subtitle,Ingredients\n'), isEmpty);
    });
  });
}
