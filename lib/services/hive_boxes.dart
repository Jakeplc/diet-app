import 'package:hive/hive.dart';

import '../models/food_item.dart';
import '../models/food_entry.dart';
import '../models/day_log.dart';

class HiveBoxes {
  static const foodsBox = 'foods';
  static const entriesBox = 'entries';
  static const dayLogsBox = 'daylogs';

  static Box<FoodItem> foods() => Hive.box<FoodItem>(foodsBox);
  static Box<FoodEntry> entries() => Hive.box<FoodEntry>(entriesBox);
  static Box<DayLog> dayLogs() => Hive.box<DayLog>(dayLogsBox);
}
