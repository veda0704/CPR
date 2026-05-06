import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'dart:math' as math;

class LoadingSpinner extends StatefulWidget {
  final bool fullScreen;
  final String message;
  final double size;
  final bool showSpinner;

  const LoadingSpinner({
    super.key,
    this.fullScreen = false,
    this.message = '',
    this.size = 140, // Increased default size for Elite design
    this.showSpinner = true,
  });

  const LoadingSpinner.fullScreen({
    super.key,
    this.message = 'Initializing Scenario...',
    this.size = 140,
    this.showSpinner = true,
  }) : fullScreen = true;

  const LoadingSpinner.compact({
    super.key,
    this.message = '',
    this.size = 28, // Scaled for inline button use
    this.showSpinner = true,
  }) : fullScreen = false;

  @override
  State<LoadingSpinner> createState() => _LoadingSpinnerState();
}

class _LoadingSpinnerState extends State<LoadingSpinner>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _reverseRotationController;
  late AnimationController _pulseController;
  late AnimationController _dotController;

  @override
  void initState() {
    super.initState();
    
    // Outer Ring Rotation (2s)
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Inner Ring Reverse Rotation (2.5s)
    _reverseRotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: false); // Reverse is handled by the animation itself

    // Center Pulse (1.6s)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    // Dots Flow (1.4s)
    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _reverseRotationController.dispose();
    _pulseController.dispose();
    _dotController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final spinner = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showSpinner)
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer Ring
                RotationTransition(
                  turns: _rotationController,
                  child: CustomPaint(
                    size: Size(widget.size, widget.size),
                    painter: _RingPainter(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.35),
                      secondaryColor: Theme.of(context).primaryColor.withValues(alpha: 0.18),
                    ),
                  ),
                ),
                // Inner Ring (72% size)
                RotationTransition(
                  turns: Tween(begin: 1.0, end: 0.0).animate(_reverseRotationController),
                  child: CustomPaint(
                    size: Size(widget.size * 0.72, widget.size * 0.72),
                    painter: _RingPainter(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.35),
                      secondaryColor: Theme.of(context).primaryColor.withValues(alpha: 0.18),
                    ),
                  ),
                ),
                // Center Hub
                ScaleTransition(
                  scale: Tween(begin: 1.0, end: 1.12).animate(
                    CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
                  ),
                  child: Container(
                    width: widget.size * 0.52,
                    height: widget.size * 0.52,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF111827) : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.12),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.favorite_rounded, // Heart Pulse equivalent
                        color: Theme.of(context).primaryColor,
                        size: widget.size * 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (widget.message.isNotEmpty) ...[
          const SizedBox(height: 28),
          Text(
            widget.message,
            style: TextStyle(
              fontSize: widget.fullScreen ? 22 : 16,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 12),
          _LoadingDots(controller: _dotController),
        ],
      ],
    );

    if (widget.fullScreen) {
      return Scaffold(
        backgroundColor: isDark 
          ? const Color(0xFF020617) 
          : AppColors.bg,
        body: Container(
          decoration: isDark ? null : const BoxDecoration(gradient: AppColors.bgGradient),
          child: Center(child: spinner),
        ),
      );
    }

    return spinner;
  }
}

class _RingPainter extends CustomPainter {
  final Color color;
  final Color secondaryColor;

  _RingPainter({required this.color, required this.secondaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Main Arc
    paint.color = color;
    canvas.drawArc(rect, -math.pi / 2, math.pi / 2, false, paint);

    // Secondary Arc
    paint.color = secondaryColor;
    canvas.drawArc(rect, 0, math.pi / 4, false, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _LoadingDots extends StatelessWidget {
  final AnimationController controller;

  const _LoadingDots({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            final double delay = index * 0.2;
            final double value = (controller.value - delay).clamp(0.0, 1.0);
            final double opacity = math.sin(value * math.pi).clamp(0.25, 1.0);
            final double scale = 0.85 + (0.25 * math.sin(value * math.pi)).clamp(0.0, 0.25);

            return Transform.scale(
              scale: scale,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: opacity),
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
