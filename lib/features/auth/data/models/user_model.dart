class UserModel {
  final String id;
  final String name;
  final String email;
  final String role; // Student, Faculty, HOD, Admin
  final String? usn; // University Serial Number (for students only)
  final String? employeeId; // For Faculty and HOD
  final String? phone;
  final String? profilePicture;
  final String? department;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.usn,
    this.employeeId,
    this.phone,
    this.profilePicture,
    this.department,
    required this.createdAt,
  });

  // Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'usn': usn,
      'employeeId': employeeId,
      'phone': phone,
      'profilePicture': profilePicture,
      'department': department,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      usn: json['usn'] as String?,
      employeeId: json['employeeId'] as String?,
      phone: json['phone'] as String?,
      profilePicture: json['profilePicture'] as String?,
      department: json['department'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  // Create a copy with modified fields
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? usn,
    String? employeeId,
    String? phone,
    String? profilePicture,
    String? department,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      usn: usn ?? this.usn,
      employeeId: employeeId ?? this.employeeId,
      phone: phone ?? this.phone,
      profilePicture: profilePicture ?? this.profilePicture,
      department: department ?? this.department,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
