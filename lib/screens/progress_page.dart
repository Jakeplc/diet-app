import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import 'day_log_page.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();

    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day)
        .subtract(const Duration(days: 6));

    final days = List.generate(7, (i) {
      final d = start.add(Duration(days: i));
      final key = dayKeyOf(d);
      final totals = s.totalsForDayKey(key);
      return _DayBar(
          date: d,
          dayKey: key,
          label: _dow(d.weekday),
          calories: totals.calories);
    });

    final weeklyTotal = days.fold<int>(0, (sum, x) => sum + x.calories);
    final weeklyAvg = (weeklyTotal / 7).round();
    final streak = s.currentStreak(from: today);
    final goal = s.dayLog.calorieGoal;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
                child: GlassCard(
                    context: context,
                    child: _StatContent(
                        title: 'Current streak',
                        value: '$streak days',
                        subtitle: 'Days with food logged'))),
            const SizedBox(width: 12),
            Expanded(
                child: GlassCard(
                    context: context,
                    child: _StatContent(
                        title: 'Weekly avg',
                        value: '$weeklyAvg',
                        subtitle: 'Calories/day'))),
          ],
        ),
        const SizedBox(height: 16),
        Text('Last 7 days', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        GlassCard(
          context: context,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Calories', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text('Goal line: $goal cal',
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: _BarChart(
                    days: days,
                    goal: goal,
                    today: today,
                    onTapDay: (d) {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => DayLogPage(date: d)));
                    }),
              ),
              const SizedBox(height: 8),
              Text('Tap a bar to open that day’s log.',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...days.map((d) {
          final label = '${d.label} ${d.date.month}/${d.date.day}';
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GlassCard(
              context: context,
              child: ListTile(
                title: Text(label),
                trailing: Text('${d.calories} cal',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => DayLogPage(date: d.date))),
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        GlassCard(
          context: context,
          child: ListTile(
            title: const Text('Weekly total'),
            trailing: Text('$weeklyTotal cal',
                style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
        ),
      ],
    );
  }

  static String _dow(int weekday) => switch (weekday) {
        1 => 'Mon',
        2 => 'Tue',
        3 => 'Wed',
        4 => 'Thu',
        5 => 'Fri',
        6 => 'Sat',
        7 => 'Sun',
        _ => '',
      };
}

class _DayBar {
  final DateTime date;
  final String dayKey;
  final String label;
  final int calories;

  const _DayBar(
      {required this.date,
      required this.dayKey,
      required this.label,
      required this.calories});
}

class _StatContent extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;

  const _StatContent(
      {required this.title, required this.value, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 6),
          Text(value,
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

Widget GlassCard({
  required BuildContext context,
  required Widget child,
  EdgeInsets padding = const EdgeInsets.all(0),
  double borderRadius = 20,
  double blur = 12,
  double opacity = 0.12,
}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(borderRadius),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor.withOpacity(opacity),
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.2),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4)),
          ],
        ),
        child: child,
      ),
    ),
  );
}

class _BarChart extends StatelessWidget {
  final List<_DayBar> days;
  final int goal;
  final DateTime today;
  final void Function(DateTime) onTapDay;

  const _BarChart(
      {required this.days,
      required this.goal,
      required this.today,
      required this.onTapDay});

  @override
  Widget build(BuildContext context) {
    final maxVal = days.map((d) => d.calories).fold(0, (m, v) => v > m ? v : m);
    final yMax = _niceMax(maxVal > goal ? maxVal : goal);
    final goalPct = yMax == 0 ? 0.0 : (goal / yMax).clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        const chartH = 150.0;
        final lineY = chartH * (1 - goalPct);

        return Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: lineY,
              child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(999))),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: chartH + 40,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 40,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$yMax'),
                          Text('${(yMax * 0.5).round()}'),
                          const Text('0')
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Row(
                        children: days.map((d) {
                          final pct = yMax == 0
                              ? 0.0
                              : (d.calories / yMax).clamp(0.0, 1.0);
                          final isToday = _isSameDay(d.date, today);
                          return Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: _Bar(
                                label: d.label,
                                value: d.calories,
                                pct: pct,
                                isToday: isToday,
                                onTap: () => onTapDay(d.date),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static int _niceMax(int v) {
    if (v <= 0) return 0;
    const steps = [
      250,
      500,
      750,
      1000,
      1500,
      2000,
      2500,
      3000,
      3500,
      4000,
      5000
    ];
    for (final s in steps) if (v <= s) return s;
    return ((v + 999) ~/ 1000) * 1000;
  }
}

class _Bar extends StatelessWidget {
  final String label;
  final int value;
  final double pct;
  final bool isToday;
  final VoidCallback onTap;

  const _Bar(
      {required this.label,
      required this.value,
      required this.pct,
      required this.isToday,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final barColor =
        isToday ? cs.primary : cs.primaryContainer.withOpacity(0.9);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(value == 0 ? '' : '$value',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w400)),
          const SizedBox(height: 6),
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                height: 150 * pct,
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(10),
                  border:
                      isToday ? Border.all(color: cs.primary, width: 2) : null,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w400)),
        ],
      ),
    );
  }
}
