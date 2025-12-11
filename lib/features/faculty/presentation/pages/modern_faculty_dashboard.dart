import 'package:flutter/material.dart';
import 'dart:io';
import '../../../../core/config/modern_theme.dart';
import '../../../../core/widgets/modern_widgets.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/demo_data_service.dart';
import '../../../../core/widgets/bottom_nav_scaffold.dart';
import '../../presentation/pages/faculty_profile_page.dart';
import '../../presentation/pages/manage_session_page.dart';
import '../../../common/presentation/pages/notifications_page.dart';

/// Modern Professional Faculty Dashboard
/// Clean interface for faculty to manage courses and attendance
class ModernFacultyDashboard extends StatefulWidget {
  const ModernFacultyDashboard({super.key});

  @override
  State<ModernFacultyDashboard> createState() => _ModernFacultyDashboardState();
}

class _ModernFacultyDashboardState extends State<ModernFacultyDashboard> {
  int _currentIndex = 0;
  final AuthService _authService = AuthService();
  final DemoDataService _demoDataService = DemoDataService();

  String _userName = '';
  String _userEmail = '';
  String _userId = '';
  String? _profilePicture;
  List<Map<String, dynamic>> _courses = [];
  List<Map<String, dynamic>> _activeSessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final user = await _authService.getCurrentUser();
    if (user != null) {
      _userId = user.id;
      _userName = user.name;
      _userEmail = user.email;
      _profilePicture = user.profilePicture;

      // Load courses (using subjects as courses for demo)
      _courses = await _demoDataService.getSubjects();
      
      // Mock active sessions
      _activeSessions = [
        {
          'id': '1',
          'courseName': 'Mathematics',
          'courseCode': 'MAT101',
          'studentsPresent': 45,
          'totalStudents': 50,
          'startTime': DateTime.now().subtract(const Duration(minutes: 15)),
          'status': 'active',
        },
      ];
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _buildHomeContent(),
      const FacultyProfilePage(),
      const NotificationsPage(),
    ];

