import 'package:csv/csv.dart';

/// Templates and header definitions for Recipe CSV imports and exports.
class RecipeCsvTemplates {
  const RecipeCsvTemplates._();

  /// Standard column headers for the 12-column exported CSV file.
  static const List<String> exportHeaders = [
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
}

