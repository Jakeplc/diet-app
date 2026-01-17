import 'package:hive/hive.dart';

class PrefsStore {
  static const boxName = 'prefs';

  static const _kFavorites = 'favorites';
  static const _kRecents = 'recents';

  static Future<void> open() async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox(boxName);
    }
  }

  static Box get _box => Hive.box(boxName);

  static List<String> favorites() =>
      (_box.get(_kFavorites, defaultValue: <String>[]) as List).cast<String>();

  static List<String> recents() =>
      (_box.get(_kRecents, defaultValue: <String>[]) as List).cast<String>();

  static Future<void> toggleFavorite(String foodId) async {
    final fav = favorites();
    if (fav.contains(foodId)) {
      fav.remove(foodId);
    } else {
      fav.insert(0, foodId);
    }
    await _box.put(_kFavorites, fav);
  }

  static Future<void> pushRecent(String foodId, {int max = 12}) async {
    final r = recents();
    r.remove(foodId);
    r.insert(0, foodId);
    if (r.length > max) r.removeRange(max, r.length);
    await _box.put(_kRecents, r);
  }
}
