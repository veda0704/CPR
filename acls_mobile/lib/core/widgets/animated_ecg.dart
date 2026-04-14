import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AnimatedECGBackground extends StatefulWidget {
  final Widget child;
  final bool animate;
  const AnimatedECGBackground({super.key, required this.child, this.animate = true});

  @override
  State<AnimatedECGBackground> createState() => _AnimatedECGBackgroundState();
}

class _AnimatedECGBackgroundState extends State<AnimatedECGBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    if (widget.animate) _controller.repeat();
  }

  @override
  void didUpdateWidget(AnimatedECGBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate != oldWidget.animate) {
      if (widget.animate) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _ECGPainter(progress: _controller.value),
              );
            },
          ),
        ),
        widget.child,
      ],
    );
  }
}

class _ECGPainter extends CustomPainter {
  final double progress;
  _ECGPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.orange.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final step = size.width / 100;

    path.moveTo(0, size.height * 0.7);

    for (double i = 0; i <= size.width; i += step) {
      double x = i;
      // Calculate a "moving" wave effect
      double normalizedX = (x / size.width + progress) % 1.0;
      double y = size.height * 0.7;

      // Simulate ECG Pulse (P-QRS-T complex)
      double waveX = normalizedX * 10; // 10 pulses across screen
      double localX = waveX % 1.0;

      if (localX > 0.1 && localX < 0.15) {
        // P-wave
        y -= 5 * math.sin((localX - 0.1) / 0.05 * math.pi);
      } else if (localX > 0.2 && localX < 0.22) {
        // Q-dip
        y += 5;
      } else if (localX > 0.22 && localX < 0.25) {
        // R-peak
        y -= 40 * math.sin((localX - 0.22) / 0.03 * math.pi);
      } else if (localX > 0.25 && localX < 0.28) {
        // S-dip
        y += 10 * math.sin((localX - 0.25) / 0.03 * math.pi);
      } else if (localX > 0.4 && localX < 0.55) {
        // T-wave
        y -= 10 * math.sin((localX - 0.4) / 0.15 * math.pi);
      }

      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);

    // Draw a second pulse lower down with offset
    final path2 = Path();
    path2.moveTo(0, size.height * 0.85);
    for (double i = 0; i <= size.width; i += step) {
      double x = i;
      double normalizedX = (x / size.width + progress + 0.3) % 1.0;
      double y = size.height * 0.85;
      double waveX = normalizedX * 8;
      double localX = waveX % 1.0;

      if (localX > 0.22 && localX < 0.25) {
        y -= 30 * math.sin((localX - 0.22) / 0.03 * math.pi);
      }
      path2.lineTo(x, y);
    }
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant _ECGPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
