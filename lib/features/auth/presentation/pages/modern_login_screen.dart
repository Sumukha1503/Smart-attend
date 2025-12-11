import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animate_do/animate_do.dart';
import '../../../../core/config/modern_theme.dart';
import '../../../../core/widgets/modern_widgets.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/constants/app_routes.dart';

/// Modern Professional Login Screen
/// Clean & Welcoming Design inspired by Stripe and Airbnb
class ModernLoginScreen extends StatefulWidget {
  const ModernLoginScreen({super.key});

  @override
  State<ModernLoginScreen> createState() => _ModernLoginScreenState();
}

class _ModernLoginScreenState extends State<ModernLoginScreen> {
  final AuthService _authService = AuthService();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _showPassword = false;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

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
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: ModernTheme.rose,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: ModernTheme.radiusMedium,
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernTheme.offWhite,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Responsive layout
            final isWide = constraints.maxWidth > 800;

            return Row(
              children: [
                // Left Side - Illustration/Branding (only on wide screens)
                if (isWide)
                  Expanded(
                    flex: 5,
                    child: _buildBrandingSection(),
                  ),

                // Right Side - Login Form
                Expanded(
                  flex: isWide ? 5 : 1,
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(32),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: _buildLoginForm(),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBrandingSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: ModernTheme.primaryGradient,
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeInLeft(
                duration: const Duration(milliseconds: 800),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    size: 120,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              FadeInLeft(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 200),
                child: Text(
                  'Smart Attend',
                  style: ModernTheme.h1.copyWith(
                    fontSize: 48,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FadeInLeft(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 400),
                child: Text(
                  'Modern attendance management\nmade simple and efficient',
                  textAlign: TextAlign.center,
                  style: ModernTheme.bodyLarge.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Welcome Header
          FadeInDown(
            duration: const Duration(milliseconds: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back',
                  style: ModernTheme.h1,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue to your dashboard',
                  style: ModernTheme.bodyMedium.copyWith(
                    color: ModernTheme.slateGrey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // Email Field
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 100),
            child: ModernTextField(
              controller: _emailController,
              label: 'Email Address',
              hint: 'Enter your email',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                return null;
              },
            ),
          ),

          const SizedBox(height: 24),

          // Password Field
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 200),
            child: ModernTextField(
              controller: _passwordController,
              label: 'Password',
              hint: 'Enter your password',
              prefixIcon: Icons.lock_outline,
              obscureText: !_showPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _showPassword ? Icons.visibility_off : Icons.visibility,
                  color: ModernTheme.slateGrey,
                ),
                onPressed: () => setState(() => _showPassword = !_showPassword),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            ),
          ),

          const SizedBox(height: 32),

          // Login Button
          FadeInUp(
            duration: const Duration(milliseconds: 600),
            delay: const Duration(milliseconds: 300),
            child: ModernButton.gradient(
              label: 'Sign In',
              icon: Icons.arrow_forward,
              onPressed: _isLoading ? null : _handleLogin,
              isLoading: _isLoading,
            ),
          ),
        ],
      ),
    );
  }
}
