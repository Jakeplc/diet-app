import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'app_shell.dart';
import 'theme/app_theme.dart';

import 'models/food_item.dart';
import 'models/food_entry.dart';
import 'models/day_log.dart';
import 'models/glp1_log.dart';

import 'services/hive_boxes.dart';
import 'services/food_seed.dart';
import 'services/prefs_store.dart';

import 'state/app_state.dart';
import 'state/subscription_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // Manual adapters (no build_runner needed)
  Hive.registerAdapter(FoodItemAdapter());
  Hive.registerAdapter(MealTypeAdapter());
  Hive.registerAdapter(FoodEntryAdapter());
  Hive.registerAdapter(DayLogAdapter());
  Hive.registerAdapter(Glp1LogAdapter());

  await Hive.openBox<FoodItem>(HiveBoxes.foodsBox);
  await Hive.openBox<FoodEntry>(HiveBoxes.entriesBox);
  await Hive.openBox<DayLog>(HiveBoxes.dayLogsBox);
  await Hive.openBox<Glp1Log>(HiveBoxes.glp1Box);

  await PrefsStore.open();
  await FoodSeed.ensureSeeded();

  // Initialize states
  final appState = AppState();
  await appState.loadDay();

  final subState = await SubscriptionState.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => appState),
        ChangeNotifierProvider(create: (_) => subState),
      ],
      child: const DietApp(),
    ),
  );
}

class DietApp extends StatelessWidget {
  const DietApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diet App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const AppShell(),
    );
  }
}
