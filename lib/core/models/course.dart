/// Course Model
/// Represents a course/subject with faculty and student details
class Course {
  final String id;
  final String code;
  final String name;
  final int semester;
  final String section;
  final String department;
  final String facultyId;
  final String facultyName;
  final List<String> studentIds;
  final int totalClasses;
  final int conductedClasses;
  final Map<String, dynamic>? schedule; // Weekly schedule
  final DateTime createdAt;
  final DateTime? updatedAt;

  Course({
    required this.id,
    required this.code,
    required this.name,
    required this.semester,
    required this.section,
    required this.department,
    required this.facultyId,
    required this.facultyName,
    this.studentIds = const [],
    this.totalClasses = 0,
    this.conductedClasses = 0,
    this.schedule,
    required this.createdAt,
    this.updatedAt,
  });

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'semester': semester,
      'section': section,
      'department': department,
      'facultyId': facultyId,
      'facultyName': facultyName,
      'studentIds': studentIds,
      'totalClasses': totalClasses,
      'conductedClasses': conductedClasses,
      'schedule': schedule,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Create from Firestore document
  factory Course.fromFirestore(Map<String, dynamic> data) {
    return Course(
      id: data['id'] ?? '',
      code: data['code'] ?? '',
      name: data['name'] ?? '',
      semester: data['semester'] ?? 1,
      section: data['section'] ?? 'A',
      department: data['department'] ?? '',
      facultyId: data['facultyId'] ?? '',
      facultyName: data['facultyName'] ?? '',
      studentIds: List<String>.from(data['studentIds'] ?? []),
      totalClasses: data['totalClasses'] ?? 0,
      conductedClasses: data['conductedClasses'] ?? 0,
      schedule: data['schedule'],
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: data['updatedAt'] != null ? DateTime.parse(data['updatedAt']) : null,
    );
  }

  /// Convert to Map
  Map<String, dynamic> toMap() => toFirestore();

  /// Create from Map
  factory Course.fromMap(Map<String, dynamic> data) => Course.fromFirestore(data);

  /// Get completion percentage
  double get completionPercentage {
    if (totalClasses == 0) return 0.0;
    return (conductedClasses / totalClasses) * 100;
  }

  /// Get remaining classes
  int get remainingClasses {
    return totalClasses - conductedClasses;
  }

  /// Get student count
  int get studentCount => studentIds.length;

  /// Copy with method
  Course copyWith({
    String? id,
    String? code,
    String? name,
    int? semester,
    String? section,
    String? department,
    String? facultyId,
    String? facultyName,
    List<String>? studentIds,
    int? totalClasses,
    int? conductedClasses,
    Map<String, dynamic>? schedule,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Course(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      semester: semester ?? this.semester,
      section: section ?? this.section,
      department: department ?? this.department,
      facultyId: facultyId ?? this.facultyId,
      facultyName: facultyName ?? this.facultyName,
      studentIds: studentIds ?? this.studentIds,
      totalClasses: totalClasses ?? this.totalClasses,
      conductedClasses: conductedClasses ?? this.conductedClasses,
      schedule: schedule ?? this.schedule,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get display name (code - name)
  String get displayName => '$code - $name';
}
