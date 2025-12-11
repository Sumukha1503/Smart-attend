import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/config/futuristic_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/aurora_background.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/demo_data_service.dart';
import '../../../../core/constants/app_routes.dart';

class FuturisticFacultyDashboard extends StatefulWidget {
  const FuturisticFacultyDashboard({super.key});

  @override
  State<FuturisticFacultyDashboard> createState() =>
      _FuturisticFacultyDashboardState();
}

class _FuturisticFacultyDashboardState
    extends State<FuturisticFacultyDashboard> {
  final AuthService _authService = AuthService();
  final DemoDataService _demoDataService = DemoDataService();

  bool _isLoading = true;
  Map<String, dynamic>? _userData;
  List<Map<String, dynamic>> _courses = [];
  List<Map<String, dynamic>> _recentActivity = [];

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

      final allCourses = await _demoDataService.getSubjects();
      final courses = allCourses.where((c) => c['facultyId'] == user.id).toList();

      // Mock recent activity
      final activity = [
        {
          'type': 'session_created',
          'course': 'CS201',
          'time': '2 hours ago',
          'icon': Icons.play_circle_outline,
          'color': FuturisticTheme.neonCyan,
        },
        {
          'type': 'attendance_marked',
          'course': 'CS203',
          'time': '5 hours ago',
          'icon': Icons.check_circle_outline,
          'color': FuturisticTheme.neonGreen,
        },
        {
          'type': 'report_generated',
          'course': 'CS201',
          'time': '1 day ago',
          'icon': Icons.description_outlined,
          'color': FuturisticTheme.neonMagenta,
        },
      ];

      setState(() {
        _userData = {
          'name': user.name,
          'employeeId': user.employeeId,
          'role': user.role,
        };
        _courses = courses;
        _recentActivity = activity;
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
        child: CyberGrid(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Responsive layout
                      if (constraints.maxWidth > 1200) {
                        return _buildDesktopLayout();
                      } else if (constraints.maxWidth > 600) {
                        return _buildTabletLayout();
                      } else {
                        return _buildMobileLayout();
                      }
                    },
                  ),
                ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        children: [
          Icon(Icons.terminal, color: FuturisticTheme.neonCyan, size: 24.sp),
          SizedBox(width: 8.w),
          ShaderMask(
            shaderCallback: (bounds) =>
                FuturisticTheme.neonCyanGradient.createShader(bounds),
            child: Text(
              'COMMAND CENTER',
              style: FuturisticTheme.h4Futuristic.copyWith(
                color: Colors.white,
                fontSize: 20.sp,
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.psychology, color: FuturisticTheme.neonPurple),
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.aiPredictions);
          },
        ),
        IconButton(
          icon: Icon(Icons.person_outline, color: FuturisticTheme.neonCyan),
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.facultyProfile);
          },
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      color: FuturisticTheme.neonCyan,
      backgroundColor: FuturisticTheme.deepSpace,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(child: _buildWelcomeHeader()),
            SizedBox(height: 24.h),
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: _buildQuickStats(),
            ),
            SizedBox(height: 24.h),
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: _buildCoursesList(),
            ),
            SizedBox(height: 24.h),
            FadeInUp(
              delay: const Duration(milliseconds: 600),
              child: _buildRecentActivity(),
            ),
            SizedBox(height: 24.h),
            FadeInUp(
              delay: const Duration(milliseconds: 800),
              child: _buildQuickActions(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        // Left Panel - Courses & Actions
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                _buildWelcomeHeader(),
                SizedBox(height: 24.h),
                _buildQuickStats(),
                SizedBox(height: 24.h),
                _buildCoursesList(),
                SizedBox(height: 24.h),
                _buildQuickActions(),
              ],
            ),
          ),
        ),
        // Right Panel - Activity Feed
        Expanded(
          flex: 1,
          child: Container(
            margin: EdgeInsets.only(right: 16.w, top: 16.h, bottom: 16.h),
            child: _buildRecentActivity(),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Left Sidebar
        Container(
          width: 280.w,
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              _buildWelcomeHeader(),
              SizedBox(height: 24.h),
              _buildQuickActions(),
            ],
          ),
        ),
        // Center - Main Content
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                _buildQuickStats(),
                SizedBox(height: 24.h),
                _buildCoursesList(),
              ],
            ),
          ),
        ),
        // Right - Activity Feed
        Container(
          width: 320.w,
          padding: EdgeInsets.all(16.w),
          child: _buildRecentActivity(),
        ),
      ],
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FACULTY PORTAL',
          style: FuturisticTheme.labelTech.copyWith(
            color: FuturisticTheme.neonCyan.withOpacity(0.7),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          _userData?['name'] ?? 'Faculty',
          style: FuturisticTheme.h2Futuristic.copyWith(
            fontSize: 28.sp,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'ID: ${_userData?['employeeId'] ?? ''}',
          style: FuturisticTheme.captionTech,
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'COURSES',
            _courses.length.toString(),
            Icons.book_outlined,
            FuturisticTheme.neonCyan,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _buildStatCard(
            'ACTIVE',
            '2',
            Icons.play_circle_outline,
            FuturisticTheme.neonGreen,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _buildStatCard(
            'REPORTS',
            '12',
            Icons.description_outlined,
            FuturisticTheme.neonMagenta,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return NeonGlowContainer(
      glowColor: color,
      glowIntensity: 0.3,
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32.sp),
          SizedBox(height: 8.h),
          Text(
            value,
            style: FuturisticTheme.numericCounterSmall.copyWith(
              fontSize: 28.sp,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: FuturisticTheme.labelTech.copyWith(
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'YOUR COURSES',
          style: FuturisticTheme.labelTech.copyWith(
            color: FuturisticTheme.neonCyan.withOpacity(0.7),
          ),
        ),
        SizedBox(height: 16.h),
        ...List.generate(
          _courses.length,
          (index) => FadeInUp(
            delay: Duration(milliseconds: 200 + (index * 100)),
            child: _buildCourseCard(_courses[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    return GlassContainer(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.w),
      borderColor: FuturisticTheme.neonCyan.withOpacity(0.3),
      onTap: () {
        HapticFeedback.lightImpact();
        // Navigate to course details
      },
      child: Row(
        children: [
          // Course Icon
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              gradient: FuturisticTheme.neonCyanGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                course['code'].substring(0, 2),
                style: FuturisticTheme.h4Futuristic.copyWith(
                  color: FuturisticTheme.midnight,
                  fontSize: 20.sp,
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          // Course Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course['name'],
                  style: FuturisticTheme.bodyTechBold.copyWith(
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${course['code']} • Sem ${course['semester']} • Sec ${course['section']}',
                  style: FuturisticTheme.captionTech,
                ),
              ],
            ),
          ),
          // Arrow
          Icon(
            Icons.arrow_forward_ios,
            color: FuturisticTheme.neonCyan.withOpacity(0.5),
            size: 16.sp,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return GlassContainer(
      padding: EdgeInsets.all(20.w),
      borderColor: FuturisticTheme.neonMagenta.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, color: FuturisticTheme.neonMagenta, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'RECENT ACTIVITY',
                style: FuturisticTheme.labelTech.copyWith(
                  color: FuturisticTheme.neonMagenta,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          ...List.generate(
            _recentActivity.length,
            (index) => _buildActivityItem(_recentActivity[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: activity['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: activity['color'].withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              activity['icon'],
              color: activity['color'],
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['course'],
                  style: FuturisticTheme.bodyTechBold.copyWith(
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  activity['time'],
                  style: FuturisticTheme.captionTech.copyWith(
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
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
        _buildActionButton(
          'Create Session',
          Icons.add_circle_outline,
          FuturisticTheme.neonCyanGradient,
          () {
            HapticFeedback.mediumImpact();
            Navigator.pushNamed(context, AppRoutes.createGeoSession);
          },
        ),
        SizedBox(height: 12.h),
        _buildActionButton(
          'Mark Attendance',
          Icons.check_circle_outline,
          FuturisticTheme.successGradient,
          () {
            HapticFeedback.mediumImpact();
            Navigator.pushNamed(context, AppRoutes.markAttendance);
          },
        ),
        SizedBox(height: 12.h),
        _buildActionButton(
          'View Analytics',
          Icons.bar_chart,
          FuturisticTheme.neonMagentaGradient,
          () {
            HapticFeedback.mediumImpact();
            Navigator.pushNamed(context, AppRoutes.analyticsDashboard);
          },
        ),
        SizedBox(height: 12.h),
        _buildActionButton(
          'Generate Report',
          Icons.description_outlined,
          FuturisticTheme.warningGradient,
          () {
            HapticFeedback.mediumImpact();
            // Navigate to reports
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Gradient gradient,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: FuturisticTheme.neonCyan.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                label,
                style: FuturisticTheme.bodyTechBold.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward,
              color: Colors.white.withOpacity(0.7),
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}
