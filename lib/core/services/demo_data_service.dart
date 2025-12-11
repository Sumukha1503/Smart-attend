import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import '../services/storage_service.dart';
import '../services/firebase_session_service.dart';

class DemoDataService {
  // Singleton pattern
  static final DemoDataService _instance = DemoDataService._internal();
  
  factory DemoDataService() {
    return _instance;
  }
  
  DemoDataService._internal();
  
  final StorageService _storageService = StorageService();

  // Initialize demo data
  Future<void> initializeDemoData() async {
    final prefs = await SharedPreferences.getInstance();
    final isInitialized = prefs.getBool('demo_data_initialized') ?? false;

    if (!isInitialized) {
      await _createDemoUsers();
      await _createDemoSubjects();
      await _createDemoAttendance();
      await prefs.setBool('demo_data_initialized', true);
      print('Demo data initialized successfully!');
    }
  }

  Future<void> _createDemoUsers() async {
    // Demo Admin
    final admin = {
      'id': '4001',
      'name': 'System Administrator',
      'email': 'admin@smartattend.com',
      'username': 'admin123',
      'password': 'Admin@123',
      'role': 'Admin',
      'usn': null,
      'employeeId': null,
      'phone': null,
      'profilePicture': null,
      'createdAt': DateTime.now().toIso8601String(),
    };

    // Demo HOD
    final hod = {
      'id': '3001',
      'name': 'Dr. Ramesh Gupta',
      'email': 'ramesh@hod.com',
      'password': 'HOD@123',
      'role': 'HOD',
      'usn': null,
      'employeeId': 'HOD001',
      'phone': '+91 98765 43210',
      'profilePicture': null,
      'createdAt': DateTime.now().toIso8601String(),
    };

    // Demo Faculty
    final faculty = [
      {
        'id': '2001',
        'name': 'Dr. Suresh Reddy',
        'email': 'suresh@faculty.com',
        'password': 'Faculty@123',
        'role': 'Faculty',
        'usn': null,
        'employeeId': 'FAC001',
        'phone': '+91 98765 11111',
        'profilePicture': null,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': '2002',
        'name': 'Prof. Anjali Desai',
        'email': 'anjali@faculty.com',
        'password': 'Faculty@123',
        'role': 'Faculty',
        'usn': null,
        'employeeId': 'FAC002',
        'phone': '+91 98765 22222',
        'profilePicture': null,
        'createdAt': DateTime.now().toIso8601String(),
      },
    ];

    // Demo Students
    final students = [
      {
        'id': '1001',
        'name': 'Rahul Sharma',
        'email': 'rahul@student.com',
        'password': 'Student@123',
        'role': 'Student',
        'usn': '1AB23CS001',
        'employeeId': null,
        'phone': '+91 98765 00001',
        'profilePicture': null,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': '1002',
        'name': 'Priya Patel',
        'email': 'priya@student.com',
        'password': 'Student@123',
        'role': 'Student',
        'usn': '1AB23CS002',
        'employeeId': null,
        'phone': '+91 98765 00002',
        'profilePicture': null,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': '1003',
        'name': 'Amit Kumar',
        'email': 'amit@student.com',
        'password': 'Student@123',
        'role': 'Student',
        'usn': '1AB23CS003',
        'employeeId': null,
        'phone': '+91 98765 00003',
        'profilePicture': null,
        'createdAt': DateTime.now().toIso8601String(),
      },
    ];

    // Save all users
    await _storageService.saveUser(admin);
    await _storageService.saveUser(hod);
    for (var fac in faculty) {
      await _storageService.saveUser(fac);
    }
    for (var student in students) {
      await _storageService.saveUser(student);
    }
  }

  Future<void> _createDemoSubjects() async {
    final prefs = await SharedPreferences.getInstance();
    
    final subjects = [
      {
        'id': 'SUB001',
        'name': 'Data Structures',
        'code': 'CS201',
        'facultyId': '2001',
        'facultyName': 'Dr. Suresh Reddy',
        'semester': 3,
        'section': 'A',
        'totalClasses': 45,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'SUB002',
        'name': 'Database Management Systems',
        'code': 'CS202',
        'facultyId': '2002',
        'facultyName': 'Prof. Anjali Desai',
        'semester': 3,
        'section': 'A',
        'totalClasses': 40,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'SUB003',
        'name': 'Operating Systems',
        'code': 'CS203',
        'facultyId': '2001',
        'facultyName': 'Dr. Suresh Reddy',
        'semester': 3,
        'section': 'A',
        'totalClasses': 42,
        'createdAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'SUB004',
        'name': 'Computer Networks',
        'code': 'CS204',
        'facultyId': '2002',
        'facultyName': 'Prof. Anjali Desai',
        'semester': 3,
        'section': 'A',
        'totalClasses': 38,
        'createdAt': DateTime.now().toIso8601String(),
      },
    ];

    final subjectsJson = subjects.map((s) => jsonEncode(s)).toList();
    await prefs.setStringList('subjects', subjectsJson);
  }

