import 'package:flutter/material.dart';

import 'screens/today_page.dart';
import 'screens/log_food_page.dart';
import 'screens/progress_page.dart';
import 'screens/goals_editor_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    const pages = [
      TodayPage(),
      LogFoodPage(),
      ProgressPage(),
    ];

    const titles = ['Today', 'Log Food', 'Progress'];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[index]),
        actions: [
          if (index == 0)
            IconButton(
              tooltip: 'Edit goals',
              icon: const Icon(Icons.tune),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const GoalsEditorPage()),
              ),
            ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: pages[index],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => setState(() => index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.today), label: 'Today'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Log'),
          NavigationDestination(
              icon: Icon(Icons.show_chart), label: 'Progress'),
        ],
      ),
    );
  }
}
