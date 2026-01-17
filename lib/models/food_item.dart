import 'package:hive/hive.dart';

class FoodItem {
  final String id; // stable unique id
  final String name;

  // per 1 serving
  final int calories;
  final double protein;
  final double carbs;
  final double fat;

  final String servingLabel;

  const FoodItem({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.servingLabel,
  });
}

class FoodItemAdapter extends TypeAdapter<FoodItem> {
  @override
  final int typeId = 1;

  @override
  FoodItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return FoodItem(
      id: fields[0] as String,
      name: fields[1] as String,
      calories: fields[2] as int,
      protein: (fields[3] as num).toDouble(),
      carbs: (fields[4] as num).toDouble(),
      fat: (fields[5] as num).toDouble(),
      servingLabel: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, FoodItem obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.calories)
      ..writeByte(3)
      ..write(obj.protein)
      ..writeByte(4)
      ..write(obj.carbs)
      ..writeByte(5)
      ..write(obj.fat)
      ..writeByte(6)
      ..write(obj.servingLabel);
  }
}
