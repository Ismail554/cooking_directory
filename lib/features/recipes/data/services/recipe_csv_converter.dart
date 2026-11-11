import 'package:csv/csv.dart';
import '../../domain/entities/recipe.dart';

/// Service responsible for serializing recipes into RFC 4180 compliant CSV format.
class RecipeCsvConverter {
  const RecipeCsvConverter();

  /// Standard column headers for the exported CSV file.
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

  /// Converts a collection of [Recipe] entities into an RFC 4180 compliant CSV string.
  String convertToCsv(List<Recipe> recipes) {
    final List<List<dynamic>> rows = [];

    // Header row
    rows.add(headers);

    // Data rows
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

  /// Formats a single recipe into a CSV row list.
  List<dynamic> _recipeToRow(Recipe recipe) {
    // Delimit ingredients and steps with semicolons so commas within items
    // do not split individual elements, and CSV quoting safely encloses the field.
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
