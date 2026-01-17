import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/food_entry.dart';
import '../../models/food_item.dart';
import '../../state/app_state.dart';
import 'serving_page.dart';
import 'custom_food_page.dart';

class SearchFoodPage extends StatefulWidget {
  final MealType meal;
  const SearchFoodPage({super.key, required this.meal});

  @override
  State<SearchFoodPage> createState() => _SearchFoodPageState();
}

class _SearchFoodPageState extends State<SearchFoodPage> {
  String q = '';

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final foodsById = {for (final f in s.allFoods) f.id: f};

    List<FoodItem> mapIds(List<String> ids) {
      final out = <FoodItem>[];
      for (final id in ids) {
        final f = foodsById[id];
        if (f != null) out.add(f);
      }
      return out;
    }

    final favorites = mapIds(s.favoriteIds);
    final recents = mapIds(s.recentIds);

    final all = s.allFoods;
    final filtered = q.trim().isEmpty
        ? all
        : all.where((f) => f.name.toLowerCase().contains(q.toLowerCase())).toList();

    final showSections = q.trim().isEmpty;

    Future<void> createCustom() async {
      final created = await Navigator.of(context).push<FoodItem>(
        MaterialPageRoute(builder: (_) => const CustomFoodPage()),
      );
      if (created != null && context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ServingPage(meal: widget.meal, food: created)),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search food'),
        actions: [
          IconButton(
            tooltip: 'Create custom food',
            icon: const Icon(Icons.add),
            onPressed: createCustom,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search foods (e.g., chicken, rice)',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => q = v.trim()),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  if (showSections && favorites.isNotEmpty) ...[
                    const _SectionHeader(title: 'Favorites'),
                    ...favorites.map((f) => _FoodRow(meal: widget.meal, food: f)),
                    const SizedBox(height: 10),
                  ],
                  if (showSections && recents.isNotEmpty) ...[
                    const _SectionHeader(title: 'Recents'),
                    ...recents.map((f) => _FoodRow(meal: widget.meal, food: f)),
                    const SizedBox(height: 10),
                  ],
                  _SectionHeader(title: showSections ? 'All foods' : 'Results'),
                  ...filtered.map((f) => _FoodRow(meal: widget.meal, food: f)),
                  const SizedBox(height: 70),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Custom food'),
        onPressed: createCustom,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 6),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _FoodRow extends StatelessWidget {
  final MealType meal;
  final FoodItem food;

  const _FoodRow({required this.meal, required this.food});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final fav = s.isFavorite(food.id);

    return Card(
      child: ListTile(
        title: Text(food.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${food.calories} cal • ${food.protein.toStringAsFixed(0)}P ${food.carbs.toStringAsFixed(0)}C ${food.fat.toStringAsFixed(0)}F • ${food.servingLabel}',
        ),
        leading: IconButton(
          icon: Icon(fav ? Icons.star : Icons.star_border),
          onPressed: () => context.read<AppState>().toggleFavorite(food.id),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ServingPage(meal: meal, food: food)),
        ),
      ),
    );
  }
}
