import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../../../../core/services/demo_data_service.dart';
import '../../../../core/services/auth_service.dart';

class CreateGeoSessionPage extends StatefulWidget {
  const CreateGeoSessionPage({super.key});

  @override
  State<CreateGeoSessionPage> createState() => _CreateGeoSessionPageState();
}

class _CreateGeoSessionPageState extends State<CreateGeoSessionPage> {
  final DemoDataService _demoDataService = DemoDataService();
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> _courses = [];
  String? _selectedCourseId;
  double _radius = 50.0;
  bool _isSessionActive = false;
  bool _isLoading = false;
  bool _isLoadingCourses = true;
  Timer? _timer;
  int _remainingSeconds = 120; // 2 minutes

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() => _isLoadingCourses = true);
    final user = await _authService.getCurrentUser();
    if (user != null) {
      final allCourses = await _demoDataService.getSubjects();
      setState(() {
        _courses = allCourses.where((c) => c['facultyId'] == user.id).toList();
        _isLoadingCourses = false;
      });
    } else {
      setState(() => _isLoadingCourses = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _startSession() async {
    if (_selectedCourseId == null) return;

    setState(() => _isLoading = true);

    try {
      // Show immediate feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
                SizedBox(width: 12),
                Text('Getting location...'),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }

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
              content: const Text('Location permission is required to create a session. Please enable it in settings.'),
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
        setState(() => _isLoading = false);
        return;
      }

      // Get location with timeout
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10), // Add 10 second timeout
      );
      
      // Find the selected course
      final selectedCourse = _courses.firstWhere((c) => c['id'] == _selectedCourseId);
      
      // Get current user for faculty info
      final user = await _authService.getCurrentUser();

      final session = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'courseId': selectedCourse['id'],
        'courseName': '${selectedCourse['code']} - ${selectedCourse['name']}',
        'courseCode': selectedCourse['code'],
        'facultyId': user?.id ?? 'unknown',
        'facultyName': user?.name ?? 'Unknown Faculty',
        'latitude': position.latitude,
        'longitude': position.longitude,
        'radius': _radius,
        'createdAt': DateTime.now().toIso8601String(),
        'expiresAt': DateTime.now().add(const Duration(minutes: 2)).toIso8601String(),
        'isActive': true,
      };

      await _demoDataService.createSession(session);

      setState(() {
        _isSessionActive = true;
        _isLoading = false;
        _remainingSeconds = 120;
      });

      _startTimer();
      
      // Show success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text('Session started for ${selectedCourse['code']}'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on TimeoutException {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⏱️ Location request timed out. Please try again.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _stopSession();
      }
    });
  }

  void _stopSession() {
    _timer?.cancel();
    setState(() {
      _isSessionActive = false;
      _remainingSeconds = 120;
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Session')),
      body: _isLoadingCourses
          ? const Center(child: CircularProgressIndicator())
          : _courses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_late, size: 80, color: Colors.orange[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No Courses Assigned',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.grey[800],
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          'You are not assigned to any courses yet.',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey[600],
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 32),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue.shade700, size: 32),
                            const SizedBox(height: 8),
                            Text(
                              'What to do?',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.blue.shade900,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Please contact your HOD to assign you to courses. Once assigned, you can create sessions here.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.blue.shade800,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Go Back'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Session Details', style: Theme.of(context).textTheme.titleLarge),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                decoration: const InputDecoration(
                                  labelText: 'Select Course',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.book),
                                ),
                                value: _selectedCourseId,
                                items: _courses.map((course) {
                                  return DropdownMenuItem<String>(
                                    value: course['id'],
                                    child: Text('${course['code']} - ${course['name']}'),
                                  );
                                }).toList(),
                                onChanged: _isSessionActive ? null : (value) => setState(() => _selectedCourseId = value),
                              ),
                              const SizedBox(height: 16),
                              Text('Geofence Radius: ${_radius.round()} meters'),
                              Slider(
                                value: _radius,
                                min: 10,
                                max: 100,
                                divisions: 9,
                                label: '${_radius.round()}m',
                                onChanged: _isSessionActive ? null : (value) => setState(() => _radius = value),
                              ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_isSessionActive)
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const Icon(Icons.location_on, size: 64, color: Colors.green),
                      const SizedBox(height: 16),
                      Text(
                        'Session Active',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Time Remaining: ${_formatTime(_remainingSeconds)}',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('Students can now mark attendance within range.'),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _selectedCourseId == null || _isLoading
                  ? null
                  : () {
                      if (_isSessionActive) {
                        _stopSession();
                      } else {
                        _startSession();
                      }
                    },
              icon: _isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Icon(_isSessionActive ? Icons.stop : Icons.play_arrow),
              label: Text(_isSessionActive ? 'Stop Session' : 'Start Session'),
              style: FilledButton.styleFrom(
                backgroundColor: _isSessionActive ? Colors.red : null,
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
