import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

enum Plan { premiumMonthly, premiumYearly, proMonthly, proYearly }

class SubscriptionState extends ChangeNotifier {
  static const _boxName = 'sub';
  static const _kTier = 'tier'; // free, premium, pro
  static const _kTrialStart = 'trialStartMs'; // msSinceEpoch
  static const _kSelectedPlan = 'selectedPlan'; // string name

  late final Box _box;

  bool isBusy = false;

  String get tier => _box.get(_kTier, defaultValue: 'free') as String;
  bool get isPremium => tier == 'premium';
  bool get isPro => tier == 'pro';

  Plan get selectedPlan {
    final s = _box.get(_kSelectedPlan, defaultValue: Plan.premiumMonthly.name)
        as String;
    return Plan.values
        .firstWhere((p) => p.name == s, orElse: () => Plan.premiumMonthly);
  }

  bool get hasTrialAvailable => _box.get(_kTrialStart) == null;

  DateTime? get trialStart {
    final v = _box.get(_kTrialStart);
    if (v == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(v as int);
  }

  int get trialDaysLeft {
    final ts = trialStart;
    if (ts == null) return 0;
    final elapsed = DateTime.now().difference(ts).inDays;
    final left = 7 - elapsed;
    return left.clamp(0, 7);
  }

  bool get trialActive => trialStart != null && trialDaysLeft > 0;

  /// GLP-1 gating: allowed if Premium/Pro OR trialActive
  bool get canUseGlp1 => isPremium || isPro || trialActive;

  /// Barcode Scanner + Online Database gating: allowed if Premium/Pro OR trialActive
  bool get canUseBarcode => isPremium || isPro || trialActive;

  static Future<SubscriptionState> init() async {
    final s = SubscriptionState._();
    s._box = await Hive.openBox(_boxName);
    return s;
  }

  SubscriptionState._();

  void selectPlan(Plan plan) {
    _box.put(_kSelectedPlan, plan.name);
    notifyListeners();
  }

  Future<void> startTrialIfNeeded() async {
    if (!hasTrialAvailable) return;
    await _box.put(_kTrialStart, DateTime.now().millisecondsSinceEpoch);
    notifyListeners();
  }

  Future<void> purchaseSelectedPlan() async {
    // TODO: Replace with RevenueCat / in_app_purchase
    isBusy = true;
    notifyListeners();

    await startTrialIfNeeded();
    await Future.delayed(const Duration(milliseconds: 650));

    final p = selectedPlan;
    if (p == Plan.premiumMonthly || p == Plan.premiumYearly) {
      await _box.put(_kTier, 'premium');
    } else {
      await _box.put(_kTier, 'pro');
    }

    isBusy = false;
    notifyListeners();
  }

  Future<void> restorePurchases() async {
    // TODO: Replace with real restore logic
    isBusy = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    isBusy = false;
    notifyListeners();
  }

  Future<void> setFree() async {
    await _box.put(_kTier, 'free');
    notifyListeners();
  }
}
