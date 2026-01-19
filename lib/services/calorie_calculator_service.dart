import 'dart:math';
import '../models/user_profile.dart';

class CalorieCalculatorService {
  // Calculate BMR using Mifflin-St Jeor Equation
  static double calculateBMR(UserProfile profile) {
    double bmr;

    if (profile.gender.toLowerCase() == 'male') {
      bmr =
          (10 * profile.weight) +
          (6.25 * profile.height) -
          (5 * profile.age) +
          5;
    } else {
      bmr =
          (10 * profile.weight) +
          (6.25 * profile.height) -
          (5 * profile.age) -
          161;
    }

    return bmr;
  }

  // Calculate TDEE (Total Daily Energy Expenditure)
  static double calculateTDEE(UserProfile profile) {
    final bmr = calculateBMR(profile);

    double multiplier;
    switch (profile.activityLevel) {
      case 'sedentary':
        multiplier = 1.2;
        break;
      case 'light':
        multiplier = 1.375;
        break;
      case 'moderate':
        multiplier = 1.55;
        break;
      case 'active':
        multiplier = 1.725;
        break;
      case 'very_active':
        multiplier = 1.9;
        break;
      default:
        multiplier = 1.2;
    }

    return bmr * multiplier;
  }

  // Adjust calories based on goal
  static double calculateDailyCalorieTarget(UserProfile profile) {
    final tdee = calculateTDEE(profile);

    switch (profile.goal) {
      case 'lose_weight':
        return tdee - 500; // 0.5 kg per week loss
      case 'gain_weight':
        return tdee + 500; // 0.5 kg per week gain
      case 'maintain':
      default:
        return tdee;
    }
  }

  // Calculate macro targets (40/30/30 split as default)
  static Map<String, double> calculateMacroTargets(double dailyCalories) {
    // Protein: 30% of calories (4 cal/g)
    final protein = (dailyCalories * 0.30) / 4;

    // Carbs: 40% of calories (4 cal/g)
    final carbs = (dailyCalories * 0.40) / 4;

    // Fats: 30% of calories (9 cal/g)
    final fats = (dailyCalories * 0.30) / 9;

    return {'protein': protein, 'carbs': carbs, 'fats': fats};
  }

  // Calculate water target (ml) based on weight
  static double calculateWaterTarget(double weightKg) {
    // 30-35 ml per kg of body weight
    return weightKg * 33;
  }

  // Calculate ideal weight range (BMI 18.5 - 24.9)
  static Map<String, double> calculateIdealWeightRange(double heightCm) {
    final heightM = heightCm / 100;
    return {
      'min': 18.5 * (heightM * heightM),
      'max': 24.9 * (heightM * heightM),
    };
  }

  // Calculate BMI
  static double calculateBMI(double weightKg, double heightCm) {
    final heightM = heightCm / 100;
    return weightKg / (heightM * heightM);
  }

  // Get BMI category
  static String getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  // Calculate estimated time to goal (in weeks)
  static int calculateWeeksToGoal(
    double currentWeight,
    double targetWeight,
    String goal,
  ) {
    final difference = (targetWeight - currentWeight).abs();
    // Assuming 0.5 kg per week is healthy
    return (difference / 0.5).ceil();
  }

  // Generate daily insights based on logs
  static String generateDailyInsight({
    required double caloriesConsumed,
    required double caloriesTarget,
    required double proteinConsumed,
    required double proteinTarget,
    required double waterConsumed,
    required double waterTarget,
  }) {
    final caloriesDiff = caloriesTarget - caloriesConsumed;
    final proteinProgress = proteinConsumed / proteinTarget;
    final waterProgress = waterConsumed / waterTarget;

    if (caloriesDiff > 500) {
      return 'You have ${caloriesDiff.toInt()} calories left. Try adding a protein-rich snack!';
    } else if (caloriesDiff < -500) {
      return 'You\'ve exceeded your calorie target. Consider a light dinner or extra activity.';
    } else if (proteinProgress < 0.7) {
      return 'Your protein intake is low. Add lean meats, eggs, or legumes.';
    } else if (waterProgress < 0.5) {
      return 'Drink more water! You\'re at ${(waterProgress * 100).toInt()}% of your goal.';
    } else if (waterProgress >= 1.0 &&
        caloriesDiff.abs() < 200 &&
        proteinProgress >= 0.9) {
      return '🎉 Great day! You\'re on track with all your goals!';
    }

    return 'Keep going! You\'re ${caloriesDiff.toInt()} calories from your target.';
  }
}
