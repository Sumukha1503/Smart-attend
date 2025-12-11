import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/config/futuristic_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/aurora_background.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/biometric_auth_service.dart';
import '../../../../core/constants/app_routes.dart';

class FuturisticLoginScreen extends StatefulWidget {
  const FuturisticLoginScreen({super.key});

  @override
  State<FuturisticLoginScreen> createState() => _FuturisticLoginScreenState();
}

class _FuturisticLoginScreenState extends State<FuturisticLoginScreen>
    with TickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final BiometricAuthService _biometricService = BiometricAuthService();
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _biometricAvailable = false;
  bool _showPassword = false;
  
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;
  
  @override
  void initState() {
    super.initState();
    _checkBiometric();
    _initScanAnimation();
  }
  
  void _initScanAnimation() {
    _scanController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );
  }
  
  Future<void> _checkBiometric() async {
    await _biometricService.initialize();
    final canCheck = await _biometricService.canCheckBiometrics();
    setState(() => _biometricAvailable = canCheck);
  }
  
  Future<void> _handleBiometricLogin() async {
    setState(() => _isLoading = true);
    _scanController.forward();
    
    HapticFeedback.mediumImpact();
    
    final authenticated = await _biometricService.authenticate(
      reason: 'Authenticate to access Smart Attend',
    );
    
    _scanController.reverse();
    
    if (authenticated) {
      HapticFeedback.heavyImpact();
      await _navigateToDashboard();
    } else {
      setState(() => _isLoading = false);
      HapticFeedback.vibrate();
    }
  }
  
  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError('Please enter email and password');
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final result = await _authService.login(
        identifier: _emailController.text.trim(),
        password: _passwordController.text,
      );
      
      if (result['success'] == true) {
        HapticFeedback.heavyImpact();
        await _navigateToDashboard();
      } else {
        _showError(result['message'] ?? 'Invalid credentials');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showError(e.toString());
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _navigateToDashboard() async {
    final user = await _authService.getCurrentUser();
    if (!mounted) return;
    
    String route = AppRoutes.studentHome;
    if (user?.role == 'Faculty') route = AppRoutes.facultyHome;
    if (user?.role == 'HOD') route = AppRoutes.hodDashboard;
    if (user?.role == 'Admin') route = AppRoutes.adminDashboard;
    
    Navigator.pushReplacementNamed(context, route);
  }
  
  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: FuturisticTheme.plasmaRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _scanController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuroraBackground(
        child: ParticleField(
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo & Title
                    FadeInDown(
                      duration: const Duration(milliseconds: 800),
                      child: _buildHeader(),
                    ),
                    
                    SizedBox(height: 60.h),
                    
                    // Login Form
                    FadeInUp(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 200),
                      child: _buildLoginForm(),
                    ),
                    
                    SizedBox(height: 24.h),
                    
                    // Biometric Login
                    if (_biometricAvailable)
                      FadeInUp(
                        duration: const Duration(milliseconds: 800),
                        delay: const Duration(milliseconds: 400),
                        child: _buildBiometricButton(),
                      ),
                    
                    SizedBox(height: 32.h),
                    
                    // Demo Credentials
                    FadeInUp(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 600),
                      child: _buildDemoCredentials(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Column(
      children: [
        // Glowing Logo
        NeonGlowContainer(
          glowColor: FuturisticTheme.neonCyan,
          glowIntensity: 0.5,
          padding: EdgeInsets.all(24.w),
          borderRadius: BorderRadius.circular(30),
          child: Icon(
            Icons.fingerprint,
            size: 80.sp,
            color: FuturisticTheme.neonCyan,
          ),
        ),
        
        SizedBox(height: 24.h),
        
        // Title
        ShaderMask(
          shaderCallback: (bounds) => FuturisticTheme.neonCyanGradient
              .createShader(bounds),
          child: Text(
            'SMART ATTEND',
            style: FuturisticTheme.h1Futuristic.copyWith(
              fontSize: 42.sp,
              color: Colors.white,
            ),
          ),
        ),
        
        SizedBox(height: 8.h),
        
        Text(
          '2025 CYBER-FUTURE EDITION',
          style: FuturisticTheme.labelTech.copyWith(
            color: FuturisticTheme.neonCyan.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
  
  Widget _buildLoginForm() {
    return GlassContainer(
      padding: EdgeInsets.all(24.w),
      borderColor: FuturisticTheme.neonCyan.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Email Field
          _buildTextField(
            controller: _emailController,
            label: 'EMAIL',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          
          SizedBox(height: 20.h),
          
          // Password Field
          _buildTextField(
            controller: _passwordController,
            label: 'PASSWORD',
            icon: Icons.lock_outline,
            obscureText: !_showPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _showPassword ? Icons.visibility_off : Icons.visibility,
                color: FuturisticTheme.neonCyan.withOpacity(0.5),
              ),
              onPressed: () => setState(() => _showPassword = !_showPassword),
            ),
          ),
          
          SizedBox(height: 32.h),
          
          // Login Button
          _buildLoginButton(),
        ],
      ),
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: FuturisticTheme.labelTech.copyWith(
            color: FuturisticTheme.neonCyan,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: FuturisticTheme.glassBorder,
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            style: FuturisticTheme.bodyTech,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: FuturisticTheme.neonCyan),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildLoginButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _handleLogin,
      child: Container(
        height: 56.h,
        decoration: BoxDecoration(
          gradient: FuturisticTheme.neonCyanGradient,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: FuturisticTheme.neonCyan.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: _isLoading
              ? SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: const CircularProgressIndicator(
                    color: Colors.black,
                    strokeWidth: 3,
                  ),
                )
              : Text(
                  'AUTHENTICATE',
                  style: FuturisticTheme.bodyTechBold.copyWith(
                    color: FuturisticTheme.midnight,
                    fontSize: 16.sp,
                  ),
                ),
        ),
      ),
    );
  }
  
  Widget _buildBiometricButton() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: FuturisticTheme.glassBorder)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                'OR',
                style: FuturisticTheme.captionTech,
              ),
            ),
            Expanded(child: Divider(color: FuturisticTheme.glassBorder)),
          ],
        ),
        
        SizedBox(height: 24.h),
        
        GestureDetector(
          onTap: _isLoading ? null : _handleBiometricLogin,
          child: AnimatedBuilder(
            animation: _scanAnimation,
            builder: (context, child) {
              return NeonGlowContainer(
                glowColor: FuturisticTheme.neonMagenta,
                glowIntensity: 0.3 + (_scanAnimation.value * 0.4),
                padding: EdgeInsets.all(20.w),
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.fingerprint,
                          size: 64.sp,
                          color: FuturisticTheme.neonMagenta,
                        ),
                        if (_scanAnimation.value > 0)
                          SizedBox(
                            width: 80.w,
                            height: 80.w,
                            child: CircularProgressIndicator(
                              value: _scanAnimation.value,
                              strokeWidth: 3,
                              color: FuturisticTheme.neonMagenta,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      _isLoading ? 'SCANNING...' : 'BIOMETRIC LOGIN',
                      style: FuturisticTheme.bodyTechBold.copyWith(
                        color: FuturisticTheme.neonMagenta,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildDemoCredentials() {
    return GlassContainer(
      padding: EdgeInsets.all(16.w),
      opacity: 0.05,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16.sp,
                color: FuturisticTheme.neonCyan.withOpacity(0.7),
              ),
              SizedBox(width: 8.w),
              Text(
                'DEMO CREDENTIALS',
                style: FuturisticTheme.labelTech.copyWith(
                  color: FuturisticTheme.neonCyan.withOpacity(0.7),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildCredentialRow('Student', 'rahul@student.com', 'Student@123'),
          _buildCredentialRow('Faculty', 'suresh@faculty.com', 'Faculty@123'),
          _buildCredentialRow('HOD', 'ramesh@hod.com', 'HOD@123'),
        ],
      ),
    );
  }
  
  Widget _buildCredentialRow(String role, String email, String password) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          SizedBox(
            width: 70.w,
            child: Text(
              role,
              style: FuturisticTheme.captionTech.copyWith(
                color: FuturisticTheme.neonCyan.withOpacity(0.5),
              ),
            ),
          ),
          Expanded(
            child: Text(
              '$email / $password',
              style: FuturisticTheme.captionTech.copyWith(
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
