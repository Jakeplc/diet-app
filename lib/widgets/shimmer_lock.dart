import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Animated shimmer lock icon (pulsing glow effect)
class ShimmerLock extends StatefulWidget {
  final double size;
  const ShimmerLock({super.key, this.size = 48});

  @override
  State<ShimmerLock> createState() => _ShimmerLockState();
}

class _ShimmerLockState extends State<ShimmerLock>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat();
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
            gradient: LinearGradient(
              colors: [
                cs.primary.withOpacity(0.8),
                cs.secondary.withOpacity(0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(widget.size / 3),
            boxShadow: [
              BoxShadow(
                blurRadius: 18,
                spreadRadius: 2,
                color: cs.primary.withOpacity(glow),
              ),
            ],
          ),
          child:
              Icon(Icons.lock, color: Colors.white, size: widget.size * 0.55),
        );
      },
    );
  }
}

/// Full overlay shimmer lock for widgets
class ShimmerOverlayLock extends StatefulWidget {
  final Widget child;
  final bool isLocked;
  final VoidCallback? onTap;
  final String label;

  const ShimmerOverlayLock({
    super.key,
    required this.child,
    this.isLocked = false,
    this.onTap,
    this.label = 'Premium',
  });

  @override
  State<ShimmerOverlayLock> createState() => _ShimmerOverlayLockState();
}

class _ShimmerOverlayLockState extends State<ShimmerOverlayLock>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    if (widget.isLocked) {
      _shimmerController = AnimationController(
        duration: const Duration(seconds: 2),
        vsync: this,
      )..repeat();
    }
  }

  @override
  void didUpdateWidget(ShimmerOverlayLock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLocked && !oldWidget.isLocked) {
      _shimmerController = AnimationController(
        duration: const Duration(seconds: 2),
        vsync: this,
      )..repeat();
    } else if (!widget.isLocked && oldWidget.isLocked) {
      _shimmerController.dispose();
    }
  }

  @override
  void dispose() {
    if (widget.isLocked) {
      _shimmerController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLocked) {
      return widget.child;
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        children: [
          // Dimmed child
          Opacity(
            opacity: 0.6,
            child: widget.child,
          ),
          // Shimmer overlay
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _shimmerController,
              builder: (context, _) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.0),
                        Colors.white.withOpacity(0.2),
                        Colors.white.withOpacity(0.0),
                      ],
                      stops: [
                        _shimmerController.value - 0.3,
                        _shimmerController.value,
                        _shimmerController.value + 0.3,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Lock icon center
          Positioned.fill(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 48,
                    color: Colors.white.withOpacity(0.95),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.label,
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
