import 'package:hive/hive.dart';

class Glp1Log {
  final String id;
  final DateTime injectionAt;
  final String medication;
  final double doseMg;
  final String site;
  final String sideEffects;
  final String notes;

  const Glp1Log({
    required this.id,
    required this.injectionAt,
    required this.medication,
    required this.doseMg,
    this.site = '',
    this.sideEffects = '',
    this.notes = '',
  });
}

class Glp1LogAdapter extends TypeAdapter<Glp1Log> {
  @override
  final int typeId = 5;

  @override
  Glp1Log read(BinaryReader reader) {
    final n = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < n; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return Glp1Log(
      id: fields[0] as String,
      injectionAt: DateTime.fromMillisecondsSinceEpoch(fields[1] as int),
      medication: fields[2] as String,
      doseMg: (fields[3] as num).toDouble(),
      site: fields[4] as String,
      sideEffects: fields[5] as String,
      notes: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Glp1Log obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.injectionAt.millisecondsSinceEpoch)
      ..writeByte(2)
      ..write(obj.medication)
      ..writeByte(3)
      ..write(obj.doseMg)
      ..writeByte(4)
      ..write(obj.site)
      ..writeByte(5)
      ..write(obj.sideEffects)
      ..writeByte(6)
      ..write(obj.notes);
  }
}
