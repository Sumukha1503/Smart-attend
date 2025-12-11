import 'dart:ui';
import 'package:flutter/material.dart';
import '../config/futuristic_theme.dart';

/// Core Glass Container - Glassmorphism 2.0
/// The primary building block for all futuristic UI elements
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double opacity;
  final double blurStrength;
  final Color? borderColor;
  final double borderWidth;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final List<Color>? gradientColors;
  final bool showNoise;
  final VoidCallback? onTap;

  const GlassContainer({
    super.key,
    required this.child,
    this.opacity = 0.1,
    this.blurStrength = 10.0,
    this.borderColor,
    this.borderWidth = 1.0,
    this.borderRadius,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.gradientColors,
    this.showNoise = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(20);

    Widget glassWidget = ClipRRect(
      borderRadius: effectiveBorderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: blurStrength,
          sigmaY: blurStrength,
        ),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            gradient: gradientColors != null
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradientColors!,
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(opacity),
                      Colors.white.withOpacity(opacity * 0.5),
                    ],
                  ),
            borderRadius: effectiveBorderRadius,
            border: Border.all(
              color: borderColor ?? FuturisticTheme.glassBorder,
              width: borderWidth,
            ),
          ),
          child: Stack(
            children: [
              // Noise texture overlay
              if (showNoise)
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.03,
                    child: CustomPaint(
                      painter: NoisePainter(),
                    ),
                  ),
                ),
              // Content
              child,
            ],
          ),
        ),
      ),
    );

    if (margin != null) {
      glassWidget = Padding(
        padding: margin!,
        child: glassWidget,
      );
    }

    if (onTap != null) {
      glassWidget = GestureDetector(
        onTap: onTap,
        child: glassWidget,
      );
    }

    return glassWidget;
  }
}

/// Neon Glow Glass Container
class NeonGlowContainer extends StatelessWidget {
  final Widget child;
  final Color glowColor;
  final double glowIntensity;
  final double blurStrength;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const NeonGlowContainer({
    super.key,
    required this.child,
    required this.glowColor,
    this.glowIntensity = 0.3,
    this.blurStrength = 10.0,
    this.borderRadius,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(20);

    Widget glowWidget = ClipRRect(
      borderRadius: effectiveBorderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: blurStrength,
          sigmaY: blurStrength,
        ),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.05),
                Colors.white.withOpacity(0.02),
              ],
            ),
            borderRadius: effectiveBorderRadius,
            border: Border.all(
              color: glowColor.withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: glowColor.withOpacity(glowIntensity),
                blurRadius: 30,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: glowColor.withOpacity(glowIntensity * 0.5),
                blurRadius: 60,
                spreadRadius: 5,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    if (margin != null) {
      glowWidget = Padding(
        padding: margin!,
        child: glowWidget,
      );
    }

    if (onTap != null) {
      glowWidget = GestureDetector(
        onTap: onTap,
        child: glowWidget,
      );
    }

    return glowWidget;
  }
}

/// Pulsing Wrapper for Critical Alerts
class PulsingWrapper extends StatefulWidget {
  final Widget child;
  final Color pulseColor;
  final Duration duration;

  const PulsingWrapper({
    super.key,
    required this.child,
    required this.pulseColor,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<PulsingWrapper> createState() => _PulsingWrapperState();
}

class _PulsingWrapperState extends State<PulsingWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.pulseColor.withOpacity(_animation.value),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: widget.child,
        );
      },
      child: widget.child,
    );
  }
}

/// Floating Action Bubble
class FloatingBubble extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Gradient gradient;

  const FloatingBubble({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: FuturisticTheme.neonCyan.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: FuturisticTheme.bodyTechBold.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Noise Texture Painter
class NoisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final random = DateTime.now().millisecondsSinceEpoch;
    for (int i = 0; i < 1000; i++) {
      final x = (random * i * 7) % size.width;
      final y = (random * i * 13) % size.height;
      canvas.drawCircle(Offset(x, y), 0.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Glowing Dot Indicator
class GlowingDot extends StatelessWidget {
  final Color color;
  final double size;
  final bool isPulsing;

  const GlowingDot({
    super.key,
    required this.color,
    this.size = 12,
    this.isPulsing = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget dot = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.6),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
    );

    if (isPulsing) {
      return PulsingWrapper(
        pulseColor: color,
        duration: const Duration(milliseconds: 1500),
        child: dot,
      );
    }

    return dot;
  }
}
