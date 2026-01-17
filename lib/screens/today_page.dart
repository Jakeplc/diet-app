import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/food_entry.dart';
import '../state/app_state.dart';
import '../state/subscription_state.dart';
import '../widgets/glass_card.dart';
import '../widgets/macro_ring_dashboard.dart';
import '../widgets/step_counter_widget.dart';
import 'add_food_flow/select_meal_page.dart';
import 'add_food_flow/serving_page.dart';
import 'glp1/glp1_tracker_page.dart';
import 'paywall/paywall_page.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final cs = Theme.of(context).colorScheme;

    final caloriesLeft = state.caloriesGoal - state.caloriesEaten;
    final progress = (state.caloriesEaten / state.caloriesGoal).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [cs.background, cs.surface],
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Macro Dashboard with gradient rings
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('Calories Today',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  const MacroRingDashboard(),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Step Counter
            GlassCard(child: const StepCounterWidget()),

            const SizedBox(height: 24),

            // Quick Add Meals (gradient glass cards)
            Text('Quick Add', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                _QuickMealCard(
                    icon: Icons.free_breakfast,
                    label: 'Breakfast',
                    colorStart: Colors.orange.shade300,
                    colorEnd: Colors.deepOrange.shade600),
                _QuickMealCard(
                    icon: Icons.lunch_dining,
                    label: 'Lunch',
                    colorStart: Colors.green.shade300,
                    colorEnd: Colors.teal.shade600),
                _QuickMealCard(
                    icon: Icons.dinner_dining,
                    label: 'Dinner',
                    colorStart: Colors.purple.shade300,
                    colorEnd: Colors.indigo.shade600),
                _QuickMealCard(
                    icon: Icons.icecream,
                    label: 'Snack',
                    colorStart: Colors.pink.shade300,
                    colorEnd: Colors.redAccent.shade700),
              ],
            ),

            const SizedBox(height: 24),

            // GLP-1 Tracker Tile
            _Glp1Tile(),

            const SizedBox(height: 24),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('Water Intake',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  _AnimatedWaterTracker(
                      cupsDrunk: state.waterCups,
                      goal: 8), // Replace with your state
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Empty state or logged foods list...
            if (state.foodEntries.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(Icons.restaurant_menu,
                        size: 80, color: cs.primary.withOpacity(0.5)),
                    const SizedBox(height: 16),
                    Text('No foods logged yet.\nAdd your first meal!',
                        textAlign: TextAlign.center),
                  ],
                ),
              )
            else
              // Your food list here...
              const Text('Your meals today...'),
          ],
        ),
      ),
    );
  }
}

class _QuickMealCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color colorStart;
  final Color colorEnd;

  const _QuickMealCard(
      {required this.icon,
      required this.label,
      required this.colorStart,
      required this.colorEnd});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to add food flow
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [colorStart, colorEnd]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _AnimatedWaterTracker extends StatefulWidget {
  final int cupsDrunk;
  final int goal;
  final VoidCallback? onUpdate; // Optional callback if not using direct state

  const _AnimatedWaterTracker({
    required this.cupsDrunk,
    required this.goal,
    this.onUpdate,
  });

  @override
  State<_AnimatedWaterTracker> createState() => _AnimatedWaterTrackerState();
}

class _AnimatedWaterTrackerState extends State<_AnimatedWaterTracker> {
  @override
  Widget build(BuildContext context) {
    final progress = widget.cupsDrunk / widget.goal;
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            // Optional: toggle or increment on whole tracker tap
          },
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.cyan.withOpacity(0.4)),
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              ClipRRect(
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(24)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubicEmphasized,
                  height: 180 * progress.clamp(0.0, 1.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.cyan.shade600,
                        Colors.blueAccent.shade300
                      ],
                      stops: const [0.0, 1.0],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '${widget.cupsDrunk} / ${widget.goal} cups',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(color: cs.onSurface),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: List.generate(widget.goal, (i) {
            final filled = i < widget.cupsDrunk;
            return GestureDetector(
              onTap: () {
                // Update your state here
                // Example: Provider.of<AppState>(context, listen: false).setWaterCups(i + 1);
                if (widget.onUpdate != null) widget.onUpdate!();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: filled ? Colors.cyan : cs.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: filled
                      ? [
                          BoxShadow(
                              color: Colors.cyan.withOpacity(0.4),
                              blurRadius: 8)
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      color: filled ? Colors.white : cs.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
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
