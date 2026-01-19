class FoodItem {
  String id;
  String name;
  String barcode;
  double servingSize; // grams
  double calories;
  double protein; // grams
  double carbs; // grams
  double fats; // grams
  double fiber; // grams
  double sugar; // grams
  double sodium; // mg
  String category; // fruit, vegetable, protein, grain, dairy, snack
  bool isCustom; // User-created food
  String? imageUrl;

  FoodItem({
    required this.id,
    required this.name,
    this.barcode = '',
    this.servingSize = 100,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    this.fiber = 0,
    this.sugar = 0,
    this.sodium = 0,
    this.category = 'other',
    this.isCustom = false,
    this.imageUrl,
  });

  // Health score (green/yellow/red based on nutritional value)
  String get healthScore {
    final proteinRatio = protein / servingSize;
    final sugarRatio = sugar / servingSize;
    final sodiumRatio = sodium / servingSize;

    if (proteinRatio > 0.15 && sugarRatio < 0.05 && sodiumRatio < 0.4) {
      return 'green'; // Healthy
    } else if (sugarRatio > 0.15 || sodiumRatio > 0.8) {
      return 'red'; // Less healthy
    }
    return 'yellow'; // Moderate
  }

  FoodItem copyWith({
    String? id,
    String? name,
    String? barcode,
    double? servingSize,
    double? calories,
    double? protein,
    double? carbs,
    double? fats,
    double? fiber,
    double? sugar,
    double? sodium,
    String? category,
    bool? isCustom,
    String? imageUrl,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      servingSize: servingSize ?? this.servingSize,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fats: fats ?? this.fats,
      fiber: fiber ?? this.fiber,
      sugar: sugar ?? this.sugar,
      sodium: sodium ?? this.sodium,
      category: category ?? this.category,
      isCustom: isCustom ?? this.isCustom,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