    return BottomNavScaffold(
      title: _currentIndex == 0 ? 'Faculty Dashboard' : null,
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() => _currentIndex = index);
        if (index == 0) {
          _loadData();
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
        BottomNavigationBarItem(
            icon: Icon(Icons.notifications_rounded), label: 'Notifications'),
      ],
      body: tabs[_currentIndex],
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.createGeoSession);
              },
              backgroundColor: ModernTheme.royalBlue,
              icon: const Icon(Icons.add_location_alt_rounded),
              label: const Text('Create Session'),
            )
          : null,
    );
  }

  Widget _buildHomeContent() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadData,
            color: ModernTheme.royalBlue,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Header Section
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: ModernTheme.primaryGradient,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.white,
                              backgroundImage: _profilePicture != null
                                  ? FileImage(File(_profilePicture!))
                                  : null,
                              child: _profilePicture == null
                                  ? Text(
                                      _userName.isNotEmpty
                                          ? _userName[0].toUpperCase()
                                          : 'F',
                                      style: ModernTheme.h3.copyWith(
                                        color: ModernTheme.royalBlue,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome back,',
                                    style: ModernTheme.bodyMedium.copyWith(
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _userName.isNotEmpty ? _userName : 'Faculty',
                                    style: ModernTheme.h3.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Quick Stats
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildQuickStat(
                            'Courses',
                            '${_courses.length}',
                            Icons.book_rounded,
                            ModernTheme.royalBlue,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildQuickStat(
                            'Active',
                            '${_activeSessions.length}',
                            Icons.play_circle_rounded,
                            ModernTheme.softEmerald,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildQuickStat(
                            'Today',
                            '${_courses.length * 2}',
                            Icons.today_rounded,
                            ModernTheme.deepIndigo,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Active Sessions
                if (_activeSessions.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Active Sessions', style: ModernTheme.h3),
                          StatusChip.good('Live'),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: _activeSessions
                            .map((session) => _buildActiveSessionCard(session))
                            .toList(),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],

                // Quick Actions
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                    child: Text('Quick Actions', style: ModernTheme.h3),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        _buildQuickActionCard(
                          'Mark Attendance',
                          'Take attendance for your class',
                          Icons.how_to_reg_rounded,
                          ModernTheme.royalBlue,
                          () => Navigator.pushNamed(context, AppRoutes.markAttendance),
                        ),
                        const SizedBox(height: 12),
                        _buildQuickActionCard(
                          'Manage Courses',
                          'View and edit your courses',
                          Icons.school_rounded,
                          ModernTheme.deepIndigo,
                          () => Navigator.pushNamed(context, AppRoutes.courseManagement),
                        ),
                        const SizedBox(height: 12),
                        _buildQuickActionCard(
                          'View Analytics',
                          'Check attendance statistics',
                          Icons.analytics_rounded,
                          ModernTheme.softEmerald,
                          () => Navigator.pushNamed(context, AppRoutes.analyticsDashboard),
                        ),
                      ],
                    ),
                  ),
                ),

                // My Courses
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('My Courses', style: ModernTheme.h3),
                        Text(
                          '${_courses.length} courses',
                          style: ModernTheme.label,
                        ),
                      ],
                    ),
                  ),
                ),

                // Course Cards
                if (_courses.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.book_outlined,
                            size: 80,
                            color: ModernTheme.lightSlateGrey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No courses assigned',
                            style: ModernTheme.bodyLarge.copyWith(
                              color: ModernTheme.slateGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final course = _courses[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildCourseCard(course),
                          );
                        },
                        childCount: _courses.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
  }

  Widget _buildQuickStat(String label, String value, IconData icon, Color color) {
    return ModernCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: ModernTheme.h3.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: ModernTheme.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActiveSessionCard(Map<String, dynamic> session) {
    final attendance = (session['studentsPresent'] / session['totalStudents'] * 100);

    return ModernCard(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: ModernTheme.softEmerald,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: ModernTheme.softEmerald.withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text('LIVE SESSION', style: ModernTheme.captionBold.copyWith(
                color: ModernTheme.softEmerald,
              )),
              const Spacer(),
              Text(
                _getTimeAgo(session['startTime']),
                style: ModernTheme.caption,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            session['courseName'],
            style: ModernTheme.h4,
          ),
          const SizedBox(height: 4),
          Text(
            session['courseCode'],
            style: ModernTheme.bodyMedium.copyWith(
              color: ModernTheme.slateGrey,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Attendance', style: ModernTheme.caption),
                    const SizedBox(height: 4),
                    Text(
                      '${session['studentsPresent']}/${session['totalStudents']}',
                      style: ModernTheme.h5,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Percentage', style: ModernTheme.caption),
                    const SizedBox(height: 4),
                    Text(
                      '${attendance.toStringAsFixed(0)}%',
                      style: ModernTheme.h5.copyWith(
                        color: ModernTheme.softEmerald,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ModernButton(
            label: 'Manage Session',
            icon: Icons.settings_rounded,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ManageSessionPage(session: session),
                ),
              );
            },
            isFullWidth: true,
            backgroundColor: ModernTheme.softEmerald,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ModernCard(
      onTap: onTap,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: ModernTheme.h5),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: ModernTheme.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: ModernTheme.lightSlateGrey,
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(Map<String, dynamic> course) {
    return ModernCard(
      onTap: () => _showCourseDetails(course),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: ModernTheme.deepIndigo.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.book_rounded,
              color: ModernTheme.deepIndigo,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course['name'],
                  style: ModernTheme.h5,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  course['code'],
                  style: ModernTheme.caption,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.people_rounded,
                      size: 16,
                      color: ModernTheme.slateGrey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${course['totalClasses']} students',
                      style: ModernTheme.caption,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: ModernTheme.lightSlateGrey,
          ),
        ],
      ),
    );
  }

  void _showCourseDetails(Map<String, dynamic> course) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: ModernTheme.pureWhite,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ModernTheme.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(course['name'], style: ModernTheme.h2),
            const SizedBox(height: 8),
            Text(
              course['code'],
              style: ModernTheme.bodyMedium.copyWith(
                color: ModernTheme.slateGrey,
              ),
            ),
            const SizedBox(height: 24),
            ModernButton.gradient(
              label: 'Mark Attendance',
              icon: Icons.how_to_reg_rounded,
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.markAttendance);
              },
            ),
            const SizedBox(height: 12),
            ModernButton.outline(
              label: 'View Analytics',
              icon: Icons.analytics_rounded,
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.analyticsDashboard);
              },
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}
