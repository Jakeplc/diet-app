import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/food_item.dart';

class FoodSearchApiService {
  // Using USDA FoodData Central API (free, no API key required for basic search)
  static const String baseUrl = 'https://api.nal.usda.gov/fdc/v1';

  // USDA API Key - Registered for unlimited requests
  static const String apiKey = 'T4mJBAhHcHkUi6QmoopfepfPBhXHT3bG5AG6HuUo';

  /// Search for foods using USDA FoodData Central
  static Future<List<FoodItem>> searchFoods(String query) async {
    if (query.isEmpty) return [];

    try {
      final url = Uri.parse('$baseUrl/foods/search').replace(
        queryParameters: {'query': query, 'pageSize': '20', 'api_key': apiKey},
      );

      if (kDebugMode) {
        print('Searching USDA API for: $query');
      }

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final foods = data['foods'] as List?;

        if (foods == null || foods.isEmpty) {
          return [];
        }

        return foods.map((food) => _parseFoodItem(food)).toList();
      } else {
        if (kDebugMode) {
          print('USDA API error: ${response.statusCode}');
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error searching USDA API: $e');
      }
      return [];
    }
  }

  static FoodItem _parseFoodItem(Map<String, dynamic> food) {
    // Extract basic info
    final description = food['description'] ?? 'Unknown Food';
    final fdcId = food['fdcId']?.toString() ?? '';

    // Extract nutrients
    final nutrients = food['foodNutrients'] as List? ?? [];
    double calories = 0;
    double protein = 0;
    double carbs = 0;
    double fats = 0;
    double fiber = 0;
    double sugar = 0;

    for (var nutrient in nutrients) {
      final nutrientName =
          nutrient['nutrientName']?.toString().toLowerCase() ?? '';
      final value = _parseDouble(nutrient['value']);

      if (nutrientName.contains('energy') || nutrientName.contains('calor')) {
        // Convert kJ to kcal if needed
        if (nutrient['unitName'] == 'kJ') {
          calories = value / 4.184;
        } else {
          calories = value;
        }
      } else if (nutrientName.contains('protein')) {
        protein = value;
      } else if (nutrientName.contains('carbohydrate')) {
        carbs = value;
      } else if (nutrientName.contains('total lipid') ||
          nutrientName.contains('fat, total')) {
        fats = value;
      } else if (nutrientName.contains('fiber')) {
        fiber = value;
      } else if (nutrientName.contains('sugars, total') ||
          nutrientName.contains('total sugars')) {
        sugar = value;
      }
    }

    // Determine category based on food description and nutrients
    final category = _determineCategory(description, protein, carbs, fats);

    return FoodItem(
      id: 'usda_$fdcId',
      name: description,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fats: fats,
      fiber: fiber,
      sugar: sugar,
      servingSize: 100,
      category: category,
      barcode: '',
    );
  }

  static String _determineCategory(
    String description,
    double protein,
    double carbs,
    double fats,
  ) {
    final desc = description.toLowerCase();

    // Check description keywords first
    if (desc.contains('breakfast') ||
        desc.contains('cereal') ||
        desc.contains('oatmeal')) {
      return 'breakfast';
    } else if (desc.contains('snack') ||
        desc.contains('chip') ||
        desc.contains('cookie') ||
        desc.contains('candy')) {
      return 'snacks';
    } else if (desc.contains('beverage') ||
        desc.contains('drink') ||
        desc.contains('juice') ||
        desc.contains('soda')) {
      return 'beverages';
    } else if (desc.contains('milk') ||
        desc.contains('cheese') ||
        desc.contains('yogurt') ||
        desc.contains('cream')) {
      return 'dairy';
    } else if (desc.contains('meat') ||
        desc.contains('chicken') ||
        desc.contains('fish') ||
        desc.contains('egg')) {
      return 'protein';
    } else if (desc.contains('fruit') ||
        desc.contains('vegetable') ||
        desc.contains('salad')) {
      return 'produce';
    }

    // Fallback to macronutrient analysis
    if (protein > 15) {
      return 'protein';
    } else if (carbs > 50) {
      return 'breakfast';
    } else if (fats > 20) {
      return 'snacks';
    }

    return 'other';
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
