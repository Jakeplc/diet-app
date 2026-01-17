import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';

import '../models/food_entry.dart';
import '../models/food_item.dart';
import '../state/app_state.dart';
import '../services/hive_boxes.dart';
import '../widgets/barcode_scanner.dart';

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  MobileScannerController cameraController = MobileScannerController();
  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Product Barcode'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) async {
              if (isProcessing) return;
              isProcessing = true;

              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final String? code = barcode.rawValue;
                if (code != null) {
                  await cameraController.stop();
                  await _fetchAndSaveProduct(code);
                  if (mounted) {
                    Navigator.pop(context);
                  }
                  return;
                }
              }
            },
          ),
          // Scanline overlay
          Positioned.fill(
            child: Center(
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: cs.primary, width: 3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    // Corner brackets
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: cs.primary, width: 4),
                            left: BorderSide(color: cs.primary, width: 4),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: cs.primary, width: 4),
                            right: BorderSide(color: cs.primary, width: 4),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: cs.primary, width: 4),
                            left: BorderSide(color: cs.primary, width: 4),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: cs.primary, width: 4),
                            right: BorderSide(color: cs.primary, width: 4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Instructions
          Positioned(
            bottom: 40,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Center barcode in frame to scan',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchAndSaveProduct(String barcode) async {
    try {
      // Show loading indicator
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fetching product...'),
          duration: Duration(seconds: 2),
        ),
      );

      // Fetch from Open Food Facts
      final response = await OpenFoodFacts.getProduct(
        ProductQueryConfiguration(
          barcode: barcode,
          language: OpenFoodFactsLanguage.ENGLISH,
        ),
      );

      if (!mounted) return;

      if (response.status == 1 && response.product != null) {
        final product = response.product!;
        final calories = (product.nutriments?.energyKCal?.toInt()) ?? 0;
        final protein = product.nutriments?.proteins ?? 0;
        final carbs = product.nutriments?.carbohydrates ?? 0;
        final fat = product.nutriments?.fat ?? 0;

        // Show result dialog
        final shouldAdd = await showDialog<bool>(
          context: context,
          builder: (context) => BarcodeResultCard(
            productName: product.productName ?? 'Unknown Product',
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            servingSize: product.servingSize ?? '100g',
            allergens: product.allergensList?.toList(),
            source: 'Open Food Facts',
          ),
        );

        if (shouldAdd == true && mounted) {
          // Add to food database if new
          final appState = context.read<AppState>();
          final existingFood = appState.allFoods.firstWhere(
            (f) => f.id == barcode,
            orElse: () => null as dynamic,
          );

          if (existingFood == null) {
            // Create new food item
            final newFood = FoodItem(
              id: barcode,
              name: product.productName ?? 'Unknown Product',
              calories: calories,
              protein: protein,
              carbs: carbs,
              fat: fat,
            );
            // Save to Hive
            await HiveBoxes.foods().put(barcode, newFood);
          }

          // Log entry for today
          await appState.addFood(
            food: appState.allFoods.firstWhere(
              (f) => f.id == barcode,
            ),
            meal: MealType.snack,
            servings: 1.0,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added: ${product.productName ?? "Product"}'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Product not found in database. Try manual entry.',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    isProcessing = false;
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}
