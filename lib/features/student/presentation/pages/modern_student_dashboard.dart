import 'package:flutter/material.dart';
import 'dart:io';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../../core/config/modern_theme.dart';
import '../../../../core/widgets/modern_widgets.dart';
import '../../../../core/animations/modern_animations.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/demo_data_service.dart';
import '../../../../core/widgets/bottom_nav_scaffold.dart';
import '../../presentation/pages/student_profile_page.dart';
import '../../../common/presentation/pages/notifications_page.dart';
import 'join_session_page.dart';

/// Modern Professional Student Dashboard
/// "The Overview" - Clean, elegant, and informative
class ModernStudentDashboard extends StatefulWidget {
  const ModernStudentDashboard({super.key});

  @override
  State<ModernStudentDashboard> createState() => _ModernStudentDashboardState();
}

class _ModernStudentDashboardState extends State<ModernStudentDashboard> {
  int _currentIndex = 0;
  final AuthService _authService = AuthService();
  final DemoDataService _demoDataService = DemoDataService();

  String _userName = '';
  String _userEmail = '';
  String _userUsn = '';
  String _userId = '';
  String? _profilePicture;
  List<Map<String, dynamic>> _subjects = [];
  Map<String, double> _attendancePercentages = {};
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
      _userUsn = user.usn ?? '';
      _profilePicture = user.profilePicture;

      // Load subjects
      _subjects = await _demoDataService.getSubjects();

      // Load attendance percentages for each subject
      for (var subject in _subjects) {
        final percentage = await _demoDataService.getAttendancePercentage(
          _userId,
          subject['id'],
        );
        _attendancePercentages[subject['id']] = percentage;
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _buildHomeContent(),
      const StudentProfilePage(),
      const NotificationsPage(),
    ];

    return BottomNavScaffold(
      title: _currentIndex == 0 ? 'Dashboard' : null,
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const JoinSessionPage()),
                );
              },
              backgroundColor: ModernTheme.royalBlue,
              icon: const Icon(Icons.qr_code_scanner_rounded),
              label: const Text('Join Session'),
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
                                          : 'S',
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
                                    _userName.isNotEmpty ? _userName : 'Student',
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


                // Insight Cards - Horizontal Scroll
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24, bottom: 16),
                    child: SizedBox(
                      height: 170, // Increased from 160 to prevent overflow
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        children: [
                          _buildInsightCard(
                            title: 'Overall Attendance',
                            value: _getOverallAttendance(),
                            icon: Icons.analytics_rounded,
                            color: ModernTheme.royalBlue,
                            subtitle: _getAttendanceStatus(),
                            width: 200,
                          ),
                          const SizedBox(width: 16),
                          _buildInsightCard(
                            title: 'Total Subjects',
                            value: '${_subjects.length}',
                            icon: Icons.book_rounded,
                            color: ModernTheme.deepIndigo,
                            subtitle: 'Enrolled',
                            width: 180,
                          ),
                          const SizedBox(width: 16),
                          _buildInsightCard(
                            title: 'This Week',
                            value: '${_subjects.length * 5}',
                            icon: Icons.calendar_today_rounded,
                            color: ModernTheme.softEmerald,
                            subtitle: 'Classes',
                            width: 180,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Subjects Section Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'My Subjects',
                          style: ModernTheme.h3,
                        ),
                        Text(
                          '${_subjects.length} enrolled',
                          style: ModernTheme.label,
                        ),
                      ],
                    ),
                  ),
                ),

                // Subject Cards
                if (_subjects.isEmpty)
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
                            'No subjects found',
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
                          final subject = _subjects[index];
                          final percentage =
                              _attendancePercentages[subject['id']] ?? 0.0;
                          return StaggeredListAnimation(
                            index: index,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildSubjectCard(subject, percentage),
                            ),
                          );
                        },
                        childCount: _subjects.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
  }

  Widget _buildInsightCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
    double width = 200,
  }) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ModernTheme.pureWhite,
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: ModernTheme.radiusLarge,
        boxShadow: ModernTheme.softShadow,
      ),
      padding: const EdgeInsets.all(16), // Reduced from 20 to 16
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Use spaceBetween instead of Spacer
        children: [
          Container(
            padding: const EdgeInsets.all(10), // Reduced from 12 to 10
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24, // Reduced from 28 to 24
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: ModernTheme.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: ModernTheme.h2.copyWith(
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null) ...[ 
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: ModernTheme.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(Map<String, dynamic> subject, double percentage) {
    final statusColor = ModernTheme.getAttendanceColor(percentage);
    final statusBgColor = ModernTheme.getAttendanceBackgroundColor(percentage);

    return ModernCard(
      onTap: () => _showSubjectDetails(subject, percentage),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Subject Icon
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: ModernTheme.royalBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.book_rounded,
              color: ModernTheme.royalBlue,
              size: 28,
            ),
          ),

          const SizedBox(width: 16),

          // Subject Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject['name'],
                  style: ModernTheme.h5,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${subject['code']} • ${subject['facultyName']}',
                  style: ModernTheme.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: ModernTheme.borderLight,
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Attendance Percentage
          Column(
            children: [
              CircularPercentIndicator(
                radius: 32,
                lineWidth: 6,
                percent: percentage / 100,
                center: Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: ModernTheme.labelBold.copyWith(
                    color: statusColor,
                    fontSize: 13,
                  ),
                ),
                progressColor: statusColor,
                backgroundColor: statusBgColor,
                circularStrokeCap: CircularStrokeCap.round,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSubjectDetails(Map<String, dynamic> subject, double percentage) {
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
            // Handle
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

            // Subject Name
            Text(
              subject['name'],
              style: ModernTheme.h2,
            ),
            const SizedBox(height: 8),
            Text(
              subject['code'],
              style: ModernTheme.bodyMedium.copyWith(
                color: ModernTheme.slateGrey,
              ),
            ),

            const SizedBox(height: 24),

            // Details
            _buildDetailRow('Faculty', subject['facultyName']),
            const SizedBox(height: 16),
            _buildDetailRow('Total Classes', '${subject['totalClasses']}'),
            const SizedBox(height: 16),
            _buildDetailRow('Attendance', '${percentage.toStringAsFixed(1)}%'),

            const SizedBox(height: 32),

            // Action Button
            ModernButton.gradient(
              label: 'View Attendance History',
              icon: Icons.history_rounded,
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  AppRoutes.attendanceHistory,
                  arguments: {
                    'subjectId': subject['id'],
                    'subjectName': subject['name'],
                  },
                );
              },
            ),

            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: ModernTheme.bodyMedium.copyWith(
            color: ModernTheme.slateGrey,
          ),
        ),
        Text(
          value,
          style: ModernTheme.labelBold,
        ),
      ],
    );
  }

  String _getOverallAttendance() {
    if (_attendancePercentages.isEmpty) return '0%';

    final avgAttendance = _attendancePercentages.values.reduce((a, b) => a + b) /
        _attendancePercentages.length;

    return '${avgAttendance.toStringAsFixed(1)}%';
  }

  String _getAttendanceStatus() {
    if (_attendancePercentages.isEmpty) return 'No data';

    final avgAttendance = _attendancePercentages.values.reduce((a, b) => a + b) /
        _attendancePercentages.length;

    return ModernTheme.getAttendanceStatus(avgAttendance);
  }
}
