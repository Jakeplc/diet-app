import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/food_item.dart';
import '../../services/hive_boxes.dart';
import '../../services/nutrition_scan.dart';

class CustomFoodPage extends StatefulWidget {
  const CustomFoodPage({super.key});

  @override
  State<CustomFoodPage> createState() => _CustomFoodPageState();
}

class _CustomFoodPageState extends State<CustomFoodPage> {
  final _formKey = GlobalKey<FormState>();

  final name = TextEditingController();
  final serving = TextEditingController(text: '1 serving');

  final calories = TextEditingController();
  final protein = TextEditingController();
  final carbs = TextEditingController();
  final fat = TextEditingController();

  double _d(String s) => double.tryParse(s.trim()) ?? 0;
  int _i(String s) => int.tryParse(s.trim()) ?? 0;

  Future<void> _scanLabel() async {
    final picker = ImagePicker();

    final shot = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (shot == null) return;

    final res = await NutritionScan.scanFromFile(File(shot.path));

    if (!res.hasAnything) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Could not read label clearly. Try again with better lighting.'),
        ),
      );
      return;
    }

    // Fill controllers (only if found)
    if (res.calories != null) calories.text = res.calories.toString();
    if (res.protein != null) protein.text = res.protein!.toStringAsFixed(0);
    if (res.carbs != null) carbs.text = res.carbs!.toStringAsFixed(0);
    if (res.fat != null) fat.text = res.fat!.toStringAsFixed(0);

    // Optional serving label
    if (res.servingLabel != null && res.servingLabel!.isNotEmpty) {
      serving.text = res.servingLabel!;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Scanned! Review values before saving.')),
    );
  }

  @override
  void dispose() {
    name.dispose();
    serving.dispose();
    calories.dispose();
    protein.dispose();
    carbs.dispose();
    fat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create custom food')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ✅ Scan button belongs OUTSIDE the Row(fields) so layout is valid.
          FilledButton.icon(
            icon: const Icon(Icons.camera_alt),
            label: const Text('Scan nutrition label'),
            onPressed: _scanLabel,
          ),
          const SizedBox(height: 12),

          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: name,
                  decoration: const InputDecoration(labelText: 'Food name'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: serving,
                  decoration: const InputDecoration(
                    labelText: 'Serving label (e.g. 100g, 1 cup)',
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: calories,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Calories per serving'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: protein,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Protein (g)'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: carbs,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Carbs (g)'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: fat,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Fat (g)'),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Save food'),
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;

                    final id =
                        'custom_${DateTime.now().microsecondsSinceEpoch}';
                    final item = FoodItem(
                      id: id,
                      name: name.text.trim(),
                      calories: _i(calories.text),
                      protein: _d(protein.text),
                      carbs: _d(carbs.text),
                      fat: _d(fat.text),
                      servingLabel: serving.text.trim().isEmpty
                          ? '1 serving'
                          : serving.text.trim(),
                    );

                    await HiveBoxes.foods().put(item.id, item);

                    if (mounted) Navigator.pop(context, item);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
