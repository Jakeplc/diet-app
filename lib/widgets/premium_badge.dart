import 'package:flutter/material.dart';

class PremiumBadge extends StatelessWidget {
  final String label;
  const PremiumBadge({super.key, this.label = 'Premium'});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.primary.withOpacity(0.2),
            cs.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.primary.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 14, color: cs.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: cs.primary,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Crown-shaped premium indicator (for top corners)
class LockedCrownBadge extends StatelessWidget {
  final double size;

  const LockedCrownBadge({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [cs.primary, cs.secondary],
        ),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(Icons.star, color: Colors.white, size: size * 0.6),
    );
  }
}
