import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/food_item.dart';

class BarcodeApiService {
  static const String _openFoodFactsUrl =
      'https://world.openfoodfacts.org/api/v0/product';

  /// Fetch product information from Open Food Facts by barcode
  static Future<FoodItem?> lookupBarcode(String barcode) async {
    try {
      final url = Uri.parse('$_openFoodFactsUrl/$barcode.json');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        if (kDebugMode) {
          print('API request failed with status: ${response.statusCode}');
        }
        return null;
      }

      final data = json.decode(response.body);

      // Check if product was found
      if (data['status'] != 1 || data['product'] == null) {
        if (kDebugMode) {
          print('Product not found for barcode: $barcode');
        }
        return null;
      }

      final product = data['product'];

      // Extract nutrition data (per 100g)
      final nutriments = product['nutriments'] ?? {};

      // Get product name (try multiple language fields)
      String productName =
          product['product_name'] ??
          product['product_name_en'] ??
          product['generic_name'] ??
          'Unknown Product';

      // Get serving size (default to 100g if not specified)
      double servingSize = 100.0;
      if (product['serving_quantity'] != null) {
        servingSize = _parseDouble(product['serving_quantity']);
      }

      // Extract macros per 100g
      double calories = _parseDouble(
        nutriments['energy-kcal_100g'] ?? nutriments['energy-kcal'] ?? 0,
      );
      double protein = _parseDouble(
        nutriments['proteins_100g'] ?? nutriments['proteins'] ?? 0,
      );
      double carbs = _parseDouble(
        nutriments['carbohydrates_100g'] ?? nutriments['carbohydrates'] ?? 0,
      );
      double fats = _parseDouble(
        nutriments['fat_100g'] ?? nutriments['fat'] ?? 0,
      );
      double fiber = _parseDouble(
        nutriments['fiber_100g'] ?? nutriments['fiber'] ?? 0,
      );
      double sugar = _parseDouble(
        nutriments['sugars_100g'] ?? nutriments['sugars'] ?? 0,
      );
      double sodium = _parseDouble(
        nutriments['sodium_100g'] ?? nutriments['sodium'] ?? 0,
      );

      // Determine category
      String category = _determineCategory(product);

      // Calculate health score
      String healthScore = _calculateHealthScore(
        protein,
        carbs,
        fats,
        fiber,
        sugar,
      );

      return FoodItem(
        id: '', // Will be generated when saved
        name: productName,
        barcode: barcode,
        servingSize: servingSize,
        calories: calories,
        protein: protein,
        carbs: carbs,
        fats: fats,
        fiber: fiber,
        sugar: sugar,
        sodium: sodium,
        category: category,
        isCustom: false,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error looking up barcode: $e');
      }
      return null;
    }
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  static String _determineCategory(Map<String, dynamic> product) {
    final categories = product['categories'] ?? '';
    final categoriesLower = categories.toString().toLowerCase();

    if (categoriesLower.contains('breakfast') ||
        categoriesLower.contains('cereals')) {
      return 'breakfast';
    } else if (categoriesLower.contains('snack') ||
        categoriesLower.contains('chips') ||
        categoriesLower.contains('candy')) {
      return 'snacks';
    } else if (categoriesLower.contains('beverage') ||
        categoriesLower.contains('drink')) {
      return 'beverages';
    } else if (categoriesLower.contains('dairy') ||
        categoriesLower.contains('cheese') ||
        categoriesLower.contains('milk')) {
      return 'dairy';
    } else if (categoriesLower.contains('meat') ||
        categoriesLower.contains('poultry') ||
        categoriesLower.contains('fish')) {
      return 'protein';
    } else if (categoriesLower.contains('fruit') ||
        categoriesLower.contains('vegetable')) {
      return 'produce';
    } else {
      return 'other';
    }
  }

  static String _calculateHealthScore(
    double protein,
    double carbs,
    double fats,
    double fiber,
    double sugar,
  ) {
    int score = 0;

    // Protein is good (more = better)
    if (protein > 15) {
      score += 2;
    } else if (protein > 8) {
      score += 1;
    }

    // Fiber is good (more = better)
    if (fiber > 5) {
      score += 2;
    } else if (fiber > 2) {
      score += 1;
    }

    // High sugar is bad
    if (sugar > 20) {
      score -= 2;
    } else if (sugar > 10) {
      score -= 1;
    }

    // High fat could be bad (depending on type, but we simplify)
    if (fats > 30) {
      score -= 1;
    }

    // Determine health score category
    if (score >= 2) {
      return 'green'; // Healthy
    } else if (score >= 0) {
      return 'yellow'; // Moderate
    } else {
      return 'red'; // Less healthy
    }
  }
}
