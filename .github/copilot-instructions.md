# Diet App - AI Coding Agent Instructions

## Architecture Overview

This is a **Flutter diet tracking app** using **Provider for state management** and **Hive for local persistence**. The architecture separates concerns into clean layers:

- **State Layer** (`state/app_state.dart`): Single `AppState` ChangeNotifier that manages app-wide state (selected day, goals, favorites/recents). Provides all business logic through methods like `loadDay()`, `setGoals()`, `toggleFavorite()`.
- **Models** (`models/`): Data classes (FoodItem, FoodEntry, DayLog) with manual Hive TypeAdapters (no build_runner needed).
- **Services** (`services/`): Low-level data access and storage:
  - `HiveBoxes`: Static accessors for three Hive boxes (foods, entries, daylogs)
  - `PrefsStore`: Preferences for favorites/recents lists (stored in Hive)
  - `FoodSeed`: Initializes default food database
- **Screens & Widgets**: UI layer using Provider to observe `AppState` for reactivity.

## Key Architectural Decisions

1. **No build_runner**: Hive adapters are manually written. When adding new models with Hive persistence, follow the pattern in `FoodItemAdapter`—don't generate them.
2. **Hive typeId requirements**: Each TypeAdapter has a unique `typeId` (1-4 currently assigned). Avoid conflicts when adding new types.
3. **Day-scoped state**: `DayLog` is the root entity holding goals and entry references. Load daily data via `AppState.loadDay(date)`. Use `dayKeyOf(DateTime)` (YYYY-MM-DD format) for consistent keys.
4. **Two-way references**: `FoodEntry.foodId` references `FoodItem.id`; `DayLog.entryIds` references `FoodEntry.id`. Maintain referential integrity when deleting.

## Common Workflows

- **Adding a food entry**: Create `FoodEntry`, add to `HiveBoxes.entries()`, append entry.id to `DayLog.entryIds`, call `AppState.notifyListeners()`.
- **Loading a different day**: Call `appState.loadDay(selectedDate)` to fetch/create DayLog and refresh UI.
- **Persisting model changes**: Always call `HiveBoxes.xxx().put(key, obj)` after mutating objects, then `notifyListeners()` for Provider listeners.
- **Managing food data**: Use `FoodSeed.ensureSeeded()` (run once at startup) to populate default foods; add custom foods to `HiveBoxes.foods()` as needed.

## Code Style & Patterns

- **Provider observability**: Screens wrap Hive reads in `context.watch<AppState>()` to trigger rebuilds on state changes. Avoid direct Hive box reads in widgets.
- **Naming conventions**: Use `dayKey` (YYYY-MM-DD), `foodId`/`entryId` for references, `servings` for quantity multipliers (not integer portions).
- **Null safety**: Models use `required` fields; `DayLog?` may be null before `loadDay()` is called—check with `_dayLog!` after confirming it's loaded.
- **List mutations in Hive**: For lists stored in Hive (e.g., `entryIds`), mutate the local list, then call `.put()` to persist the entire object.

## File Organization

```
lib/
├── main.dart                    # App initialization, Hive setup, Provider wrapping
├── app_shell.dart              # Bottom nav shell (Today/Log/Progress)
├── state/app_state.dart        # Central ChangeNotifier with all business logic
├── models/                     # Hive data classes + TypeAdapters
├── services/                   # HiveBoxes, PrefsStore, FoodSeed
├── screens/                    # Page widgets (TodayPage, LogFoodPage, etc.)
├── screens/add_food_flow/      # Multi-step food logging UX
└── widgets/                    # Reusable UI components
```

## Integration Points & Gotchas

- **Hive initialization**: Must call `Hive.initFlutter()`, register all adapters, and open boxes in `main()` before `runApp()`. See [main.dart](lib/main.dart#L18-L31).
- **PrefsStore initialization**: Call `PrefsStore.open()` in `main()` after Hive init.
- **DateTime formatting**: Always use `dayKeyOf(DateTime)` (defined in [app_state.dart](app_state.dart#L12)) for day keys—ensures YYYY-MM-DD consistency.
- **Unique IDs**: Use `newId()` (timestamp-based) for entry/food IDs; stable `id` field on FoodItem is external data key.

## When Adding Features

- **New persistent data**: Create a model class, write a TypeAdapter with unused `typeId`, open a Hive box in `main()`.
- **New state logic**: Add methods to `AppState`, mutate models, call `.put()` on Hive boxes, call `notifyListeners()`.
- **UI for state changes**: Wrap reads with `context.watch<AppState>()` in build methods to auto-rebuild.
- **Navigation**: Use `Navigator.of(context).push()` for new screens (see GoalsEditorPage example in [app_shell.dart](app_shell.dart#L30-L35)).
