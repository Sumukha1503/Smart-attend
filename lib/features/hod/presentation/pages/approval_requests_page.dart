import 'package:flutter/material.dart';
import '../../../../core/services/approval_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../auth/data/models/device_approval_request_model.dart';

class ApprovalRequestsPage extends StatefulWidget {
  const ApprovalRequestsPage({super.key});

  @override
  State<ApprovalRequestsPage> createState() => _ApprovalRequestsPageState();
}

class _ApprovalRequestsPageState extends State<ApprovalRequestsPage> {
  final ApprovalService _approvalService = ApprovalService();
  final AuthService _authService = AuthService();
  List<DeviceApprovalRequest> _pendingRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    
    final user = await _authService.getCurrentUser();
    final allRequests = await _approvalService.getPendingRequests();
    
    if (user != null) {
      _pendingRequests = allRequests.where((r) {
        // Filter by department if available
        if (user.department != null && r.department != null) {
          return user.department == r.department;
        }
        return true; // Show if department info is missing (legacy compatibility)
      }).toList();
    } else {
      _pendingRequests = [];
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _approveRequest(DeviceApprovalRequest request) async {
    final user = await _authService.getCurrentUser();
    if (user == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Request'),
        content: Text(
          'Approve login request for ${request.studentName} (${request.studentUsn})?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _approvalService.approveRequest(
        request.id,
        user.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Request approved successfully'
                  : 'Failed to approve request',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );

        if (success) {
          _loadRequests();
        }
      }
    }
  }

  Future<void> _rejectRequest(DeviceApprovalRequest request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Request'),
        content: Text(
          'Reject login request for ${request.studentName} (${request.studentUsn})?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _approvalService.rejectRequest(request.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Request rejected'
                  : 'Failed to reject request',
            ),
            backgroundColor: success ? Colors.orange : Colors.red,
          ),
        );

        if (success) {
          _loadRequests();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Approval Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRequests,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingRequests.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No pending requests',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadRequests,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _pendingRequests.length,
                    itemBuilder: (context, index) {
                      final request = _pendingRequests[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    child: Text(
                                      request.studentName[0].toUpperCase(),
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          request.studentName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          request.studentUsn,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              _buildInfoRow(
                                Icons.school,
                                'Department',
                                request.department ?? 'N/A',
                              ),
                              const SizedBox(height: 8),
                              _buildInfoRow(
                                Icons.phone_android,
                                'Device',
                                request.deviceInfo,
                              ),
                              const SizedBox(height: 8),
                              _buildInfoRow(
                                Icons.access_time,
                                'Requested',
                                _formatDateTime(request.requestedAt),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _rejectRequest(request),
                                      icon: const Icon(Icons.close),
                                      label: const Text('Reject'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: FilledButton.icon(
                                      onPressed: () => _approveRequest(request),
                                      icon: const Icon(Icons.check),
                                      label: const Text('Approve'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 13,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
