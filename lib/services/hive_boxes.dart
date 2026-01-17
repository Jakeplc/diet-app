import 'package:hive/hive.dart';

import '../models/food_item.dart';
import '../models/food_entry.dart';
import '../models/day_log.dart';
import '../models/glp1_log.dart';

class HiveBoxes {
  static const foodsBox = 'foods';
  static const entriesBox = 'entries';
  static const dayLogsBox = 'daylogs';
  static const glp1Box = 'glp1';

  static Box<FoodItem> foods() => Hive.box<FoodItem>(foodsBox);
  static Box<FoodEntry> entries() => Hive.box<FoodEntry>(entriesBox);
  static Box<DayLog> dayLogs() => Hive.box<DayLog>(dayLogsBox);
  static Box<Glp1Log> glp1() => Hive.box<Glp1Log>(glp1Box);
}
