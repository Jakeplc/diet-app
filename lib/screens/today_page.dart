import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/food_entry.dart';
import '../state/app_state.dart';
import '../state/subscription_state.dart';
import 'add_food_flow/select_meal_page.dart';
import 'add_food_flow/serving_page.dart';
import 'glp1/glp1_tracker_page.dart';
import 'paywall/paywall_page.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _DailyGoalCard(),
        const SizedBox(height: 12),
        Text('Quick add', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.6,
          children: const [
            _MealTile(
                meal: MealType.breakfast,
                icon: Icons.free_breakfast,
                label: 'Breakfast'),
            _MealTile(
                meal: MealType.lunch, icon: Icons.lunch_dining, label: 'Lunch'),
            _MealTile(
                meal: MealType.dinner,
                icon: Icons.dinner_dining,
                label: 'Dinner'),
            _MealTile(
                meal: MealType.snack, icon: Icons.icecream, label: 'Snack'),
          ],
        ),
        const SizedBox(height: 12),
        const _WaterCard(),
        const SizedBox(height: 12),
        _Glp1Tile(),
        const SizedBox(height: 12),
        Text('Today', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        const _MealSection(meal: MealType.breakfast),
        const _MealSection(meal: MealType.lunch),
        const _MealSection(meal: MealType.dinner),
        const _MealSection(meal: MealType.snack),
        if (s.todaysEntries.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Text('No foods logged yet. Add your first meal 👇'),
          ),
      ],
    );
  }
}

class _MealTile extends StatelessWidget {
  final MealType meal;
  final IconData icon;
  final String label;

  const _MealTile({
    required this.meal,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (_) => SelectMealPage(preselected: meal)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Icon(icon),
              const SizedBox(width: 10),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
              const Spacer(),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _WaterCard extends StatelessWidget {
  const _WaterCard();

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final cups = s.dayLog.waterCups;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Water', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                Text('$cups/8 cups',
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(8, (i) {
                final selected = i < cups;
                return FilterChip(
                  label: Text('${i + 1}'),
                  selected: selected,
                  onSelected: (v) =>
                      context.read<AppState>().setWaterCups(v ? i + 1 : i),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyGoalCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final totals = s.totals;
    final log = s.dayLog;

    final goal = log.calorieGoal;
    final eaten = totals.calories;
    final left = (goal - eaten).clamp(0, 999999);

    double pctNum(num v, num g) => g <= 0 ? 0 : (v / g).clamp(0, 1).toDouble();

    final calPct = pctNum(eaten, goal);
    final pPct = pctNum(totals.protein, log.proteinGoal);
    final cPct = pctNum(totals.carbs, log.carbsGoal);
    final fPct = pctNum(totals.fat, log.fatGoal);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SizedBox(
              width: 86,
              height: 86,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: calPct,
                    strokeWidth: 10,
                    strokeCap: StrokeCap.round,
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$left',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w800)),
                      const Text('left', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Today', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text('Goal: $goal • Eaten: $eaten',
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 10),
                  _MacroProgress(
                      label: 'Protein',
                      current: totals.protein,
                      goal: log.proteinGoal,
                      value: pPct),
                  const SizedBox(height: 6),
                  _MacroProgress(
                      label: 'Carbs',
                      current: totals.carbs,
                      goal: log.carbsGoal,
                      value: cPct),
                  const SizedBox(height: 6),
                  _MacroProgress(
                      label: 'Fat',
                      current: totals.fat,
                      goal: log.fatGoal,
                      value: fPct),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _MacroProgress extends StatelessWidget {
  final String label;
  final double current;
  final double goal;
  final double value;

  const _MacroProgress({
    required this.label,
    required this.current,
    required this.goal,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final cur = current.isFinite ? current : 0;
    final g = goal.isFinite && goal > 0 ? goal : 1;

    return Row(
      children: [
        SizedBox(
            width: 58,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall)),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(minHeight: 10, value: value),
          ),
        ),
        const SizedBox(width: 8),
        Text('${cur.toStringAsFixed(0)}/${g.toStringAsFixed(0)}g',
            style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _MealSection extends StatelessWidget {
  final MealType meal;
  const _MealSection({required this.meal});

  String _mealLabel(MealType m) => switch (m) {
        MealType.breakfast => 'Breakfast',
        MealType.lunch => 'Lunch',
        MealType.dinner => 'Dinner',
        MealType.snack => 'Snack',
      };

  IconData _mealIcon(MealType m) => switch (m) {
        MealType.breakfast => Icons.free_breakfast,
        MealType.lunch => Icons.lunch_dining,
        MealType.dinner => Icons.dinner_dining,
        MealType.snack => Icons.icecream,
      };

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final entries = s.todaysEntries.where((e) => e.meal == meal).toList();
    if (entries.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: ListTile(
            leading: Icon(_mealIcon(meal)),
            title: Text(_mealLabel(meal),
                style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle:
                Text('${entries.length} item${entries.length == 1 ? '' : 's'}'),
          ),
        ),
        const SizedBox(height: 6),
        ...entries.map((e) =>
            _EntryTile(entryId: e.id, meal: e.meal, servings: e.servings)),
        const SizedBox(height: 10),
      ],
    );
  }
}

class _EntryTile extends StatelessWidget {
  final String entryId;
  final MealType meal;
  final double servings;

  const _EntryTile({
    required this.entryId,
    required this.meal,
    required this.servings,
  });

  String _mealLabel(MealType m) => switch (m) {
        MealType.breakfast => 'Breakfast',
        MealType.lunch => 'Lunch',
        MealType.dinner => 'Dinner',
        MealType.snack => 'Snack',
      };

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final entry = s.todaysEntries.firstWhere((e) => e.id == entryId);
    final food = s.allFoods.firstWhere((f) => f.id == entry.foodId);

    return Dismissible(
      key: ValueKey(entryId),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => context.read<AppState>().removeEntry(entryId),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete),
      ),
      child: Card(
        child: ListTile(
          title: Text(food.name,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(
            '${_mealLabel(meal)} • ${servings.toStringAsFixed(servings % 1 == 0 ? 0 : 2)} × ${food.servingLabel}',
          ),
          trailing: Text('${(food.calories * servings).round()} cal'),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ServingPage(
                meal: entry.meal,
                food: food,
                editingEntryId: entry.id,
                initialServings: entry.servings,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Glp1Tile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final sub = context.watch<SubscriptionState>();
    final locked = !sub.canUseGlp1;

    return Card(
      child: ListTile(
        leading: const Icon(Icons.vaccines),
        title: const Text('GLP-1 Tracker',
            style: TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(
          locked
              ? '7-day trial available • Tap to unlock'
              : (sub.trialActive
                  ? 'Trial: ${sub.trialDaysLeft} day(s) left'
                  : 'Dose log • Side effects • Notes'),
        ),
        trailing: Icon(locked ? Icons.lock : Icons.chevron_right),
        onTap: () {
          if (sub.canUseGlp1) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => Glp1TrackerPage(),
              ),
            );
          } else {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PaywallPage(source: 'glp1'),
              ),
            );
          }
        },
      ),
    );
  }
}
