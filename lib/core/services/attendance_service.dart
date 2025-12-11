import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance_record.dart';

/// Attendance Service
/// Manages attendance records in Firestore with real-time sync
class AttendanceService {
  static final AttendanceService _instance = AttendanceService._internal();
  factory AttendanceService() => _instance;
  AttendanceService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'attendance';

  /// Mark attendance for a student
  Future<void> markAttendance(AttendanceRecord record) async {
    try {
      await _firestore.collection(_collection).doc(record.id).set(record.toFirestore());
      print('✅ Attendance marked: ${record.studentName} - ${record.status.displayName}');
    } catch (e) {
      print('❌ Error marking attendance: $e');
      rethrow;
    }
  }

  /// Bulk mark attendance for multiple students
  Future<void> bulkMarkAttendance(List<AttendanceRecord> records) async {
    try {
      final batch = _firestore.batch();
      
      for (var record in records) {
        final docRef = _firestore.collection(_collection).doc(record.id);
        batch.set(docRef, record.toFirestore());
      }
      
      await batch.commit();
      print('✅ Bulk attendance marked: ${records.length} students');
    } catch (e) {
      print('❌ Error in bulk marking: $e');
      rethrow;
    }
  }

  /// Get attendance for a specific session
  Future<List<AttendanceRecord>> getSessionAttendance(String sessionId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('sessionId', isEqualTo: sessionId)
          .get();

      return snapshot.docs
          .map((doc) => AttendanceRecord.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      print('❌ Error fetching session attendance: $e');
      return [];
    }
  }

