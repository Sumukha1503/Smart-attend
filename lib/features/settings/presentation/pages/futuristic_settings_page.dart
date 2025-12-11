import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/config/futuristic_theme.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/aurora_background.dart';
import '../../../core/constants/app_routes.dart';

class FuturisticSettingsPage extends StatefulWidget {
  const FuturisticSettingsPage({super.key});

  @override
  State<FuturisticSettingsPage> createState() => _FuturisticSettingsPageState();
}

class _FuturisticSettingsPageState extends State<FuturisticSettingsPage> {
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  bool _darkModeEnabled = true;
  bool _hapticFeedbackEnabled = true;
  double _glowIntensity = 0.4;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: AuroraBackground(
        child: CyberGrid(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 100.h, 16.w, 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInDown(child: _buildHeader()),
                  SizedBox(height: 24.h),
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: _buildGeneralSettings(),
                  ),
                  SizedBox(height: 16.h),
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: _buildSecuritySettings(),
                  ),
                  SizedBox(height: 16.h),
                  FadeInUp(
                    delay: const Duration(milliseconds: 600),
                    child: _buildAppearanceSettings(),
                  ),
                  SizedBox(height: 16.h),
                  FadeInUp(
                    delay: const Duration(milliseconds: 800),
                    child: _buildAboutSection(),
                  ),
                ],
              ),
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
      title: Row(
        children: [
          Icon(Icons.settings, color: FuturisticTheme.neonMagenta, size: 24.sp),
          SizedBox(width: 8.w),
          ShaderMask(
            shaderCallback: (bounds) =>
                FuturisticTheme.neonMagentaGradient.createShader(bounds),
            child: Text(
              'SYSTEM SETTINGS',
              style: FuturisticTheme.h4Futuristic.copyWith(
                color: Colors.white,
                fontSize: 20.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CONFIGURATION',
          style: FuturisticTheme.labelTech.copyWith(
            color: FuturisticTheme.neonMagenta.withOpacity(0.7),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Customize Your Experience',
          style: FuturisticTheme.h2Futuristic.copyWith(
            fontSize: 28.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildGeneralSettings() {
    return GlassContainer(
      padding: EdgeInsets.all(20.w),
      borderColor: FuturisticTheme.neonCyan.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune, color: FuturisticTheme.neonCyan, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'GENERAL',
                style: FuturisticTheme.labelTech.copyWith(
                  color: FuturisticTheme.neonCyan,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildToggleSetting(
            'Notifications',
            'Receive push notifications',
            Icons.notifications_outlined,
            _notificationsEnabled,
            (value) {
              setState(() => _notificationsEnabled = value);
              HapticFeedback.lightImpact();
            },
          ),
          _buildToggleSetting(
            'Haptic Feedback',
            'Vibration on interactions',
            Icons.vibration,
            _hapticFeedbackEnabled,
            (value) {
              setState(() => _hapticFeedbackEnabled = value);
              if (value) HapticFeedback.mediumImpact();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySettings() {
    return GlassContainer(
      padding: EdgeInsets.all(20.w),
      borderColor: FuturisticTheme.neonGreen.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.security, color: FuturisticTheme.neonGreen, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'SECURITY',
                style: FuturisticTheme.labelTech.copyWith(
                  color: FuturisticTheme.neonGreen,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildToggleSetting(
            'Biometric Login',
            'Use fingerprint/face ID',
            Icons.fingerprint,
            _biometricEnabled,
            (value) {
              setState(() => _biometricEnabled = value);
              HapticFeedback.mediumImpact();
            },
          ),
          _buildNavigationSetting(
            'Biometric Setup',
            'Configure biometric authentication',
            Icons.settings_outlined,
            () {
              Navigator.pushNamed(context, AppRoutes.biometricSetup);
            },
          ),
          _buildNavigationSetting(
            'Change Password',
            'Update your password',
            Icons.lock_outline,
            () {
              HapticFeedback.mediumImpact();
              // Change password
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSettings() {
    return GlassContainer(
      padding: EdgeInsets.all(20.w),
      borderColor: FuturisticTheme.neonMagenta.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.palette, color: FuturisticTheme.neonMagenta, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'APPEARANCE',
                style: FuturisticTheme.labelTech.copyWith(
                  color: FuturisticTheme.neonMagenta,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildToggleSetting(
            'Dark Mode',
            'Cyber-future theme',
            Icons.dark_mode,
            _darkModeEnabled,
            (value) {
              setState(() => _darkModeEnabled = value);
              HapticFeedback.lightImpact();
            },
          ),
          _buildSliderSetting(
            'Glow Intensity',
            'Adjust neon glow effect',
            Icons.brightness_6,
            _glowIntensity,
            (value) {
              setState(() => _glowIntensity = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return GlassContainer(
      padding: EdgeInsets.all(20.w),
      borderColor: FuturisticTheme.neonPurple.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: FuturisticTheme.neonPurple, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'ABOUT',
                style: FuturisticTheme.labelTech.copyWith(
                  color: FuturisticTheme.neonPurple,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildInfoRow('Version', '3.0.0 - Cyber-Future Edition'),
          _buildInfoRow('Build', '2025.12.10'),
          _buildInfoRow('Theme', 'Aurora Glass & Neon'),
          SizedBox(height: 16.h),
          _buildNavigationSetting(
            'Privacy Policy',
            'View privacy policy',
            Icons.privacy_tip_outlined,
            () {},
          ),
          _buildNavigationSetting(
            'Terms of Service',
            'View terms of service',
            Icons.description_outlined,
            () {},
          ),
          _buildNavigationSetting(
            'Licenses',
            'Open source licenses',
            Icons.code,
            () {},
          ),
        ],
      ),
    );
  }

  Widget _buildToggleSetting(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: FuturisticTheme.glassBorder,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: FuturisticTheme.neonCyan, size: 24.sp),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: FuturisticTheme.bodyTechBold.copyWith(
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: FuturisticTheme.captionTech.copyWith(
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: FuturisticTheme.neonCyan,
            activeTrackColor: FuturisticTheme.neonCyan.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderSetting(
    String title,
    String subtitle,
    IconData icon,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: FuturisticTheme.glassBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: FuturisticTheme.neonMagenta, size: 24.sp),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: FuturisticTheme.bodyTechBold.copyWith(
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: FuturisticTheme.captionTech.copyWith(
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(value * 100).toInt()}%',
                style: FuturisticTheme.bodyTechBold.copyWith(
                  color: FuturisticTheme.neonMagenta,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: FuturisticTheme.neonMagenta,
              inactiveTrackColor: FuturisticTheme.neonMagenta.withOpacity(0.2),
              thumbColor: FuturisticTheme.neonMagenta,
              overlayColor: FuturisticTheme.neonMagenta.withOpacity(0.2),
            ),
            child: Slider(
              value: value,
              onChanged: onChanged,
              min: 0.0,
              max: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationSetting(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: FuturisticTheme.glassBorder,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: FuturisticTheme.neonCyan, size: 24.sp),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: FuturisticTheme.bodyTechBold.copyWith(
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: FuturisticTheme.captionTech.copyWith(
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: FuturisticTheme.neonCyan.withOpacity(0.5),
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: FuturisticTheme.captionTech,
          ),
          Text(
            value,
            style: FuturisticTheme.bodyTechBold.copyWith(
              fontSize: 14.sp,
              color: FuturisticTheme.neonPurple,
            ),
          ),
        ],
      ),
    );
  }
}
