class MealPlan {
  String id;
  String name;
  DateTime date;
  String dayOfWeek; // Monday, Tuesday, etc.
  String mealType; // Breakfast, Lunch, Dinner, Snack
  List<String> foodItemIds; // Food items for this meal
  bool isPremium; // Premium plans have more features

  MealPlan({
    required this.id,
    required this.name,
    required this.date,
    required this.dayOfWeek,
    required this.mealType,
    this.foodItemIds = const [],
    this.isPremium = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'dayOfWeek': dayOfWeek,
      'mealType': mealType,
      'foodItemIds': foodItemIds,
      'isPremium': isPremium,
    };
  }

  factory MealPlan.fromMap(Map<String, dynamic> map) {
    return MealPlan(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      date: DateTime.parse(map['date']),
      dayOfWeek: map['dayOfWeek'] ?? '',
      mealType: map['mealType'] ?? '',
      foodItemIds: List<String>.from(map['foodItemIds'] ?? []),
      isPremium: map['isPremium'] ?? false,
    );
  }
}