  /// Get attendance for a student in a course
  Future<List<AttendanceRecord>> getStudentCourseAttendance({
    required String studentId,
    required String courseId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('studentId', isEqualTo: studentId)
          .where('courseId', isEqualTo: courseId)
          .orderBy('markedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => AttendanceRecord.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      print('❌ Error fetching student course attendance: $e');
      return [];
    }
  }

  /// Get all attendance for a student
  Future<List<AttendanceRecord>> getStudentAttendance(String studentId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('studentId', isEqualTo: studentId)
          .orderBy('markedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => AttendanceRecord.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      print('❌ Error fetching student attendance: $e');
      return [];
    }
  }

  /// Get attendance stream for real-time updates
  Stream<List<AttendanceRecord>> getAttendanceStream({
    String? studentId,
    String? courseId,
    String? sessionId,
  }) {
    Query query = _firestore.collection(_collection);

    if (studentId != null) {
      query = query.where('studentId', isEqualTo: studentId);
    }
    if (courseId != null) {
      query = query.where('courseId', isEqualTo: courseId);
    }
    if (sessionId != null) {
      query = query.where('sessionId', isEqualTo: sessionId);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => AttendanceRecord.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  /// Calculate attendance percentage for a student in a course
  Future<Map<String, dynamic>> calculateAttendancePercentage({
    required String studentId,
    required String courseId,
  }) async {
    try {
      final records = await getStudentCourseAttendance(
        studentId: studentId,
        courseId: courseId,
      );

      int present = 0;
      int absent = 0;
      int late = 0;
      int onDuty = 0;
      int leave = 0;

      for (var record in records) {
        switch (record.status) {
          case AttendanceStatus.present:
            present++;
            break;
          case AttendanceStatus.absent:
            absent++;
            break;
          case AttendanceStatus.late:
            late++;
            break;
          case AttendanceStatus.onDuty:
            onDuty++;
            break;
          case AttendanceStatus.leave:
            leave++;
            break;
        }
      }

      final total = present + absent + late + onDuty + leave;
      final percentage = total > 0 ? (present / total) * 100 : 0.0;

      return {
        'present': present,
        'absent': absent,
        'late': late,
        'onDuty': onDuty,
        'leave': leave,
        'total': total,
        'percentage': percentage,
        'status': _getAttendanceStatus(percentage),
      };
    } catch (e) {
      print('❌ Error calculating attendance: $e');
      return {
        'present': 0,
        'absent': 0,
        'late': 0,
        'onDuty': 0,
        'leave': 0,
        'total': 0,
        'percentage': 0.0,
        'status': 'unknown',
      };
    }
  }

  /// Get attendance status based on percentage
  String _getAttendanceStatus(double percentage) {
    if (percentage >= 85) return 'excellent';
    if (percentage >= 75) return 'good';
    if (percentage >= 65) return 'warning';
    return 'critical';
  }

  /// Get attendance summary for all courses of a student
  Future<Map<String, Map<String, dynamic>>> getStudentAttendanceSummary(
    String studentId,
    List<String> courseIds,
  ) async {
    final summary = <String, Map<String, dynamic>>{};

    for (var courseId in courseIds) {
      summary[courseId] = await calculateAttendancePercentage(
        studentId: studentId,
        courseId: courseId,
      );
    }

    return summary;
  }

  /// Update attendance record
  Future<void> updateAttendance({
    required String attendanceId,
    required AttendanceStatus newStatus,
    required String modifiedBy,
    String? remarks,
  }) async {
    try {
      await _firestore.collection(_collection).doc(attendanceId).update({
        'status': newStatus.name,
        'modifiedAt': DateTime.now().toIso8601String(),
        'modifiedBy': modifiedBy,
        if (remarks != null) 'remarks': remarks,
      });
      print('✅ Attendance updated: $attendanceId');
    } catch (e) {
      print('❌ Error updating attendance: $e');
      rethrow;
    }
  }

  /// Delete attendance record
  Future<void> deleteAttendance(String attendanceId) async {
    try {
      await _firestore.collection(_collection).doc(attendanceId).delete();
      print('✅ Attendance deleted: $attendanceId');
    } catch (e) {
      print('❌ Error deleting attendance: $e');
      rethrow;
    }
  }

  /// Get attendance for a date range
  Future<List<AttendanceRecord>> getAttendanceByDateRange({
    required String studentId,
    required DateTime startDate,
    required DateTime endDate,
    String? courseId,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('studentId', isEqualTo: studentId)
          .where('markedAt', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('markedAt', isLessThanOrEqualTo: endDate.toIso8601String());

      if (courseId != null) {
        query = query.where('courseId', isEqualTo: courseId);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => AttendanceRecord.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Error fetching attendance by date range: $e');
      return [];
    }
  }

  /// Get students with low attendance (below threshold)
  Future<List<Map<String, dynamic>>> getLowAttendanceStudents({
    required String courseId,
    double threshold = 75.0,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('courseId', isEqualTo: courseId)
          .get();

      // Group by student
      final studentAttendance = <String, Map<String, dynamic>>{};

      for (var doc in snapshot.docs) {
        final record = AttendanceRecord.fromFirestore(doc.data());
        final studentId = record.studentId;

        if (!studentAttendance.containsKey(studentId)) {
          studentAttendance[studentId] = {
            'studentId': studentId,
            'studentName': record.studentName,
            'studentUsn': record.studentUsn,
            'present': 0,
            'total': 0,
          };
        }

        studentAttendance[studentId]!['total']++;
        if (record.status == AttendanceStatus.present) {
          studentAttendance[studentId]!['present']++;
        }
      }

      // Calculate percentages and filter
      final lowAttendance = <Map<String, dynamic>>[];

      studentAttendance.forEach((studentId, data) {
        final percentage = (data['present'] / data['total']) * 100;
        if (percentage < threshold) {
          lowAttendance.add({
            ...data,
            'percentage': percentage,
          });
        }
      });

      // Sort by percentage (lowest first)
      lowAttendance.sort((a, b) => a['percentage'].compareTo(b['percentage']));

      return lowAttendance;
    } catch (e) {
      print('❌ Error fetching low attendance students: $e');
      return [];
    }
  }

  /// Calculate classes needed to reach target percentage
  int calculateClassesNeeded({
    required int present,
    required int total,
    required double targetPercentage,
  }) {
    if (total == 0) return 0;

    final currentPercentage = (present / total) * 100;
    if (currentPercentage >= targetPercentage) return 0;

    // Formula: (present + x) / (total + x) = target/100
    // Solving for x: x = (target * total - 100 * present) / (100 - target)
    final x = (targetPercentage * total - 100 * present) / (100 - targetPercentage);

    return x.ceil();
  }

  /// Get attendance calendar data (for calendar view)
  Future<Map<DateTime, AttendanceStatus>> getAttendanceCalendar({
    required String studentId,
    required String courseId,
    required DateTime month,
  }) async {
    try {
      final startDate = DateTime(month.year, month.month, 1);
      final endDate = DateTime(month.year, month.month + 1, 0);

      final records = await getAttendanceByDateRange(
        studentId: studentId,
        startDate: startDate,
        endDate: endDate,
        courseId: courseId,
      );

      final calendar = <DateTime, AttendanceStatus>{};

      for (var record in records) {
        final date = DateTime(
          record.markedAt.year,
          record.markedAt.month,
          record.markedAt.day,
        );
        calendar[date] = record.status;
      }

      return calendar;
    } catch (e) {
      print('❌ Error fetching attendance calendar: $e');
      return {};
    }
  }
}
