import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/subscription_state.dart';
import 'add_food_flow/select_meal_page.dart';
import 'barcode_scanner_page.dart';
import 'paywall/paywall_page.dart';

class LogFoodPage extends StatelessWidget {
  const LogFoodPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sub = context.watch<SubscriptionState>();
    final isBarcodeLocked = !sub.canUseBarcode;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Manual Food Entry
          Card(
            child: ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('Add food manually'),
              subtitle: const Text('Pick a meal → search → servings → add'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SelectMealPage()),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Barcode Scanner (Premium)
          Card(
            child: ListTile(
              leading: Icon(
                Icons.qr_code_2,
                color: isBarcodeLocked ? Colors.grey : cs.primary,
              ),
              title: const Text('Scan barcode'),
              subtitle: Text(
                isBarcodeLocked
                    ? 'Premium feature • 7-day trial available'
                    : 'Instant online nutrition lookup',
              ),
              trailing: isBarcodeLocked
                  ? Icon(Icons.lock, color: cs.primary)
                  : const Icon(Icons.chevron_right),
              onTap: () {
                if (isBarcodeLocked) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PaywallPage(source: 'barcode'),
                    ),
                  );
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const BarcodeScannerPage(),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
