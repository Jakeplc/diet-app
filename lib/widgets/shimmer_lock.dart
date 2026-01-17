import 'dart:math' as math;
import 'package:flutter/material.dart';

class ShimmerLock extends StatefulWidget {
  final double size;
  const ShimmerLock({super.key, this.size = 48});

  @override
  State<ShimmerLock> createState() => _ShimmerLockState();
}

class _ShimmerLockState extends State<ShimmerLock> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final t = _c.value;
        final glow = 0.35 + 0.35 * math.sin(t * math.pi * 2);
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: cs.primaryContainer.withOpacity(0.9),
            borderRadius: BorderRadius.circular(widget.size / 3),
            boxShadow: [
              BoxShadow(
                blurRadius: 18,
                spreadRadius: 1,
                color: cs.primary.withOpacity(glow),
              ),
            ],
          ),
          child: Icon(Icons.lock, color: cs.onPrimaryContainer, size: widget.size * 0.55),
        );
      },
    );
  }
}
