import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/constants/app_routes.dart';
import 'core/config/futuristic_theme.dart';
import 'core/config/modern_theme.dart';

// Original Pages
import 'features/auth/presentation/pages/splash_screen.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/signup_page.dart';
import 'features/auth/presentation/pages/pending_approval_page.dart';
import 'features/student/presentation/pages/student_home_page.dart';
import 'features/student/presentation/pages/student_profile_page.dart';
import 'features/faculty/presentation/pages/faculty_home_page.dart';
import 'features/faculty/presentation/pages/faculty_profile_page.dart';
import 'features/faculty/presentation/pages/course_management_page.dart';
import 'features/hod/presentation/pages/hod_dashboard.dart';
import 'features/hod/presentation/pages/hod_profile_page.dart';
import 'features/hod/presentation/pages/approval_requests_page.dart';
import 'features/admin/presentation/pages/admin_dashboard.dart';
import 'features/hod/presentation/pages/manage_faculty_page.dart';
import 'features/hod/presentation/pages/manage_students_page.dart';
import 'features/hod/presentation/pages/department_stats_page.dart';
import 'features/hod/presentation/pages/course_assignment_page.dart';
import 'features/student/presentation/pages/attendance_history_page.dart';
import 'features/faculty/presentation/pages/mark_attendance_page.dart';
import 'features/faculty/presentation/pages/create_geo_session_page.dart';
import 'features/analytics/presentation/pages/analytics_dashboard.dart';
import 'features/calendar/presentation/pages/attendance_calendar_page.dart';
import 'features/biometric/presentation/pages/biometric_setup_page.dart';
import 'features/ai/presentation/pages/ai_predictions_dashboard.dart';

// Futuristic Pages (2025 Cyber-Future Edition)
import 'features/auth/presentation/pages/futuristic_login_screen.dart';
import 'features/student/presentation/pages/futuristic_student_dashboard.dart';
import 'features/faculty/presentation/pages/futuristic_faculty_dashboard.dart';
import 'features/faculty/presentation/pages/futuristic_attendance_marking.dart';
import 'features/analytics/presentation/pages/futuristic_analytics_screen.dart';

// Modern Professional Pages (2025 Soft Modern Edition)
import 'features/auth/presentation/pages/modern_login_screen.dart';
import 'features/student/presentation/pages/modern_student_dashboard.dart';
import 'features/faculty/presentation/pages/modern_faculty_dashboard.dart';
import 'features/analytics/presentation/pages/modern_analytics_screen.dart';

/// UI Theme Mode
/// Change this to switch between different UI styles
enum UIThemeMode {
  futuristic, // Cyber-Future with Aurora Glass & Neon
  modern,     // Soft Modern Professional (Stripe/Airbnb style)
  classic,    // Original Material Design
}

class SmartAttendApp extends StatelessWidget {
  const SmartAttendApp({super.key});

  // ⚡ CHANGE THIS TO SWITCH UI THEMES ⚡
  static const UIThemeMode currentTheme = UIThemeMode.modern;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X base
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: _getAppTitle(),
          debugShowCheckedModeBanner: false,
          theme: _getTheme(),
          builder: (context, widget) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: widget!,
            );
          },
          initialRoute: AppRoutes.splash,
          routes: _getRoutes(),
        );
      },
    );
  }

  String _getAppTitle() {
    switch (currentTheme) {
      case UIThemeMode.futuristic:
        return 'Smart Attend - 2025 Cyber-Future Edition';
      case UIThemeMode.modern:
        return 'Smart Attend - Modern Professional';
      case UIThemeMode.classic:
        return 'Smart Attend';
    }
  }

  ThemeData _getTheme() {
    switch (currentTheme) {
      case UIThemeMode.futuristic:
        return FuturisticTheme.darkTheme;
      case UIThemeMode.modern:
        return ModernTheme.lightTheme;
      case UIThemeMode.classic:
        return ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        );
    }
  }

  Map<String, WidgetBuilder> _getRoutes() {
    // Base routes that are common to all themes
    final baseRoutes = {
      AppRoutes.splash: (context) => const SplashScreen(),
      AppRoutes.signup: (context) => const SignupPage(),
      AppRoutes.pendingApproval: (context) => const PendingApprovalPage(),
      
      // Student routes (common)
      AppRoutes.studentProfile: (context) => const StudentProfilePage(),
      AppRoutes.attendanceHistory: (context) => const AttendanceHistoryPage(),
      
      // Faculty routes (common)
      AppRoutes.facultyProfile: (context) => const FacultyProfilePage(),
      AppRoutes.courseManagement: (context) => const CourseManagementPage(),
      AppRoutes.markAttendance: (context) => const MarkAttendancePage(),
      AppRoutes.createGeoSession: (context) => const CreateGeoSessionPage(),
      
      // HOD routes
      AppRoutes.hodDashboard: (context) => const HodDashboard(),
      AppRoutes.hodProfile: (context) => const HodProfilePage(),
      AppRoutes.approvalRequests: (context) => const ApprovalRequestsPage(),
      AppRoutes.manageFaculty: (context) => const ManageFacultyPage(),
      AppRoutes.manageStudents: (context) => const ManageStudentsPage(),
      AppRoutes.departmentStats: (context) => const DepartmentStatsPage(),
      AppRoutes.courseAssignment: (context) => const CourseAssignmentPage(),
      
      // Analytics & Reports
      AppRoutes.analyticsDashboard: (context) => const AnalyticsDashboard(),
      AppRoutes.attendanceCalendar: (context) => const AttendanceCalendarPage(),
      
      // Phase 3: Premium Features
      AppRoutes.biometricSetup: (context) => const BiometricSetupPage(),
      AppRoutes.aiPredictions: (context) => const AIPredictionsDashboard(),
      
      // Admin routes
      AppRoutes.adminDashboard: (context) => const AdminDashboard(),
    };

    // Theme-specific routes
    switch (currentTheme) {
      case UIThemeMode.futuristic:
        return {
          ...baseRoutes,
          AppRoutes.login: (context) => const FuturisticLoginScreen(),
          AppRoutes.studentHome: (context) => const FuturisticStudentDashboard(),
          AppRoutes.facultyHome: (context) => const FuturisticFacultyDashboard(),
        };

      case UIThemeMode.modern:
        return {
          ...baseRoutes,
          AppRoutes.login: (context) => const ModernLoginScreen(),
          AppRoutes.studentHome: (context) => const ModernStudentDashboard(),
          AppRoutes.facultyHome: (context) => const ModernFacultyDashboard(),
          AppRoutes.analyticsDashboard: (context) => const ModernAnalyticsScreen(),
        };

      case UIThemeMode.classic:
        return {
          ...baseRoutes,
          AppRoutes.login: (context) => const LoginPage(),
          AppRoutes.studentHome: (context) => const StudentHomePage(),
          AppRoutes.facultyHome: (context) => const FacultyHomePage(),
        };
    }
  }
}
