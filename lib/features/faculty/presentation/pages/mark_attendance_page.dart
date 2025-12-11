import 'package:flutter/material.dart';

class MarkAttendancePage extends StatefulWidget {
  const MarkAttendancePage({super.key});

  @override
  State<MarkAttendancePage> createState() => _MarkAttendancePageState();
}

class _MarkAttendancePageState extends State<MarkAttendancePage> {
  // Dummy data
  final List<String> _courses = ['CS101 - Intro to CS', 'CS102 - Data Structures'];
  String? _selectedCourse;
  DateTime _selectedDate = DateTime.now();
  
  final List<Map<String, dynamic>> _students = [
    {'name': 'Rahul Sharma', 'usn': '1AB23CS001', 'isPresent': true},
    {'name': 'Priya Patel', 'usn': '1AB23CS002', 'isPresent': true},
    {'name': 'Amit Kumar', 'usn': '1AB23CS003', 'isPresent': false},
    {'name': 'Sneha Gupta', 'usn': '1AB23CS004', 'isPresent': true},
    {'name': 'Vikram Singh', 'usn': '1AB23CS005', 'isPresent': true},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Attendance'),
      ),
      body: Column(
        children: [
          // Filters
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Select Course',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedCourse,
                    items: _courses.map((course) {
                      return DropdownMenuItem(value: course, child: Text(course));
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedCourse = value),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2024),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() => _selectedDate = date);
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Student List
          Expanded(
            child: _selectedCourse == null
                ? const Center(child: Text('Please select a course'))
                : ListView.builder(
                    itemCount: _students.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final student = _students[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(student['name'][0]),
                          ),
                          title: Text(student['name']),
                          subtitle: Text(student['usn']),
                          trailing: Switch(
                            value: student['isPresent'],
                            activeColor: Colors.green,
                            onChanged: (value) {
                              setState(() {
                                student['isPresent'] = value;
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _selectedCourse != null
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: FilledButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Attendance submitted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Submit Attendance'),
              ),
            )
          : null,
    );
  }
}
