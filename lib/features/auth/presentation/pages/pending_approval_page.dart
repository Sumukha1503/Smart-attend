import 'package:flutter/material.dart';
import '../../../../core/services/approval_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/constants/app_routes.dart';
import '../../data/models/device_approval_request_model.dart';

class PendingApprovalPage extends StatefulWidget {
  const PendingApprovalPage({super.key});

  @override
  State<PendingApprovalPage> createState() => _PendingApprovalPageState();
}

class _PendingApprovalPageState extends State<PendingApprovalPage> {
  final ApprovalService _approvalService = ApprovalService();
  final AuthService _authService = AuthService();
  DeviceApprovalRequest? _request;
  bool _isLoading = true;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _loadRequest();
    _startPeriodicCheck();
  }

  Future<void> _loadRequest() async {
    setState(() => _isLoading = true);
    
    final user = await _authService.getCurrentUser();
    if (user != null) {
      final requests = await _approvalService.getAllApprovalRequests();
      final userRequests = requests.where((r) => r['studentId'] == user.id).toList();
      
      if (userRequests.isNotEmpty) {
        _request = DeviceApprovalRequest.fromJson(userRequests.last);
      }
    }
    
    setState(() => _isLoading = false);
  }

  void _startPeriodicCheck() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _checkApprovalStatus();
      }
    });
  }

  Future<void> _checkApprovalStatus() async {
    if (_isChecking || !mounted) return;
    
    setState(() => _isChecking = true);
    
    await _loadRequest();
    
    if (_request?.status == 'approved') {
      // Approval granted, navigate to home
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.studentHome);
      }
    } else if (_request?.status == 'rejected') {
      // Show rejection message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your login request was rejected by HOD'),
            backgroundColor: Colors.red,
          ),
        );
        await _authService.logout();
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    } else {
      // Still pending, check again after 5 seconds
      _startPeriodicCheck();
    }
    
    setState(() => _isChecking = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated waiting icon
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(seconds: 2),
                      builder: (context, double value, child) {
                        return Transform.scale(
                          scale: 0.8 + (value * 0.2),
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.hourglass_empty,
                              size: 80,
                              color: Colors.orange,
                            ),
                          ),
                        );
                      },
                      onEnd: () {
                        if (mounted) {
                          setState(() {});
                        }
                      },
                    ),
                    const SizedBox(height: 40),
                    
                    // Title
                    Text(
                      'Pending HOD Approval',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    
                    // Message
                    Text(
                      'Your login request has been sent to the HOD for approval.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    
                    // Info card
                    if (_request != null)
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow('Student Name', _request!.studentName),
                              const Divider(height: 24),
                              _buildInfoRow('USN', _request!.studentUsn),
                              const Divider(height: 24),
                              _buildInfoRow('Device', _request!.deviceInfo),
                              const Divider(height: 24),
                              _buildInfoRow(
                                'Requested At',
                                _formatDateTime(_request!.requestedAt),
                              ),
                              const Divider(height: 24),
                              Row(
                                children: [
                                  Text(
                                    'Status: ',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _request!.status.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.orange,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 32),
                    
                    // Checking status
                    if (_isChecking)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Checking approval status...',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    
                    const SizedBox(height: 32),
                    
                    // Logout button
                    OutlinedButton.icon(
                      onPressed: () async {
                        await _authService.logout();
                        if (mounted) {
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.login,
                          );
                        }
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Cancel & Logout'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
