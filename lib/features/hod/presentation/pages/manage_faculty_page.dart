import 'package:flutter/material.dart';
import '../../../../core/services/demo_data_service.dart';
import '../../../../core/services/auth_service.dart';

class ManageFacultyPage extends StatefulWidget {
  const ManageFacultyPage({super.key});

  @override
  State<ManageFacultyPage> createState() => _ManageFacultyPageState();
}

class _ManageFacultyPageState extends State<ManageFacultyPage> {
  final DemoDataService _demoDataService = DemoDataService();
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> _faculty = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFaculty();
  }

  Future<void> _loadFaculty() async {
    setState(() => _isLoading = true);
    final faculty = await _demoDataService.getFaculty();
    setState(() {
      _faculty = faculty;
      _isLoading = false;
    });
  }

  Future<void> _deleteFaculty(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Faculty'),
        content: const Text('Are you sure you want to delete this faculty member?'),
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
      _loadFaculty();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Faculty deleted successfully')),
        );
      }
    }
  }

  void _showAddDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final idController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Faculty'),
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
                controller: idController,
                decoration: const InputDecoration(labelText: 'Employee ID'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
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
                  role: 'Faculty',
                  employeeId: idController.text,
                );

                if (mounted) {
                  Navigator.pop(context);
                  if (result['success']) {
                    _loadFaculty();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Faculty added successfully')),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Faculty')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _faculty.isEmpty
              ? const Center(child: Text('No faculty found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _faculty.length,
                  itemBuilder: (context, index) {
                    final fac = _faculty[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(fac['name'][0].toUpperCase()),
                        ),
                        title: Text(fac['name']),
                        subtitle: Text('${fac['employeeId']} • ${fac['email']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteFaculty(fac['id']),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
