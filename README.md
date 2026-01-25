# Diet App

A Flutter diet tracking application for logging meals, tracking macros (protein, carbs, fat), and monitoring daily calorie intake.

## 🔒 Keeping Your Code Private

Want to keep this repository private? See **[PRIVACY.md](PRIVACY.md)** for a comprehensive guide on:
- Making your repository private on GitHub
- Protecting sensitive information and secrets
- Security best practices for Flutter projects
- Managing local data privacy

All user data in this app is stored **locally only** (Hive database) - no data is sent to external servers.

## Features

- **Daily tracking**: Log meals throughout the day (breakfast, lunch, dinner, snack)
- **Macro tracking**: Track calories, protein, carbs, and fat with visual progress indicators
- **Custom foods**: Create custom food items with specific macro values
- **Favorites & Recents**: Quick access to frequently logged foods
- **Weekly progress**: View 7-day calorie trends with bar chart visualization
- **Streak tracking**: Monitor consecutive days of logged food
- **Water intake**: Track daily water consumption
- **Goal management**: Set custom daily goals for calories and macros

## Architecture

- **State Management**: Provider for reactive UI updates
- **Local Storage**: Hive for fast, embedded data persistence (no build_runner needed)
- **Models**: `FoodItem`, `FoodEntry`, `DayLog` with manual TypeAdapters
- **Services**: `HiveBoxes` (box accessors), `PrefsStore` (favorites/recents), `FoodSeed` (default foods)

See `.github/copilot-instructions.md` for detailed architecture and coding patterns.

## Getting Started

### Prerequisites

- Flutter 3.0.0+
- Dart 3.0.0+

### Installation

```bash
# Get dependencies
flutter pub get

# Run the app
flutter run
```

### Project Structure

```
lib/
├── main.dart                    # App entry point and Hive setup
├── app_shell.dart              # Bottom navigation shell
├── state/app_state.dart        # Central ChangeNotifier with business logic
├── models/                     # Data classes with Hive adapters
├── services/                   # HiveBoxes, PrefsStore, FoodSeed
├── screens/                    # Page widgets
│   ├── today_page.dart        # Daily tracking view
│   ├── log_food_page.dart     # Food logging entry point
│   ├── progress_page.dart     # Weekly trends and stats
│   ├── goals_editor_page.dart # Goal configuration
│   ├── day_log_page.dart      # Historical day view
│   └── add_food_flow/         # Multi-step food logging UX
└── widgets/                    # Reusable components
```

## Key Concepts

### Day Scoping

All data is organized around daily `DayLog` objects (keyed by YYYY-MM-DD). Use `appState.loadDay(date)` to switch days.

### Two-Way References

- `FoodEntry.foodId` → `FoodItem.id`
- `DayLog.entryIds` → `FoodEntry.id`

Always maintain referential integrity when modifying these relationships.

### No Build Runner

Hive TypeAdapters are written manually. When adding new persistent models:

1. Create a TypeAdapter class with unused `typeId` (currently 1-4 assigned)
2. Register in `main()` before opening boxes
3. Open Hive box in `main()`

### Provider Reactivity

Screens use `context.watch<AppState>()` to observe state changes and rebuild automatically. Avoid direct Hive box reads in widgets.

## Common Tasks

### Add a Food Entry

```dart
final entry = FoodEntry(
  id: newId(),
  foodId: selectedFood.id,
  meal: MealType.breakfast,
  servings: 1.5,
  createdAt: DateTime.now(),
);
await HiveBoxes.entries().put(entry.id, entry);
final log = appState.dayLog;
log.entryIds = [...log.entryIds, entry.id];
await HiveBoxes.dayLogs().put(log.dayKey, log);
appState.notifyListeners();
```

### Switch to a Different Day

```dart
await appState.loadDay(DateTime(2024, 1, 15));
```

### Update Daily Goals

```dart
await appState.setGoals(
  calorieGoal: 2200,
  proteinGoal: 160,
  carbsGoal: 220,
  fatGoal: 65,
);
```

## Development

### Run lint analysis

```bash
flutter analyze
```

### Build for release

```bash
flutter build apk     # Android
flutter build ios     # iOS
```

## Dependencies

- **provider**: State management
- **hive**: Local database
- **hive_flutter**: Hive Flutter integration
- **intl**: Date/time formatting

## Notes

- The app uses Material Design 3 with `useMaterial3: true`
- Food macros are stored per serving; multiply by servings when calculating totals
- Streak calculation looks back from today until the first day with no logged entries
