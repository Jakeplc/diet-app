import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/food_entry.dart';
import '../state/app_state.dart';
import 'add_food_flow/serving_page.dart';

class DayLogPage extends StatelessWidget {
  final DateTime date;
  const DayLogPage({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final key = dayKeyOf(date);

    final entries = s.entriesForDayKey(key);
    final totals = s.totalsForDayKey(key);

    final title = '${date.month}/${date.day}/${date.year}';

    return Scaffold(
      appBar: AppBar(title: Text('Log • $title')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Totals', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text('${totals.calories} cal',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text(
                    '${totals.protein.toStringAsFixed(0)}P  ${totals.carbs.toStringAsFixed(0)}C  ${totals.fat.toStringAsFixed(0)}F',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (entries.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('No foods logged this day.'),
            ),
          ...entries.map((e) {
            final food = s.allFoods.firstWhere((f) => f.id == e.foodId);
            return Card(
              child: ListTile(
                title: Text(food.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(
                  '${_mealLabel(e.meal)} • ${e.servings.toStringAsFixed(e.servings % 1 == 0 ? 0 : 2)} × ${food.servingLabel}',
                ),
                trailing: Text('${(food.calories * e.servings).round()} cal'),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ServingPage(
                      meal: e.meal,
                      food: food,
                      editingEntryId: e.id,
                      initialServings: e.servings,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  static String _mealLabel(MealType m) => switch (m) {
        MealType.breakfast => 'Breakfast',
        MealType.lunch => 'Lunch',
        MealType.dinner => 'Dinner',
        MealType.snack => 'Snack',
      };
}
