import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? opacity;
  final double? radius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.opacity,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius ?? 20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor.withOpacity(opacity ?? 0.15),
            borderRadius: BorderRadius.circular(radius ?? 20),
            border: Border.all(color: Colors.white.withOpacity(0.18)),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
          ),
          child: child,
        ),
      ),
    );
  }
}
