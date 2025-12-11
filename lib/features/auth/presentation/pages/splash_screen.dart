import 'package:flutter/material.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Artificial delay for splash effect
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;

    final user = await _authService.getCurrentUser();

    if (user != null) {
      // User is logged in, navigate based on role
      switch (user.role) {
        case 'Student':
          Navigator.pushReplacementNamed(context, AppRoutes.studentHome);
          break;
        case 'Faculty':
          Navigator.pushReplacementNamed(context, AppRoutes.facultyHome);
          break;
        case 'HOD':
          Navigator.pushReplacementNamed(context, AppRoutes.hodDashboard);
          break;
        case 'Admin':
          Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
          break;
        default:
          Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    } else {
      // No user logged in
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.qr_code_scanner,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            const Text(
              'Smart Attend',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Attendance Made Easy',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
