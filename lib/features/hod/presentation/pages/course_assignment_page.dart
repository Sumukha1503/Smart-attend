import 'package:flutter/material.dart';
import '../../../../core/services/demo_data_service.dart';
import '../../../../core/services/auth_service.dart';

class CourseAssignmentPage extends StatefulWidget {
  const CourseAssignmentPage({super.key});

  @override
  State<CourseAssignmentPage> createState() => _CourseAssignmentPageState();
}

class _CourseAssignmentPageState extends State<CourseAssignmentPage> {
  final DemoDataService _demoDataService = DemoDataService();
  final AuthService _authService = AuthService();
  
  List<Map<String, dynamic>> _courses = [];
  List<Map<String, dynamic>> _faculty = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final courses = await _demoDataService.getSubjects();
      final faculty = await _demoDataService.getFaculty();
      
      setState(() {
        _courses = courses;
        _faculty = faculty;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  Future<void> _assignFaculty(String courseId, String facultyId) async {
    try {
      final selectedFaculty = _faculty.firstWhere((f) => f['id'] == facultyId);
      
      await _demoDataService.updateSubject(courseId, {
        'facultyId': facultyId,
        'facultyName': selectedFaculty['name'],
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Faculty assigned successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      _loadData(); // Reload data
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error assigning faculty: $e')),
        );
      }
    }
  }

  Future<void> _showAssignDialog(Map<String, dynamic> course) async {
    String? selectedFacultyId = course['facultyId'];

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Assign Faculty to ${course['code']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                course['name'],
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              const Text('Select Faculty:'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedFacultyId,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                items: _faculty.map((faculty) {
                  return DropdownMenuItem<String>(
                    value: faculty['id'],
                    child: Text(faculty['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setDialogState(() => selectedFacultyId = value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: selectedFacultyId == null
                  ? null
                  : () {
                      Navigator.pop(context);
                      _assignFaculty(course['id'], selectedFacultyId!);
                    },
              child: const Text('Assign'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Assignments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _courses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.book_outlined, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No courses found',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add courses to assign faculty',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[500],
                            ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _courses.length,
                    itemBuilder: (context, index) {
                      final course = _courses[index];
                      final assignedFaculty = _faculty.firstWhere(
                        (f) => f['id'] == course['facultyId'],
                        orElse: () => {'name': 'Unassigned'},
                      );
                      final isAssigned = course['facultyId'] != null;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Leading Icon
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isAssigned
                                      ? Colors.green.withOpacity(0.1)
                                      : Colors.orange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  isAssigned ? Icons.check_circle : Icons.warning,
                                  color: isAssigned ? Colors.green : Colors.orange,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${course['code']} - ${course['name']}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.person,
                                          size: 16,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            assignedFaculty['name'],
                                            style: TextStyle(
                                              color: isAssigned
                                                  ? Colors.grey[700]
                                                  : Colors.orange[700],
                                              fontWeight: isAssigned
                                                  ? FontWeight.normal
                                                  : FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.school,
                                          size: 16,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Semester ${course['semester']} - Section ${course['section']}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    // Button moved below content
                                    SizedBox(
                                      width: double.infinity,
                                      child: FilledButton.icon(
                                        onPressed: () => _showAssignDialog(course),
                                        icon: Icon(
                                          isAssigned ? Icons.edit : Icons.add,
                                          size: 18,
                                        ),
                                        label: Text(isAssigned ? 'Change Faculty' : 'Assign Faculty'),
                                        style: FilledButton.styleFrom(
                                          backgroundColor:
                                              isAssigned ? Colors.blue : Colors.green,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
}
