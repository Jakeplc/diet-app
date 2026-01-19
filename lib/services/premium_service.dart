import 'package:shared_preferences/shared_preferences.dart';

class PremiumService {
  static const String _premiumKey = 'is_premium';
  static const String _premiumExpiryKey = 'premium_expiry';

  // In a real app, you'd use in_app_purchase package
  // This is simplified for MVP demonstration

  // Check if user has premium subscription
  static Future<bool> isPremium() async {
    final prefs = await SharedPreferences.getInstance();
    final isPremium = prefs.getBool(_premiumKey) ?? false;

    if (isPremium) {
      // Check if subscription is still valid
      final expiryTimestamp = prefs.getInt(_premiumExpiryKey);
      if (expiryTimestamp != null) {
        final expiry = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
        if (DateTime.now().isAfter(expiry)) {
          // Subscription expired
          await setPremiumStatus(false);
          return false;
        }
      }
    }

    return isPremium;
  }

  // Set premium status (normally called after successful purchase)
  static Future<void> setPremiumStatus(
    bool isPremium, {
    DateTime? expiryDate,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, isPremium);

    if (isPremium && expiryDate != null) {
      await prefs.setInt(_premiumExpiryKey, expiryDate.millisecondsSinceEpoch);
    }
  }

  // Simulate purchase (for testing only - replace with real IAP)
  static Future<bool> purchasePremium(String productId) async {
    // In real implementation:
    // 1. Use in_app_purchase package
    // 2. Connect to Google Play/App Store
    // 3. Process payment
    // 4. Verify receipt on backend

    // For MVP testing: Set 30-day trial
    final expiryDate = DateTime.now().add(const Duration(days: 30));
    await setPremiumStatus(true, expiryDate: expiryDate);
    return true;
  }

  // Restore purchases (from app stores)
  static Future<bool> restorePurchases() async {
    // In real implementation:
    // Check with Google Play/App Store for existing purchases
    // Update local premium status

    // For MVP: Check existing status
    return await isPremium();
  }

  // Get premium benefits list
  static List<String> getPremiumBenefits() {
    return [
      '🚫 Remove all ads',
      '📊 Advanced analytics & detailed reports',
      '🔬 Track micronutrients (vitamins & minerals)',
      '🤖 AI-powered meal suggestions',
      '📸 Unlimited food photo recognition',
      '☁️ Cloud sync across devices',
      '🍽️ Unlimited custom recipes',
      '📈 Export data to CSV/PDF',
      '⏰ Smart reminders & coaching tips',
      '💪 Workout & activity tracking',
      '👥 Share meal plans with friends',
      '🎯 Custom macro ratio targets',
    ];
  }

  // Feature gates - check before showing premium features
  static Future<bool> canUseFeature(String featureName) async {
    final isPremiumUser = await isPremium();

    final premiumFeatures = [
      'advanced_analytics',
      'micronutrient_tracking',
      'ai_suggestions',
      'unlimited_photo_recognition',
      'cloud_sync',
      'unlimited_recipes',
      'data_export',
      'smart_coaching',
      'workout_tracking',
      'meal_sharing',
      'custom_macro_ratios',
    ];

    if (premiumFeatures.contains(featureName)) {
      return isPremiumUser;
    }

    // Free features - always available
    return true;
  }

  // Ad display logic
  static Future<bool> shouldShowAds() async {
    return !(await isPremium());
  }
}
