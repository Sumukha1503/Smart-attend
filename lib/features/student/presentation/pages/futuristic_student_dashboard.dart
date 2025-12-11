import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/config/futuristic_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/aurora_background.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/attendance_service.dart';
import '../../../../core/services/demo_data_service.dart';
import '../../../../core/constants/app_routes.dart';

class FuturisticStudentDashboard extends StatefulWidget {
  const FuturisticStudentDashboard({super.key});

  @override
  State<FuturisticStudentDashboard> createState() =>
      _FuturisticStudentDashboardState();
}

class _FuturisticStudentDashboardState
    extends State<FuturisticStudentDashboard> {
  final AuthService _authService = AuthService();
  final AttendanceService _attendanceService = AttendanceService();
  final DemoDataService _demoDataService = DemoDataService();

  bool _isLoading = true;
  Map<String, dynamic>? _userData;
  double _overallAttendance = 0.0;
  List<Map<String, dynamic>> _subjects = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      final user = await _authService.getCurrentUser();
      if (user == null) return;

      final subjects = await _demoDataService.getSubjects();
      
      // Calculate overall attendance
      double totalPercentage = 0;
      int count = 0;
      
      List<Map<String, dynamic>> subjectData = [];
      
      for (var subject in subjects.take(4)) {
        final summary = await _attendanceService.calculateAttendancePercentage(
          studentId: user.id,
          courseId: subject['id'],
        );
        
        final percentage = summary['percentage'] as double;
        totalPercentage += percentage;
        count++;
        
        subjectData.add({
          ...subject,
          'percentage': percentage,
          'present': summary['presentClasses'],
          'total': summary['totalClasses'],
        });
      }

      setState(() {
        _userData = {
          'name': user.name,
          'usn': user.usn,
          'role': user.role,
        };
        _overallAttendance = count > 0 ? totalPercentage / count : 0;
        _subjects = subjectData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: AuroraBackground(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadDashboardData,
                color: FuturisticTheme.neonCyan,
                backgroundColor: FuturisticTheme.deepSpace,
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(16.w, 100.h, 16.w, 16.h),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Welcome Header
                            FadeInDown(
                              child: _buildWelcomeHeader(),
                            ),
                            
                            SizedBox(height: 24.h),
                            
                            // Bento Grid
                            _buildBentoGrid(),
                            
                            SizedBox(height: 24.h),
                            
                            // Quick Actions
                            FadeInUp(
                              delay: const Duration(milliseconds: 600),
                              child: _buildQuickActions(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: _buildFloatingBottomBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: ShaderMask(
        shaderCallback: (bounds) =>
            FuturisticTheme.neonCyanGradient.createShader(bounds),
        child: Text(
          'SMART ATTEND',
          style: FuturisticTheme.h4Futuristic.copyWith(
            color: Colors.white,
            fontSize: 20.sp,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_outlined, color: FuturisticTheme.neonCyan),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.person_outline, color: FuturisticTheme.neonCyan),
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.studentProfile);
          },
        ),
      ],
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WELCOME BACK',
          style: FuturisticTheme.labelTech.copyWith(
            color: FuturisticTheme.neonCyan.withOpacity(0.7),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          _userData?['name'] ?? 'Student',
          style: FuturisticTheme.h2Futuristic.copyWith(
            fontSize: 32.sp,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          _userData?['usn'] ?? '',
          style: FuturisticTheme.captionTech,
        ),
      ],
    );
  }

  Widget _buildBentoGrid() {
    return StaggeredGrid.count(
      crossAxisCount: 2,
      mainAxisSpacing: 16.h,
      crossAxisSpacing: 16.w,
      children: [
        // Hero Card - Overall Attendance (Large)
        StaggeredGridTile.count(
          crossAxisCellCount: 2,
          mainAxisCellCount: 1.2,
          child: FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: _buildHeroAttendanceCard(),
          ),
        ),
        
        // Subject Cards
        ...List.generate(
          _subjects.length,
          (index) => StaggeredGridTile.count(
            crossAxisCellCount: 1,
            mainAxisCellCount: 1,
            child: FadeInUp(
              delay: Duration(milliseconds: 300 + (index * 100)),
              child: _buildSubjectCard(_subjects[index]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroAttendanceCard() {
    final statusColor = FuturisticTheme.getStatusColor(_overallAttendance);
    final statusGradient = FuturisticTheme.getStatusGradient(_overallAttendance);
    
    return NeonGlowContainer(
      glowColor: statusColor,
      glowIntensity: 0.4,
      padding: EdgeInsets.all(24.w),
      child: Row(
        children: [
          // Radial Gauge
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 140.h,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Ring Chart
                  PieChart(
                    PieChartData(
                      startDegreeOffset: -90,
                      sectionsSpace: 0,
                      centerSpaceRadius: 50.w,
                      sections: [
                        PieChartSectionData(
                          value: _overallAttendance,
                          color: statusColor,
                          radius: 20.w,
                          showTitle: false,
                        ),
                        PieChartSectionData(
                          value: 100 - _overallAttendance,
                          color: Colors.white.withOpacity(0.1),
                          radius: 20.w,
                          showTitle: false,
                        ),
                      ],
                    ),
                  ),
                  // Center Text
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) =>
                            statusGradient.createShader(bounds),
                        child: Text(
                          '${_overallAttendance.toStringAsFixed(0)}%',
                          style: FuturisticTheme.numericCounterSmall.copyWith(
                            color: Colors.white,
                            fontSize: 36.sp,
                          ),
                        ),
                      ),
                      Text(
                        FuturisticTheme.getStatusText(_overallAttendance),
                        style: FuturisticTheme.labelTech.copyWith(
                          color: statusColor,
                          fontSize: 10.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(width: 16.w),
          
          // Info
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'OVERALL',
                  style: FuturisticTheme.labelTech.copyWith(
                    color: FuturisticTheme.neonCyan.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'ATTENDANCE',
                  style: FuturisticTheme.h3Futuristic.copyWith(
                    fontSize: 24.sp,
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    GlowingDot(color: statusColor, size: 8),
                    SizedBox(width: 8.w),
                    Text(
                      '${_subjects.length} Subjects',
                      style: FuturisticTheme.captionTech,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(Map<String, dynamic> subject) {
    final percentage = subject['percentage'] as double;
    final statusColor = FuturisticTheme.getStatusColor(percentage);
    
    return GlassContainer(
      padding: EdgeInsets.all(16.w),
      borderColor: statusColor.withOpacity(0.3),
      onTap: () {
        HapticFeedback.lightImpact();
        // Navigate to subject details
      },
      child: Stack(
        children: [
          // Watermark Code
          Positioned(
            right: -10.w,
            bottom: -10.h,
            child: Opacity(
              opacity: 0.05,
              child: Text(
                subject['code'],
                style: FuturisticTheme.h1Futuristic.copyWith(
                  fontSize: 48.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Dot
              Row(
                children: [
                  GlowingDot(color: statusColor, size: 8),
                  const Spacer(),
                  Text(
                    '${percentage.toStringAsFixed(0)}%',
                    style: FuturisticTheme.bodyTechBold.copyWith(
                      color: statusColor,
                      fontSize: 18.sp,
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 12.h),
              
              // Subject Name
              Text(
                subject['name'],
                style: FuturisticTheme.bodyTechBold.copyWith(
                  fontSize: 14.sp,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              SizedBox(height: 8.h),
              
              // Code
              Text(
                subject['code'],
                style: FuturisticTheme.labelTech.copyWith(
                  color: FuturisticTheme.neonCyan.withOpacity(0.7),
                ),
              ),
              
              const Spacer(),
              
              // Progress Bar
              Container(
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: percentage / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: FuturisticTheme.getStatusGradient(percentage),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              
              SizedBox(height: 8.h),
              
              // Stats
              Text(
                '${subject['present']}/${subject['total']} Classes',
                style: FuturisticTheme.captionTech.copyWith(
                  fontSize: 11.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QUICK ACTIONS',
          style: FuturisticTheme.labelTech.copyWith(
            color: FuturisticTheme.neonCyan.withOpacity(0.7),
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: FloatingBubble(
                icon: Icons.qr_code_scanner,
                label: 'Join Session',
                gradient: FuturisticTheme.neonCyanGradient,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.pushNamed(context, AppRoutes.joinSession);
                },
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: FloatingBubble(
                icon: Icons.calendar_today,
                label: 'Calendar',
                gradient: FuturisticTheme.neonMagentaGradient,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.pushNamed(context, AppRoutes.attendanceCalendar);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFloatingBottomBar() {
    return Container(
      margin: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
      child: GlassContainer(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        borderRadius: BorderRadius.circular(30),
        borderColor: FuturisticTheme.neonCyan.withOpacity(0.3),
        blurStrength: 20,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, 'Home', true),
            _buildNavItem(Icons.bar_chart, 'Analytics', false),
            _buildNavItem(Icons.history, 'History', false),
            _buildNavItem(Icons.person, 'Profile', false),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        // Handle navigation
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive
                ? FuturisticTheme.neonCyan
                : Colors.white.withOpacity(0.5),
            size: 24.sp,
          ),
          SizedBox(height: 4.h),
          if (isActive)
            Container(
              width: 4.w,
              height: 4.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: FuturisticTheme.neonCyan,
                boxShadow: [
                  BoxShadow(
                    color: FuturisticTheme.neonCyan.withOpacity(0.6),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
