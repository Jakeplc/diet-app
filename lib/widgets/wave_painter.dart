import 'package:flutter/material.dart';
import 'dart:math' as math;

class WavePainter extends CustomPainter {
  final double waveHeight;
  final double waveFrequency;
  final double wavePhase;
  final Color waveColor;

  WavePainter({
    required this.waveHeight,
    required this.waveFrequency,
    required this.wavePhase,
    required this.waveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = waveColor
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);

    // Create wave using sine function
    for (double x = 0; x <= size.width; x++) {
      final y = waveHeight *
              math.sin(
                  (x / size.width) * waveFrequency * 2 * math.pi + wavePhase) +
          (size.height * 0.5);
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return oldDelegate.wavePhase != wavePhase ||
        oldDelegate.waveHeight != waveHeight ||
        oldDelegate.waveFrequency != waveFrequency;
  }
}

class WaveLiquidContainer extends StatefulWidget {
  final double fillPercentage; // 0.0 to 1.0
  final int goal;
  final int current;
  final Color gradientColorStart;
  final Color gradientColorEnd;

  const WaveLiquidContainer({
    super.key,
    required this.fillPercentage,
    required this.goal,
    required this.current,
    this.gradientColorStart = const Color(0xFF0EA5E9),
    this.gradientColorEnd = const Color(0xFF0284C7),
  });

  @override
  State<WaveLiquidContainer> createState() => _WaveLiquidContainerState();
}

class _WaveLiquidContainerState extends State<WaveLiquidContainer>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _fillController;
  late Animation<double> _fillAnimation;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _fillController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fillAnimation =
        Tween<double>(begin: 0, end: widget.fillPercentage).animate(
      CurvedAnimation(parent: _fillController, curve: Curves.easeOutCubic),
    );

    _fillController.forward();
  }

  @override
  void didUpdateWidget(WaveLiquidContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fillPercentage != widget.fillPercentage) {
      _fillAnimation =
          Tween<double>(begin: _fillAnimation.value, end: widget.fillPercentage)
              .animate(
        CurvedAnimation(parent: _fillController, curve: Curves.easeOutCubic),
      );
      _fillController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _fillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(
              color: widget.gradientColorStart.withOpacity(0.4), width: 2),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background
            Container(
              color: Colors.grey.shade100,
            ),
            // Animated wave liquid
            AnimatedBuilder(
              animation: _waveController,
              builder: (context, child) {
                return ClipPath(
                  clipper: _WaveClipper(
                    fillPercentage: _fillAnimation.value,
                    wavePhase: _waveController.value * 2 * math.pi,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          widget.gradientColorStart,
                          widget.gradientColorEnd
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            // Text overlay
            Positioned(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${widget.current}/${widget.goal}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'cups',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  final double fillPercentage;
  final double wavePhase;

  _WaveClipper({required this.fillPercentage, required this.wavePhase});

  @override
  Path getClip(Size size) {
    final path = Path();
    final fillHeight = size.height * (1 - fillPercentage);

    // Wave parameters
    const waveCount = 2;
    const waveAmplitude = 8.0;

    path.moveTo(0, fillHeight);

    // Draw wave
    for (double x = 0; x <= size.width; x += 1) {
      final waveY = waveAmplitude *
          math.sin((x / size.width) * waveCount * 2 * math.pi + wavePhase);
      path.lineTo(x, fillHeight + waveY);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(_WaveClipper oldClipper) {
    return oldClipper.fillPercentage != fillPercentage ||
        oldClipper.wavePhase != wavePhase;
  }
}
