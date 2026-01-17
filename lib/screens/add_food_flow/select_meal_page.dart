import 'package:flutter/material.dart';
import '../../models/food_entry.dart';
import 'search_food_page.dart';

class SelectMealPage extends StatelessWidget {
  final MealType? preselected;
  const SelectMealPage({super.key, this.preselected});

  @override
  Widget build(BuildContext context) {
    final meals = <(MealType, String, IconData)>[
      (MealType.breakfast, 'Breakfast', Icons.free_breakfast),
      (MealType.lunch, 'Lunch', Icons.lunch_dining),
      (MealType.dinner, 'Dinner', Icons.dinner_dining),
      (MealType.snack, 'Snack', Icons.icecream),
    ];

    if (preselected != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => SearchFoodPage(meal: preselected!)),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Select meal')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...meals.map((m) {
            return Card(
              child: ListTile(
                leading: Icon(m.$3),
                title: Text(m.$2),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => SearchFoodPage(meal: m.$1)),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
