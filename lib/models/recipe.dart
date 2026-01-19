class RecipeIngredient {
  final String foodItemId;
  final String foodName;
  final double servings;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  RecipeIngredient({
    required this.foodItemId,
    required this.foodName,
    required this.servings,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  Map<String, dynamic> toMap() {
    return {
      'foodItemId': foodItemId,
      'foodName': foodName,
      'servings': servings,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }

  factory RecipeIngredient.fromMap(Map<String, dynamic> map) {
    return RecipeIngredient(
      foodItemId: map['foodItemId'],
      foodName: map['foodName'],
      servings: map['servings'],
      calories: map['calories'],
      protein: map['protein'],
      carbs: map['carbs'],
      fat: map['fat'],
    );
  }
}

class Recipe {
  final String id;
  final String name;
  final List<RecipeIngredient> ingredients;
  final String? instructions;
  final DateTime createdAt;
  final bool isPremium;

  Recipe({
    required this.id,
    required this.name,
    required this.ingredients,
    this.instructions,
    required this.createdAt,
    this.isPremium = false,
  });

  double get totalCalories => ingredients.fold(0, (sum, i) => sum + i.calories);
  double get totalProtein => ingredients.fold(0, (sum, i) => sum + i.protein);
  double get totalCarbs => ingredients.fold(0, (sum, i) => sum + i.carbs);
  double get totalFat => ingredients.fold(0, (sum, i) => sum + i.fat);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'ingredients': ingredients.map((i) => i.toMap()).toList(),
      'instructions': instructions,
      'createdAt': createdAt.toIso8601String(),
      'isPremium': isPremium,
    };
  }

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'],
      name: map['name'],
      ingredients: (map['ingredients'] as List)
          .map((i) => RecipeIngredient.fromMap(i))
          .toList(),
      instructions: map['instructions'],
      createdAt: DateTime.parse(map['createdAt']),
      isPremium: map['isPremium'] ?? false,
    );
  }
}
