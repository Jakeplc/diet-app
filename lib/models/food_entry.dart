import 'package:hive/hive.dart';

enum MealType {
  breakfast,
  lunch,
  dinner,
  snack,
}

class MealTypeAdapter extends TypeAdapter<MealType> {
  @override
  final int typeId = 2;

  @override
  MealType read(BinaryReader reader) {
    final v = reader.readByte();
    return MealType.values[v.clamp(0, MealType.values.length - 1)];
    }

  @override
  void write(BinaryWriter writer, MealType obj) {
    writer.writeByte(obj.index);
  }
}

class FoodEntry {
  final String id; // unique entry id
  final String foodId; // references FoodItem.id
  final MealType meal;
  final double servings; // multiplier
  final DateTime createdAt;

  const FoodEntry({
    required this.id,
    required this.foodId,
    required this.meal,
    required this.servings,
    required this.createdAt,
  });
}

class FoodEntryAdapter extends TypeAdapter<FoodEntry> {
  @override
  final int typeId = 3;

  @override
  FoodEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }

    return FoodEntry(
      id: fields[0] as String,
      foodId: fields[1] as String,
      meal: fields[2] as MealType,
      servings: (fields[3] as num).toDouble(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(fields[4] as int),
    );
  }

  @override
  void write(BinaryWriter writer, FoodEntry obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.foodId)
      ..writeByte(2)
      ..write(obj.meal)
      ..writeByte(3)
      ..write(obj.servings)
      ..writeByte(4)
      ..write(obj.createdAt.millisecondsSinceEpoch);
  }
}
