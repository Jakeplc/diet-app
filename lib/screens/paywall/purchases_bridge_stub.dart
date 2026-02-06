// Web stub for purchases_flutter to allow web builds without RevenueCat support.
class Offerings {
  const Offerings();
  dynamic get current => null;
}

class CustomerInfo {
  const CustomerInfo();
  _Entitlements get entitlements => const _Entitlements();
}

class _Entitlements {
  const _Entitlements();
  Map<String, _Entitlement> get all => const {};
  Map<String, _Entitlement> get active => const {};
}

class _Entitlement {
  const _Entitlement();
  bool get isActive => false;
}

class Package {
  const Package();
  PackageType get packageType => PackageType.unknown;
  _StoreProduct get storeProduct => const _StoreProduct();
}

class _StoreProduct {
  const _StoreProduct();
  String get priceString => '';
  String get title => '';
}

enum PackageType { monthly, annual, lifetime, unknown }

class Purchases {
  static Future<CustomerInfo> getCustomerInfo() async => const CustomerInfo();
  static Future<Offerings> getOfferings() async => const Offerings();
  static Future<CustomerInfo> purchasePackage(Package package) async => const CustomerInfo();
  static Future<CustomerInfo> restorePurchases() async => const CustomerInfo();
}
