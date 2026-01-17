import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/food_entry.dart';
import '../../models/food_item.dart';
import '../../state/app_state.dart';

class ServingPage extends StatefulWidget {
  final MealType meal;
  final FoodItem food;

  // Edit mode
  final String? editingEntryId;
  final double? initialServings;

  const ServingPage({
    super.key,
    required this.meal,
    required this.food,
    this.editingEntryId,
    this.initialServings,
  });

  @override
  State<ServingPage> createState() => _ServingPageState();
}

class _ServingPageState extends State<ServingPage> {
  late double servings;

  @override
  void initState() {
    super.initState();
    servings = widget.initialServings ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    final f = widget.food;

    final cal = (f.calories * servings).round();
    final p = (f.protein * servings);
    final c = (f.carbs * servings);
    final fat = (f.fat * servings);

    final isEdit = widget.editingEntryId != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit entry' : 'Servings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    f.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text('Per serving: ${f.servingLabel}'),
                  const SizedBox(height: 14),
                  Text('$cal cal', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text('${p.toStringAsFixed(0)}P  ${c.toStringAsFixed(0)}C  ${fat.toStringAsFixed(0)}F'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Servings: ${servings.toStringAsFixed(servings % 1 == 0 ? 0 : 2)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Slider(
            value: servings,
            min: 0.25,
            max: 6,
            divisions: 23,
            label: servings.toStringAsFixed(2),
            onChanged: (v) => setState(() => servings = v),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            icon: Icon(isEdit ? Icons.save : Icons.check),
            label: Text(isEdit ? 'Save changes' : 'Add to day'),
            onPressed: () async {
              final state = context.read<AppState>();

              if (isEdit) {
                await state.updateEntryServings(
                  entryId: widget.editingEntryId!,
                  servings: servings,
                );
                if (mounted) Navigator.pop(context);
              } else {
                await state.addFood(food: f, meal: widget.meal, servings: servings);
                if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
              }
            },
          ),
        ],
      ),
    );
  }
}
