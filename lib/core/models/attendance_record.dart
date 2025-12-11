import 'package:cloud_firestore/cloud_firestore.dart';

/// Attendance Record Model
/// Represents a single attendance entry for a student in a session
class AttendanceRecord {
  final String id;
  final String sessionId;
  final String studentId;
  final String studentName;
  final String studentUsn;
  final String courseId;
  final String courseName;
  final String courseCode;
  final String facultyId;
  final String facultyName;
  final AttendanceStatus status;
  final DateTime markedAt;
  final String? markedBy;
  final Map<String, dynamic>? location;
  final Map<String, dynamic>? deviceInfo;
  final String? remarks;
  final DateTime? modifiedAt;
  final String? modifiedBy;

  AttendanceRecord({
    required this.id,
    required this.sessionId,
    required this.studentId,
    required this.studentName,
    required this.studentUsn,
    required this.courseId,
    required this.courseName,
    required this.courseCode,
    required this.facultyId,
    required this.facultyName,
    required this.status,
    required this.markedAt,
    this.markedBy,
    this.location,
    this.deviceInfo,
    this.remarks,
    this.modifiedAt,
    this.modifiedBy,
  });

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'sessionId': sessionId,
      'studentId': studentId,
      'studentName': studentName,
      'studentUsn': studentUsn,
      'courseId': courseId,
      'courseName': courseName,
      'courseCode': courseCode,
      'facultyId': facultyId,
      'facultyName': facultyName,
      'status': status.name,
      'markedAt': markedAt.toIso8601String(),
      'markedBy': markedBy,
      'location': location,
      'deviceInfo': deviceInfo,
      'remarks': remarks,
      'modifiedAt': modifiedAt?.toIso8601String(),
      'modifiedBy': modifiedBy,
    };
  }

  /// Create from Firestore document
  factory AttendanceRecord.fromFirestore(Map<String, dynamic> data) {
    return AttendanceRecord(
      id: data['id'] ?? '',
      sessionId: data['sessionId'] ?? '',
      studentId: data['studentId'] ?? '',
      studentName: data['studentName'] ?? '',
      studentUsn: data['studentUsn'] ?? '',
      courseId: data['courseId'] ?? '',
      courseName: data['courseName'] ?? '',
      courseCode: data['courseCode'] ?? '',
      facultyId: data['facultyId'] ?? '',
      facultyName: data['facultyName'] ?? '',
      status: AttendanceStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => AttendanceStatus.absent,
      ),
      markedAt: DateTime.parse(data['markedAt']),
      markedBy: data['markedBy'],
      location: data['location'],
      deviceInfo: data['deviceInfo'],
      remarks: data['remarks'],
      modifiedAt: data['modifiedAt'] != null ? DateTime.parse(data['modifiedAt']) : null,
      modifiedBy: data['modifiedBy'],
    );
  }

  /// Convert to Map for compatibility
  Map<String, dynamic> toMap() => toFirestore();

  /// Create from Map
  factory AttendanceRecord.fromMap(Map<String, dynamic> data) => AttendanceRecord.fromFirestore(data);

  /// Copy with method for easy updates
  AttendanceRecord copyWith({
    String? id,
    String? sessionId,
    String? studentId,
    String? studentName,
    String? studentUsn,
    String? courseId,
    String? courseName,
    String? courseCode,
    String? facultyId,
    String? facultyName,
    AttendanceStatus? status,
    DateTime? markedAt,
    String? markedBy,
    Map<String, dynamic>? location,
    Map<String, dynamic>? deviceInfo,
    String? remarks,
    DateTime? modifiedAt,
    String? modifiedBy,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      studentUsn: studentUsn ?? this.studentUsn,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      courseCode: courseCode ?? this.courseCode,
      facultyId: facultyId ?? this.facultyId,
      facultyName: facultyName ?? this.facultyName,
      status: status ?? this.status,
      markedAt: markedAt ?? this.markedAt,
      markedBy: markedBy ?? this.markedBy,
      location: location ?? this.location,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      remarks: remarks ?? this.remarks,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      modifiedBy: modifiedBy ?? this.modifiedBy,
    );
  }
}

/// Attendance Status Enum
enum AttendanceStatus {
  present,
  absent,
  late,
  onDuty,
  leave,
}

/// Extension for AttendanceStatus
extension AttendanceStatusExtension on AttendanceStatus {
  String get displayName {
    switch (this) {
      case AttendanceStatus.present:
        return 'Present';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.late:
        return 'Late';
      case AttendanceStatus.onDuty:
        return 'On Duty';
      case AttendanceStatus.leave:
        return 'Leave';
    }
  }

  String get shortName {
    switch (this) {
      case AttendanceStatus.present:
        return 'P';
      case AttendanceStatus.absent:
        return 'A';
      case AttendanceStatus.late:
        return 'L';
      case AttendanceStatus.onDuty:
        return 'OD';
      case AttendanceStatus.leave:
        return 'LV';
    }
  }
}
