import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/subscription_state.dart';
import '../../widgets/premium_badge.dart';
import '../../widgets/shimmer_lock.dart';

class PaywallPage extends StatelessWidget {
  final String source; // e.g. "glp1"
  const PaywallPage({super.key, required this.source});

  @override
  Widget build(BuildContext context) {
    final sub = context.watch<SubscriptionState>();
    final cs = Theme.of(context).colorScheme;

    final title =
        source == 'glp1' ? 'GLP-1 Tracker is Premium' : 'Unlock Premium';
    final heroLine = source == 'glp1'
        ? 'Track injections, dose schedule, side effects, and notes — in one place.'
        : 'Save time, see trends, and stay consistent.';

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
                const Spacer(),
                if (sub.isPremium || sub.isPro)
                  const PremiumBadge(label: 'Active'),
              ],
            ),
            const SizedBox(height: 6),
            Card(
              color: cs.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const ShimmerLock(size: 56),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 6),
                          Text(heroLine,
                              style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _pill(context, '7-day free trial'),
                              _pill(context, 'Cancel anytime'),
                              _pill(context, 'No ads'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Choose your plan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            _PlanCard(
              title: 'Premium',
              subtitle: 'GLP-1 tracker + label scan + unlimited history',
              priceTop: '\$9.99',
              priceBottom: 'per month',
              tag: 'Most popular',
              selected: sub.selectedPlan == Plan.premiumMonthly,
              onTap: () => sub.selectPlan(Plan.premiumMonthly),
            ),
            _PlanCard(
              title: 'Premium (Yearly)',
              subtitle: 'Best value (save ~33%)',
              priceTop: '\$79.99',
              priceBottom: 'per year',
              tag: 'Best value',
              selected: sub.selectedPlan == Plan.premiumYearly,
              onTap: () => sub.selectPlan(Plan.premiumYearly),
            ),
            _PlanCard(
              title: 'Pro',
              subtitle:
                  'Meal templates + smart macro adjustments + AI insights',
              priceTop: '\$19.99',
              priceBottom: 'per month',
              tag: 'Power users',
              selected: sub.selectedPlan == Plan.proMonthly,
              onTap: () => sub.selectPlan(Plan.proMonthly),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: sub.isBusy
                  ? null
                  : () async {
                      await sub.purchaseSelectedPlan();
                      if (context.mounted) Navigator.pop(context);
                    },
              child: Text(sub.hasTrialAvailable
                  ? 'Start 7-day free trial'
                  : 'Continue'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: sub.isBusy ? null : () async => sub.restorePurchases(),
              child: const Text('Restore purchases'),
            ),
            const SizedBox(height: 12),
            Text(
              'Trial converts to a paid subscription unless canceled at least 24 hours before the end of the trial. '
              'Subscriptions renew automatically. Manage or cancel in your App Store / Play Store settings.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(BuildContext context, String text) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: cs.onPrimaryContainer,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String priceTop;
  final String priceBottom;
  final String tag;
  final bool selected;
  final VoidCallback onTap;

  const _PlanCard({
    required this.title,
    required this.subtitle,
    required this.priceTop,
    required this.priceBottom,
    required this.tag,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Radio<bool>(
                  value: true, groupValue: selected, onChanged: (_) => onTap()),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(title,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w800)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: cs.secondaryContainer,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              color: cs.onSecondaryContainer,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(subtitle,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(priceTop,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w900)),
                  Text(priceBottom,
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
