class Recipe {
  final String id;
  final String title;
  final String description;
  final String category;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final int servings;
  final int calories;
  final String difficulty;
  final List<String> ingredients;
  final List<String> steps;
  final bool isFavorite;
  final DateTime createdAt;

  const Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.servings,
    required this.calories,
    required this.difficulty,
    required this.ingredients,
    required this.steps,
    this.isFavorite = false,
    required this.createdAt,
  });

  Recipe copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    int? prepTimeMinutes,
    int? cookTimeMinutes,
    int? servings,
    int? calories,
    String? difficulty,
    List<String>? ingredients,
    List<String>? steps,
    bool? isFavorite,
    DateTime? createdAt,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      cookTimeMinutes: cookTimeMinutes ?? this.cookTimeMinutes,
      servings: servings ?? this.servings,
      calories: calories ?? this.calories,
      difficulty: difficulty ?? this.difficulty,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Recipe && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Recipe(id: $id, title: $title)';
}
