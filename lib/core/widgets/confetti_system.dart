import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Confetti Particle System
/// Creates an explosion of colorful particles
class ConfettiExplosion extends StatefulWidget {
  final Widget child;
  final bool isExploding;
  final VoidCallback? onComplete;
  final int particleCount;
  final Duration duration;

  const ConfettiExplosion({
    super.key,
    required this.child,
    this.isExploding = false,
    this.onComplete,
    this.particleCount = 100,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<ConfettiExplosion> createState() => _ConfettiExplosionState();
}

class _ConfettiExplosionState extends State<ConfettiExplosion>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    _initParticles();
  }

  void _initParticles() {
    final random = math.Random();
    _particles = List.generate(widget.particleCount, (index) {
      return ConfettiParticle(
        color: _randomColor(random),
        angle: random.nextDouble() * 2 * math.pi,
        velocity: 200 + random.nextDouble() * 300,
        size: 4 + random.nextDouble() * 8,
        rotation: random.nextDouble() * 2 * math.pi,
        rotationSpeed: (random.nextDouble() - 0.5) * 4,
      );
    });
  }

  Color _randomColor(math.Random random) {
    final colors = [
      const Color(0xFF00F0FF), // Cyan
      const Color(0xFFFF00FF), // Magenta
      const Color(0xFF9D00FF), // Purple
      const Color(0xFF39FF14), // Green
      const Color(0xFFFF5F1F), // Orange
      const Color(0xFFFFD700), // Gold
    ];
    return colors[random.nextInt(colors.length)];
  }

  @override
  void didUpdateWidget(ConfettiExplosion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExploding && !oldWidget.isExploding) {
      _initParticles();
      _controller.forward(from: 0);
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
        widget.child,
        if (widget.isExploding)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: ConfettiPainter(
                    particles: _particles,
                    progress: _controller.value,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class ConfettiParticle {
  final Color color;
  final double angle;
  final double velocity;
  final double size;
  final double rotation;
  final double rotationSpeed;

  ConfettiParticle({
    required this.color,
    required this.angle,
    required this.velocity,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
  });
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;
  final double gravity = 500.0;

  ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    for (var particle in particles) {
      final t = progress;
      
      // Calculate position with gravity
      final vx = math.cos(particle.angle) * particle.velocity;
      final vy = math.sin(particle.angle) * particle.velocity;
      
      final x = centerX + vx * t;
      final y = centerY + vy * t + 0.5 * gravity * t * t;

      // Skip if out of bounds
      if (x < -50 || x > size.width + 50 || y > size.height + 50) {
        continue;
      }

      // Calculate rotation
      final rotation = particle.rotation + particle.rotationSpeed * t;

      // Draw particle
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rotation);

      final paint = Paint()
        ..color = particle.color.withOpacity(1.0 - progress * 0.5)
        ..style = PaintingStyle.fill;

      // Draw as rectangle for confetti effect
      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: particle.size,
        height: particle.size * 2,
      );
      canvas.drawRect(rect, paint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Success Animation with Confetti
class SuccessWithConfetti extends StatefulWidget {
  final String message;
  final VoidCallback? onComplete;

  const SuccessWithConfetti({
    super.key,
    this.message = 'SUCCESS!',
    this.onComplete,
  });

  @override
  State<SuccessWithConfetti> createState() => _SuccessWithConfettiState();
}

class _SuccessWithConfettiState extends State<SuccessWithConfetti>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _showConfetti = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _showConfetti = true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConfettiExplosion(
      isExploding: _showConfetti,
      onComplete: widget.onComplete,
      child: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF39FF14), Color(0xFF00FF88)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF39FF14).withOpacity(0.6),
                      blurRadius: 40,
                      spreadRadius: 20,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                widget.message,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Celebration Overlay
class CelebrationOverlay extends StatelessWidget {
  final Widget child;
  final bool isVisible;
  final String message;
  final VoidCallback? onDismiss;

  const CelebrationOverlay({
    super.key,
    required this.child,
    this.isVisible = false,
    this.message = 'SUCCESS!',
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isVisible)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.7),
              child: SuccessWithConfetti(
                message: message,
                onComplete: onDismiss,
              ),
            ),
          ),
      ],
    );
  }
}
