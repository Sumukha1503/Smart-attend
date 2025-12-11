import 'package:flutter/material.dart';
import '../../../../core/services/demo_data_service.dart';
import '../../../../core/services/auth_service.dart';

class ManageStudentsPage extends StatefulWidget {
  const ManageStudentsPage({super.key});

  @override
  State<ManageStudentsPage> createState() => _ManageStudentsPageState();
}

class _ManageStudentsPageState extends State<ManageStudentsPage> {
  final DemoDataService _demoDataService = DemoDataService();
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> _students = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);
    final students = await _demoDataService.getStudents();
    setState(() {
      _students = students;
      _isLoading = false;
    });
  }

  Future<void> _deleteStudent(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: const Text('Are you sure you want to delete this student?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _demoDataService.deleteUser(id);
      _loadStudents();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student deleted successfully')),
        );
      }
    }
  }

  void _showAddDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final usnController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String selectedDepartment = 'CSE';
    final List<String> departments = ['CSE', 'ECE', 'MECH', 'CIVIL', 'EEE'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Student'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: usnController,
                  decoration: const InputDecoration(labelText: 'USN'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                DropdownButtonFormField<String>(
                  value: selectedDepartment,
                  decoration: const InputDecoration(labelText: 'Department'),
                  items: departments.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                  onChanged: (v) => setState(() => selectedDepartment = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final result = await _authService.register(
                    name: nameController.text,
                    email: emailController.text,
                    password: 'password123', // Default password
                    role: 'Student',
                    usn: usnController.text,
                    department: selectedDepartment,
                  );

                  if (mounted) {
                    Navigator.pop(context);
                    if (result['success']) {
                      _loadStudents();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Student added successfully')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(result['message'])),
                      );
                    }
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Students')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _students.isEmpty
              ? const Center(child: Text('No students found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _students.length,
                  itemBuilder: (context, index) {
                    final student = _students[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(student['name'][0].toUpperCase()),
                        ),
                        title: Text(student['name']),
                        subtitle: Text('${student['usn']} • ${student['department'] ?? 'N/A'}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteStudent(student['id']),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
