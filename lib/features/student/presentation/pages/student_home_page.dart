import 'package:flutter/material.dart';
import 'dart:io';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/demo_data_service.dart';
import '../../../../core/widgets/bottom_nav_scaffold.dart';
import '../../presentation/pages/student_profile_page.dart';
import '../../../common/presentation/pages/notifications_page.dart';
import 'join_session_page.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
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
      title: _currentIndex == 0 ? 'Student Dashboard' : null,
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() => _currentIndex = index);
        if (index == 0) {
          _loadData();
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
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
              icon: const Icon(Icons.add_location_alt),
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
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Card
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                backgroundImage: _profilePicture != null
                                    ? FileImage(File(_profilePicture!))
                                    : null,
                                child: _profilePicture == null
                                    ? Text(
                                        _userName.isNotEmpty
                                            ? _userName[0].toUpperCase()
                                            : 'S',
                                        style: const TextStyle(
                                          fontSize: 28,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome back!',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Colors.grey[600],
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _userName.isNotEmpty
                                          ? _userName
                                          : 'Student',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 8),
                          _buildInfoRow(Icons.badge, 'USN', _userUsn),
                          const SizedBox(height: 8),
                          _buildInfoRow(Icons.email, 'Email', _userEmail),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Overall Attendance Summary
                  _buildOverallAttendance(),
                  const SizedBox(height: 24),

                  // Subjects Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My Subjects',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        '${_subjects.length} subjects',
                        style:
                            Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Subject Cards
                  if (_subjects.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.book_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No subjects found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _subjects.length,
                      itemBuilder: (context, index) {
                        final subject = _subjects[index];
                        final percentage =
                            _attendancePercentages[subject['id']] ?? 0.0;
                        return _buildSubjectCard(subject, percentage);
                      },
                    ),
                ],
              ),
            ),
          );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildOverallAttendance() {
    if (_attendancePercentages.isEmpty) return const SizedBox.shrink();

    final avgAttendance = _attendancePercentages.values.reduce((a, b) => a + b) /
        _attendancePercentages.length;

    Color getAttendanceColor(double percentage) {
      if (percentage >= 75) return Colors.green;
      if (percentage >= 60) return Colors.orange;
      return Colors.red;
    }

    return Card(
      elevation: 3,
      color: getAttendanceColor(avgAttendance).withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: getAttendanceColor(avgAttendance).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.analytics,
                size: 32,
                color: getAttendanceColor(avgAttendance),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overall Attendance',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${avgAttendance.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: getAttendanceColor(avgAttendance),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectCard(Map<String, dynamic> subject, double percentage) {
    Color getAttendanceColor(double percentage) {
      if (percentage >= 75) return Colors.green;
      if (percentage >= 60) return Colors.orange;
      return Colors.red;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () {
          _showSubjectDetails(subject, percentage);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.book,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject['name'],
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${subject['code']} • ${subject['facultyName']}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Attendance',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: percentage / 100,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            getAttendanceColor(percentage),
                          ),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: getAttendanceColor(percentage),
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSubjectDetails(Map<String, dynamic> subject, double percentage) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                subject['name'],
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                subject['code'],
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 24),
              _buildDetailRow('Faculty', subject['facultyName']),
              const Divider(height: 24),
              _buildDetailRow('Total Classes', '${subject['totalClasses']}'),
              const Divider(height: 24),
              _buildDetailRow(
                  'Attendance', '${percentage.toStringAsFixed(1)}%'),
              const SizedBox(height: 24),
              FilledButton.icon(
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
                icon: const Icon(Icons.history),
                label: const Text('View Attendance History'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
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
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
