import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../models/day_log.dart';
import '../models/food_entry.dart';
import '../models/food_item.dart';
import '../services/hive_boxes.dart';
import '../services/prefs_store.dart';

String dayKeyOf(DateTime dt) => DateFormat('yyyy-MM-dd').format(dt);
String newId() => DateTime.now().microsecondsSinceEpoch.toString();

class MacroTotals {
  final int calories;
  final double protein;
  final double carbs;
  final double fat;

  const MacroTotals({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  MacroTotals operator +(MacroTotals other) => MacroTotals(
        calories: calories + other.calories,
        protein: protein + other.protein,
        carbs: carbs + other.carbs,
        fat: fat + other.fat,
      );
}

class AppState extends ChangeNotifier {
  DateTime _selectedDay = DateTime.now();
  DayLog? _dayLog;

  DateTime get selectedDay => _selectedDay;
  DayLog get dayLog => _dayLog!;

  Future<void> loadDay([DateTime? day]) async {
    if (day != null) _selectedDay = day;
    final key = dayKeyOf(_selectedDay);

    final box = HiveBoxes.dayLogs();
    var log = box.get(key);
    if (log == null) {
      log = DayLog(dayKey: key);
      await box.put(key, log);
    }
    _dayLog = log;
    notifyListeners();
  }

  Future<DayLog> getOrCreateLogFor(DateTime day) async {
    final key = dayKeyOf(day);
    final box = HiveBoxes.dayLogs();
    var log = box.get(key);
    if (log == null) {
      log = DayLog(dayKey: key);
      await box.put(key, log);
    }
    return log;
  }

  // ---- Water ----
  Future<void> setWaterCups(int cups) async {
    final log = dayLog;
    log.waterCups = math.max(0, math.min(16, cups));
    await HiveBoxes.dayLogs().put(log.dayKey, log);
    notifyListeners();
  }

  // ---- Goals ----
  Future<void> setGoals({
    int? calorieGoal,
    double? proteinGoal,
    double? carbsGoal,
    double? fatGoal,
  }) async {
    final log = dayLog;
    if (calorieGoal != null) log.calorieGoal = calorieGoal;
    if (proteinGoal != null) log.proteinGoal = proteinGoal;
    if (carbsGoal != null) log.carbsGoal = carbsGoal;
    if (fatGoal != null) log.fatGoal = fatGoal;
    await HiveBoxes.dayLogs().put(log.dayKey, log);
    notifyListeners();
  }

  // ---- Favorites + Recents ----
  List<String> get favoriteIds => PrefsStore.favorites();
  List<String> get recentIds => PrefsStore.recents();

  bool isFavorite(String foodId) => favoriteIds.contains(foodId);

  Future<void> toggleFavorite(String foodId) async {
    await PrefsStore.toggleFavorite(foodId);
    notifyListeners();
  }

  // ---- Foods ----
  List<FoodItem> get allFoods =>
      HiveBoxes.foods().values.toList()..sort((a, b) => a.name.compareTo(b.name));

  // ---- Entries (selected day) ----
  List<FoodEntry> get todaysEntries => entriesForDayKey(dayLog.dayKey);

  List<FoodEntry> entriesForDayKey(String key) {
    final log = HiveBoxes.dayLogs().get(key);
    if (log == null) return [];

    final entriesBox = HiveBoxes.entries();
    final list = <FoodEntry>[];

    for (final id in log.entryIds) {
      final e = entriesBox.get(id);
      if (e != null) list.add(e);
    }

    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<void> addFood({
    required FoodItem food,
    required MealType meal,
    required double servings,
  }) async {
    final entry = FoodEntry(
      id: newId(),
      foodId: food.id,
      meal: meal,
      servings: servings,
      createdAt: DateTime.now(),
    );

    await HiveBoxes.entries().put(entry.id, entry);

    final log = dayLog;
    log.entryIds = [...log.entryIds, entry.id];
    await HiveBoxes.dayLogs().put(log.dayKey, log);

    await PrefsStore.pushRecent(food.id);
    notifyListeners();
  }

  Future<void> updateEntryServings({
    required String entryId,
    required double servings,
  }) async {
    final box = HiveBoxes.entries();
    final entry = box.get(entryId);
    if (entry == null) return;

    final updated = FoodEntry(
      id: entry.id,
      foodId: entry.foodId,
      meal: entry.meal,
      servings: servings,
      createdAt: entry.createdAt,
    );

    await box.put(entryId, updated);
    await PrefsStore.pushRecent(updated.foodId);

    notifyListeners();
  }

  Future<void> removeEntry(String entryId) async {
    final log = dayLog;
    log.entryIds = log.entryIds.where((id) => id != entryId).toList();
    await HiveBoxes.dayLogs().put(log.dayKey, log);

    await HiveBoxes.entries().delete(entryId);
    notifyListeners();
  }

  MacroTotals totalsForDayKey(String key) {
    final log = HiveBoxes.dayLogs().get(key);
    if (log == null) return const MacroTotals(calories: 0, protein: 0, carbs: 0, fat: 0);

    final foods = HiveBoxes.foods();
    final entriesBox = HiveBoxes.entries();

    MacroTotals t = const MacroTotals(calories: 0, protein: 0, carbs: 0, fat: 0);

    for (final id in log.entryIds) {
      final e = entriesBox.get(id);
      if (e == null) continue;
      final food = foods.get(e.foodId);
      if (food == null) continue;

      t = t +
          MacroTotals(
            calories: (food.calories * e.servings).round(),
            protein: food.protein * e.servings,
            carbs: food.carbs * e.servings,
            fat: food.fat * e.servings,
          );
    }
    return t;
  }

  MacroTotals get totals => totalsForDayKey(dayLog.dayKey);

  int currentStreak({DateTime? from}) {
    final start = from ?? DateTime.now();
    int streak = 0;

    for (int i = 0; i < 3650; i++) {
      final day = DateTime(start.year, start.month, start.day).subtract(Duration(days: i));
      final key = dayKeyOf(day);
      final log = HiveBoxes.dayLogs().get(key);
      final hasLogged = (log != null && log.entryIds.isNotEmpty);
      if (!hasLogged) break;
      streak++;
    }
    return streak;
  }
}