  Future<void> _createDemoAttendance() async {
    final prefs = await SharedPreferences.getInstance();
    final attendanceRecords = <Map<String, dynamic>>[];

    final now = DateTime.now();
    final subjects = ['SUB001', 'SUB002', 'SUB003', 'SUB004'];
    final subjectNames = [
      'Data Structures',
      'Database Management Systems',
      'Operating Systems',
      'Computer Networks'
    ];
    final students = [
      {'id': '1001', 'name': 'Rahul Sharma', 'usn': '1AB23CS001'},
      {'id': '1002', 'name': 'Priya Patel', 'usn': '1AB23CS002'},
      {'id': '1003', 'name': 'Amit Kumar', 'usn': '1AB23CS003'},
    ];

    int recordId = 1;
    for (int day = 0; day < 10; day++) {
      final date = now.subtract(Duration(days: day));
      
      for (int subIndex = 0; subIndex < subjects.length; subIndex++) {
        for (var student in students) {
          final isPresent = (recordId % 5) != 0;
          
          attendanceRecords.add({
            'id': 'ATT${recordId.toString().padLeft(5, '0')}',
            'studentId': student['id'],
            'studentName': student['name'],
            'studentUsn': student['usn'],
            'subjectId': subjects[subIndex],
            'subjectName': subjectNames[subIndex],
            'date': DateTime(date.year, date.month, date.day).toIso8601String(),
            'isPresent': isPresent,
            'remarks': isPresent ? null : 'Absent',
          });
          
          recordId++;
        }
      }
    }

    final attendanceJson = attendanceRecords.map((a) => jsonEncode(a)).toList();
    await prefs.setStringList('attendance_records', attendanceJson);
  }

  Future<List<Map<String, dynamic>>> getSubjects() async {
    final prefs = await SharedPreferences.getInstance();
    final subjectsJson = prefs.getStringList('subjects') ?? [];
    return subjectsJson
        .map((s) => jsonDecode(s) as Map<String, dynamic>)
        .toList();
  }

  Future<List<Map<String, dynamic>>> getStudentAttendance(
      String studentId) async {
    final prefs = await SharedPreferences.getInstance();
    final attendanceJson = prefs.getStringList('attendance_records') ?? [];
    
    final allRecords = attendanceJson
        .map((a) => jsonDecode(a) as Map<String, dynamic>)
        .toList();
    
    return allRecords.where((record) => record['studentId'] == studentId).toList();
  }

  Future<double> getAttendancePercentage(
      String studentId, String subjectId) async {
    final records = await getStudentAttendance(studentId);
    final subjectRecords =
        records.where((r) => r['subjectId'] == subjectId).toList();
    
    if (subjectRecords.isEmpty) return 0.0;
    
    final presentCount =
        subjectRecords.where((r) => r['isPresent'] == true).length;
    return (presentCount / subjectRecords.length) * 100;
  }

  Future<List<Map<String, dynamic>>> getFaculty() async {
    final users = await _storageService.getAllUsers();
    return users.where((u) => u['role'] == 'Faculty').toList();
  }

  Future<List<Map<String, dynamic>>> getStudents() async {
    final users = await _storageService.getAllUsers();
    return users.where((u) => u['role'] == 'Student').toList();
  }

  Future<void> deleteUser(String userId) async {
    await _storageService.deleteUser(userId);
  }

  Future<void> addSubject(Map<String, dynamic> subject) async {
    final prefs = await SharedPreferences.getInstance();
    final subjects = await getSubjects();
    subjects.add(subject);
    final subjectsJson = subjects.map((s) => jsonEncode(s)).toList();
    await prefs.setStringList('subjects', subjectsJson);
  }

  Future<void> updateSubject(String subjectId, Map<String, dynamic> updates) async {
    final prefs = await SharedPreferences.getInstance();
    final subjects = await getSubjects();
    final index = subjects.indexWhere((s) => s['id'] == subjectId);
    
    if (index != -1) {
      // Merge updates with existing subject data
      subjects[index] = {...subjects[index], ...updates};
      final subjectsJson = subjects.map((s) => jsonEncode(s)).toList();
      await prefs.setStringList('subjects', subjectsJson);
    }
  }

