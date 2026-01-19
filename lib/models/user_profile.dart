class UserProfile {
  String name;
  int age;
  double height; // cm
  double weight; // kg
  String gender; // male/female/other
  String activityLevel; // sedentary, light, moderate, active, very_active
  String goal; // lose_weight, maintain, gain_weight
  String dietType; // standard, vegetarian, vegan, keto, paleo
  String measurementSystem; // metric, imperial
  double dailyCalorieTarget;
  double proteinTarget; // grams
  double carbsTarget; // grams
  double fatsTarget; // grams
  double waterTarget; // ml
  DateTime createdAt;
  DateTime updatedAt;
  int currentStreak;

  UserProfile({
    required this.name,
    required this.age,
    required this.height,
    required this.weight,
    required this.gender,
    required this.activityLevel,
    required this.goal,
    this.dietType = 'standard',
    this.measurementSystem = 'metric',
    this.dailyCalorieTarget = 2000,
    this.proteinTarget = 150,
    this.carbsTarget = 200,
    this.fatsTarget = 65,
    this.waterTarget = 2000,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.currentStreak = 0,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();
}
