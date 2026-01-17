import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class StepCounterWidget extends StatelessWidget {
  const StepCounterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Example values – replace with your real logic
    // You can store steps in AppState, Hive, or integrate with pedometer package
    const currentSteps = 7423; // ← Replace with real data
    const dailyGoal = 10000;
    final progress = (currentSteps / dailyGoal).clamp(0.0, 1.0);

    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Steps Today',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          CircularPercentIndicator(
            radius: 85,
            lineWidth: 16,
            percent: progress,
            animation: true,
            animateFromLastPercent: true,
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: cs.primary,
            backgroundColor: cs.primaryContainer.withOpacity(0.3),
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$currentSteps',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
                Text(
                  '/ $dailyGoal',
                  style: TextStyle(
                    fontSize: 16,
                    color: cs.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${(progress * 100).toStringAsFixed(0)}% of daily goal',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface.withOpacity(0.8),
                ),
          ),
        ],
      ),
    );
  }
}
