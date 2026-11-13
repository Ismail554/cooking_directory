import '../models/recipe_model.dart';

/// Starter culinary recipe for new users and offline discovery.
final List<RecipeModel> kSeedRecipes = [
  RecipeModel(
    id: 'recipe_001',
    title: 'Creamy Tuscan Garlic Chicken',
    subtitle: 'Pan-seared cutlets in savory herb cream',
    description: 'Pan-seared chicken cutlets bathed in a rich garlic, sun-dried tomato, and spinach cream sauce.',
    category: 'Dinner',
    prepTimeMinutes: 15,
    cookTimeMinutes: 20,
    servings: 4,
    calories: 450,
    difficulty: 'Medium',
    ingredients: const [
      '2 boneless skinless chicken breasts',
      '3 cloves garlic minced',
      '1 cup heavy cream',
      '1/2 cup chicken broth',
      '1/2 cup sun-dried tomatoes chopped',
      '2 cups fresh baby spinach',
      '1/4 cup grated parmesan cheese',
      '1 tbsp olive oil'
    ],
    steps: const [
      'Season chicken breasts with salt, pepper, and Italian herbs.',
      'Heat olive oil in skillet and sear chicken for 6 minutes per side until golden.',
      'Remove chicken and set aside on a warm plate.',
      'Sauté garlic until fragrant, then add sun-dried tomatoes and chicken broth.',
      'Pour in heavy cream and bring to a gentle simmer.',
      'Add spinach and parmesan cheese, stirring until spinach wilts.',
      'Return chicken to skillet and simmer for 3 minutes before serving.'
    ],
    isFavorite: true,
    createdAt: DateTime(2026, 1, 15, 12, 0),
  ),
];
