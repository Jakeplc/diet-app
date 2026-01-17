import 'package:flutter/material.dart';

import 'screens/today_page.dart';
import 'screens/log_food_page.dart';
import 'screens/progress_page.dart';
import 'screens/goals_editor_page.dart';
import 'screens/settings_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  var _index = 0;

  static const _pages = [
    TodayPage(),
    LogFoodPage(),
    ProgressPage(),
  ];

  static const _titles = ['Today', 'Log Food', 'Progress'];

  static const _destinations = [
    NavigationDestination(icon: Icon(Icons.today), label: 'Today'),
    NavigationDestination(icon: Icon(Icons.search), label: 'Log'),
    NavigationDestination(icon: Icon(Icons.show_chart), label: 'Progress'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SettingsPage())),
          ),
          if (_index == 0)
            IconButton(
              icon: const Icon(Icons.tune),
              tooltip: 'Edit goals',
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const GoalsEditorPage())),
            ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: _pages[_index],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: _destinations,
      ),
    );
  }
}
