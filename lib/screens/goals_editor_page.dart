import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class GoalsEditorPage extends StatefulWidget {
  const GoalsEditorPage({super.key});

  @override
  State<GoalsEditorPage> createState() => _GoalsEditorPageState();
}

class _GoalsEditorPageState extends State<GoalsEditorPage> {
  late final TextEditingController calories;
  late final TextEditingController protein;
  late final TextEditingController carbs;
  late final TextEditingController fat;

  int _i(String s) => int.tryParse(s.trim()) ?? 0;
  double _d(String s) => double.tryParse(s.trim()) ?? 0;

  @override
  void initState() {
    super.initState();
    final log = context.read<AppState>().dayLog;

    calories = TextEditingController(text: log.calorieGoal.toString());
    protein = TextEditingController(text: log.proteinGoal.toStringAsFixed(0));
    carbs = TextEditingController(text: log.carbsGoal.toStringAsFixed(0));
    fat = TextEditingController(text: log.fatGoal.toStringAsFixed(0));
  }

  @override
  void dispose() {
    calories.dispose();
    protein.dispose();
    carbs.dispose();
    fat.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await context.read<AppState>().setGoals(
          calorieGoal: _i(calories.text),
          proteinGoal: _d(protein.text),
          carbsGoal: _d(carbs.text),
          fatGoal: _d(fat.text),
        );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit goals'),
        actions: [
          TextButton(onPressed: _save, child: const Text('Save')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Applies to: ${s.dayLog.dayKey}', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          TextField(
            controller: calories,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Calories goal',
              prefixIcon: Icon(Icons.local_fire_department),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: protein,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Protein (g)'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: carbs,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Carbs (g)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: fat,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Fat (g)'),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Save goals'),
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
