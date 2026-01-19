# 🚀 QUICK START GUIDE - Diet Tracker App

## ⚡ Get Running in 5 Minutes

### Step 1: Install Dependencies

```bash
cd c:\Users\Jake\diet_app
flutter pub get
```

### Step 2: Check for Errors (OPTIONAL - Skip for now)

```bash
flutter analyze
```

### Step 3: Run the App

**For Android Emulator:**

```bash
flutter run
```

**For Physical Device (with USB debugging enabled):**

```bash
flutter run
```

**For Chrome (Web - Quick Test):**

```bash
flutter run -d chrome
```

---

## ✅ What's Already Built

### 🎨 **5 Complete Screens**

1. **Onboarding** - 5-step setup for new users
2. **Dashboard** - Circular charts for calories/macros/water
3. **Food Logging** - Search, barcode scan, custom entry
4. **Progress** - Weight tracking with charts
5. **Settings** - Profile, goals, premium upgrade

### 💾 **Offline-First Architecture**

- ✅ All data stored locally (Hive database)
- ✅ Works without internet after first run
- ✅ Instant loading - no API delays
- ✅ Pre-seeded with 8 common foods

### 💰 **Freemium Model**

- ✅ Free: Core tracking, basic charts, ads
- ✅ Premium: Advanced analytics, ad-free, exports
- ✅ In-app purchase flow (simulated for MVP)
- ✅ Paywall screen with pricing

### 📊 **Smart Features**

- ✅ BMR/TDEE calorie calculation
- ✅ Macro targets (40/30/30 split)
- ✅ Water tracking
- ✅ Streak counter
- ✅ Daily insights
- ✅ Health scores (green/yellow/red)

---

## 🐛 Common Issues & Fixes

### Issue 1: "Cannot find Adapter" Error

**Fix:** The app uses Maps for storage (no code generation needed initially)

```bash
# If you want type-safe storage later, run:
dart run build_runner build --delete-conflicting-outputs
```

### Issue 2: Camera Permission Error

**Android:** Permissions auto-requested  
**iOS:** Add to `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>We need camera to scan barcodes</string>
```

### Issue 3: Build Errors

```bash
flutter clean
flutter pub get
flutter run
```

---

## 📱 Test the App Flow

### First Launch

1. **Splash Screen** (2 seconds)
2. **Onboarding** (5 steps):
   - Welcome
   - Personal info (name, age, gender)
   - Physical stats (height, weight, activity)
   - Goals (lose/maintain/gain)
   - Diet preferences
3. **Dashboard** - You're in!

### Core Actions to Test

- ✅ **Add Food**: Tap "Log Food" tab → Search "chicken" → Add
- ✅ **Track Weight**: Tap "Progress" tab → + icon → Enter weight
- ✅ **View Charts**: Dashboard shows circular progress
- ✅ **Try Premium**: Settings → Upgrade banner → View paywall
- ✅ **Barcode Scan**: Log Food → Scan Barcode button

---

## 🎯 Next Steps (After Running)

### Phase 1: Fix Small Issues (1-2 hours)

- Remove all `@HiveField` annotations from models (causes lint warnings)
- Test on physical device for camera/scanner
- Customize app colors/branding

### Phase 2: Complete Storage Layer (2-3 hours)

Convert Map storage to proper Hive type adapters:

```bash
# 1. Uncomment `part 'model_name.g.dart'` in each model file
# 2. Add back @HiveType and @HiveField annotations  
# 3. Run code generator:
dart run build_runner build --delete-conflicting-outputs
# 4. Update StorageService to use typed boxes
```

### Phase 3: Real Monetization (4-6 hours)

- Set up Google AdMob account → Get Ad Unit IDs
- Configure Google Play Console for IAP products
- Replace simulated purchase with real `in_app_purchase` package calls
- Test with Google Play test accounts

### Phase 4: Advanced Features (1-2 weeks)

- Cloud sync with Firebase
- TensorFlow Lite for photo food recognition
- Wearables integration (Apple Health / Google Fit)
- Recipe builder
- Social sharing

---

## 📦 Key Files to Understand

| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry, routing, theme |
| `lib/screens/dashboard_screen.dart` | Main home screen |
| `lib/services/storage_service.dart` | All database operations |
| `lib/services/calorie_calculator_service.dart` | BMR/TDEE math |
| `lib/services/premium_service.dart` | Freemium logic |
| `pubspec.yaml` | Dependencies list |

---

## 💡 Tips for Solo Development

### Development Workflow

1. **Hot Reload** (r) - Instant UI updates
2. **Hot Restart** (R) - Full app restart
3. **Debug Console** - Check errors
4. **Flutter DevTools** - Performance monitoring

### Time-Saving Practices

- Use `flutter run` in background, edit code, save (auto hot reload)
- Test on emulator first, then physical device
- Use `flutter pub outdated` to check for package updates
- Enable "Show Layout Bounds" in device settings to debug UI

### When Stuck

- Check `flutter doctor` for environment issues
- Read error message carefully (line number!)
- Search StackOverflow with exact error
- Use Claude/ChatGPT for specific code questions

---

## 🚀 Deploy to Production

### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release

# Find output:
# APK: build/app/outputs/flutter-apk/app-release.apk
# Bundle: build/app/outputs/bundle/release/app-release.aab
```

### iOS (requires Mac)

```bash
flutter build ios --release
# Then open Xcode and archive
```

---

## 📞 Support

- **Flutter Docs**: <https://docs.flutter.dev>
- **Hive Docs**: <https://docs.hivedb.dev>
- **fl_chart Examples**: <https://github.com/imaNNeo/fl_chart>

---

**You're all set! Run `flutter run` and start tracking! 🥗📊💪**
