import '../models/food_item.dart';
import 'hive_boxes.dart';

class FoodSeed {
  static Future<void> ensureSeeded() async {
    final box = HiveBoxes.foods();
    if (box.isNotEmpty) return;

    const items = <FoodItem>[
      FoodItem(
        id: 'chicken_breast',
        name: 'Chicken breast',
        calories: 165,
        protein: 31,
        carbs: 0,
        fat: 3.6,
        servingLabel: '100g',
      ),
      FoodItem(
        id: 'white_rice',
        name: 'White rice',
        calories: 205,
        protein: 4.3,
        carbs: 44.5,
        fat: 0.4,
        servingLabel: '1 cup',
      ),
      FoodItem(
        id: 'banana',
        name: 'Banana',
        calories: 105,
        protein: 1.3,
        carbs: 27,
        fat: 0.4,
        servingLabel: '1 medium',
      ),
      FoodItem(
        id: 'protein_bar',
        name: 'Protein bar',
        calories: 200,
        protein: 20,
        carbs: 22,
        fat: 7,
        servingLabel: '1 bar',
      ),
      FoodItem(
        id: 'egg',
        name: 'Egg',
        calories: 78,
        protein: 6.3,
        carbs: 0.6,
        fat: 5.3,
        servingLabel: '1 large',
      ),
      FoodItem(
        id: 'greek_yogurt',
        name: 'Greek yogurt',
        calories: 130,
        protein: 23,
        carbs: 9,
        fat: 0,
        servingLabel: '1 cup',
      ),
    ];

    for (final f in items) {
      await box.put(f.id, f);
    }
  }
}
