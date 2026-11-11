import 'package:flutter_test/flutter_test.dart';
import 'package:cooking_directory/features/recipes/data/models/recipe_model.dart';
import 'package:cooking_directory/features/recipes/domain/entities/recipe.dart';

void main() {
  group('RecipeModel', () {
    final sampleModel = RecipeModel(
      id: 'm1',
      title: 'Chicken Tikka',
      description: 'Spiced and roasted chicken bites',
      category: 'Dinner',
      prepTimeMinutes: 20,
      cookTimeMinutes: 25,
      servings: 4,
      calories: 420,
      difficulty: 'Medium',
      ingredients: const ['Chicken', 'Yogurt', 'Garam Masala'],
      steps: const ['Marinate chicken', 'Skewer and roast'],
      isFavorite: true,
      createdAt: DateTime(2026, 3, 15, 10, 30),
    );

    test('toJson and fromJson preserves all attributes symmetrically', () {
      final json = sampleModel.toJson();
      final parsed = RecipeModel.fromJson(json);

      expect(parsed.id, sampleModel.id);
      expect(parsed.title, sampleModel.title);
      expect(parsed.description, sampleModel.description);
      expect(parsed.category, sampleModel.category);
      expect(parsed.prepTimeMinutes, sampleModel.prepTimeMinutes);
      expect(parsed.cookTimeMinutes, sampleModel.cookTimeMinutes);
      expect(parsed.servings, sampleModel.servings);
      expect(parsed.calories, sampleModel.calories);
      expect(parsed.difficulty, sampleModel.difficulty);
      expect(parsed.ingredients, sampleModel.ingredients);
      expect(parsed.steps, sampleModel.steps);
      expect(parsed.isFavorite, sampleModel.isFavorite);
      expect(parsed.createdAt, sampleModel.createdAt);
    });

    test('fromJson falls back safely on null or missing fields', () {
      final emptyJson = <String, dynamic>{};
      final fallbackModel = RecipeModel.fromJson(emptyJson);

      expect(fallbackModel.id, '');
      expect(fallbackModel.title, '');
      expect(fallbackModel.description, '');
      expect(fallbackModel.category, 'General');
      expect(fallbackModel.prepTimeMinutes, 0);
      expect(fallbackModel.cookTimeMinutes, 0);
      expect(fallbackModel.servings, 1);
      expect(fallbackModel.calories, 0);
      expect(fallbackModel.difficulty, 'Easy');
      expect(fallbackModel.ingredients, isEmpty);
      expect(fallbackModel.steps, isEmpty);
      expect(fallbackModel.isFavorite, false);
      expect(fallbackModel.createdAt, isA<DateTime>());
    });

    test('converts seamlessly between Recipe entity and RecipeModel', () {
      final Recipe entity = Recipe(
        id: 'ent_1',
        title: 'Lentil Soup',
        description: 'Warm, spiced soup',
        category: 'Lunch',
        prepTimeMinutes: 10,
        cookTimeMinutes: 30,
        servings: 4,
        calories: 220,
        difficulty: 'Easy',
        ingredients: const ['Red lentils', 'Cumin', 'Vegetable stock'],
        steps: const ['Sauté cumin', 'Add lentils and stock', 'Simmer 25 mins'],
        isFavorite: false,
        createdAt: DateTime(2026, 4, 1),
      );

      final model = RecipeModel.fromEntity(entity);
      expect(model.id, entity.id);
      expect(model.title, entity.title);

      final convertedEntity = model.toEntity();
      expect(convertedEntity.id, entity.id);
      expect(convertedEntity.title, entity.title);
    });
  });
}
