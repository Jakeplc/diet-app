import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class NutritionScanResult {
  final int? calories;
  final double? protein;
  final double? carbs;
  final double? fat;
  final String? servingLabel; // optional

  const NutritionScanResult({
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
    this.servingLabel,
  });

  bool get hasAnything =>
      calories != null ||
      protein != null ||
      carbs != null ||
      fat != null ||
      servingLabel != null;
}

class NutritionScan {
  static final _recognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  static Future<NutritionScanResult> scanFromFile(File imageFile) async {
    final input = InputImage.fromFile(imageFile);
    final recognized = await _recognizer.processImage(input);
    final raw = recognized.text;

    // Normalize
    final text =
        raw.replaceAll('\u00A0', ' ').replaceAll(',', '.').toLowerCase();

    // Heuristics: look for "calories", "protein", "total carbohydrate", "carbohydrate", "fat"
    int? calories = _findIntNear(text, ['calories', 'kcal']);
    final protein = _findDoubleNear(text, ['protein']);
    final carbs =
        _findDoubleNear(text, ['total carbohydrate', 'carbohydrate', 'carb']);
    final fat = _findDoubleNear(text, ['total fat', 'fat']);

    // Serving label (very heuristic): try "serving size"
    final servingLabel = _findServing(text);

    return NutritionScanResult(
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      servingLabel: servingLabel,
    );
  }

  static int? _findIntNear(String text, List<String> keys) {
    for (final k in keys) {
      final idx = text.indexOf(k);
      if (idx == -1) continue;

      // Grab a window after key
      final window = text.substring(idx, (idx + 60).clamp(0, text.length));
      final m = RegExp(r'(\d{2,5})').firstMatch(window);
      if (m != null) return int.tryParse(m.group(1)!);
    }
    return null;
  }

  static double? _findDoubleNear(String text, List<String> keys) {
    for (final k in keys) {
      final idx = text.indexOf(k);
      if (idx == -1) continue;

      final window = text.substring(idx, (idx + 80).clamp(0, text.length));
      // match patterns like "protein 12g" or "protein: 12 g"
      final m = RegExp(r'(\d{1,3}(?:\.\d{1,2})?)\s*g').firstMatch(window);
      if (m != null) return double.tryParse(m.group(1)!);
    }
    return null;
  }

  static String? _findServing(String text) {
    final idx = text.indexOf('serving size');
    if (idx == -1) return null;
    final window = text.substring(idx, (idx + 120).clamp(0, text.length));
    // e.g. "serving size 2/3 cup (55g)" or "serving size: 1 bar (60g)"
    final cleaned =
        window.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    // take the part after "serving size"
    final m = RegExp(
            r'serving size[:\s]+(.+?)(?:calories|protein|total fat|carbohydrate|$)')
        .firstMatch(cleaned);
    if (m == null) return null;
    return m.group(1)!.trim();
  }
}
