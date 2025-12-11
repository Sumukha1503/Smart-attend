import 'package:flutter/material.dart';
import 'dart:io';
import '../../../../core/services/auth_service.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/bottom_nav_scaffold.dart';
import '../../presentation/pages/hod_profile_page.dart';
import '../../../common/presentation/pages/notifications_page.dart';

class HodDashboard extends StatefulWidget {
  const HodDashboard({super.key});

  @override
  State<HodDashboard> createState() => _HodDashboardState();
}

class _HodDashboardState extends State<HodDashboard> {
  int _currentIndex = 0;
  final AuthService _authService = AuthService();
  String _userName = '';
  String _userEmail = '';
  String? _profilePicture;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await _authService.getCurrentUser();
    if (user != null) {
      setState(() {
        _userName = user.name;
        _userEmail = user.email;
        _profilePicture = user.profilePicture;
      });
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.logout();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _buildHomeContent(),
      const HodProfilePage(),
      const NotificationsPage(),
    ];

    return BottomNavScaffold(
      title: _currentIndex == 0 ? 'HOD Dashboard' : null,
      actions: _currentIndex == 0
          ? [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: _handleLogout,
                tooltip: 'Logout',
              ),
            ]
          : null,
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() => _currentIndex = index);
        if (index == 0) {
          _loadUserData();
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
      ],
      body: tabs[_currentIndex],
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    backgroundImage: _profilePicture != null
                        ? FileImage(File(_profilePicture!))
                        : null,
                    child: _profilePicture == null
                        ? Text(
                            _userName.isNotEmpty ? _userName[0].toUpperCase() : 'H',
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
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
                          'Welcome back!',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _userName.isNotEmpty ? _userName : 'HOD',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _userEmail,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Quick Actions
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.95,
            children: [
              _buildActionCard(
                context,
                icon: Icons.approval,
                title: 'Approvals',
                subtitle: 'Pending requests',
                color: Colors.blue,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.approvalRequests);
                },
              ),
              _buildActionCard(
                context,
                icon: Icons.people,
                title: 'Faculty',
                subtitle: 'Manage faculty',
                color: Colors.green,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.manageFaculty);
                },
              ),
              _buildActionCard(
                context,
                icon: Icons.school,
                title: 'Students',
                subtitle: 'Manage students',
                color: Colors.orange,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.manageStudents);
                },
              ),
              _buildActionCard(
                context,
                icon: Icons.assignment_ind,
                title: 'Course Assign',
                subtitle: 'Assign faculty',
                color: Colors.teal,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.courseAssignment);
                },
              ),
              _buildActionCard(
                context,
                icon: Icons.bar_chart,
                title: 'Analytics',
                subtitle: 'View insights',
                color: Colors.purple,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.analyticsDashboard);
                },
              ),
              _buildActionCard(
                context,
                icon: Icons.calendar_today,
                title: 'Calendar',
                subtitle: 'Attendance view',
                color: Colors.indigo,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.attendanceCalendar);
                },
              ),
              _buildActionCard(
                context,
                icon: Icons.psychology,
                title: 'AI Predictions',
                subtitle: 'Smart insights',
                color: Colors.deepPurple,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.aiPredictions);
                },
              ),
              _buildActionCard(
                context,
                icon: Icons.fingerprint,
                title: 'Biometric',
                subtitle: 'Security setup',
                color: Colors.cyan,
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.biometricSetup);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
