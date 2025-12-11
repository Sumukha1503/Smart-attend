import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/config/futuristic_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/aurora_background.dart';
import '../../../../core/services/auth_service.dart';

class FuturisticProfilePage extends StatefulWidget {
  const FuturisticProfilePage({super.key});

  @override
  State<FuturisticProfilePage> createState() => _FuturisticProfilePageState();
}

class _FuturisticProfilePageState extends State<FuturisticProfilePage> {
  final AuthService _authService = AuthService();
  
  bool _isLoading = true;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        setState(() {
          _userData = {
            'name': user.name,
            'email': user.email,
            'role': user.role,
            'id': user.role == 'Student' ? user.usn : user.employeeId,
            'department': 'Computer Science',
            'semester': user.role == 'Student' ? '5' : null,
            'section': user.role == 'Student' ? 'A' : null,
            'joinDate': '2023-08-01',
            'attendance': 85.5,
          };
          _isLoading = false;
        });
      }
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
            : SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(16.w, 100.h, 16.w, 16.h),
                  child: Column(
                    children: [
                      FadeInDown(child: _buildProfileHeader()),
                      SizedBox(height: 24.h),
                      FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        child: _buildStatsCards(),
                      ),
                      SizedBox(height: 24.h),
                      FadeInUp(
                        delay: const Duration(milliseconds: 400),
                        child: _buildInfoSection(),
                      ),
                      SizedBox(height: 24.h),
                      FadeInUp(
                        delay: const Duration(milliseconds: 600),
                        child: _buildActionButtons(),
                      ),
                    ],
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
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: FuturisticTheme.neonCyan),
        onPressed: () => Navigator.pop(context),
      ),
      title: ShaderMask(
        shaderCallback: (bounds) =>
            FuturisticTheme.neonCyanGradient.createShader(bounds),
        child: Text(
          'PROFILE',
          style: FuturisticTheme.h4Futuristic.copyWith(
            color: Colors.white,
            fontSize: 20.sp,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.edit, color: FuturisticTheme.neonCyan),
          onPressed: () {
            HapticFeedback.mediumImpact();
            // Edit profile
          },
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return NeonGlowContainer(
      glowColor: FuturisticTheme.neonCyan,
      glowIntensity: 0.4,
      padding: EdgeInsets.all(24.w),
      child: Column(
        children: [
          // Avatar
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: FuturisticTheme.neonCyanGradient,
                  boxShadow: [
                    BoxShadow(
                      color: FuturisticTheme.neonCyan.withOpacity(0.6),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _userData?['name']?.substring(0, 1).toUpperCase() ?? 'U',
                    style: FuturisticTheme.h1Futuristic.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: FuturisticTheme.successGradient,
                    border: Border.all(
                      color: FuturisticTheme.deepSpace,
                      width: 3,
                    ),
                  ),
                  child: Icon(
                    Icons.verified,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Name
          ShaderMask(
            shaderCallback: (bounds) =>
                FuturisticTheme.neonCyanGradient.createShader(bounds),
            child: Text(
              _userData?['name'] ?? 'User',
              style: FuturisticTheme.h2Futuristic.copyWith(
                fontSize: 28.sp,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          // Role & ID
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: FuturisticTheme.neonCyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: FuturisticTheme.neonCyan.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.badge,
                  color: FuturisticTheme.neonCyan,
                  size: 16.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  '${_userData?['role']} • ${_userData?['id']}',
                  style: FuturisticTheme.bodyTech.copyWith(
                    color: FuturisticTheme.neonCyan,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    if (_userData?['role'] != 'Student') {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'ATTENDANCE',
            '${_userData?['attendance']}%',
            Icons.check_circle_outline,
            FuturisticTheme.neonGreen,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatCard(
            'SEMESTER',
            _userData?['semester'] ?? 'N/A',
            Icons.school_outlined,
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
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32.sp),
          SizedBox(height: 12.h),
          ShaderMask(
            shaderCallback: (bounds) =>
                LinearGradient(colors: [color, color.withOpacity(0.7)])
                    .createShader(bounds),
            child: Text(
              value,
              style: FuturisticTheme.numericCounterSmall.copyWith(
                fontSize: 28.sp,
                color: Colors.white,
              ),
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

  Widget _buildInfoSection() {
    return GlassContainer(
      padding: EdgeInsets.all(20.w),
      borderColor: FuturisticTheme.neonCyan.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'INFORMATION',
            style: FuturisticTheme.labelTech.copyWith(
              color: FuturisticTheme.neonCyan,
            ),
          ),
          SizedBox(height: 16.h),
          _buildInfoRow('Email', _userData?['email'] ?? 'N/A', Icons.email),
          _buildInfoRow('Department', _userData?['department'] ?? 'N/A', Icons.business),
          if (_userData?['semester'] != null)
            _buildInfoRow('Section', _userData?['section'] ?? 'N/A', Icons.class_),
          _buildInfoRow('Joined', _userData?['joinDate'] ?? 'N/A', Icons.calendar_today),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: FuturisticTheme.neonCyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: FuturisticTheme.neonCyan, size: 20.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: FuturisticTheme.captionTech,
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: FuturisticTheme.bodyTechBold.copyWith(
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        _buildActionButton(
          'Edit Profile',
          Icons.edit,
          FuturisticTheme.neonCyanGradient,
          () {
            HapticFeedback.mediumImpact();
            // Edit profile
          },
        ),
        SizedBox(height: 12.h),
        _buildActionButton(
          'Settings',
          Icons.settings,
          FuturisticTheme.neonMagentaGradient,
          () {
            HapticFeedback.mediumImpact();
            Navigator.pushNamed(context, '/settings');
          },
        ),
        SizedBox(height: 12.h),
        _buildActionButton(
          'Logout',
          Icons.logout,
          FuturisticTheme.criticalGradient,
          () async {
            HapticFeedback.heavyImpact();
            await _authService.logout();
            if (mounted) {
              Navigator.pushReplacementNamed(context, '/login');
            }
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
        width: double.infinity,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24.sp),
            SizedBox(width: 12.w),
            Text(
              label,
              style: FuturisticTheme.bodyTechBold.copyWith(
                color: Colors.white,
                fontSize: 16.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
