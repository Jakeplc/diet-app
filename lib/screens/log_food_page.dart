import 'package:flutter/material.dart';
import 'add_food_flow/select_meal_page.dart';

class LogFoodPage extends StatelessWidget {
  const LogFoodPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('Add food'),
              subtitle: const Text('Pick a meal → search → servings → add'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SelectMealPage()),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text('Next: barcode scan + online database (optional).'),
        ],
      ),
    );
  }
}
