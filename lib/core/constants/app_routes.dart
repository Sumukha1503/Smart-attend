class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String pendingApproval = '/pending-approval';
  
  // Student
  static const String studentHome = '/student/home';
  static const String studentProfile = '/student/profile';
  static const String attendanceDetail = '/student/attendance-detail';
  static const String joinSession = '/student/join-session';
  static const String attendanceHistory = '/student/attendance-history';
  
  // Faculty
  static const String facultyHome = '/faculty/home';
  static const String facultyProfile = '/faculty/profile';
  static const String courseManagement = '/faculty/course-management';
  static const String markAttendance = '/faculty/mark-attendance';
  static const String createGeoSession = '/faculty/create-geo-session';
  
  // HOD
  static const String hodDashboard = '/hod/dashboard';
  static const String hodProfile = '/hod/profile';
  static const String approvalRequests = '/hod/approval-requests';
  static const String scanStudentId = '/hod/scan-student-id';
  static const String manageFaculty = '/hod/manage-faculty';
  static const String manageStudents = '/hod/manage-students';
  static const String departmentStats = '/hod/department-stats';
  static const String courseAssignment = '/hod/course-assignment';
  
  // Analytics & Reports (Phase 2)
  static const String analyticsDashboard = '/analytics/dashboard';
  static const String attendanceCalendar = '/calendar/attendance';
  
  // Phase 3: Premium Features
  static const String biometricSetup = '/settings/biometric';
  static const String aiPredictions = '/ai/predictions';
  
  // Admin
  static const String adminDashboard = '/admin/dashboard';
}