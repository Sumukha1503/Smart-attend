class AttendanceRecordModel {
  final String id;
  final String studentId;
  final String studentName;
  final String studentUsn;
  final String subjectId;
  final String subjectName;
  final DateTime date;
  final bool isPresent;
  final String? remarks;

  AttendanceRecordModel({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.studentUsn,
    required this.subjectId,
    required this.subjectName,
    required this.date,
    required this.isPresent,
    this.remarks,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'studentName': studentName,
      'studentUsn': studentUsn,
      'subjectId': subjectId,
      'subjectName': subjectName,
      'date': date.toIso8601String(),
      'isPresent': isPresent,
      'remarks': remarks,
    };
  }

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    return AttendanceRecordModel(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      studentName: json['studentName'] as String,
      studentUsn: json['studentUsn'] as String,
      subjectId: json['subjectId'] as String,
      subjectName: json['subjectName'] as String,
      date: DateTime.parse(json['date'] as String),
      isPresent: json['isPresent'] as bool,
      remarks: json['remarks'] as String?,
    );
  }
}
