class WeightLog {
  String id;
  double weight; // kg
  DateTime timestamp;
  String? notes;
  String? photoPath; // Progress photo

  WeightLog({
    required this.id,
    required this.weight,
    required this.timestamp,
    this.notes,
    this.photoPath,
  });
}
