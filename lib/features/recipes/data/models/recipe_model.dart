import '../../domain/entities/recipe.dart';

/// Data Transfer Object for [Recipe] with JSON serialization.
class RecipeModel extends Recipe {
  const RecipeModel({
    required super.id,
    required super.title,
    required super.description,
    required super.category,
    required super.prepTimeMinutes,
    required super.cookTimeMinutes,
    required super.servings,
    required super.calories,
    required super.difficulty,
    required super.ingredients,
    required super.steps,
    super.isFavorite = false,
    required super.createdAt,
  });

  /// Factory constructor to create a [RecipeModel] from JSON map.
  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      prepTimeMinutes: (json['prepTimeMinutes'] as num?)?.toInt() ?? 0,
      cookTimeMinutes: (json['cookTimeMinutes'] as num?)?.toInt() ?? 0,
      servings: (json['servings'] as num?)?.toInt() ?? 1,
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      difficulty: json['difficulty'] as String? ?? 'Easy',
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      steps: (json['steps'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      isFavorite: json['isFavorite'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Converts the [RecipeModel] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'prepTimeMinutes': prepTimeMinutes,
      'cookTimeMinutes': cookTimeMinutes,
      'servings': servings,
      'calories': calories,
      'difficulty': difficulty,
      'ingredients': ingredients,
      'steps': steps,
      'isFavorite': isFavorite,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Creates a [RecipeModel] from a domain [Recipe] entity.
  factory RecipeModel.fromEntity(Recipe recipe) {
    return RecipeModel(
      id: recipe.id,
      title: recipe.title,
      description: recipe.description,
      category: recipe.category,
      prepTimeMinutes: recipe.prepTimeMinutes,
      cookTimeMinutes: recipe.cookTimeMinutes,
      servings: recipe.servings,
      calories: recipe.calories,
      difficulty: recipe.difficulty,
      ingredients: List<String>.from(recipe.ingredients),
      steps: List<String>.from(recipe.steps),
      isFavorite: recipe.isFavorite,
      createdAt: recipe.createdAt,
    );
  }

  /// Converts this model directly to its domain [Recipe] entity.
  Recipe toEntity() => this;
}
