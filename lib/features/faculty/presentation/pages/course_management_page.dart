import 'package:flutter/material.dart';
import '../../../../core/services/demo_data_service.dart';
import '../../../../core/services/auth_service.dart';

class CourseManagementPage extends StatefulWidget {
  const CourseManagementPage({super.key});

  @override
  State<CourseManagementPage> createState() => _CourseManagementPageState();
}

class _CourseManagementPageState extends State<CourseManagementPage> {
  final DemoDataService _demoDataService = DemoDataService();
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> _courses = [];
  List<Map<String, dynamic>> _myCourses = [];
  bool _isLoading = true;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() => _isLoading = true);
    final user = await _authService.getCurrentUser();
    final courses = await _demoDataService.getSubjects();
    
    setState(() {
      _currentUserId = user?.id;
      _courses = courses;
      // Filter courses for current faculty
      _myCourses = courses.where((c) => c['facultyId'] == user?.id).toList();
      _isLoading = false;
    });
  }

  void _showAddCourseDialog() {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final semesterController = TextEditingController();
    final sectionController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Course'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Course Name',
                    hintText: 'e.g., Data Structures',
                    prefixIcon: Icon(Icons.book),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Course name is required' : null,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: codeController,
                  decoration: const InputDecoration(
                    labelText: 'Course Code',
                    hintText: 'e.g., CS201',
                    prefixIcon: Icon(Icons.tag),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Course code is required' : null,
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: semesterController,
                        decoration: const InputDecoration(
                          labelText: 'Semester',
                          hintText: 'e.g., 3',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          final sem = int.tryParse(v);
                          if (sem == null || sem < 1 || sem > 8) {
                            return 'Enter 1-8';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: sectionController,
                        decoration: const InputDecoration(
                          labelText: 'Section',
                          hintText: 'e.g., A',
                          prefixIcon: Icon(Icons.group),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        textCapitalization: TextCapitalization.characters,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final user = await _authService.getCurrentUser();
                if (user != null) {
                  await _demoDataService.addSubject({
                    'id': 'SUB${DateTime.now().millisecondsSinceEpoch}',
                    'name': nameController.text.trim(),
                    'code': codeController.text.trim().toUpperCase(),
                    'semester': int.parse(semesterController.text),
                    'section': sectionController.text.trim().toUpperCase(),
                    'facultyId': user.id,
                    'facultyName': user.name,
                    'totalClasses': 0,
                    'createdAt': DateTime.now().toIso8601String(),
                  });
                  if (mounted) {
                    Navigator.pop(context);
                    _loadCourses();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Course added successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Course'),
          ),
        ],
      ),
    );
  }

  void _showEditCourseDialog(Map<String, dynamic> course) {
    final nameController = TextEditingController(text: course['name']);
    final codeController = TextEditingController(text: course['code']);
    final semesterController = TextEditingController(text: course['semester']?.toString() ?? '');
    final sectionController = TextEditingController(text: course['section'] ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Course'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Course Name',
                    prefixIcon: Icon(Icons.book),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Course name is required' : null,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: codeController,
                  decoration: const InputDecoration(
                    labelText: 'Course Code',
                    prefixIcon: Icon(Icons.tag),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Course code is required' : null,
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: semesterController,
                        decoration: const InputDecoration(
                          labelText: 'Semester',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          final sem = int.tryParse(v);
                          if (sem == null || sem < 1 || sem > 8) {
                            return 'Enter 1-8';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: sectionController,
                        decoration: const InputDecoration(
                          labelText: 'Section',
                          prefixIcon: Icon(Icons.group),
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                        textCapitalization: TextCapitalization.characters,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                await _demoDataService.updateSubject(course['id'], {
                  'name': nameController.text.trim(),
                  'code': codeController.text.trim().toUpperCase(),
                  'semester': int.parse(semesterController.text),
                  'section': sectionController.text.trim().toUpperCase(),
                });
                if (mounted) {
                  Navigator.pop(context);
                  _loadCourses();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Course updated successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.save),
            label: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCourse(Map<String, dynamic> course) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Course'),
        content: Text('Are you sure you want to delete "${course['name']}"?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _demoDataService.deleteSubject(course['id']);
      if (mounted) {
        _loadCourses();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Course deleted successfully!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Courses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCourses,
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCourseDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Course'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _myCourses.isEmpty
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
                        'Add your first course to get started',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[500],
                            ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: _showAddCourseDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Course'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadCourses,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _myCourses.length,
                    itemBuilder: (context, index) {
                      final course = _myCourses[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            child: Text(
                              course['code'].toString().substring(0, 2).toUpperCase(),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            course['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('Code: ${course['code']}'),
                              if (course['semester'] != null && course['section'] != null)
                                Text('Semester ${course['semester']} - Section ${course['section']}'),
                              Text(
                                'Classes: ${course['totalClasses'] ?? 0}',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            icon: const Icon(Icons.more_vert),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 20),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, size: 20, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Delete', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showEditCourseDialog(course);
                              } else if (value == 'delete') {
                                _deleteCourse(course);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
