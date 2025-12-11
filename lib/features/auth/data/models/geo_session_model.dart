/// Session Model for Firebase Firestore
/// 
/// Represents an attendance session with geolocation data
class SessionModel {
  final String id;
  final String courseId;
  final String courseName;
  final String courseCode;
  final String facultyId;
  final String facultyName;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isActive;
  final double latitude;
  final double longitude;
  final double radius;

  SessionModel({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.courseCode,
    required this.facultyId,
    required this.facultyName,
    required this.createdAt,
    required this.expiresAt,
    required this.isActive,
    required this.latitude,
    required this.longitude,
    required this.radius,
  });

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'courseId': courseId,
      'courseName': courseName,
      'courseCode': courseCode,
      'facultyId': facultyId,
      'facultyName': facultyName,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'isActive': isActive,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
    };
  }

  /// Create from Firestore document
  factory SessionModel.fromFirestore(Map<String, dynamic> data) {
    return SessionModel(
      id: data['id'] ?? '',
      courseId: data['courseId'] ?? '',
      courseName: data['courseName'] ?? '',
      courseCode: data['courseCode'] ?? '',
      facultyId: data['facultyId'] ?? '',
      facultyName: data['facultyName'] ?? '',
      createdAt: DateTime.parse(data['createdAt']),
      expiresAt: DateTime.parse(data['expiresAt']),
      isActive: data['isActive'] ?? false,
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      radius: (data['radius'] ?? 50.0).toDouble(),
    );
  }

  /// Convert to Map for compatibility with existing code
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseId': courseId,
      'courseName': courseName,
      'courseCode': courseCode,
      'facultyId': facultyId,
      'facultyName': facultyName,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'isActive': isActive,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
    };
  }

  /// Create from Map (for backward compatibility)
  factory SessionModel.fromMap(Map<String, dynamic> data) {
    return SessionModel(
      id: data['id'] ?? '',
      courseId: data['courseId'] ?? '',
      courseName: data['courseName'] ?? '',
      courseCode: data['courseCode'] ?? '',
      facultyId: data['facultyId'] ?? '',
      facultyName: data['facultyName'] ?? '',
      createdAt: DateTime.parse(data['createdAt']),
      expiresAt: data['expiresAt'] != null 
          ? DateTime.parse(data['expiresAt'])
          : DateTime.now().add(const Duration(minutes: 2)),
      isActive: data['isActive'] ?? true,
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      radius: (data['radius'] ?? 50.0).toDouble(),
    );
  }

  /// Check if session is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Get remaining time in seconds
  int get remainingSeconds {
    final diff = expiresAt.difference(DateTime.now());
    return diff.inSeconds > 0 ? diff.inSeconds : 0;
  }

  /// Get remaining time formatted as MM:SS
  String get remainingTimeFormatted {
    final seconds = remainingSeconds;
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
