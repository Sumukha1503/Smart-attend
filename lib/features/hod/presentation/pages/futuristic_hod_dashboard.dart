import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/config/futuristic_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/aurora_background.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/demo_data_service.dart';
import '../../../../core/constants/app_routes.dart';

class FuturisticHODDashboard extends StatefulWidget {
  const FuturisticHODDashboard({super.key});

  @override
  State<FuturisticHODDashboard> createState() => _FuturisticHODDashboardState();
}

class _FuturisticHODDashboardState extends State<FuturisticHODDashboard> {
  final AuthService _authService = AuthService();
  final DemoDataService _demoDataService = DemoDataService();

  bool _isLoading = true;
  Map<String, dynamic>? _userData;
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _pendingApprovals = [];
  List<Map<String, dynamic>> _alerts = [];

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

      final students = await _demoDataService.getStudents();
      final courses = await _demoDataService.getSubjects();

      // Mock data
      final pendingApprovals = [
        {
          'type': 'leave',
          'student': 'Rahul Sharma',
          'usn': '1AB23CS001',
          'date': 'Today',
          'icon': Icons.event_busy,
          'color': FuturisticTheme.solarOrange,
        },
        {
          'type': 'registration',
          'student': 'Priya Patel',
          'usn': '1AB23CS045',
          'date': '2 hours ago',
          'icon': Icons.person_add,
          'color': FuturisticTheme.neonCyan,
        },
      ];

      final alerts = [
        {
          'type': 'critical',
          'message': '8 students below 75% attendance',
          'icon': Icons.warning,
          'color': FuturisticTheme.plasmaRed,
        },
        {
          'type': 'info',
          'message': 'New session started in CS201',
          'icon': Icons.info,
          'color': FuturisticTheme.neonCyan,
        },
      ];

