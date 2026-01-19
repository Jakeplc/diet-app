# 🔧 Troubleshooting Guide

## Quick Fixes for Common Issues

---

## 🚨 Build & Compilation Errors

### Error: "Target of URI doesn't exist"

**Cause**: Missing or incorrect import paths

**Fix**:

```bash
flutter clean
flutter pub get
flutter run
```

---

### Error: "Cannot find Adapter / Type is not a subtype"

**Cause**: Hive type adapters not registered

**Current Status**: App uses Map-based storage (no adapters needed for MVP)

**If you want typed storage later**:

```bash
# Uncomment `part 'model.g.dart'` lines in model files
# Add back @HiveType and @HiveField annotations
dart run build_runner build --delete-conflicting-outputs
```

---

### Error: "CocoaPods not installed" (iOS/Mac only)

**Fix**:

```bash
sudo gem install cocoapods
cd ios
pod install
cd ..
flutter run
```

---

### Error: "Gradle build failed" (Android)

**Fix**:

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

---

## 📱 Runtime Errors

### Error: "setState() called after dispose()"

**Cause**: Trying to update UI after screen is closed

**Already Fixed**: All screens use `if (mounted)` checks before setState

---

### Error: "Null check operator used on null value"

**Cause**: Trying to access property of null object

**Common Culprit**: UserProfile not loaded

**Fix**: Check data loads in initState:

```dart
@override
void initState() {
  super.initState();
  _loadData();
}

Future<void> _loadData() async {
  final profile = StorageService.getUserProfile();
  if (profile == null) {
    // Handle missing profile
    return;
  }
  setState(() => _profile = profile);
}
```

---

### Error: "HiveError: Box has already been closed"

**Cause**: Trying to access closed Hive box

**Fix**: Ensure StorageService.init() called in main():

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  runApp(const DietApp());
}
```

---

## 🎨 UI Issues

### Issue: "UI not updating after data change"

**Fix 1**: Call setState:

```dart
setState(() {
  // Update data here
});
```

**Fix 2**: Use ValueNotifier/ChangeNotifier for reactive updates

**Fix 3**: Hot restart (press `R` in terminal)

---

### Issue: "Keyboard covers text field"

**Fix**: Wrap in SingleChildScrollView:

```dart
SingleChildScrollView(
  child: Column(
    children: [
      TextField(...),
    ],
  ),
)
```

Or use `Padding` with `MediaQuery.of(context).viewInsets.bottom`

---

### Issue: "Overflow by X pixels"

**Cause**: Content doesn't fit in available space

**Fix**: Wrap in Expanded/Flexible or add ListView:

```dart
// Before
Column(
  children: [
    Container(height: 1000), // Too tall!
  ],
)

// After
Column(
  children: [
    Expanded(
      child: ListView(...), // Scrollable
    ),
  ],
)
```

---

## 📷 Camera & Scanner Issues

### Issue: "Camera permission denied"

**Android Fix**:
Check `android/app/src/main/AndroidManifest.xml` has:

```xml
<uses-permission android:name="android.permission.CAMERA"/>
```

**iOS Fix**:
Add to `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>We need camera to scan barcodes</string>
```

Then:

```bash
flutter clean
flutter run
```

---

### Issue: "Barcode scanner shows black screen"

**Fix 1**: Grant camera permission in device settings

**Fix 2**: Test on physical device (emulator camera may not work)

**Fix 3**: Check if `mobile_scanner` package is latest version

---

## 🔔 Notification Issues

### Issue: "Notifications not showing"

**Fix 1**: Grant notification permission:

- Android: Settings → Apps → Diet Tracker → Notifications → Allow

**Fix 2**: Check if reminders enabled in app Settings

**Fix 3**: Ensure notification scheduled in future (not past time)

**Fix 4**: Test on physical device (emulator notifications unreliable)

---

## 💳 Monetization Issues

### Issue: "In-app purchase fails"

**Current Status**: IAP is simulated for MVP

**For Real IAP Later**:

1. Set up products in Google Play Console
2. Add test account
3. Configure product IDs in app
4. Use actual `in_app_purchase` package methods
5. Test with real payment

---

### Issue: "Ads not showing"

**Current Status**: Placeholder ad banner shown

**For Real Ads Later**:

1. Create Google AdMob account
2. Get Ad Unit IDs
3. Update `ad_banner_widget.dart` with real IDs
4. Initialize MobileAds in main()
5. Test with test ad IDs first

---

## 💾 Data Persistence Issues

### Issue: "Data disappears after app restart"

**Cause 1**: Not calling `await` on save operations

**Fix**:

```dart
// Wrong
StorageService.saveFoodLog(log);

