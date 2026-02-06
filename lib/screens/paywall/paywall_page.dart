import 'package:flutter/material.dart';
import 'purchases_bridge.dart'
  if (dart.library.html) 'purchases_bridge_stub.dart';

class PaywallPage extends StatefulWidget {
  final String source; // e.g., "glp1", "barcode", "settings"
  const PaywallPage({super.key, required this.source});

  @override
  State<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends State<PaywallPage> {
  bool _loading = true;
  String? _error;
  Offerings? _offerings;
  CustomerInfo? _customerInfo;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      _customerInfo = await Purchases.getCustomerInfo();
      _offerings = await Purchases.getOfferings();
      if (_offerings?.current == null) {
        _error = 'No plans available right now.';
      }
    } catch (e) {
      _error = e.toString();
    }

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _buy(Package package) async {
    try {
      // TODO: Implement purchases_flutter integration
      // final info = await Purchases.purchasePackage(package);
      // _customerInfo = info;

      if (!mounted) return;
      // final unlocked = info.entitlements.all['premium']?.isActive == true ||
      //     info.entitlements.active.isNotEmpty;

      // if (unlocked) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Premium unlocked!')),
        );
        Navigator.pop(context);
      // } else {
      //   ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(
        //       content: Text('Purchase completed, but no entitlement is active.'),
        //     ),
        //   );
      // }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    }
  }

  Future<void> _restore() async {
    try {
      final info = await Purchases.restorePurchases();
      _customerInfo = info;

      if (!mounted) return;
      if (info.entitlements.all['premium']?.isActive ?? false) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Restored!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nothing to restore')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Restore failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Go Premium')),
        body: Center(child: Text('Error: $_error')),
      );
    }

    final current = _offerings?.current;
    final packages = current?.availablePackages ?? <Package>[];
    if (current == null || packages.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Go Premium')),
        body: const Center(child: Text('No plans found')),
      );
    }

    final heroCopy = _heroCopy(widget.source);

    return Scaffold(
      appBar: AppBar(title: const Text('Go Premium')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.lock_open, size: 80, color: Colors.deepOrange),
            const SizedBox(height: 16),
            Text('Unlock Premium',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              heroCopy,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Plans from RevenueCat offerings
            ...packages.map(
              (pkg) => Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  title: Text(_packageLabel(pkg)),
                  subtitle: Text(pkg.storeProduct.priceString),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () => _buy(pkg),
                ),
              ),
            ),

            const Spacer(),
            TextButton(
                onPressed: _restore, child: const Text('Restore Purchases')),
            const SizedBox(height: 16),
            const Text(
              '7-day free trial (if configured in your store product). '
              'Auto-renews unless canceled 24h before end. Manage in store settings.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  String _packageLabel(Package pkg) {
    switch (pkg.packageType) {
      case PackageType.monthly:
        return 'Monthly';
      case PackageType.annual:
        return 'Yearly (save more)';
      case PackageType.lifetime:
        return 'Lifetime';
      default:
        return pkg.storeProduct.title.isNotEmpty
            ? pkg.storeProduct.title
            : 'Plan';
    }
  }

  String _heroCopy(String source) {
    switch (source) {
      case 'glp1':
        return 'Track injections, dose schedules, side effects, and notes in one place.';
      case 'barcode':
        return 'Scan barcodes for instant nutrition lookup with online database access.';
      default:
        return 'Unlock the barcode scanner, GLP-1 tracker, and more premium tools.';
    }
  }
}