      setState(() {
        _userData = {
          'name': user.name,
          'employeeId': user.employeeId,
          'department': 'Computer Science',
        };
        _stats = {
          'totalStudents': students.length,
          'totalFaculty': 12,
          'totalCourses': courses.length,
          'avgAttendance': 82.5,
          'activeSessions': 3,
          'pendingApprovals': pendingApprovals.length,
        };
        _pendingApprovals = pendingApprovals;
        _alerts = alerts;
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
          Icon(Icons.dashboard, color: FuturisticTheme.neonMagenta, size: 24.sp),
          SizedBox(width: 8.w),
          ShaderMask(
            shaderCallback: (bounds) =>
                FuturisticTheme.neonMagentaGradient.createShader(bounds),
            child: Text(
              'EXECUTIVE COMMAND',
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
          icon: Icon(Icons.notifications_outlined, color: FuturisticTheme.neonCyan),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.settings_outlined, color: FuturisticTheme.neonCyan),
          onPressed: () {
            Navigator.pushNamed(context, '/settings');
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
            FadeInDown(child: _buildHeader()),
            SizedBox(height: 24.h),
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: _buildStatsGrid(),
            ),
            SizedBox(height: 24.h),
            FadeInUp(
              delay: const Duration(milliseconds: 400),
              child: _buildAlerts(),
            ),
            SizedBox(height: 24.h),
            FadeInUp(
              delay: const Duration(milliseconds: 600),
              child: _buildPendingApprovals(),
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
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                _buildHeader(),
                SizedBox(height: 24.h),
                _buildStatsGrid(),
                SizedBox(height: 24.h),
                _buildQuickActions(),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            margin: EdgeInsets.only(right: 16.w, top: 16.h, bottom: 16.h),
            child: Column(
              children: [
                Expanded(child: _buildAlerts()),
                SizedBox(height: 16.h),
                Expanded(child: _buildPendingApprovals()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Left Panel - Stats & Actions
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                _buildHeader(),
                SizedBox(height: 24.h),
                _buildStatsGrid(),
                SizedBox(height: 24.h),
                _buildQuickActions(),
              ],
            ),
          ),
        ),
        // Center - Alerts
        Expanded(
          flex: 1,
          child: Container(
            padding: EdgeInsets.all(16.w),
            child: _buildAlerts(),
          ),
        ),
        // Right - Approvals
        Expanded(
          flex: 1,
          child: Container(
            padding: EdgeInsets.all(16.w),
            child: _buildPendingApprovals(),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EXECUTIVE DASHBOARD',
          style: FuturisticTheme.labelTech.copyWith(
            color: FuturisticTheme.neonMagenta.withOpacity(0.7),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          _userData?['name'] ?? 'HOD',
          style: FuturisticTheme.h2Futuristic.copyWith(
            fontSize: 28.sp,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          '${_userData?['department']} Department',
          style: FuturisticTheme.captionTech,
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12.h,
      crossAxisSpacing: 12.w,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard(
          'STUDENTS',
          _stats['totalStudents'].toString(),
          Icons.people_outline,
          FuturisticTheme.neonCyan,
          '+12 this month',
        ),
        _buildStatCard(
          'FACULTY',
          _stats['totalFaculty'].toString(),
          Icons.school_outlined,
          FuturisticTheme.neonMagenta,
          '3 active now',
        ),
        _buildStatCard(
          'COURSES',
          _stats['totalCourses'].toString(),
          Icons.book_outlined,
          FuturisticTheme.neonPurple,
          '${_stats['activeSessions']} sessions',
        ),
        _buildStatCard(
          'AVG ATTENDANCE',
          '${_stats['avgAttendance']}%',
          Icons.trending_up,
          FuturisticTheme.neonGreen,
          '+2.5% vs last week',
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return NeonGlowContainer(
      glowColor: color,
      glowIntensity: 0.3,
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24.sp),
              Text(
                label,
                style: FuturisticTheme.labelTech.copyWith(
                  color: color.withOpacity(0.7),
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
          ShaderMask(
            shaderCallback: (bounds) =>
                LinearGradient(colors: [color, color.withOpacity(0.7)])
                    .createShader(bounds),
            child: Text(
              value,
              style: FuturisticTheme.numericCounterSmall.copyWith(
                fontSize: 32.sp,
                color: Colors.white,
              ),
            ),
          ),
          Text(
            subtitle,
            style: FuturisticTheme.captionTech.copyWith(
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlerts() {
    return GlassContainer(
      padding: EdgeInsets.all(20.w),
      borderColor: FuturisticTheme.plasmaRed.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notifications_active, color: FuturisticTheme.plasmaRed, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'SYSTEM ALERTS',
                style: FuturisticTheme.labelTech.copyWith(
                  color: FuturisticTheme.plasmaRed,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...List.generate(
            _alerts.length,
            (index) => _buildAlertItem(_alerts[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(Map<String, dynamic> alert) {
    return PulsingWrapper(
      pulseColor: alert['color'],
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: alert['color'].withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: alert['color'].withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(alert['icon'], color: alert['color'], size: 24.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                alert['message'],
                style: FuturisticTheme.bodyTech.copyWith(
                  fontSize: 14.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingApprovals() {
    return GlassContainer(
      padding: EdgeInsets.all(20.w),
      borderColor: FuturisticTheme.solarOrange.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.pending_actions, color: FuturisticTheme.solarOrange, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'PENDING APPROVALS',
                    style: FuturisticTheme.labelTech.copyWith(
                      color: FuturisticTheme.solarOrange,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: FuturisticTheme.solarOrange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _pendingApprovals.length.toString(),
                  style: FuturisticTheme.bodyTechBold.copyWith(
                    color: FuturisticTheme.solarOrange,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...List.generate(
            _pendingApprovals.length,
            (index) => _buildApprovalItem(_pendingApprovals[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalItem(Map<String, dynamic> approval) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: approval['color'].withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: approval['color'].withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(approval['icon'], color: approval['color'], size: 20.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      approval['student'],
                      style: FuturisticTheme.bodyTechBold.copyWith(
                        fontSize: 14.sp,
                      ),
                    ),
                    Text(
                      approval['usn'],
                      style: FuturisticTheme.captionTech.copyWith(
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                approval['date'],
                style: FuturisticTheme.captionTech.copyWith(
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    // Approve action
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    decoration: BoxDecoration(
                      gradient: FuturisticTheme.successGradient,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'APPROVE',
                        style: FuturisticTheme.labelTech.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    // Reject action
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: FuturisticTheme.plasmaRed.withOpacity(0.5),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        'REJECT',
                        style: FuturisticTheme.labelTech.copyWith(
                          color: FuturisticTheme.plasmaRed,
                        ),
                      ),
                    ),
                  ),
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
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12.h,
          crossAxisSpacing: 12.w,
          childAspectRatio: 2,
          children: [
            _buildActionButton(
              'Analytics',
              Icons.bar_chart,
              FuturisticTheme.neonMagentaGradient,
              () => Navigator.pushNamed(context, AppRoutes.analyticsDashboard),
            ),
            _buildActionButton(
              'Calendar',
              Icons.calendar_today,
              FuturisticTheme.neonCyanGradient,
              () => Navigator.pushNamed(context, '/calendar'),
            ),
            _buildActionButton(
              'Manage Faculty',
              Icons.people,
              FuturisticTheme.successGradient,
              () => Navigator.pushNamed(context, AppRoutes.manageFaculty),
            ),
            _buildActionButton(
              'Reports',
              Icons.description,
              FuturisticTheme.warningGradient,
              () {},
            ),
          ],
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
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 28.sp),
            SizedBox(height: 4.h),
            Text(
              label,
              style: FuturisticTheme.bodyTechBold.copyWith(
                color: Colors.white,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
