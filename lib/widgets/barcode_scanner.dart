import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/subscription_state.dart';
import '../widgets/shimmer_lock.dart';
import '../widgets/premium_badge.dart';

/// Barcode Scanner + Online Database Feature
/// Premium-exclusive feature for scanning products and fetching real-time nutrition data
class BarcodeScanner extends StatelessWidget {
  final VoidCallback? onScan;
  final VoidCallback? onUnlock;

  const BarcodeScanner({
    super.key,
    this.onScan,
    this.onUnlock,
  });

  @override
  Widget build(BuildContext context) {
    final sub = context.watch<SubscriptionState>();
    final isLocked = !sub.canUseBarcode;
    final cs = Theme.of(context).colorScheme;

    return ShimmerOverlayLock(
      isLocked: isLocked,
      label: 'Premium Feature',
      onTap: isLocked ? onUnlock : null,
      child: GestureDetector(
        onTap: !isLocked ? onScan : null,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                cs.primary.withOpacity(0.15),
                cs.secondary.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: cs.primary.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [cs.primary, cs.secondary],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Barcode Scanner',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Instant online nutrition lookup',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: cs.onSurface.withOpacity(0.7),
                              ),
                        ),
                      ],
                    ),
                  ),
                  if (isLocked)
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: LockedCrownBadge(size: 28),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isLocked
                      ? '7-day trial available • Unlock for \$4.99/month'
                      : 'Scan any product barcode to fetch nutrition data',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Barcode Scanner Results Card (shown after scan)
class BarcodeResultCard extends StatelessWidget {
  final String productName;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final String servingSize;
  final List<String>? allergens;
  final String source;

  const BarcodeResultCard({
    super.key,
    required this.productName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.servingSize,
    this.allergens,
    this.source = 'Online Database',
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          productName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Per $servingSize',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: cs.onSurface.withOpacity(0.6),
                              ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.check_circle, color: Colors.green, size: 32),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _MacroDisplay(label: 'Cals', value: calories.toString()),
                    _MacroDisplay(label: 'Protein', value: '${protein.toStringAsFixed(1)}g'),
                    _MacroDisplay(label: 'Carbs', value: '${carbs.toStringAsFixed(1)}g'),
                    _MacroDisplay(label: 'Fat', value: '${fat.toStringAsFixed(1)}g'),
                  ],
                ),
              ),
              if (allergens != null && allergens!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Allergens',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: allergens!
                      .map((a) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: Colors.red.withOpacity(0.3)),
                            ),
                            child: Text(
                              a,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                'Source: $source',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: cs.onSurface.withOpacity(0.5),
                    ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Add to Log'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MacroDisplay extends StatelessWidget {
  final String label;
  final String value;

  const _MacroDisplay({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: cs.primary,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: cs.onSurface.withOpacity(0.7),
              ),
        ),
      ],
    );
  }
}
