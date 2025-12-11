import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/demo_data_service.dart';
import 'package:intl/intl.dart';

class AttendanceHistoryPage extends StatefulWidget {
  const AttendanceHistoryPage({super.key});

  @override
  State<AttendanceHistoryPage> createState() => _AttendanceHistoryPageState();
}

class _AttendanceHistoryPageState extends State<AttendanceHistoryPage> {
  final AuthService _authService = AuthService();
  final DemoDataService _demoDataService = DemoDataService();
  
  List<Map<String, dynamic>> _records = [];
  bool _isLoading = true;
  String _subjectName = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _subjectName = args['subjectName'] ?? 'Attendance History';
      _loadHistory(args['subjectId']);
    }
  }

  Future<void> _loadHistory(String subjectId) async {
    setState(() => _isLoading = true);
    final user = await _authService.getCurrentUser();
    if (user != null) {
      final allRecords = await _demoDataService.getStudentAttendance(user.id);
      // Filter by subject
      final subjectRecords = allRecords.where((r) => r['subjectId'] == subjectId).toList();
      
      // Sort by date descending
      subjectRecords.sort((a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));
      
      setState(() {
        _records = subjectRecords;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_subjectName)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _records.isEmpty
              ? const Center(child: Text('No attendance records found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _records.length,
                  itemBuilder: (context, index) {
                    final record = _records[index];
                    final date = DateTime.parse(record['date']);
                    final isPresent = record['isPresent'] == true;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isPresent ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          child: Icon(
                            isPresent ? Icons.check : Icons.close,
                            color: isPresent ? Colors.green : Colors.red,
                          ),
                        ),
                        title: Text(
                          DateFormat('EEEE, MMM d, yyyy').format(date),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(isPresent ? 'Present' : 'Absent'),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isPresent ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isPresent ? 'Present' : 'Absent',
                            style: TextStyle(
                              color: isPresent ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