// Correct
await StorageService.saveFoodLog(log);
```

**Cause 2**: Hive box not initialized

**Fix**: Ensure `StorageService.init()` completes before using boxes

---

### Issue: "Can't clear data / reset app"

**Fix Option 1**: Use in-app clear:

- Settings → Danger Zone → Clear All Data

**Fix Option 2**: Manually clear:

```bash
# Android
flutter clean
adb uninstall com.dietapp.letswin.diet_app

# iOS
flutter clean
# Delete app from simulator/device
```

---

## 🌐 Network & Sync Issues

### Issue: "App requires internet"

**This app is offline-first!** Should work without internet after first install.

**If facing issues**:

1. Check if external packages require network (they shouldn't)
2. Ensure all data uses Hive, not API calls
3. Test in airplane mode

---

## 🐛 Debugging Tips

### Enable Debug Logging

Add to main():

```dart
void main() async {
  // Enable debug logging
  debugPrint('App starting...');
  
  // Rest of main()...
}
```

Use throughout app:

```dart
debugPrint('User profile: ${profile.name}');
debugPrint('Calories consumed: $caloriesConsumed');
```

---

### Use Flutter DevTools

```bash
# While app is running
flutter pub global activate devtools
flutter pub global run devtools
```

Opens browser with:

- Widget inspector
- Performance profiler
- Network monitor
- Logging console

---

### Check Flutter Doctor

```bash
flutter doctor -v
```

Shows:

- ✓ Flutter SDK installed
- ✓ Android toolchain ready
- ✓ Connected devices
- ✗ Any missing components

---

## 📱 Device-Specific Issues

### Android Emulator Slow

**Fix**:

1. Increase emulator RAM (AVD Manager → Edit → Advanced)
2. Enable hardware acceleration (Intel HAXM / AMD Hypervisor)
3. Use ARM emulator on Apple Silicon Macs

---

### iOS Simulator Black Screen

**Fix**:

```bash
xcrun simctl erase all
flutter clean
flutter run
```

---

### Physical Device Not Detected

**Android**:

1. Enable Developer Options (tap Build Number 7 times)
2. Enable USB Debugging
3. Check `flutter devices` shows device

**iOS**:

1. Trust computer on device
2. Check Xcode can see device
3. Pair device wirelessly if needed

---

## 🚀 Performance Issues

### App Slow / Laggy

**Fix 1**: Use `const` constructors:

```dart
// Before
Text('Hello')

// After
const Text('Hello')
```

**Fix 2**: Avoid rebuilding entire trees:

```dart
// Use StatefulWidget with setState for specific widgets
// Or use ValueNotifier/Provider for state management
```

**Fix 3**: Profile and optimize:

```bash
flutter run --profile
# Check DevTools Performance tab
```

---

### App Size Too Large

**Check size**:

```bash
flutter build apk --analyze-size
```

**Reduce size**:

- Remove unused packages
- Use `--split-per-abi` for Android
- Enable obfuscation: `flutter build apk --obfuscate --split-debug-info=./symbols`

---

## 🔄 Still Stuck?

### Nuclear Option (Fixes 90% of issues)

```bash
# 1. Clean everything
flutter clean
rm -rf ios/Pods ios/Podfile.lock
cd android && ./gradlew clean && cd ..

# 2. Reinstall dependencies
flutter pub get

# 3. Delete app from device
# (Uninstall manually or via adb)

# 4. Fresh install
flutter run
```

---

### Get Help

1. **Check the error message carefully** - Line number tells you where!
2. **Search StackOverflow** - Copy exact error text
3. **Flutter Discord** - <https://discord.gg/flutter>
4. **GitHub Issues** - Check package repositories
5. **Flutter Docs** - <https://docs.flutter.dev>

---

### Quick Reference Commands

```bash
# Basic
flutter run                    # Run app
flutter clean                  # Clean build
flutter pub get                # Get packages

# Devices
flutter devices                # List devices
flutter emulators              # List emulators
flutter emulators --launch <id>  # Launch emulator

# Building
flutter build apk              # Build Android
flutter build appbundle        # Build for Play Store
flutter build ios              # Build iOS (Mac only)

# Testing
flutter test                   # Run tests
flutter analyze                # Static analysis
flutter doctor                 # Check setup

# Updates
flutter upgrade                # Update Flutter
flutter pub outdated           # Check outdated packages
flutter pub upgrade            # Update packages
```

---

**Remember**: Most issues are fixed with `flutter clean && flutter pub get` 🎯
