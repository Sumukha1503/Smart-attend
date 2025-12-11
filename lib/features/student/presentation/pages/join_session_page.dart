import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../../../../core/services/demo_data_service.dart';

class JoinSessionPage extends StatefulWidget {
  const JoinSessionPage({super.key});

  @override
  State<JoinSessionPage> createState() => _JoinSessionPageState();
}

class _JoinSessionPageState extends State<JoinSessionPage> {
  final DemoDataService _demoDataService = DemoDataService();
  bool _isMarking = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Refresh countdown every second
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _markAttendance(Map<String, dynamic> session) async {
    setState(() => _isMarking = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permissions are denied';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Permission Required'),
              content: const Text('Location permission is required to mark attendance. Please enable it in settings.'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Geolocator.openAppSettings();
                  },
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition();

      // Calculate distance
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        session['latitude'],
        session['longitude'],
      );

      if (distance <= session['radius']) {
        // Mark attendance (dummy success for now)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Attendance marked successfully!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ You are too far! Distance: ${distance.round()}m (Max: ${session['radius'].round()}m)'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isMarking = false);
    }
  }

  String _formatTime(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'N/A';
    }
  }

  String _getTimeRemaining(String expiresAtString) {
    try {
      final expiresAt = DateTime.parse(expiresAtString);
      final now = DateTime.now();
      final diff = expiresAt.difference(now);
      
      if (diff.isNegative) return 'Expired';
      
      final minutes = diff.inMinutes;
      final seconds = diff.inSeconds % 60;
      return '${minutes}m ${seconds}s';
    } catch (e) {
      return 'N/A';
    }
  }

  Color _getTimeColor(String expiresAtString) {
    try {
      final expiresAt = DateTime.parse(expiresAtString);
      final now = DateTime.now();
      final diff = expiresAt.difference(now);
      
      if (diff.inSeconds < 30) return Colors.red;
      if (diff.inSeconds < 60) return Colors.orange;
      return Colors.green;
    } catch (e) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Session'),
        actions: [
          // Firebase indicator
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('Live', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _demoDataService.getActiveSessionsStream(),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Connecting to sessions...'),
                ],
              ),
            );
          }

          // Error state
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading sessions',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: TextStyle(color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => setState(() {}),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // No data or empty list
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No active sessions',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Waiting for faculty to create a session...',
                    style: TextStyle(color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  const CircularProgressIndicator(),
                  const SizedBox(height: 8),
                  Text(
                    'Listening for new sessions',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          // Display sessions
          final sessions = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {}); // Trigger rebuild
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                final timeRemaining = _getTimeRemaining(session['expiresAt'] ?? session['createdAt']);
                final timeColor = _getTimeColor(session['expiresAt'] ?? session['createdAt']);
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        session['courseCode']?.substring(0, 2).toUpperCase() ?? 'CS',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      session['courseName'] ?? 'Unknown Course',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Faculty: ${session['facultyName'] ?? 'Unknown'}'),
                        Text('Started: ${_formatTime(session['createdAt'])}'),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.timer, size: 16, color: timeColor),
                            const SizedBox(width: 4),
                            Text(
                              'Expires in: $timeRemaining',
                              style: TextStyle(
                                color: timeColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: _isMarking
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : FilledButton(
                            onPressed: () => _markAttendance(session),
                            child: const Text('Mark Present'),
                          ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
