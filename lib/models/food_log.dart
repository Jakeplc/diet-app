class FoodLog {
  String id;
  String foodItemId;
  String foodName;
  double servings;
  DateTime timestamp;
  String mealType; // breakfast, lunch, dinner, snack
  double calories;
  double protein;
  double carbs;
  double fats;
  String? notes;
  String? photoPath; // Local path for photo

  FoodLog({
    required this.id,
    required this.foodItemId,
    required this.foodName,
    this.servings = 1.0,
    required this.timestamp,
    required this.mealType,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    this.notes,
    this.photoPath,
  });

  // Get date without time for daily grouping
  String get dateKey {
    return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}';
  }
}
