import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/config/futuristic_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/aurora_background.dart';

class FuturisticAttendanceMarking extends StatefulWidget {
  const FuturisticAttendanceMarking({super.key});

  @override
  State<FuturisticAttendanceMarking> createState() =>
      _FuturisticAttendanceMarkingState();
}

class _FuturisticAttendanceMarkingState
    extends State<FuturisticAttendanceMarking>
    with TickerProviderStateMixin {
  bool _isScanning = false;
  bool _isMarking = false;
  bool _isSuccess = false;
  double _markProgress = 0.0;

  late AnimationController _radarController;
  late AnimationController _markController;
  late AnimationController _successController;
  late Animation<double> _radarAnimation;
  late Animation<double> _markAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    // Radar scan animation
    _radarController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _radarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _radarController, curve: Curves.linear),
    );

    // Mark progress animation
    _markController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _markAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _markController, curve: Curves.easeInOut),
    );

    // Success animation controller
    _successController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _markAnimation.addListener(() {
      setState(() => _markProgress = _markAnimation.value);
    });

    _markController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _handleMarkingComplete();
      }
    });
  }

  Future<void> _startScanning() async {
    setState(() => _isScanning = true);
    _radarController.repeat();
    HapticFeedback.mediumImpact();

    // Simulate location detection
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isScanning = false);
    _radarController.stop();
  }

  void _startMarking() {
    setState(() => _isMarking = true);
    _markController.forward();
    HapticFeedback.heavyImpact();
  }

  Future<void> _handleMarkingComplete() async {
    setState(() {
      _isMarking = false;
      _isSuccess = true;
    });

    _successController.forward();
    HapticFeedback.heavyImpact();

    // Color shift animation
    await Future.delayed(const Duration(milliseconds: 500));

    // Show confetti or success animation
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _radarController.dispose();
    _markController.dispose();
    _successController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: FuturisticTheme.neonCyan),
          onPressed: () => Navigator.pop(context),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) =>
              FuturisticTheme.neonCyanGradient.createShader(bounds),
          child: Text(
            'MARK ATTENDANCE',
            style: FuturisticTheme.h4Futuristic.copyWith(
              color: Colors.white,
              fontSize: 20.sp,
            ),
          ),
        ),
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: _isSuccess
            ? BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    FuturisticTheme.neonGreen.withOpacity(0.2),
                    FuturisticTheme.deepSpace,
                  ],
                ),
              )
            : const BoxDecoration(
                gradient: FuturisticTheme.auroraGradient,
              ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: _buildMainContent(),
                ),
              ),
              _buildBottomControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (_isSuccess) {
      return _buildSuccessView();
    } else if (_isScanning) {
      return _buildRadarScanner();
    } else if (_isMarking) {
      return _buildMarkingProgress();
    } else {
      return _buildInitialView();
    }
  }

  Widget _buildInitialView() {
    return FadeIn(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          NeonGlowContainer(
            glowColor: FuturisticTheme.neonCyan,
            glowIntensity: 0.4,
            padding: EdgeInsets.all(40.w),
            borderRadius: BorderRadius.circular(100),
            child: Icon(
              Icons.location_on_outlined,
              size: 80.sp,
              color: FuturisticTheme.neonCyan,
            ),
          ),
          SizedBox(height: 32.h),
          Text(
            'READY TO MARK',
            style: FuturisticTheme.h3Futuristic.copyWith(
              fontSize: 24.sp,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Scan location to begin',
            style: FuturisticTheme.captionTech,
          ),
        ],
      ),
    );
  }

  Widget _buildRadarScanner() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Radar Display
        SizedBox(
          width: 280.w,
          height: 280.w,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Radar circles
              ...List.generate(4, (index) {
                return Container(
                  width: (280 - index * 60).w,
                  height: (280 - index * 60).w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: FuturisticTheme.neonCyan.withOpacity(0.3 - index * 0.05),
                      width: 1,
                    ),
                  ),
                );
              }),
              // Radar sweep
              AnimatedBuilder(
                animation: _radarAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size(280.w, 280.w),
                    painter: RadarSweepPainter(
                      progress: _radarAnimation.value,
                      color: FuturisticTheme.neonCyan,
                    ),
                  );
                },
              ),
              // Center icon
              Icon(
                Icons.my_location,
                size: 48.sp,
                color: FuturisticTheme.neonCyan,
              ),
            ],
          ),
        ),
        SizedBox(height: 32.h),
        Text(
          'SCANNING LOCATION...',
          style: FuturisticTheme.h4Futuristic.copyWith(
            fontSize: 20.sp,
            color: FuturisticTheme.neonCyan,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          'Please wait',
          style: FuturisticTheme.captionTech,
        ),
      ],
    );
  }

  Widget _buildMarkingProgress() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Hold to Mark Circle
        SizedBox(
          width: 280.w,
          height: 280.w,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Progress ring
              SizedBox(
                width: 280.w,
                height: 280.w,
                child: CircularProgressIndicator(
                  value: _markProgress,
                  strokeWidth: 8,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    FuturisticTheme.neonGreen,
                  ),
                ),
              ),
              // Center content
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fingerprint,
                    size: 80.sp,
                    color: FuturisticTheme.neonGreen,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    '${(_markProgress * 100).toInt()}%',
                    style: FuturisticTheme.numericCounterSmall.copyWith(
                      color: FuturisticTheme.neonGreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 32.h),
        PulsingWrapper(
          pulseColor: FuturisticTheme.neonGreen,
          child: Text(
            'MARKING ATTENDANCE',
            style: FuturisticTheme.h4Futuristic.copyWith(
              fontSize: 20.sp,
              color: FuturisticTheme.neonGreen,
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          'Hold to complete',
          style: FuturisticTheme.captionTech,
        ),
      ],
    );
  }

  Widget _buildSuccessView() {
    return ZoomIn(
      duration: const Duration(milliseconds: 500),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Success Icon with particles
          Stack(
            alignment: Alignment.center,
            children: [
              // Glow effect
              Container(
                width: 200.w,
                height: 200.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: FuturisticTheme.neonGreen.withOpacity(0.6),
                      blurRadius: 80,
                      spreadRadius: 40,
                    ),
                  ],
                ),
              ),
              // Check icon
              Icon(
                Icons.check_circle,
                size: 120.sp,
                color: FuturisticTheme.neonGreen,
              ),
            ],
          ),
          SizedBox(height: 32.h),
          ShaderMask(
            shaderCallback: (bounds) =>
                FuturisticTheme.successGradient.createShader(bounds),
            child: Text(
              'SUCCESS',
              style: FuturisticTheme.h2Futuristic.copyWith(
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Attendance marked successfully',
            style: FuturisticTheme.bodyTech.copyWith(
              color: FuturisticTheme.neonGreen,
            ),
          ),
          SizedBox(height: 32.h),
          // Stats
          GlassContainer(
            padding: EdgeInsets.all(20.w),
            margin: EdgeInsets.symmetric(horizontal: 40.w),
            borderColor: FuturisticTheme.neonGreen.withOpacity(0.3),
            child: Column(
              children: [
                _buildStatRow('Time', '10:30 AM'),
                SizedBox(height: 12.h),
                _buildStatRow('Location', 'Verified ✓'),
                SizedBox(height: 12.h),
                _buildStatRow('Status', 'Present'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: FuturisticTheme.captionTech,
        ),
        Text(
          value,
          style: FuturisticTheme.bodyTechBold.copyWith(
            color: FuturisticTheme.neonGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomControls() {
    if (_isSuccess || _isMarking) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_isScanning)
            GestureDetector(
              onTap: _startScanning,
              child: Container(
                width: double.infinity,
                height: 60.h,
                decoration: BoxDecoration(
                  gradient: FuturisticTheme.neonCyanGradient,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: FuturisticTheme.neonCyan.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'SCAN LOCATION',
                    style: FuturisticTheme.bodyTechBold.copyWith(
                      color: FuturisticTheme.midnight,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ),
            ),
          if (_isScanning) ...[
            SizedBox(height: 16.h),
            GestureDetector(
              onLongPressStart: (_) => _startMarking(),
              child: Container(
                width: double.infinity,
                height: 60.h,
                decoration: BoxDecoration(
                  gradient: FuturisticTheme.successGradient,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: FuturisticTheme.neonGreen.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'HOLD TO MARK',
                    style: FuturisticTheme.bodyTechBold.copyWith(
                      color: Colors.white,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Radar Sweep Painter
class RadarSweepPainter extends CustomPainter {
  final double progress;
  final Color color;

  RadarSweepPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final angle = progress * 2 * math.pi;

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withOpacity(0.5),
          color.withOpacity(0.0),
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    final path = Path();
    path.moveTo(center.dx, center.dy);
    path.arcTo(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      angle,
      false,
    );
    path.close();

    canvas.drawPath(path, paint);

    // Sweep line
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      center,
      Offset(
        center.dx + radius * math.cos(angle - math.pi / 2),
        center.dy + radius * math.sin(angle - math.pi / 2),
      ),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(RadarSweepPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
