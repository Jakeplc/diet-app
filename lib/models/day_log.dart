import 'package:hive/hive.dart';

class DayLog {
  final String dayKey; // YYYY-MM-DD

  int waterCups;
  int calorieGoal;
  double proteinGoal;
  double carbsGoal;
  double fatGoal;

  List<String> entryIds;

  DayLog({
    required this.dayKey,
    this.waterCups = 0,
    this.calorieGoal = 2000,
    this.proteinGoal = 150,
    this.carbsGoal = 200,
    this.fatGoal = 60,
    List<String>? entryIds,
  }) : entryIds = entryIds ?? [];
}

class DayLogAdapter extends TypeAdapter<DayLog> {
  @override
  final int typeId = 4;

  @override
  DayLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }

    return DayLog(
      dayKey: fields[0] as String,
      waterCups: fields[1] as int,
      calorieGoal: fields[2] as int,
      proteinGoal: (fields[3] as num).toDouble(),
      carbsGoal: (fields[4] as num).toDouble(),
      fatGoal: (fields[5] as num).toDouble(),
      entryIds: (fields[6] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, DayLog obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.dayKey)
      ..writeByte(1)
      ..write(obj.waterCups)
      ..writeByte(2)
      ..write(obj.calorieGoal)
      ..writeByte(3)
      ..write(obj.proteinGoal)
      ..writeByte(4)
      ..write(obj.carbsGoal)
      ..writeByte(5)
      ..write(obj.fatGoal)
      ..writeByte(6)
      ..write(obj.entryIds);
  }
}