  Future<void> deleteSubject(String subjectId) async {
    final prefs = await SharedPreferences.getInstance();
    final subjects = await getSubjects();
    subjects.removeWhere((s) => s['id'] == subjectId);
    final subjectsJson = subjects.map((s) => jsonEncode(s)).toList();
    await prefs.setStringList('subjects', subjectsJson);
  }


  // Active sessions - Firebase with SharedPreferences fallback
  bool _isFirebaseAvailable() {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> createSession(Map<String, dynamic> session) async {
    // Ensure expiresAt is set
    if (!session.containsKey('expiresAt')) {
      session['expiresAt'] = DateTime.now().add(const Duration(minutes: 2)).toIso8601String();
    }
    
    if (_isFirebaseAvailable()) {
      // Use Firebase for cross-device sync
      try {
        await FirebaseSessionService().createSession(session);
        print('✅ Session created in Firebase: ${session['courseName']}');
        return;
      } catch (e) {
        print('⚠️ Firebase failed, falling back to local storage: $e');
      }
    }
    
    // Fallback to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final sessions = await getActiveSessions();
    sessions.add(session);
    final sessionsJson = sessions.map((s) => jsonEncode(s)).toList();
    await prefs.setStringList('active_sessions', sessionsJson);
    print('📝 Session created locally: ${session['courseName']}');
  }

  /// Get active sessions as a Stream (real-time updates)
  /// 
  /// This is the KEY method for cross-device real-time sync!
  /// Use this in your UI with StreamBuilder for automatic updates.
  Stream<List<Map<String, dynamic>>> getActiveSessionsStream() {
    if (_isFirebaseAvailable()) {
      // Use Firebase for real-time cross-device sync
      try {
        return FirebaseSessionService().getActiveSessionsStream();
      } catch (e) {
        print('⚠️ Firebase stream failed: $e');
      }
    }
    
    // Fallback: Return a stream that emits local data periodically
    return Stream.periodic(const Duration(seconds: 2), (_) async {
      return await getActiveSessions();
    }).asyncMap((future) => future);
  }

  Future<List<Map<String, dynamic>>> getActiveSessions() async {
    if (_isFirebaseAvailable()) {
      // Use Firebase for cross-device sync
      try {
        final sessions = await FirebaseSessionService().getActiveSessions();
        print('✅ Sessions fetched from Firebase: ${sessions.length}');
        return sessions;
      } catch (e) {
        print('⚠️ Firebase failed, falling back to local storage: $e');
      }
    }
    
    // Fallback to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = prefs.getStringList('active_sessions') ?? [];
    
    // Parse sessions
    final allSessions = sessionsJson
        .map((s) => jsonDecode(s) as Map<String, dynamic>)
        .toList();
    
    // Filter out expired sessions (older than 2 minutes)
    final now = DateTime.now();
    final activeSessions = allSessions.where((s) {
      try {
        // Check expiresAt if available
        if (s.containsKey('expiresAt')) {
          final expiresAt = DateTime.parse(s['expiresAt']);
          return now.isBefore(expiresAt);
        }
        // Fallback to createdAt check
        final createdAt = DateTime.parse(s['createdAt']);
        return now.difference(createdAt).inMinutes < 2;
      } catch (e) {
        return false;
      }
    }).toList();
    
    // Save back the filtered list (remove expired sessions)
    if (activeSessions.length != allSessions.length) {
      final activeSessionsJson = activeSessions.map((s) => jsonEncode(s)).toList();
      await prefs.setStringList('active_sessions', activeSessionsJson);
    }
    
    print('📝 Sessions fetched locally: ${activeSessions.length}');
    return activeSessions;
  }

  Future<void> clearExpiredSessions() async {
    if (_isFirebaseAvailable()) {
      try {
        await FirebaseSessionService().cleanupExpiredSessions();
        return;
      } catch (e) {
        print('⚠️ Firebase cleanup failed: $e');
      }
    }
    // Local cleanup happens automatically in getActiveSessions()
    await getActiveSessions();
  }

  Future<void> resetDemoData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('demo_data_initialized');
    await prefs.remove('subjects');
    await prefs.remove('attendance_records');
    await prefs.remove('active_sessions');
    await _storageService.clearAll();
  }
}
