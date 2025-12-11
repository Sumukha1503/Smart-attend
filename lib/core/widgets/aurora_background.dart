import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../config/futuristic_theme.dart';

/// Animated Aurora Borealis Background
/// Creates a moving mesh gradient effect
class AuroraBackground extends StatefulWidget {
  final Widget child;

  const AuroraBackground({super.key, required this.child});

  @override
  State<AuroraBackground> createState() => _AuroraBackgroundState();
}

class _AuroraBackgroundState extends State<AuroraBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
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
        // Base gradient background
        Container(
          decoration: const BoxDecoration(
            gradient: FuturisticTheme.auroraGradient,
          ),
        ),
        // Animated aurora mesh
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: AuroraMeshPainter(
                animation: _controller.value,
              ),
              size: Size.infinite,
            );
          },
        ),
        // Content
        widget.child,
      ],
    );
  }
}

/// Aurora Mesh Painter
class AuroraMeshPainter extends CustomPainter {
  final double animation;

  AuroraMeshPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.screen;

    // Create multiple aurora waves
    _drawAuroraWave(
      canvas,
      size,
      FuturisticTheme.neonCyan.withOpacity(0.15),
      animation,
      0.0,
    );
    
    _drawAuroraWave(
      canvas,
      size,
      FuturisticTheme.neonMagenta.withOpacity(0.12),
      animation,
      0.3,
    );
    
    _drawAuroraWave(
      canvas,
      size,
      FuturisticTheme.neonPurple.withOpacity(0.1),
      animation,
      0.6,
    );
  }

  void _drawAuroraWave(
    Canvas canvas,
    Size size,
    Color color,
    double animation,
    double offset,
  ) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color,
          color.withOpacity(0.0),
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final waveOffset = (animation + offset) * 2 * math.pi;

    path.moveTo(0, size.height * 0.3);

    for (double x = 0; x <= size.width; x += 10) {
      final y = size.height * 0.3 +
          math.sin((x / size.width) * 4 * math.pi + waveOffset) * 100 +
          math.sin((x / size.width) * 2 * math.pi + waveOffset * 0.5) * 50;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(AuroraMeshPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

/// Particle Field Background
class ParticleField extends StatefulWidget {
  final Widget child;
  final int particleCount;

  const ParticleField({
    super.key,
    required this.child,
    this.particleCount = 50,
  });

  @override
  State<ParticleField> createState() => _ParticleFieldState();
}

class _ParticleFieldState extends State<ParticleField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> particles;

  @override
  void initState() {
    super.initState();
    particles = List.generate(
      widget.particleCount,
      (index) => Particle(),
    );
    _controller = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    )..repeat();
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
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: ParticlePainter(
                particles: particles,
                animation: _controller.value,
              ),
              size: Size.infinite,
            );
          },
        ),
        widget.child,
      ],
    );
  }
}

class Particle {
  double x;
  double y;
  double vx;
  double vy;
  double size;
  Color color;

  Particle()
      : x = math.Random().nextDouble(),
        y = math.Random().nextDouble(),
        vx = (math.Random().nextDouble() - 0.5) * 0.0005,
        vy = (math.Random().nextDouble() - 0.5) * 0.0005,
        size = math.Random().nextDouble() * 2 + 1,
        color = [
          FuturisticTheme.neonCyan,
          FuturisticTheme.neonMagenta,
          FuturisticTheme.neonPurple,
        ][math.Random().nextInt(3)].withOpacity(0.3);

  void update() {
    x += vx;
    y += vy;

    if (x < 0 || x > 1) vx = -vx;
    if (y < 0 || y > 1) vy = -vy;
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animation;

  ParticlePainter({required this.particles, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      particle.update();

      final paint = Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill;

      final position = Offset(
        particle.x * size.width,
        particle.y * size.height,
      );

      // Draw particle
      canvas.drawCircle(position, particle.size, paint);

      // Draw glow
      final glowPaint = Paint()
        ..color = particle.color.withOpacity(0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(position, particle.size * 3, glowPaint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}

/// Cyber Grid Background
class CyberGrid extends StatelessWidget {
  final Widget child;

  const CyberGrid({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          painter: GridPainter(),
          size: Size.infinite,
        ),
        child,
      ],
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = FuturisticTheme.neonCyan.withOpacity(0.05)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const gridSize = 50.0;

    // Vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Horizontal lines
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
