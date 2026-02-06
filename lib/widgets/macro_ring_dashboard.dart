import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart'; // Adjust path if needed

class MacroRingDashboard extends StatelessWidget {
  const MacroRingDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final dayLog = state.dayLog;

    // Calculate totals
    final totals = state.totalsForDayKey(dayLog.dayKey);

    final caloriesLeft = dayLog.calorieGoal - totals.calories;
    final calPct = (totals.calories / dayLog.calorieGoal).clamp(0.0, 1.0);

    final protPct = (totals.protein / dayLog.proteinGoal).clamp(0.0, 1.0);
    final carbsPct = (totals.carbs / dayLog.carbsGoal).clamp(0.0, 1.0);
    final fatPct = (totals.fat / dayLog.fatGoal).clamp(0.0, 1.0);

    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        children: [
          // Central big calories ring
          CircularPercentIndicator(
            radius: 100.0,
            lineWidth: 20.0,
            percent: calPct,
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$caloriesLeft',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: cs.primary,
                  ),
                ),
                Text(
                  'left',
                  style: TextStyle(
                      fontSize: 16, color: cs.onSurface.withOpacity(0.7)),
                ),
              ],
            ),
            progressColor: cs.primary,
            backgroundColor: cs.primaryContainer.withOpacity(0.3),
            animation: true,
            animateFromLastPercent: true,
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(height: 32),

          // Three smaller macro rings in a row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _MacroRing(
                label: 'Protein',
                percent: protPct,
                value:
                    '${totals.protein.toStringAsFixed(1)}/${dayLog.proteinGoal}g',
                color: Colors.purpleAccent,
              ),
              _MacroRing(
                label: 'Carbs',
                percent: carbsPct,
                value:
                    '${totals.carbs.toStringAsFixed(1)}/${dayLog.carbsGoal}g',
                color: Colors.amber,
              ),
              _MacroRing(
                label: 'Fat',
                percent: fatPct,
                value: '${totals.fat.toStringAsFixed(1)}/${dayLog.fatGoal}g',
                color: Colors.redAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroRing extends StatelessWidget {
  final String label;
  final double percent;
  final String value;
  final Color color;

  const _MacroRing({
    required this.label,
    required this.percent,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircularPercentIndicator(
          radius: 50.0,
          lineWidth: 10.0,
          percent: percent,
          center: Text(
            '${(percent * 100).toStringAsFixed(0)}%',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          progressColor: color,
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          animation: true,
          circularStrokeCap: CircularStrokeCap.round,
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 13)),
        Text(value,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
