class WaterLog {
  String id;
  double amount; // ml
  DateTime timestamp;

  WaterLog({required this.id, required this.amount, required this.timestamp});

  String get dateKey {
    return '${timestamp.year}-${timestamp.month.toString().padLeft(2, '0')}-${timestamp.day.toString().padLeft(2, '0')}';
  }
}
