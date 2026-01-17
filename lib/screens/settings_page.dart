import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/subscription_state.dart';
import 'paywall/paywall_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final sub = context.watch<SubscriptionState>();
    final cs = Theme.of(context).colorScheme;

    final trialBadge = sub.trialActive
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '${sub.trialDaysLeft} day${sub.trialDaysLeft == 1 ? '' : 's'} left',
              style: TextStyle(
                color: cs.onPrimaryContainer,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          )
        : null;

    String planLabel() {
      if (sub.isPro) return 'Pro';
      if (sub.isPremium) return 'Premium';
      if (sub.trialActive) return 'Trial';
      return 'Free';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.workspace_premium),
              title: const Text('Subscription', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('Current: ${planLabel()}'),
              trailing: trialBadge ?? const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PaywallPage(source: 'settings')),
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (!sub.trialActive && sub.hasTrialAvailable)
            Card(
              child: ListTile(
                leading: const Icon(Icons.timer),
                title: const Text('Start 7-day trial', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('Unlock GLP-1 tracker for 7 days'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  await context.read<SubscriptionState>().startTrialIfNeeded();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Trial started!')),
                    );
                  }
                },
              ),
            ),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: const Icon(Icons.restore),
              title: const Text('Restore purchases'),
              onTap: () => context.read<SubscriptionState>().restorePurchases(),
            ),
          ),
        ],
      ),
    );
  }
}
