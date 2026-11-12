import 'package:csv/csv.dart';
import '../../domain/entities/recipe.dart';

/// Service responsible for serializing and deserializing recipes to/from CSV.
class RecipeCsvConverter {
  const RecipeCsvConverter();

  /// Standard column headers for the 12-column exported CSV file.
  static const List<String> headers = [
    'ID',
    'Title',
    'Description',
    'Category',
    'Prep Time (mins)',
    'Cook Time (mins)',
    'Servings',
    'Calories',
    'Difficulty',
    'Ingredients',
    'Steps',
    'Created At',
  ];

  /// Standard column headers for the 7-column recipe import template.
  static const List<String> importHeaders = [
    'Title',
    'Subtitle',
    'Ingredients',
    'Instructions',
    'Notes/Description',
    'Time (mins)',
    'Servings',
  ];

  /// Generates a ready-to-use sample CSV template for recipes.
  static String generateSampleCsv() {
    final rows = [
      importHeaders,
      [
        "Grandma's Carbonara",
        'Classic Roman Pasta',
        '200g spaghetti; 100g guanciale; 3 egg yolks; 50g Pecorino Romano',
        '1. Boil pasta in salted water; 2. Crisp guanciale in pan; 3. Toss pasta with egg and cheese off heat',
        'Use freshly cracked black pepper and reserve 1/2 cup pasta water.',
        '25',
        '4',
      ],
      [
        'Lemon Herb Salmon',
        'Quick Mediterranean Dinner',
        '2 salmon fillets; 1 lemon sliced; 2 cloves garlic minced; 1 tbsp olive oil; Fresh dill',
        '1. Preheat oven to 200°C; 2. Place salmon on foil; 3. Top with garlic, lemon, oil, and dill; 4. Bake for 15 minutes',
        'Pairs wonderfully with roasted asparagus or steamed quinoa.',
        '20',
        '2',
      ],
    ];

    const converter = ListToCsvConverter(eol: '\r\n');
    return converter.convert(rows);
  }

  /// Converts a collection of [Recipe] entities into an RFC 4180 compliant CSV string.
  String convertToCsv(List<Recipe> recipes) {
    final List<List<dynamic>> rows = [headers];
    for (final recipe in recipes) {
      rows.add(_recipeToRow(recipe));
    }
    const converter = ListToCsvConverter(
      fieldDelimiter: ',',
      textDelimiter: '"',
      textEndDelimiter: '"',
      eol: '\r\n',
      delimitAllFields: false,
    );
    return converter.convert(rows);
  }

  /// Parses CSV string into a list of [Recipe] entities.
  /// Supports both the 7-column import format and the 12-column export format.
  List<Recipe> parseFromCsv(String csvContent) {
    if (csvContent.trim().isEmpty) return [];

    final rawRows = const CsvToListConverter(
      eol: '\n',
      shouldParseNumbers: false,
    ).convert(csvContent.replaceAll('\r\n', '\n'));

    if (rawRows.length <= 1) return [];

    final headerRow = rawRows.first.map((e) => e.toString().trim().toLowerCase()).toList();
    final is12Col = headerRow.isNotEmpty && headerRow.first.contains('id');

    final List<Recipe> parsedRecipes = [];

    for (int i = 1; i < rawRows.length; i++) {
      final row = rawRows[i];
      if (row.isEmpty || (row.length == 1 && row.first.toString().trim().isEmpty)) {
        continue;
      }
      try {
        final recipe = is12Col ? _parse12ColumnRow(row, i) : _parse7ColumnRow(row, i);
        if (recipe != null) parsedRecipes.add(recipe);
      } catch (_) {}
    }

    return parsedRecipes;
  }

  Recipe? _parse7ColumnRow(List<dynamic> row, int index) {
    if (row.isEmpty) return null;
    final title = _col(row, 0);
    if (title.isEmpty) return null;

    final subtitle = _col(row, 1);
    final rawIngredients = _col(row, 2);
    final rawSteps = _col(row, 3);
    final notes = _col(row, 4);
    final timeStr = _col(row, 5);
    final servingsStr = _col(row, 6);

    final totalTime = int.tryParse(timeStr) ?? 20;
    final prepTime = (totalTime * 0.4).round();
    final cookTime = totalTime - prepTime;
    final servings = int.tryParse(servingsStr) ?? 4;

    return Recipe(
      id: 'import_${DateTime.now().millisecondsSinceEpoch}_$index',
      title: title,
      subtitle: subtitle,
      description: notes.isNotEmpty ? notes : 'Imported recipe',
      category: 'General',
      prepTimeMinutes: prepTime > 0 ? prepTime : 5,
      cookTimeMinutes: cookTime > 0 ? cookTime : 15,
      servings: servings > 0 ? servings : 2,
      calories: 350,
      difficulty: 'Medium',
      ingredients: _splitDelimited(rawIngredients),
      steps: _cleanSteps(_splitDelimited(rawSteps)),
      createdAt: DateTime.now(),
    );
  }

  Recipe? _parse12ColumnRow(List<dynamic> row, int index) {
    if (row.length < 2) return null;
    final id = _col(row, 0).isNotEmpty ? _col(row, 0) : 'imp_$index';
    final title = _col(row, 1);
    if (title.isEmpty) return null;

    return Recipe(
      id: id,
      title: title,
      description: _col(row, 2),
      category: _col(row, 3).isNotEmpty ? _col(row, 3) : 'General',
      prepTimeMinutes: int.tryParse(_col(row, 4)) ?? 15,
      cookTimeMinutes: int.tryParse(_col(row, 5)) ?? 20,
      servings: int.tryParse(_col(row, 6)) ?? 4,
      calories: int.tryParse(_col(row, 7)) ?? 400,
      difficulty: _col(row, 8).isNotEmpty ? _col(row, 8) : 'Medium',
      ingredients: _splitDelimited(_col(row, 9)),
      steps: _cleanSteps(_splitDelimited(_col(row, 10))),
      createdAt: DateTime.tryParse(_col(row, 11)) ?? DateTime.now(),
    );
  }

  String _col(List<dynamic> row, int idx) =>
      idx < row.length ? row[idx].toString().trim() : '';

  List<String> _splitDelimited(String input) {
    if (input.trim().isEmpty) return [];
    return input
        .split(RegExp(r'[;\n]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  List<String> _cleanSteps(List<String> steps) {
    return steps.map((s) => s.replaceFirst(RegExp(r'^\d+[\.\)]\s*'), '')).toList();
  }

  List<dynamic> _recipeToRow(Recipe recipe) {
    final formattedIngredients = recipe.ingredients.join('; ');
    final formattedSteps = recipe.steps
        .asMap()
        .entries
        .map((entry) => '${entry.key + 1}. ${entry.value}')
        .join('; ');

    return [
      recipe.id,
      recipe.title,
      recipe.description,
      recipe.category,
      recipe.prepTimeMinutes,
      recipe.cookTimeMinutes,
      recipe.servings,
      recipe.calories,
      recipe.difficulty,
      formattedIngredients,
      formattedSteps,
      recipe.createdAt.toIso8601String(),
    ];
  }
}
