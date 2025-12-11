import 'package:flutter/material.dart';
import '../../../../core/config/modern_theme.dart';
import '../../../../core/widgets/modern_widgets.dart';

/// Manage Active Session Page
/// Allows faculty to view and control active attendance sessions
class ManageSessionPage extends StatefulWidget {
  final Map<String, dynamic> session;
  
  const ManageSessionPage({
    super.key,
    required this.session,
  });

  @override
  State<ManageSessionPage> createState() => _ManageSessionPageState();
}

class _ManageSessionPageState extends State<ManageSessionPage> {
  late int _remainingSeconds;
  bool _isSessionActive = true;

  @override
  void initState() {
    super.initState();
    // Calculate remaining time
    final expiresAt = DateTime.parse(widget.session['expiresAt'] ?? DateTime.now().add(const Duration(minutes: 2)).toIso8601String());
    final diff = expiresAt.difference(DateTime.now());
    _remainingSeconds = diff.inSeconds > 0 ? diff.inSeconds : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernTheme.offWhite,
      appBar: AppBar(
        title: const Text('Manage Session'),
        backgroundColor: ModernTheme.pureWhite,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Session refreshed'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Session Status Card
            ModernCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: _isSessionActive ? ModernTheme.softEmerald : ModernTheme.rose,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (_isSessionActive ? ModernTheme.softEmerald : ModernTheme.rose).withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _isSessionActive ? 'SESSION ACTIVE' : 'SESSION ENDED',
                        style: ModernTheme.labelBold.copyWith(
                          color: _isSessionActive ? ModernTheme.softEmerald : ModernTheme.rose,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.session['courseName'] ?? 'Session',
                    style: ModernTheme.h2,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.session['courseCode'] ?? '',
                    style: ModernTheme.bodyMedium.copyWith(
                      color: ModernTheme.slateGrey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_isSessionActive) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: ModernTheme.softEmerald.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: ModernTheme.softEmerald.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Time Remaining',
                            style: ModernTheme.label,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formatTime(_remainingSeconds),
                            style: ModernTheme.h1.copyWith(
                              color: _remainingSeconds < 60 ? ModernTheme.rose : ModernTheme.softEmerald,
                              fontSize: 48,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Attendance Stats
            ModernCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Attendance Statistics', style: ModernTheme.h4),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          'Present',
                          '${widget.session['studentsPresent'] ?? 0}',
                          ModernTheme.softEmerald,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatItem(
                          'Total',
                          '${widget.session['totalStudents'] ?? 0}',
                          ModernTheme.royalBlue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatItem(
                          'Percentage',
                          '${_calculatePercentage()}%',
                          ModernTheme.deepIndigo,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Session Details
            ModernCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Session Details', style: ModernTheme.h4),
                  const SizedBox(height: 20),
                  _buildDetailRow('Session ID', widget.session['id'] ?? 'N/A'),
                  const Divider(height: 24),
                  _buildDetailRow('Faculty', widget.session['facultyName'] ?? 'N/A'),
                  const Divider(height: 24),
                  _buildDetailRow('Started', _getStartTime()),
                  const Divider(height: 24),
                  _buildDetailRow('Radius', '${widget.session['radius'] ?? 50}m'),
                  const Divider(height: 24),
                  _buildDetailRow(
                    'Location',
                    '${widget.session['latitude']?.toStringAsFixed(4) ?? 'N/A'}, ${widget.session['longitude']?.toStringAsFixed(4) ?? 'N/A'}',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Actions
            if (_isSessionActive) ...[
              ModernButton(
                label: 'End Session',
                icon: Icons.stop_circle_rounded,
                onPressed: _handleEndSession,
                backgroundColor: ModernTheme.rose,
                isFullWidth: true,
              ),
              const SizedBox(height: 12),
            ],
            
            ModernButton.outline(
              label: 'View Attendance List',
              icon: Icons.list_alt_rounded,
              onPressed: _showAttendanceList,
              isFullWidth: true,
            ),

            const SizedBox(height: 12),

            ModernButton.outline(
              label: 'Export Report',
              icon: Icons.download_rounded,
              onPressed: _exportReport,
              isFullWidth: true,
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showAttendanceList() {
    // Mock attendance data - in production, this would come from database
    final attendanceList = List.generate(
      widget.session['studentsPresent'] ?? 0,
      (index) => {
        'name': 'Student ${index + 1}',
        'rollNo': 'CS${(2001 + index).toString()}',
        'time': DateTime.now().subtract(Duration(minutes: index * 2)).toString().substring(11, 16),
        'status': 'Present',
      },
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: ModernTheme.pureWhite,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ModernTheme.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ModernTheme.softEmerald.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.people_rounded,
                      color: ModernTheme.softEmerald,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Attendance List', style: ModernTheme.h3),
                        const SizedBox(height: 4),
                        Text(
                          '${attendanceList.length} students present',
                          style: ModernTheme.caption,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Attendance list
            Expanded(
              child: attendanceList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: ModernTheme.lightSlateGrey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No students marked attendance yet',
                            style: ModernTheme.bodyMedium.copyWith(
                              color: ModernTheme.slateGrey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(24),
                      itemCount: attendanceList.length,
                      separatorBuilder: (context, index) => const Divider(height: 24),
                      itemBuilder: (context, index) {
                        final student = attendanceList[index];
                        return Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: ModernTheme.softEmerald.withOpacity(0.1),
                              child: Text(
                                student['name']![0],
                                style: ModernTheme.labelBold.copyWith(
                                  color: ModernTheme.softEmerald,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    student['name']!,
                                    style: ModernTheme.labelBold,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    student['rollNo']!,
                                    style: ModernTheme.caption,
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: ModernTheme.softEmerald.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    student['status']!,
                                    style: ModernTheme.caption.copyWith(
                                      color: ModernTheme.softEmerald,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  student['time']!,
                                  style: ModernTheme.caption,
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _exportReport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.download_rounded, color: ModernTheme.royalBlue),
            const SizedBox(width: 12),
            const Text('Export Report'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose export format:',
              style: ModernTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            
            // PDF Option
            InkWell(
              onTap: () {
                Navigator.pop(context);
                _handleExport('PDF');
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: ModernTheme.borderLight),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: ModernTheme.rose.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.picture_as_pdf,
                        color: ModernTheme.rose,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('PDF Document', style: ModernTheme.labelBold),
                          const SizedBox(height: 4),
                          Text(
                            'Formatted attendance report',
                            style: ModernTheme.caption,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: ModernTheme.lightSlateGrey,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Excel Option
            InkWell(
              onTap: () {
                Navigator.pop(context);
                _handleExport('Excel');
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: ModernTheme.borderLight),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: ModernTheme.softEmerald.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.table_chart,
                        color: ModernTheme.softEmerald,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Excel Spreadsheet', style: ModernTheme.labelBold),
                          const SizedBox(height: 4),
                          Text(
                            'Editable data format',
                            style: ModernTheme.caption,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: ModernTheme.lightSlateGrey,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _handleExport(String format) {
    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Text('Generating $format report...'),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );

    // Simulate export delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text('$format report exported successfully'),
              ],
            ),
            backgroundColor: ModernTheme.softEmerald,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Open',
              textColor: Colors.white,
              onPressed: () {
                // In production, this would open the file
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('File saved to Downloads folder'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ),
        );
      }
    });
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
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
        Flexible(
          child: Text(
            value,
            style: ModernTheme.labelBold,
            textAlign: TextAlign.end,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  int _calculatePercentage() {
    final present = widget.session['studentsPresent'] ?? 0;
    final total = widget.session['totalStudents'] ?? 1;
    if (total == 0) return 0;
    return ((present / total) * 100).round();
  }

  String _getStartTime() {
    try {
      final startTime = DateTime.parse(widget.session['createdAt'] ?? DateTime.now().toIso8601String());
      final diff = DateTime.now().difference(startTime);
      if (diff.inMinutes < 60) {
        return '${diff.inMinutes} minutes ago';
      } else if (diff.inHours < 24) {
        return '${diff.inHours} hours ago';
      } else {
        return '${diff.inDays} days ago';
      }
    } catch (e) {
      return 'N/A';
    }
  }

  void _handleEndSession() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Session'),
        content: const Text('Are you sure you want to end this session? Students will no longer be able to mark attendance.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isSessionActive = false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 12),
                      Text('Session ended successfully'),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
              // Navigate back after a delay
              Future.delayed(const Duration(seconds: 1), () {
                if (mounted) {
                  Navigator.pop(context);
                }
              });
            },
            style: FilledButton.styleFrom(
              backgroundColor: ModernTheme.rose,
            ),
            child: const Text('End Session'),
          ),
        ],
      ),
    );
  }
}
